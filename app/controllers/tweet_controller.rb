require 'rubygems'
require 'uuidtools'
require 'feed_tools'
require 'notifo'

class TweetController < ApplicationController
  before_filter :see_need_login,  :only => [:submit, :submit_retweet]
  before_filter :admin_user?, :only => [:disable, :change_status]
  
  require 'BlockTEA'

  def index
    redirect_to :action=>"vote"
  end


  def show
    @tweet = Tweet.find_by_id( params['id'] )

    render :template => 'errors/404',:layout => false, :status=>404 unless !@tweet.nil?

    load_common_lists_for_feed( @current_feed )
  end

  def vote
    if params[:vote]:
        @previous_tweet = process_vote( params[:vote] )
    end

    respond_to do |format|
      format.html { redirect_to "/" }
      format.js
    end
  end

  def submit
    @tweet = Tweet.new
    @tweet.tag = session[:school_name] unless session[:school_name].nil?

    if current_user and @current_feed[:allow_retweets]
      @screen_name = params['screen_name'].strip unless params['screen_name'].nil?
      @tweets = get_recent_tweets( @screen_name, @_params['last_id'] )
      @following = ""
      current_user.twitter.get('/statuses/friends').each{|following| @following.concat( following['screen_name'] + " " )}
      @last_id = @tweets.at(-1)['id'] unless @tweets.at(-1).nil?
      respond_to do |format|
        format.html
        format.js
      end
    else
      respond_to do |format|
        format.html
      end
    end

  end


  def submit_retweet
    if current_user
      raw_tweet = current_user.twitter.get("/statuses/show/#{params['tweet_id']}")
      raw_tweet['twitter_long_id'] = params['tweet_id'] #to match tweet model
      raw_tweet['user_id'] = @current_user.id
      raw_tweet['feed_id'] = @current_feed.id
      
      @tweet = Tweet.find_or_create( raw_tweet, @current_feed )

      if @current_feed.is_admin( current_user )
        @tweet.traffic_light = 2
      else
        @tweet.traffic_light = @current_feed.light_default_status
      end
      @tweet.save
      
      if session[:recent_nominees].nil?
        session[:recent_nominees] = Array.new
      elsif session[:recent_nominees].size > 30
        session[:recent_nominees].delete_at( 0 )
      end

      submit_notification( @tweet, request.remote_ip  )unless current_user and @current_feed.is_admin( current_user )
      add_vote_to_history( @tweet.id, current_user )
      session[:recent_nominees].push( @tweet.twitter_long_id )
    else
      #not signed in
    end

    respond_to do |format|
      format.html { redirect_to @tweet }
      format.js
    end
  end

  def create
    if params['tweet'].nil?
      redirect_to submit_path
      return
    end
    
    if current_user or @current_feed.allow_anonymous_submits
      
      @tweet = Tweet.new( params['tweet'] )
      @tweet.user = current_user unless current_user.nil?
      @tweet.feed = @current_feed
      
      if @current_feed.is_admin( current_user )
        @tweet.traffic_light = 2
      elsif current_user
        @tweet.traffic_light = @current_feed.light_default_status
      else
        #all anonymous submits require admin approval
        @tweet.traffic_light = 1
      end

      @tweet.win
      
      if @tweet.save

        begin
          @tweet.short_url = get_bitly_url( "http://#{@current_feed.user.login}.feedladder.com/t/#{@tweet.id}" ) #needs to be done after save to get id
          @tweet.save
        rescue
          puts "Fail getting bit.ly link:", $!
        end
        session[:school_name] = @tweet.tag
        add_vote_to_history( @tweet.id, current_user )
        submit_notification( @tweet, request.remote_ip  ) unless current_user and @current_feed.is_admin( current_user )

        #flash[:notice] = "Successfully submitted prof quote!"
        @new_tweet = @tweet
        @tweet = Tweet.new
        @tweet.tag = session[:school_name]
        load_common_lists_for_feed( @current_feed )
        
        respond_to do |format|
          format.html { render :action => "feed/show" }
        end
      else
        respond_to do |format|
          format.html {render :action => "submit"}
        end        
      end
    end
  end

  def change_status
    @quote = Tweet.find_by_id( params['quote_id'] )
    
    if !@quote.nil? and current_user and @current_feed.is_admin( current_user )
      new_status = params['quote_status'].to_i
      if new_status == 0:
        @quote[:live_quote] = 0
        @quote[:traffic_light] = 0
      elsif new_status ==1: 
        @quote[:live_quote] = 0 unless @quote[:live_quote] != 0
        @quote[:traffic_light] = 1
      elsif new_status == 2:
        @quote[:live_quote] = 0 unless @quote[:live_quote] != 0
        @quote[:traffic_light] = 2
      end
      @quote.save
    end
    
    respond_to do |format|
      format.html { redirect_to @quote }
      format.js
    end
  end

  def ask_to_tweet
    @quote = Tweet.find_by_quote_id( params['quote_id'] )

    @candidate_tweet = get_status_update_text(@quote, "http://bit.ly/XXXXX")

    render :template => 'quote/ask_to_tweet',:layout => false
  end

  def tweet_now

    @quote = Tweet.find_by_id( params['quote_id'] )
    
    respond_to do |format|
      format.js
    end
  end

  def tweet_submission
    @quote = Tweet.find_by_id( params['id'] )
    long_url = "http://profquot.es/quotes/show/#{@quote.id}"

    @quote_text =  get_status_update_text(@quote,  get_bitly_url( long_url ))
    current_user.twitter.post('/statuses/update.json', 'status' => @quote_text)
    
    respond_to do |format|
      format.js
    end
  end

  def more_tweets
    @screen_name = params['screen_name'].strip unless params['screen_name'].nil?
    @tweets = get_recent_tweets( @screen_name, params['last_id'] )

    @tweets.delete_at(0) #returns redundant tweet from, prevents duplication
    @last_id = @tweets.at(-1)['id'] unless @tweets.at(-1).nil?
    respond_to do |format|
      format.js
    end
  end

