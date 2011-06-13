class FeedController < ApplicationController
  # GET /feed
  # GET /feed.xml

  before_filter :feed_check_admin, :only => :edit

  def feed_check_admin
    if !@current_feed.is_admin( current_user )
      redirect_to "/"
    end
  end

  def show

    load_common_lists_for_feed( @current_feed )
    @tweet = Tweet.new
    @tweet.tag = session[:school_name] unless session[:school_name].nil?
  end

  def more_tweets
    feed = Feed.find(params[:feed_id])
    @list_type = params[:type]
    @offset = params[:offset].to_i

    if params[:type] == 'new_tweets'
      if current_user and feed.is_admin( current_user )
        @tweets = Tweet.find_all_newest_twenty_for_feed( feed, @offset )
      else
        @tweets = Tweet.find_newest_twenty_for_feed( feed, @offset )
      end
    elsif params[:type] == 'best_tweets'
      @tweets = Tweet.find_best_for_feed( feed , @offset )
    elsif params[:type] == 'top_tweets'
      @tweets = Tweet.find_top_twenty_for_feed( feed, @offset )
    end

    @tweets = nil if @tweets.nil?


    respond_to do |format|
      format.html { }
      format.js{ render :action => 'show_more_tweets'}
    end
  end

  # GET /feed/1/edit
  def edit
    @feed = @current_feed
  end


  # PUT /feed/1
  # PUT /feed/1.xml
  def update
    @feed = Feed.find(params[:id])
    @feed.update_attributes(params[:feed])
    
    if @feed.save
      flash[:notice] = 'Feed was successfully updated.'
    else
      flash[:notice] = 'Feed save error'
    end
    respond_to do |format|
      format.html { render :action => "edit" }
    end
  end
end


def submit
    if current_user && current_user[:available_nominations].to_i > 0

      raw_tweet = current_user.twitter.get("/statuses/show/#{params['tweet_id']}")
      raw_tweet['tweet_id'] = raw_tweet['id'] #to match tweet model

      feed = Feed.find_by_username_or_create( raw_tweet['user']['screen_name'], current_user )
      @tweet = Tweet.find_or_create( raw_tweet, feed, current_user )

      if session[:recent_nominees].nil?
        session[:recent_nominees] = Array.new
      elsif session[:recent_nominees].size > 10
        session[:recent_nominees].delete_at( 0 )
      end

      add_vote_to_history( @tweet.id, current_user )
      session[:recent_nominees].push( @tweet.tweet_id )
      current_user.save
    elsif current_user
      flash[:notice] = "You have run out available nominations for today, please come back tomorrow!"
    else
      #not signed in
    end

    respond_to do |format|
      format.html { redirect_to :action=>"nominate" }
      format.js
    end

end


