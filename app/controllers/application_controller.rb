# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require 'rubygems'
require 'uuidtools'
require 'hoptoad_notifier'


class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  before_filter :load_config
  before_filter :update_session_expiration_date
  before_filter :attach_current_feed
  before_filter :check_admin
  before_filter :get_right_column_data
  before_filter :check_update_profile
  before_filter :check_api_calls

  #rescue_from TwitterAuth::Dispatcher::Error, :with => :system_wait
  rescue_from Errno::ECONNRESET, :with => :system_wait
  rescue_from TwitterAuth::Dispatcher::Unauthorized, :with => :force_logout

  def load_config
    @@private_keys =  YAML.load_file("#{RAILS_ROOT}/config/private_keys.yml")[RAILS_ENV]
  end

  def attach_current_feed
    if request.subdomain.present?
      @show_ads = false
      begin
        @current_feed = Feed.find_by_subdomain( request.subdomain )
      rescue
        if @current_feed.nil?
          flash[:message] = "Feed Not Found"
          redirect_to url_for(:controller => "home",
          :action => "index",
          :subdomain => false)
        end
      end
    end
  end

  def get_right_column_data
    @top_feeds = Feed.all()
  end

  def check_update_profile
    if current_user and @current_feed
      if current_user[:updated_at] < 1.day.ago
        update_feed( current_user )
      end

      if @current_feed.user[:updated_at] < 1.day.ago
        update_feed( @current_feed.user )
      end

      if current_user.shown_popup == 0
        current_user.shown_popup = 1
        current_user.save
        signup_notification
      end
    end
  end
  
  def check_admin
    @check_admin = admin_user?
  end

  def check_api_calls
    @remaining_api = 0
    if current_user
      if session[:stale_api_calls] == nil or session[:stale_api_calls] == true
        rate_limits = current_user.twitter.get("/account/rate_limit_status")
        left = rate_limits['remaining_hits']
        total = rate_limits['hourly_limit']
        @remaining_api = left.to_s + "/" + total.to_s
        session[:stale_api_calls] = false
        session[:remaining_api_calls] = @remaining_api
      else
        @remaining_api = session[:remaining_api_calls]
      end
    end
  end

  def admin_user?
    if current_user and  ['profquotes', 'imackinn', 'sustainabletips', 'antitruths', 'laughlitmus'].include?( current_user.login )
      return true
    else
      return false
    end
  end

  def update_session_expiration_date
    unless session[:sessionid]
      session[:sessionid] = UUIDTools::UUID.random_create().to_s()
      session[:votes]= 0
    end
  end

  def force_logout
    flash[:notice] = "Your Twitter authentication token was no longer valid, please sign in again"
    redirect_to logout_path 
  end

  def system_down
    logger.error("ERROR - Twitter is unreachable")
    ex = TwitterDownException.new(self)
    notify_hoptoad(ex)
    render :template => 'errors/system_down',:layout => false
  end

  def system_wait
    logger.error("Warning - Twitter wait")
    @next = request.env["PATH_INFO"]
    render :template => 'errors/system_wait',:layout => false
  end

  def assert_login
    if !current_user:
        #been through signup page, try to authenticate
        login_required
    end
  end

  class TwitterDownException < RuntimeError
    attr :environment
    def initialize(environment )
      @environment = environment
    end
  end

  def signup_notification
    notifo = Notifo.new( @@private_keys['notifo_user'], @@private_keys['notifo_key'] )
    if @current_feed
      notifo_string ="@#{current_user[:login]} signed up for #{@current_feed.user[:login]}"
    else
      notifo_string ="imack","@#{current_user[:login]} signed up"
    end

    notifo.post("imack", notifo_string, "Feed Ladder Signup", "http://twitter.com/#{current_user[:login]}" )
  end

  def load_common_lists_for_feed( feed )
    @top_tweets = Tweet.find_top_twenty_for_feed( feed )

    if current_user and feed.is_admin( current_user )
      @new_tweets = Tweet.find_all_newest_twenty_for_feed( feed )
    else
      @new_tweets = Tweet.find_newest_twenty_for_feed( feed )
    end
    @tweet_best = Tweet.find_best_for_feed( feed )
  end

  private
  def update_feed( user )
    session[:stale_api_calls] = false
    begin
      twitter_data = current_user.twitter.get("/users/show/#{user[:twitter_id]}")
    rescue
      return
    end

    user.update_twitter_attributes( twitter_data )
    user.save
  end
end
