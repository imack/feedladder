require 'BlockTEA'

class Tweet
  include MongoMapper::Document
  plugin MongoMapper::Plugins::Timestamps 
  
  attr_protected :old_id

  key :user_id, ObjectId, :index => true
  key :rating, Float
  key :score, Integer,:default => 0
  key :old_id, Integer
  key :text, String, :unique=>false
  key :live_quote, Integer,:default => 1
  key :confirmed_wins, Integer,:default => 0
  key :confirmed_losses, Integer,:default => 0
  key :random_wins, Integer,:default => 0
  key :random_losses, Integer,:default => 0
  key :traffic_light, Integer,:default => 1
  key :feed_id, ObjectId, :index => true
  key :tag, String,:default => ""
  key :retweet, Boolean,:default => false
  key :twitter_long_id, Integer
  key :owner_twitter_id, Integer
  key :feed_username, String
  key :thumb_url, String
  key :short_url, String
  timestamps! 

  belongs_to :user
  belongs_to :feed

  validates_length_of :text, :within => 1..500, :message=>"cannot be empty or exceed maximum"
  validate :has_tag_if_required

  def has_tag_if_required
    #require a taf if enabled, but only check if a new record
    if self.feed[:tag_enabled] && self.tag == "" && self.new_record?
      errors.add(:tag, ' required, please enter ' + self.feed[:tag_title])
    end
  end
    
  def self.find_or_create( params, feed )
    tweet = Tweet.first(:conditions =>  { :twitter_long_id => params['tweet_id'], :feed_id => feed["_id"] } )

    if tweet.nil?
      tweet = Tweet.new()
      feed = params['user']
      tweet.random_wins = 1
      tweet.user_id = params['user_id']
      tweet.feed_id = params['feed_id']
      tweet.text = params['text']
      tweet.retweet=1
      tweet.twitter_long_id = params['twitter_long_id']
      tweet.owner_twitter_id = feed['id']
      tweet.feed_username = feed['screen_name']
      tweet.thumb_url = feed['profile_image_url']
      tweet.calc_rating
    else
      tweet.win
    end
    
    tweet.save
    return tweet
  end
  
  def self.find_all_recent_quotes()
    last = Time.now-1.week
    Tweet.find( :all, :conditions =>  ["created_at > ?", last] )
  end

  def self.find_top_twenty_for_feed( feed , offset = 0)
    Tweet.all(:conditions =>  {:traffic_light.gt => 1, :feed_id => feed['_id']}, :order =>'rating desc', :offset => offset, :limit =>20)
  end

  def self.find_best_for_feed( feed, offset = 0 )
    Tweet.all(:conditions =>  {:traffic_light.gt => 1, :feed_id => feed['_id']}, :order =>'score desc', :offset => offset, :limit =>20)
  end

  def self.find_newest_twenty_for_feed( feed, offset = 0 )
    Tweet.all(:conditions =>  {:traffic_light.gt => 1, :feed_id => feed["_id"]}, :order =>'created_at desc', :offset => offset, :limit =>20)
  end

  def self.find_all_newest_twenty_for_feed( feed, offset = 0 )
    Tweet.all(:conditions =>  {:traffic_light.ne => 0, :feed_id => feed["_id"]}, :order =>'created_at desc', :offset => offset, :limit =>20)
  end

  def self.find_queue( feed )
    Tweet.all(:conditions => {:live_quote => 1, :traffic_light => 2, :feed_id => feed['_id']}, :order =>'rating desc', :limit =>20)
  end

  def self.pop_top_for_feed( feed )
    Tweet.first(:conditions =>  {:live_quote => 1, :traffic_light =>2, :feed_id => feed["_id"]}, :order =>'rating desc')
  end

  def self.strip_links( quoteText )
    return quoteText.gsub(/(http|ftp|https):\/\/[\S]+/, '').strip
  end

  def self.find_by_id( bson_id )
    begin
      Tweet.find_by_id( params['id'] )
    rescue
      return nil
    end
  end

  def tweet_share(force_link=false)

    if self.short_url.nil? and self.retweet == false
      bitly = Bitly.new('imack', 'R_8162d539fded85844680e38a490411ce')
      self.short_url = bitly.shorten( "http://#{ feed.user.login }.feedladder.com/t/#{ self.id }" ).short_url
      self.save
    end

    if self.retweet
      return "RT @#{self.feed_username}: #{self.text}"
    else
      if self.text.length > 140 or force_link
        bitly_text = "... #{self.short_url}"
        return self.text[0..((140 - bitly_text.length)-1)] +bitly_text
      else
        return self.text
      end
        
    end

  end

  def win
    self.confirmed_wins += 1
    calc_rating_and_score
  end

  def loss
    self.confirmed_losses += 1
    calc_rating_and_score
  end

  def wins
    self.confirmed_wins + self.random_wins
  end

  def losses
    self.confirmed_losses + self.random_losses
  end

  def feed_username
    if self[:feed_username].nil?
      self.feed.user.login
    else
      self[:feed_username]
    end
  end

  def funny_code( session )
    if session and !session[:sessionid].nil?
      encrypt(Time.now.to_i.to_s + "|" + self.id.to_s + "|" + session[:sessionid] + "|1")
    else
      return ""
    end
  end

  def lame_code( session )
    if session and !session[:sessionid].nil?
      encrypt(Time.now.to_i.to_s + "|" + self.id.to_s + "|" + session[:sessionid] + "|0")
    else
      return ""
    end
  end


  def calc_rating_and_score
    #this is the rating system used by reddit
    epoch = Time.gm(2010,2,12,0,0,0).to_time.to_i
    post_time =  Time.parse( self[:created_at].to_s).to_time.to_i

    time_diff = post_time - epoch
    vote_diff = self.confirmed_wins - self.confirmed_losses
    self.score = vote_diff

    if vote_diff > 0:
      y = 1
    elsif vote_diff == 0:
      y = 0
    else
      y = -1
    end

    if vote_diff.abs >=1
      z = vote_diff.abs
    else
      z = 1
    end

    self[:rating] = Math.log10(z) + (y * time_diff / 45000)
  end

  def screen_name
    self.feed.user[:login]
  end

  def thumb_url
    if self.retweet == true
      self[:thumb_url]
    else
      self.feed.user[:profile_image_url]
    end
    
  end

  private
    def encrypt( plaintext )
      return BlockTEA::encrypt(plaintext, "olympictorch")
    end
end
