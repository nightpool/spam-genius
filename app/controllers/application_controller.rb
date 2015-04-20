class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

    http_basic_authenticate_with name: "spamgenius", password: ENV["http_pass"]

    protect_from_forgery with: :exception

    def index
        @account = Account.order(:created).first
        render "accounts/show" 
    end
end
