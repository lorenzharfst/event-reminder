class CreateNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :notifications do |t|
      t.references :performer, null: false, foreign_key: true
      t.references :fan, null: false, foreign_key: true
      t.date :event_date

      t.timestamps
    end
  end
end
