class CreateRoutingRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :routing_requests do |t|
      t.string :origin
      t.string :destination
      t.string :status
      t.decimal :distance_km
      t.decimal :duration_minutes
      t.text :error_message

      t.timestamps
    end
  end
end
