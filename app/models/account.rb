class Account < ActiveRecord::Base
	has_and_belongs_to_many :siblings, 
		class_name: "Account", join_table: "account_links",
		foreign_key: "self", association_foreign_key: "other"

	has_many :downvotes, foreign_key: "by_user_id"

	enum is_spammer: [:no, :maybe, :yes]

	scope :created_on, ->(day) { where("created < ? AND created > ?",
	  day.tomorrow.beginning_of_day, day.beginning_of_day)}

	def update_links
		user = Genius::User.new(id: id)
		other_accounts = user.ids_with_same_ip
		all_ids = [id]+other_accounts.map{|i| i.id}
		p all_ids
		other_accounts.each do |other_acct|
			other = Account.find_or_initialize_by id: other_acct.id
			other.name = other_acct.login
			other.is_spammer = self.is_spammer unless other.created_at
			other.save
			siblings << other
		end
		other_accounts.each do |other_acct|
			other = Account.find(other_acct.id)
			other.sibling_ids = all_ids - [other_acct.id]
			other.save
		end
	end
end
