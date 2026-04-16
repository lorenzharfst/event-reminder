class CreateReminders < ActiveRecord::Migration[8.1]
  def change
    create_table :reminders do |t|
      t.references :fan, null: false, foreign_key: true
      t.references :performer, null: false, foreign_key: true

      t.timestamps
    end
  end
end
