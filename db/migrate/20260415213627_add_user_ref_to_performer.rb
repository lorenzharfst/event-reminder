class AddUserRefToPerformer < ActiveRecord::Migration[8.1]
  def change
    add_reference :performers, :user, null: false, foreign_key: true
  end
end
