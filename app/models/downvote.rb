class Downvote < ActiveRecord::Base
	belongs_to :by_user, class_name: "Account", counter_cache: "downvote_counter"
	belongs_to :of_user, class_name: "Account"
end

# Downvote.where("created_at > ? and created_at < ? and by_user_id > ?",
#     Time.zone.today.beginning_of_day, Time.zone.today.tomorrow.beginning_of_day, 
#     Account.created_on(Time.zone.yesterday).order(:created).first.id).
#   group(:by_user_id).count.sort_by{|k,v|-v}