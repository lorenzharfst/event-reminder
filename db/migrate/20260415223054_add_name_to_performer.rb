class AddNameToPerformer < ActiveRecord::Migration[8.1]
  def change
    add_column :performers, :name, :string
  end
end
