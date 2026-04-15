class Notification < ApplicationRecord
  belongs_to :performer
  belongs_to :fan
end
