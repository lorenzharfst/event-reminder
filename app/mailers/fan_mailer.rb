class FanMailer < ApplicationMailer
  def proximity_alert(fan, performer, event, distance_km)
    @performer_name = performer.name
    @location       = event.location
    @venue          = event.venue
    @distance_km    = distance_km
    mail(
      to:      fan.user.email,
      subject: "#{performer.name} is performing near you!"
    )
  end
end
