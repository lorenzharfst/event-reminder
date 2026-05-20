class AddFanIdToEventNotifications < ActiveRecord::Migration[8.1]
  def change
    EventNotification.delete_all
    add_reference :event_notifications, :fan, null: false, foreign_key: true
  end
end
