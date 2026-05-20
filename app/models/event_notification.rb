class EventNotification < ApplicationRecord
  belongs_to :event

  validates :sent_at, presence: true
end
