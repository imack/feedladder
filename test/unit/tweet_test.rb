require 'test_helper'

class TweetTest < ActiveSupport::TestCase
  
  test "URL scrubber test: remove link" do
    tweetText = "The Vancouver 2010 Olympics launch today as so do we! It isn't pretty, but V0.1 is up and running, check us out at: http://bit.ly/9hQpmv "
    after = Tweet.strip_links(tweetText)
    assert after == "The Vancouver 2010 Olympics launch today as so do we! It isn't pretty, but V0.1 is up and running, check us out at:"
  end

  test "URL scrubber test: don't remove anything" do
    tweetText = "Nah, we don't celebrate it. Don't know who St. Valentine was, don't give a shit, and doubt he wants people screwing in his memory."
    after = Tweet.strip_links(tweetText)
    assert after == "Nah, we don't celebrate it. Don't know who St. Valentine was, don't give a shit, and doubt he wants people screwing in his memory."
  end

  test "URL scrubber test: contains http, but not link" do
    tweetText = "I love the http protocol http"
    after = Tweet.strip_links(tweetText)
    assert after == "I love the http protocol http"
  end
  
end
