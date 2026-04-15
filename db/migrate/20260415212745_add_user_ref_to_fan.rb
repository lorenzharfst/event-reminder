class AddUserRefToFan < ActiveRecord::Migration[8.1]
  def change
    add_reference :fans, :user, null: false, foreign_key: true
  end
end
