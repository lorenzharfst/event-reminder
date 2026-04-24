class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.string :location
      t.references :performer, null: false, foreign_key: true
      t.date :event_date

      t.timestamps
    end
  end
end
