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
#   3. Result persistence
#      Results (and errors) are written to a `routing_requests` table so the
#      calling code can retrieve them asynchronously via polling or ActionCable.
#      Adjust #persist_result / #persist_error to match your own model.

class OsrmRoutingWorker
  include Sidekiq::Worker

  # All OSRM jobs share one dedicated queue.  Setting concurrency to 1 in
  # sidekiq.yml for this queue is what truly serialises execution.
  sidekiq_options queue: :osrm, retry: 3

  # Redis key that stores the Unix timestamp (float) of the last OSRM call.
  LAST_REQUEST_KEY    = "osrm:last_request_at"

  # Desired minimum gap between consecutive outbound requests (seconds).
  RATE_LIMIT_SECONDS  = 10

  # @param routing_request_id [Integer]  ActiveRecord id of the pending record
  # @param origin             [String]   e.g. "Girona"
  # @param destination        [String]   e.g. "Barcelona"
  def perform(origin, destination, fan_distance, fan_id)
    enforce_rate_limit!


    puts "Comparing #{origin.capitalize} with #{destination.capitalize}"
    if origin.casecmp?(destination)
      puts "Fan with id #{fan_id} will get notified for origin, destination: #{origin}, #{destination} as they are the same location"
    else
      result = OsrmRoutingService.call(origin, destination, fan_distance, fan_id)
      if result[:status] == :ok
        puts "Checking fan with id #{fan_id} with origin: #{origin} destination: #{destination}"
        if result[:distance_km] <= fan_distance
          puts "Fan with id #{fan_id} will get notified for origin, destination: #{origin}, #{destination}"
        end
      else
        puts "Error: #{result[:message]}"
      end
    end
  end

  private

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

  # -----------------------------------------------------------------------
  # Result persistence — adapt to your own model / schema
  # -----------------------------------------------------------------------

  # Schema assumed:
  #
  #   create_table :routing_requests do |t|
  #     t.string  :origin,           null: false
  #     t.string  :destination,      null: false
  #     t.string  :status,           null: false, default: "pending"
  #     t.decimal :distance_km,      precision: 10, scale: 1
  #     t.decimal :duration_minutes, precision: 10, scale: 1
  #     t.text    :error_message
  #     t.timestamps
  #   end

  # TODO: Delete once I'm sure it's not needed
  def persist_result(id, result)
    RoutingRequest.find(id).update!(
      status:           "completed",
      distance_km:      result[:distance_km],
      duration_minutes: result[:duration_minutes]
    )
  end

  def persist_error(id, message)
    RoutingRequest.find(id).update!(
      status:        "failed",
      error_message: message
    )
  end
end
