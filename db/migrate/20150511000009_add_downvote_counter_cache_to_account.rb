class AddDownvoteCounterCacheToAccount < ActiveRecord::Migration
  def change
  	add_column :accounts, :downvote_counter, :integer
  end
end
