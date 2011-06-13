class RemoveThumbsandUrlFromSchool < ActiveRecord::Migration
  def self.up
    remove_column :schools, :thumbnail
    remove_column :schools, :url
  end

  def self.down
  end
end
