class Fan < ApplicationRecord
  has_many :performers, through: :notifications
  belongs_to :user
end
