class AddLightCodeToQuote < ActiveRecord::Migration
  def self.up
    add_column :quotes, :traffic_light, :integer, :default=>1
    add_column :quotes, :feed_id, :integer

    quotes = Quote.find(:all)

    quotes.each do |q|
      q[:feed_id] =1
      q.save
    end

  end

  def self.down
    remove_column :quotes, :traffic_light
    remove_column :quotes, :feed_id
  end
end
