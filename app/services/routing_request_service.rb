# app/services/routing_request_service.rb
#
# This is what is called when you want to queue a request to check the distance between two points.
#
# Creates a pending RoutingRequest record and enqueues the OSRM job.
# Can be called from a controller, another service, a Rake task, a console
# session, or anywhere else in the app.
#
# Usage:
#   result = RoutingRequestService.call("Girona", "Barcelona")
#   result.id       # => 42         (use this to poll for the result)
#   result.status   # => "pending"
#
# Retrieve the result later:
#   rr = RoutingRequest.find(42)
#   rr.status           # => "completed" / "failed" / "pending"
#   rr.distance_km      # => 99.1
#   rr.duration_minutes # => 65.4
#   rr.error_message    # => nil (or a string if status == "failed")

class RoutingRequestService
  class InvalidInputError < StandardError; end

  # @param origin      [String]  e.g. "Girona"
  # @param destination [String]  e.g. "Barcelona"
  # @return [RoutingRequest]  the newly created, still-pending record
  # @raise  [InvalidInputError] if either argument is blank
  def self.call(origin, destination, fan_distance, fan_id, performer_id)
    new(origin, destination, fan_distance, fan_id, performer_id).call
  end

  def initialize(origin, destination, fan_distance, fan_id, performer_id)
    @origin        = origin.to_s.strip
    @destination   = destination.to_s.strip
    @fan_distance  = fan_distance
    @fan_id        = fan_id
    @performer_id  = performer_id
  end

  def call
    validate!

    OsrmRoutingWorker.perform_async(
      @origin,
      @destination,
      @fan_distance,
      @fan_id,
      @performer_id
    )
  end

  private

  def validate!
    raise InvalidInputError, "Origin can't be blank"      if @origin.blank?
    raise InvalidInputError, "Destination can't be blank" if @destination.blank?
  end
end
