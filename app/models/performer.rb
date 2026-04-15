class Performer < ApplicationRecord
  has_many :fans, through: :notifications
  belongs_to :user
end