private

  def submit_notification( tweet, ip )
    if Rails.env.production?
      notifo = Notifo.new( @@private_keys['notifo_user'], @@private_keys['notifo_key'] )
      notifo_string ="#{ip}: #{tweet.text}"
      notifo.post("imack", notifo_string, "#{@current_feed.user[:login]} Submission", "http://#{@current_feed.user[:login]}.feedladder.com/t/#{tweet.id}" )
    end
  end

def see_need_login
  if !current_user and !@current_feed.allow_anonymous_submits:
      #been through signup page, try to authenticate
      login_required
  end

end

def decrypt( ciphertext )
  return BlockTEA::decrypt(ciphertext, "olympictorch")
end

def process_vote( voteString )
  id = decrypt( voteString )

  timestamp = id.split("|")[0]
  tweet_id = id.split("|")[1]
  voted_tweet = Tweet.find_by_id( tweet_id )
  sessionid = id.split("|")[2]

  return voted_tweet unless add_vote_to_history( voted_tweet.id, current_user ) #check if prev voted

  if Time.at(timestamp.to_i) < Time.now - 5.minutes
    #vote is more than 5 minutes old, so ignore
    return voted_tweet
  elsif session[:sessionid] != sessionid:
    #sessionIDs do not match, something fishy going on
    return voted_tweet
  end

  if id.split("|")[3] == "1":
    voted_tweet.win
  else
    voted_tweet.loss
  end

  voted_tweet.save
    
  return voted_tweet
end

def add_vote_to_history( tweet_id, current_user )

    session_id = session[:sessionid]
    if current_user
      # uses new since cache returns frozen version of array
      prev_votes_raw = Rails.cache.read( "RECENT_VOTES_" + current_user.id.to_s )
    else
      prev_votes_raw = Rails.cache.read( "RECENT_VOTES_" + session_id )
    end

    # cover case where we get nothing
    if prev_votes_raw.nil?
      prev_votes = Array.new
    else
      prev_votes = Array.new( prev_votes_raw )
    end

    return false unless prev_votes.index( tweet_id ).nil?

    while prev_votes.size > 100
      prev_votes.pop()
    end

    prev_votes.insert( 0, tweet_id )

    if current_user
       Rails.cache.write( "RECENT_VOTES_" + current_user.id.to_s, prev_votes)
    else
      Rails.cache.write( "RECENT_VOTES_" + session_id, prev_votes)
    end

  return true
    
end


  def get_status_update_text(quote, bitly_link)
    "Submitted quote to profquot.es: #{bitly_link}"
  end

  def get_bitly_url( long_url )
    bitly = Bitly.new(@@private_keys['bitly_user'], @@private_keys['bitly_key'] )
    u = bitly.shorten( long_url )
    return u.short_url
  end

  def get_recent_tweets(username, since_id = "")
    if !since_id.nil? and since_id != ""
      trailer = "max_id=#{since_id}&include_rts=true"
    else
      trailer = "include_rts=true"
    end

    if (username.nil? or username == "")
      tweets = current_user.twitter.get("/statuses/friends_timeline?" + trailer)
    else
      begin
        tweets = current_user.twitter.get("/statuses/user_timeline?screen_name=#{username}&" + trailer)
      rescue TwitterAuth::Dispatcher::Error #most likely because can't find user
        tweets = Array.new
      end
    end

    return tweets
  end
end