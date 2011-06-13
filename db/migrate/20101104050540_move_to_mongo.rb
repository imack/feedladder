require 'rubygems'
require 'mongo'

include Mongo

class MoveToMongo < ActiveRecord::Migration

  module OldRecord
    class Tweet < ActiveRecord::Base

    end
    class Feed < ActiveRecord::Base

    end
    class User < ActiveRecord::Base

    end
  end

  def self.up
    puts MongoMapper.database

    OldRecord::User.all.each do |u|

      attrs = u.attributes

      user = User.new
      old_id = attrs.delete("id")

      user.update_attributes( attrs )
      user.twitter_id = attrs['twitter_id']
      user.login = attrs['login']

      if user.save
        user.created_at = attrs['created_at']
        user.old_id = old_id
        user.save
        puts user['login']
      else
        user.errors.each do |e|
          puts e
        end
      end
    end

    puts "translate feed"

    OldRecord::Feed.all.each do |u|

      attrs = u.attributes

      feed = Feed.new
      old_id = attrs.delete("id")

      puts "updating feed #{u}"

      old_user_id = attrs.delete("user_id")
      
      feed.update_attributes( attrs )
      
      user = User.find_by_old_id( old_user_id )
      feed.user = user

      if feed.save
        feed.created_at = attrs['created_at']
        feed.old_id = old_id
        feed.save
        puts feed.user['login']
      else
        feed.errors.each do |e|
          puts e
        end
      end
    end


    OldRecord::Tweet.all.each do |t|
      attrs = t.attributes

      r =  attrs["random_wins"]
      puts r

      tweet = Tweet.new
      old_id = attrs.delete("id")

      

      old_user_id = attrs.delete("user_id")
      user = User.find_by_old_id( old_user_id )
      tweet.user = user

      old_feed_id = attrs.delete("feed_id")
      feed = Feed.find_by_old_id( old_feed_id )
      
      tweet.update_attributes( attrs )
      tweet.feed = feed

      if tweet.save
        tweet.created_at = attrs['created_at']
        tweet.save
        puts tweet['twitter_long_id']
      else
        tweet.errors.each do |e|
          puts e
        end
      end
    end

  end

  def self.down
    db   = Connection.new.db("feedladder-#{Rails.env}")
    puts "DROPPING MONGO DATABASE NAMED feedladder-#{Rails.env}"
    coll = db.collection('feeds')
    coll.drop

    coll = db.collection('tweets')
    coll.drop

    coll = db.collection('twitter_auth.generic_users')
    coll.drop
  end
end
