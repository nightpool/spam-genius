
require 'mechanize'
require 'rest-client'
require 'json'

module Genius
    
    class HTMLGenius
        def initialize(server)
            @agent = Mechanize.new
            @server = server
        end
        attr_reader :server, :agent
        
        def url(url)
            url.sub!(/^\//,'')
            server + "/" + url
        end

        def get(route)
            if block_given?
                @agent.get (url route) {|page| yield page}
            else
                @agent.get (url route)
            end
        end

        def login(username, password)
            # p "attempt login"
            get 'signup_or_login' do |page|
                form = page.form( action: '/user_session')
                form.set_fields ({  
                    'user_session[login]' => username,
                    'user_session[password]' => password })
                f = form.submit
            end
        end

        def firehose
            get 'firehose' do |f|
                return f.root.to_s[/PUSHER_APP_KEY = "([\d\w]+)";/, 1]
            end
        end

        def user_page (login)
            get login
        end

        def user (login)
            User.new login: login, page: (user_page login)
        end

        Prod = HTMLGenius.new 'http://genius.com'
        @@active = nil
        class << self
          attr_accessor :active
        end
    end
    
    class APIGenius
        def initialize(server)
            @server = server
            @client = RestClient::Resource.new server
        end

        attr_reader :client, :server

        def get(url)
            JSON[@client[url].get]['response']
        end

        def user_page(id)
            get("/users/#{id}")['user']
        end

        def user(id)
            User.new(id: id, api_page: (user_page id))
        end
        Prod = APIGenius.new 'http://api.genius.com'
        @@active = nil
        class << self
          attr_accessor :active
        end
    end

    class User

        def initialize(id: nil, login: nil, page: nil, api_page: nil)
            @id = id
            @login = login
            @page = page
            @api_page = api_page
            unless [id, login, page, api_page].compact
                raise ArgumentError.new("Must pass at least one of id, login, page or api_page")
            end
        end

        # Requires page or api_page
        def id
            return @id unless @id.nil?
            return @id = api_page['id'] unless @api_page.nil?
            return @id = page.root.at('.avatar.profile_pic')['class'][/user_avatar_(\d+)/,1] unless @page.nil?

            return @id = api_page['id'] unless api_page.nil?
            return @id = page.root.at('.avatar.profile_pic')['class'][/user_avatar_(\d+)/,1] unless page.nil?
        end

        def login
            return @login unless @login.nil?
            return @login = api_page['login'] unless @api_page.nil?
            return @login = page.root.at('h1').text unless @page.nil?

            return @login = api_page['login'] unless api_page.nil?
            return @login = page.root.at('h1').text unless page.nil?
        end

        def page
            return @page unless @page.nil?
            return @page = (HTMLGenius.active.user_page login) if HTMLGenius.active
        end

        def api_page
            return @api_page unless @api_page.nil?
            return @api_page = (APIGenius.active.user_page @id) if APIGenius.active and not @id.nil?
        end

        def get_page(genius=nil)
            unless genius
                genius = Genius::HTMLGenius.active 
            end
            if genius
                @page = genius.user_page login
            else
                raise ArgumentError.new("If there is no active genius instance, you must pass one")
            end
        end
        def get_api_page(api=nil)
            unless api
                api = Genius::APIGenius.active 
            end
            if api
                @api_page = api.user_page id
            else
                raise ArgumentError.new("If there is no active genius instance, you must pass one")
            end
        end

        def mark_as_spam(confirm)
            if confirm
                page.form(action: /mark_spam/).submit
                true
            end
            false
        end

        def ids_with_same_ip
            unless page.link href: /other_users_with_ip/
                raise NotAuthorizedError.new "Not authorized to view IPs!"
            end
            ip_page = page.link({href: /other_users_with_ip/}).click
            ip_page.root.css("#main .user_badge").map do |i|
                # binding.pry
                User.new(id: i['data-badge-user-id'], login: i.at('.badge_avatar_wrapper')['href'][1..-1])
            end
        end

        def box_form
            form = page.form action: /toggle_penalty_status/
            unless form
                raise NotAuthorizedError.new "Not authorized to view penalty boxes!"
            end
            form
        end
        
        def is_boxed
            box_form['new_penalty_status'] == "true"
        end

        def box
            unless is_boxed
                 box_form.submit
            end
        end

        def unbox
            if is_boxed
                 box_form.submit
            end
        end

    end

    class NotAuthorizedError < StandardError
    end
end