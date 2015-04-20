class Downvote < ActiveRecord::Base
	belongs_to :by_user, class_name: "Account"
	belongs_to :of_user, class_name: "Account"
end
