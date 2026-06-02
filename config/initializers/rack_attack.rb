Rack::Attack.cache.store = Rails.cache

# General request throttle per IP
Rack::Attack.throttle("req/ip", limit: 300, period: 5.minutes) do |req|
  req.ip unless req.path.start_with?("/assets", "/up")
end

# Login throttle by IP — blocks brute-force from a single IP
Rack::Attack.throttle("logins/ip", limit: 5, period: 20.seconds) do |req|
  req.ip if req.path == "/users/sign_in" && req.post?
end

# Login throttle by email — blocks distributed attacks on a single account
Rack::Attack.throttle("logins/email", limit: 20, period: 20.seconds) do |req|
  if req.path == "/users/sign_in" && req.post?
    req.params.dig("user", "email").to_s.downcase.presence
  end
end

# Sign-up throttle by IP
Rack::Attack.throttle("signups/ip", limit: 10, period: 1.hour) do |req|
  req.ip if req.path == "/users" && req.post?
end

# Password reset throttle by IP
Rack::Attack.throttle("password-reset/ip", limit: 5, period: 1.hour) do |req|
  req.ip if req.path == "/users/password" && req.post?
end

# Return 429 with Retry-After header instead of the default 403
Rack::Attack.throttled_responder = lambda do |req|
  match_data = req.env["rack.attack.match_data"]
  now = match_data[:epoch_time]
  retry_after = match_data[:period] - (now % match_data[:period])

  [
    429,
    { "Content-Type" => "text/plain", "Retry-After" => retry_after.to_s },
    [ "Too many requests. Please try again later.\n" ]
  ]
end
