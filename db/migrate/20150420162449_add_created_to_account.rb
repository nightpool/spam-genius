class AddCreatedToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :created, :timestamp
  end
end
