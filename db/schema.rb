# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20101104050540) do

  create_table "admins", :force => true do |t|
    t.integer  "user_id"
    t.integer  "feed_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "feed", :force => true do |t|
    t.integer  "user_id"
    t.boolean  "allow_retweets"
    t.integer  "who_votes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "description"
    t.integer  "light_default_status",    :default => 2
    t.string   "tweet_schedule",          :default => ""
    t.string   "submit_note",             :default => ""
    t.boolean  "tag_enabled",             :default => false
    t.string   "tag_title",               :default => "Tags"
    t.boolean  "allow_long_tweets",       :default => false
    t.boolean  "allow_anonymous_submits", :default => false
  end

  create_table "tweets", :force => true do |t|
    t.integer  "user_id"
    t.float    "rating"
    t.string   "text"
    t.integer  "live_quote",                    :default => 1
    t.integer  "confirmed_wins",                :default => 0
    t.integer  "confirmed_losses",              :default => 0
    t.integer  "random_wins",                   :default => 0
    t.integer  "random_losses",                 :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "delta",                         :default => true, :null => false
    t.integer  "traffic_light",                 :default => 1
    t.integer  "feed_id"
    t.string   "tag"
    t.integer  "retweet",                       :default => 0
    t.integer  "twitter_long_id",  :limit => 8
    t.integer  "owner_twitter_id"
    t.string   "feed_username"
    t.string   "thumb_url"
  end

  create_table "users", :force => true do |t|
    t.integer  "is_spammer",                   :default => 0
    t.string   "twitter_id"
    t.string   "login"
    t.string   "access_token"
    t.string   "access_secret"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "name"
    t.string   "location"
    t.string   "description"
    t.string   "profile_image_url"
    t.string   "url"
    t.boolean  "protected"
    t.string   "profile_background_color"
    t.string   "profile_sidebar_fill_color"
    t.string   "profile_link_color"
    t.string   "profile_sidebar_border_color"
    t.string   "profile_text_color"
    t.string   "profile_background_image_url"
    t.boolean  "profile_background_tiled"
    t.integer  "friends_count"
    t.integer  "statuses_count"
    t.integer  "followers_count"
    t.integer  "favourites_count"
    t.integer  "utc_offset"
    t.string   "time_zone"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "shown_popup",                  :default => 0
  end

end
