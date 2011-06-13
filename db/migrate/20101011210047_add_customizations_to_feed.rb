class AddCustomizationsToFeed < ActiveRecord::Migration
  def self.up
    add_column :feeds, :submit_note, :string, :default => ""
    add_column :feeds, :tag_enabled, :boolean, :default => 0
    add_column :feeds, :tag_title, :string, :default => "Tags"
    add_column :feeds, :allow_long_tweets, :boolean, :default =>0
    add_column :feeds, :allow_anonymous_submits, :boolean, :default =>0
  end

  def self.down
    remove_column :feeds, :submit_note
    remove_column :feeds, :tag_enabled
    remove_column :feeds, :tag_title
    remove_column :feeds, :allow_long_tweets
    remove_column :feeds, :allow_anonymous_submits
  end
end
