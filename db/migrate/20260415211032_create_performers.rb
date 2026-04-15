class CreatePerformers < ActiveRecord::Migration[8.1]
  def change
    create_table :performers do |t|
      t.timestamps
    end
  end
end
