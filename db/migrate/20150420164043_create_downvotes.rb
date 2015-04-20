class CreateDownvotes < ActiveRecord::Migration
  def change
    create_table :downvotes do |t|
    	t.integer 'by_user'
    	t.integer 'of_user'
    	t.integer 'thread'
        t.timestamps null: false
    end
  end
end
