class CreateNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :notifications do |t|
      t.date :event_date

      t.timestamps
    end
  end
end
