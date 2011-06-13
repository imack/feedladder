require 'twitter'

def post_tweet_to_feed(tweet, feed)
    user = feed.user

    #catch for testing
    if ENV['RAILS_ENV'] != 'production'
      user = User.find_by_login("antitruths")
    end
  

    # Certain methods require authentication. To get your Twitter OAuth credentials,
    # register an app at http://dev.twitter.com/apps
    Twitter.configure do |config|
      config.consumer_key = TWITTER_CONFIG['oauth_consumer_key']
      config.consumer_secret = TWITTER_CONFIG['oauth_consumer_secret']
      config.oauth_token = user[:access_token]
      config.oauth_token_secret = user[:access_secret]
    end

    # Initialize your Twitter client
    twitter = Twitter::Client.new

    puts "Posting #{tweet.text} to #{user.login} \n"

    begin
      if tweet.retweet ==true
        puts twitter.retweet(tweet[:twitter_long_id])
      else
        return_tweet =  twitter.update( tweet.tweet_share )
        puts return_tweet
        tweet[:twitter_long_id] = return_tweet.id
      end

    rescue
      puts "PUT FAIL", $!
    end
    tweet[:live_quote] = 2
    tweet.save

    puts "Retweeted top tweet"
end
