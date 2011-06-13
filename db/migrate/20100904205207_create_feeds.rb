class CreateFeeds < ActiveRecord::Migration
  def self.up
    create_table :feeds do |t|
      t.integer :user_id
      t.string :admins
      t.boolean :allow_retweets
      t.integer :who_votes
      t.integer :push_strategy
      t.integer :tweet_hour_of_day

      t.timestamps
    end

    Feed.create(:user_id => 4,
                :admins => "['37863782','92839314']",
                :allow_retweets => false,
                :who_votes => 0,
                :push_strategy => 0,
                :tweet_hour_of_day => 20
    )

  end

  def self.down
    drop_table :feeds
  end
end
