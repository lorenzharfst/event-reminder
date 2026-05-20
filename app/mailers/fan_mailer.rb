class FanMailer < ApplicationMailer
  def proximity_alert(fan, performer, distance_km)
    @performer_name = performer.name
    @distance_km    = distance_km
    mail(
      to:      fan.user.email,
      subject: "#{performer.name} is performing near you!"
    )
  end
end
