class Downvote < ActiveRecord::Base
	belongs_to :by_user, class_name: "Account", counter_cache: true
	belongs_to :of_user, class_name: "Account"
end
