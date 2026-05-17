class RemoveEventDateFromNotifications < ActiveRecord::Migration[8.1]
  def change
    remove_column :notifications, :event_date, :string
  end
end
