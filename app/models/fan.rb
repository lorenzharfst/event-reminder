class Fan < ApplicationRecord
  has_many :notifications
  has_many :performers, through: :notifications
  belongs_to :user
end
