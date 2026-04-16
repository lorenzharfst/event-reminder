class Fan < ApplicationRecord
  has_many :reminders
  has_many :performers, through: :reminders
  belongs_to :user
end
