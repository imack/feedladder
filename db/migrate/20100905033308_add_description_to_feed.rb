class AddDescriptionToFeed < ActiveRecord::Migration
  def self.up

    add_column :feeds, :description, :string

    feed = Feed.find_by_id(1)
    feed[:description] = "Profquotes is a funny quote ranking site. You can vote
         on submissions and submit quotes you think are funny. The funniest
          quotes are tweeted by @profquotes"
    feed.save

  end

  def self.down

    remove_column :feeds, :description

  end
end
