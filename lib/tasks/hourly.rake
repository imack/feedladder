require 'feed_tools'

task  :hourly => ["hourly:crown_champion", "hourly:pad_votes"]

namespace 'hourly' do

  desc "Kills the top live green tweet and posts to feed"
  task :crown_champion => :environment do

    feeds = Feed.all()

    feeds.each do |feed|
      times = feed[:tweet_schedule].split(",")
      user = feed.user
      zone = user[:time_zone].nil? ? "Pacific Time (US & Canada)" : user[:time_zone]
      
      times.each do |time|
        local_time = Time.now.in_time_zone(zone)
        puts "now: #{local_time.hour} post #{time}"
        if local_time.hour == time.to_i
          
          tweet = Tweet.pop_top_for_feed( feed )
          begin
            post_tweet_to_feed( tweet, feed ) unless tweet.nil?
          rescue
            puts "POST FAIL", $!
          end
        end
      end
    end
  end

  desc "For tweets less than a week old, which have more than 10 votes, add a vote to simulate motion with pre-existinting probability"
  task :pad_votes => :environment do
    tweets = Tweet.all(:conditions =>  {:traffic_light.gt => 1, :created_at.gte => 1.week.ago})
    puts "Fudging the numbers on #{tweets.size} tweets"

    for tweet in tweets:
        if (tweet.confirmed_wins + tweet. confirmed_losses > 0) and (tweet.random_wins + tweet. random_losses <= 10)
          win_average = (tweet.confirmed_wins) / (tweet.confirmed_wins + tweet.confirmed_losses  + 0.0)
          puts win_average
          if rand() > win_average - 0.1:
            tweet.random_losses += 1
          else
            tweet.random_wins += 1
          end
          tweet.save
        end
    end
  end

end

