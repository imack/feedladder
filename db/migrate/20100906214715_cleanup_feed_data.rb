class CleanupFeedData < ActiveRecord::Migration
  def self.up

    remove_column :feeds, :admins
    remove_column :feeds, :push_strategy
    add_column :feeds, :light_default_status, :integer, :default => 2
    remove_column :feeds, :tweet_hour_of_day
    add_column :feeds, :tweet_schedule, :string, :default =>""
  end

  def self.down
    remove_column :feeds, :light_default_status
    add_column :feeds, :admins, :string
    add_column :feeds, :push_strategy, :integer
    add_column :feeds, :tweet_hour_of_day, :integer
    remove_column :feeds, :tweet_schedule
  end
end
