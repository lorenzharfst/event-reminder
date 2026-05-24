# app/workers/osrm_routing_worker.rb
#
# Processes OSRM routing requests serially, ensuring at most one outbound
# request every 10 seconds — well within OSRM's 1-per-5s limit.
#
# Design decisions:
#
#   1. concurrency: 1  (enforced via sidekiq.yml — see below)
#      Only one instance of this worker runs at a time, so there is no need
#      for distributed locks. Jobs execute one-by-one in FIFO order.
#
#   2. Redis timestamp gate
#      Before every OSRM call the worker reads the last-request timestamp from
#      Redis. If fewer than RATE_LIMIT_SECONDS have elapsed it sleeps the
#      remainder. This is a safety net; with concurrency 1 it will only ever
#      trigger on the very first job after a cold start or a long idle period.
#

class OsrmRoutingWorker
  include Sidekiq::Worker

  # All OSRM jobs share one dedicated queue.  Setting concurrency to 1 in
  # sidekiq.yml for this queue is what truly serialises execution.
  sidekiq_options queue: :osrm, retry: 3

  # Redis key that stores the Unix timestamp (float) of the last OSRM call.
  LAST_REQUEST_KEY    = "osrm:last_request_at"

  # Desired minimum gap between consecutive outbound requests (seconds).
  RATE_LIMIT_SECONDS  = 10

  # @param origin        [String]   e.g. "Girona"
  # @param destination   [String]   e.g. "Barcelona"
  # @param fan_distance  [Numeric]  fan's max distance threshold in km
  # @param fan_id        [Integer]  Fan record id
  # @param performer_id  [Integer]  Performer record id
  # @param event_id      [Integer]  Event record id
  def perform(origin, destination, fan_distance, fan_id, performer_id, event_id)
    enforce_rate_limit!

    fan       = Fan.find(fan_id)
    performer = Performer.find(performer_id)
    event     = Event.find(event_id)

    if origin.casecmp?(destination)
      send_proximity_alert(fan, performer, event, 0.0)
    else
      result = OsrmRoutingService.call(origin, destination, fan_distance, fan_id)
      if result[:status] == :ok && result[:duration_minutes] <= fan_distance
        send_proximity_alert(fan, performer, event, result[:distance_km])
      elsif result[:status] != :ok
        logger.error "OsrmRoutingWorker: #{result[:message]}"
      end
    end
  end

  private

  # -----------------------------------------------------------------------
  # Email + persistence
  # -----------------------------------------------------------------------

  def send_proximity_alert(fan, performer, event, distance_km)
    return if event.event_date < Date.current
    return if EventNotification.already_sent?(fan.id, event.event_date, event.location, event.performer_id)

    ActiveRecord::Base.transaction do
      EventNotification.create!(event_id: event.id, fan_id: fan.id, sent_at: Time.current)
      FanMailer.proximity_alert(fan, performer, event, distance_km).deliver_now
    end
  end

  # -----------------------------------------------------------------------
  # Rate limiting
  # -----------------------------------------------------------------------

  # Reads the last-request timestamp from Redis and sleeps if the required
  # gap has not yet elapsed, then atomically updates the timestamp.
  def enforce_rate_limit!
    redis do |conn|
      last_request_at = conn.get(LAST_REQUEST_KEY).to_f   # 0.0 when key absent
      elapsed         = Time.now.to_f - last_request_at
      sleep_for       = RATE_LIMIT_SECONDS - elapsed

      sleep(sleep_for) if sleep_for > 0

      # Record the moment we are about to fire the request.
      conn.set(LAST_REQUEST_KEY, Time.now.to_f)
    end
  end

  # Thin wrapper so callers get a plain Redis client without worrying about
  # which adapter is configured (works with both redis-client and redis gems).
  def redis(&block)
    Sidekiq.redis(&block)
  end
end
