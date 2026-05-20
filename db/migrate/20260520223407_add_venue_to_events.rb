class AddVenueToEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :events, :venue, :string
  end
end
