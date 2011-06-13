class RemoveProfandCourseFromQuote < ActiveRecord::Migration
  def self.up


    quotes = Quote.find(:all)

    quotes.each do |q|
      puts q
      q.text = q.text + " -" + q.prof + ", " + q.course_code
      q.save
    end

    remove_column :quotes, :prof
    remove_column :quotes, :subject
    remove_column :quotes, :course_code

  end

  def self.down
    #yeah, this ain't happening
  end
end
