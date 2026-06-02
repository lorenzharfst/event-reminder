class Event < ApplicationRecord
  belongs_to :performer
  has_many :event_notifications, dependent: :destroy
end
