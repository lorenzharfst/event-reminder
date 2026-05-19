# app/services/osrm_routing_service.rb
#
# Calculates driving distance and duration between two place name strings.
#
# Flow:
#   1. Geocode each place name to lat/lng via Nominatim (OpenStreetMap)
#   2. Send both coordinates to the public OSRM API
#   3. Parse and return distance (km) + duration (minutes)
#
# Usage:
#   result = OsrmRoutingService.call("Barcelona", "Madrid")
#   result[:distance_km]     # => 621.4
#   result[:duration_minutes] # => 362.1
#   result[:status]           # => :ok
#
# On error:
#   result[:status]  # => :error
#   result[:message] # => "Could not geocode origin: 'Atlantis'"

require "net/http"
require "json"

class OsrmRoutingService
  # Public OSRM demo server — fine for development and low-traffic use.
  # For production, host your own: https://github.com/Project-OSRM/osrm-backend
  OSRM_BASE_URL   = "https://router.project-osrm.org"

  # Nominatim — free OSM geocoder. Must include a descriptive User-Agent per
  # their usage policy: https://operations.osmfoundation.org/policies/nominatim/
  NOMINATIM_URL   = "https://nominatim.openstreetmap.org"
  USER_AGENT      = "MyRailsApp/1.0 (contact@myapp.example.com)"

  # Raise a specific error so callers can rescue it cleanly if preferred.
  class RoutingError < StandardError; end

  # ---------------------------------------------------------------------------
  # Entry point
  # ---------------------------------------------------------------------------

  # @param origin      [String] e.g. "Barcelona"
  # @param destination [String] e.g. "Madrid"
  # @return [Hash] with keys :status, :distance_km, :duration_minutes (or :message on error)
  def self.call(origin, destination, fan_distance, fan)
    new(origin, destination, fan_distance, fan).call
  end

  def initialize(origin, destination, fan_distance, fan)
    @origin      = origin
    @destination = destination
    @fan_distance = fan_distance
    @fan = fan
  end

  def call
    origin_coords      = geocode!(@origin,      label: "origin")
    destination_coords = geocode!(@destination, label: "destination")

    route(origin_coords, destination_coords)
  rescue RoutingError => e
    { status: :error, message: e.message }
  end

  # ---------------------------------------------------------------------------
  # Private
  # ---------------------------------------------------------------------------

  private

  # Geocodes a place name to { lat:, lng: } using Nominatim.
  #
  # Nominatim returns an array of candidates; we take the first (most relevant)
  # result. The `limit=1` param avoids fetching results we won't use.
  def geocode!(place, label:)
    uri = URI("#{NOMINATIM_URL}/search")
    uri.query = URI.encode_www_form(
      q:              place,
      format:         "json",
      limit:          1,
      addressdetails: 0
    )

    response = get(uri)
    results  = JSON.parse(response.body)

    if results.empty?
      raise RoutingError, "Could not geocode #{label}: '#{place}'"
    end

    best = results.first
    { lat: best["lat"].to_f, lng: best["lon"].to_f }
  end

  # Calls the OSRM /route/v1/driving endpoint.
  #
  # Coordinate order in the URL is lng,lat (longitude first) — this is the
  # GeoJSON convention that OSRM follows, not lat/lng.
  #
  # We request `overview=false` because we only need the summary (distance +
  # duration), not the full polyline geometry.
  def route(origin, destination)
    coords = "#{origin[:lng]},#{origin[:lat]};#{destination[:lng]},#{destination[:lat]}"
    uri    = URI("#{OSRM_BASE_URL}/route/v1/driving/#{coords}")
    uri.query = URI.encode_www_form(
      overview:   "false",
      annotations: "false"
    )

    response = get(uri)
    data     = JSON.parse(response.body)

    unless data["code"] == "Ok"
      raise RoutingError, "OSRM error: #{data['code']} — #{data['message']}"
    end

    leg = data.dig("routes", 0, "legs", 0)
    raise RoutingError, "OSRM returned no route legs" unless leg

    {
      status:           :ok,
      distance_km:      (leg["distance"] / 1000.0).round(1),  # OSRM returns metres
      duration_minutes: (leg["duration"] / 60.0).round(1)     # OSRM returns seconds
    }
  end

  # Shared HTTP GET with a sensible timeout and the required User-Agent header.
  def get(uri)
    http           = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl   = uri.scheme == "https"
    http.open_timeout = 5   # seconds to establish connection
    http.read_timeout = 10  # seconds to wait for response

    request = Net::HTTP::Get.new(uri)
    request["User-Agent"] = "event-reminder/lorenzharfst@gmail.com"
    request["Accept"]     = "application/json"

    response = http.request(request)

    unless response.is_a?(Net::HTTPSuccess)
      raise RoutingError, "HTTP #{response.code} from #{uri.host}"
    end

    response
  end
end

