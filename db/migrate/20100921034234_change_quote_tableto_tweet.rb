class ChangeQuoteTabletoTweet < ActiveRecord::Migration
  def self.up
    rename_table :quotes, :tweets
  end

  def self.down
    rename_table :tweets, :quotes
  end
end
