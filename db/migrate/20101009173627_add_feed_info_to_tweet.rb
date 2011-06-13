class AddFeedInfoToTweet < ActiveRecord::Migration
  def self.up
    add_column :tweets, :owner_twitter_id, :integer
    add_column :tweets, :feed_username, :string
    add_column :tweets, :thumb_url, :string
  end

  def self.down
    remove_column :tweets, :owner_twitter_id
    remove_column :tweets, :feed_username
    remove_column :tweets, :thumb_url
  end
end
