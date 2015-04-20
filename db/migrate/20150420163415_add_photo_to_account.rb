class AddPhotoToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :photo, :string
  end
end
