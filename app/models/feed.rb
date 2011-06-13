class Feed
  include MongoMapper::Document
  plugin MongoMapper::Plugins::Timestamps 
  
  belongs_to :user
  has_many :tweets

  attr_protected  :old_id
  
  key :user_id, ObjectId, :index => true
  key :admin_users, String, :default => ""
  key :old_id, Integer
  key :allow_retweets, Boolean,:default => false
  key :anonymous_votes, Boolean,:default => true
  key :allow_long_messages, Boolean,:default => false
  key :description, String,:default => ""
  key :light_default_status, Integer,:default => 1
  key :tweet_schedule, String,:default => ""
  key :submit_note, String,:default => ""
  key :tag_enabled, Boolean,:default => false
  key :tag_title, String,:default => "Tag"
  key :allow_long_tweets, Boolean,:default => false
  key :allow_anonymous_submits, Boolean,:default => false
  key :facebook_page_url, String, :default => ""
  timestamps! 

  def is_admin( user )
    
    if !user
      return false
    elsif (user == self.user)
      return true
    else
      self.admin_users.split(",").each do |a|
        if a.strip == user.login or a.strip == ("@" + user.login)
          return true
        end
      end
    end

    return false
  end

  def schedule_size
    scheduled_tweets = self[:tweet_schedule].split(',')

    if scheduled_tweets.size == 0
      " not scheduled to be posted"
    elsif scheduled_tweets.size == 1
      " posted once per day"
    else
      " posted #{scheduled_tweets.size} times per day "
    end
  end

  def self.find_by_subdomain( subdomain )
    user = User.find_by_login( subdomain )
    user.feed
  end
  
end
