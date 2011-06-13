module TweetHelper

  def retweet_url( tweet )
    base = "http://twitter.com/home/?status="
    primer = "RT @#{tweet.feed.screen_name}: "
    tweet_text = tweet.text
    appender = " (via @profquotes)"

    with_appender = primer + tweet_text + appender
    without_appender = primer + tweet_text

    if with_appender.length <= 140:
      return base + CGI::escape(with_appender)
    else
      return base + CGI::escape(without_appender)
    end
  end


  def submitted_class( session, tweet )
    if is_submitted( session, tweet )
      return "nominated_tweet"
    else
      return "unselected_tweet"
    end
  end

  def is_submitted( session, quote )
    return (!session[:recent_nominees].nil? and session[:recent_nominees].include?( quote['id'] ))
  end

end
