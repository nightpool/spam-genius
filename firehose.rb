
require 'set'
require 'open-uri'
require 'digest'

options = { secure: true }
# PusherClient.logger.level = PusherClient.logger.class::INFO
# Genius::HTMLGenius.active.login 'nightpool', ENV['nightpool_pass']
socket = PusherClient::Socket.new(Genius::HTMLGenius.active.firehose)
socket.subscribe('activity_stream.firehose')

all_strategies = Set[
    "user_upvoted_forum_post",
    "user_edited_the_lyrics_of_song",
    "user_created_annotation",
    "user_edited_annotation",
    "user_downvoted_annotation",
    "user_mentioned_user",
    "user_posted_in_discussion",
    "user_upvoted_annotation",
    "user_upvoted_comment",
    "user_added_a_photo_user",
    "user_added_a_suggestion_to_annotation",
    "user_deleted_annotation",
    "user_created_identity",
    "user_created_song",
    "user_followed_discussion",
    "user_pyonged_song",
    "user_proposed_an_edit_to_annotation",
    "user_downvoted_comment",
    "user_downvoted_forum_post",
    "user_replied_to_annotation",
    "user_followed_user",
    "user_marked_as_spam_user",
    "user_followed_song",
    "user_followed_group",
    "user_followed_artist",
    "user_rejected_comment",
    "user_added_a_suggestion_to_song",
    "user_accepted_comment",
    "user_accepted_annotation",
    "user_rejected_annotation",
    "user_merged_annotation_edit",
    "user_pyonged_annotation",
    "user_incorporated_annotation",
    "user_made_an_editor_out_of_user",
    "user_made_an_educator_out_of_user",
    "user_made_a_moderator_out_of_user",
    "user_made_a_mediator_out_of_user"
]

log_strat = Set["user_added_a_photo_user","user_downvoted_forum_post"]

socket['activity_stream.firehose'].bind('new_activity') do |data|
    activity = Nokogiri::Slop data
    s = activity.div['data-strategy-name']
    unless all_strategies.member? s
        all_strategies << s
        p all_strategies
    end
    if log_strat.member? s
        id = activity.at('.avatar')['class'][/avatar_(\d+) /, 1]
        user = activity.at('.avatar')['alt'].split("'")[0]
        more_url = activity.at('[data-get-url]')['data-get-url']
        case s
        when 'user_added_a_photo_user'
            puts "photo by user #{id}"
            photo = open(activity.at('.avatar')['src']).read
            photo_hash = Digest::MD5.hexdigest(photo)
            account = Account.create(id: id, name: user, created: Time.now, 
                           is_spammer: :maybe, photo: photo_hash)
            account.update_links
        when 'user_downvoted_forum_post'
            # binding.pry
            # thread = activity.at('.actor_and_action').em.text
            details = Genius::HTMLGenius.active.get more_url
            of_user, by_user = details.root.css('[data-badge-user-id]').map{|i|i['data-badge-user-id']}
            thread = details.link(href: /discussions/).href.split('/')[-1].split('-')[0]
            puts "downvote by #{user} (#{id}) in thread #{thread}"
            Downvote.create(by_user_id: id, of_user_id: of_user, thread: thread)
        end
        # binding.pry
    end
end

socket.bind('pusher:error') do |data|
    # whee supervisord!
    p data
    abort
 end

socket.connect