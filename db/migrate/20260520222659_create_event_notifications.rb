class CreateEventNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :event_notifications do |t|
      t.references :event, null: false, foreign_key: true
      t.datetime :sent_at, null: false

      t.timestamps
    end
    add_index :event_notifications, :sent_at
  end
end
