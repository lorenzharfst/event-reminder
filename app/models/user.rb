class User < ApplicationRecord
  has_secure_password
  has_one :fan, dependent: :destroy
  has_one :performer, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
