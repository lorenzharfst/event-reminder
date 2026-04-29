class AddDistanceToNotification < ActiveRecord::Migration[8.1]
  def change
    add_column :notifications, :distance, :integer
  end
end
