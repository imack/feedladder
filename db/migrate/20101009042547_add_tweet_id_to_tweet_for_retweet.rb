class AddTweetIdToTweetForRetweet < ActiveRecord::Migration
  def self.up
    add_column :tweets, :retweet, :integer, :default=>0
    add_column :tweets, :twitter_long_id, :integer, :limit => 8
  end

  def self.down
    remove_column :tweets, :retweet
    remove_column :tweets, :twitter_long_id
  end
end
