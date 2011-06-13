class AddLaughlitmusFeed < ActiveRecord::Migration
  def self.up
    Feed.create() do |f|
      f.user_id = 5
      f.allow_retweets = 1
      f.who_votes = 0
      f.description = ""
    end
  end

  def self.down
    feed = Feed.find_by_id(2)
    feed.delete
    feed.save
  end
end
