class FanMailer < ApplicationMailer
  def proximity_alert(fan, performer, event, distance_km)
    @performer_name = performer.name
    @location       = event.location
    @venue          = event.venue
    @event_date     = event.event_date
    @distance_km    = distance_km
    mail(
      to:      fan.user.email,
      subject: I18n.t("mailer.proximity_alert.subject", performer: performer.name)
    )
  end
end
