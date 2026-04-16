class Reminder < ApplicationRecord
  belongs_to :fan
  belongs_to :performer
end
