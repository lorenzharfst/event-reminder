class EventNotification < ApplicationRecord
  belongs_to :event
  belongs_to :fan

  validates :sent_at, presence: true

  def self.already_sent?(fan_id, event_date, location, performer_id)
    joins(:event)
      .where(fan_id: fan_id)
      .where(events: { event_date: event_date, location: location, performer_id: performer_id })
      .exists?
  end
end
