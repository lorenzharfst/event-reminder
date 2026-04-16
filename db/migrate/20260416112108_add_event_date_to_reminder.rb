class AddEventDateToReminder < ActiveRecord::Migration[8.1]
  def change
    add_column :reminders, :event_date, :date
  end
end
