class AddSocialsFlagToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :from_social, :boolean
  end
end
