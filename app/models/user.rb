class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_one :fan, dependent: :destroy
  has_one :performer, dependent: :destroy

  normalizes :email, with: ->(e) { e.strip.downcase }
end
