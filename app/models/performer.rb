class Performer < ApplicationRecord
  has_many :fans, through: :reminders
  belongs_to :user
end
