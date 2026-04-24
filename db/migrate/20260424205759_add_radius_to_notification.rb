class AddRadiusToNotification < ActiveRecord::Migration[8.1]
  def change
    add_column :notifications, :radius, :integer
  end
end
