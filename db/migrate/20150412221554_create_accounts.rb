class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.integer :is_spammer, default: 0
      t.string :name

      t.timestamps null: false
    end

    add_index :accounts, :id, unique: true

    create_table :account_links, id: false do |t|
    	t.integer :self
    	t.integer :other
    end
    add_index :account_links, :self
    add_index :account_links, :other
  end
end
