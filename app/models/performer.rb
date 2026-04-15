class Performer < User
  has_many :users, through: :notifications
end
