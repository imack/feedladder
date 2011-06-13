class MoveSchoolToQuote < ActiveRecord::Migration
  def self.up
    add_column :quotes, :tag, :string

    quotes = Quote.find(:all)

    quotes.each do |quote|
      puts quote.school.name
      quote[:tag] = quote.school.name
      quote.save
    end

    remove_column :quotes, :school_id
    drop_table :schools
    

  end

  def self.down
  end
end
