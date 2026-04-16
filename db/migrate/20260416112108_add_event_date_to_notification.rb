class AddEventDateToNotification < ActiveRecord::Migration[8.1]
  def change
    add_column :notifications, :event_date, :date
  end
end
