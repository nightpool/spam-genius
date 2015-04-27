class DownvoteRenameWithId < ActiveRecord::Migration
  def change
  	rename_column :downvotes, :by_user, :by_user_id
  	rename_column :downvotes, :of_user, :of_user_id
  end
end
