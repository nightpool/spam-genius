class Account < ActiveRecord::Base
	has_and_belongs_to_many :siblings, 
		class_name: "Account", join_table: "account_links",
		foreign_key: "self", association_foreign_key: "other"

	enum is_spammer: [:no, :maybe, :yes]
end
