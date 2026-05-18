class AddLocationToNotification < ActiveRecord::Migration[8.1]
  def change
    add_column :notifications, :location, :string
  end
end
