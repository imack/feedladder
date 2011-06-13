require 'rubygems'
require 'twitter'

require 'mongo'

include Mongo


namespace "db" do

  task :reload => [:drop, :download_and_install]

  desc "Drops the database for mongodb"
  task :drop do
    puts "DROPPING MONGO DATABASE NAMED feedladder-production"
    conn   = Mongo::Connection.new("localhost")
    conn.drop_database("feedladder-production")
  end

  desc "Reloads the database based the the latest backup from production"
  task :download_and_install do
    if File.exists?('/tmp/mongodb-latest.tgz')
      file = File.new('/tmp/mongodb-latest.tgz', 'r')
      puts "current file in temp is timestamp: " + file.mtime.to_s
    end
    
    if file.nil? or file.mtime < 1.day.ago
      puts "getting new backup"
      puts `scp lunarluau:/backups/latest/mongodb-latest.tgz /tmp/mongodb-latest.tgz`
      puts `rm -rf /tmp/MONGOBACKUP`
      puts `mkdir /tmp/MONGOBACKUP`
      puts `tar -C /tmp/MONGOBACKUP -xzvf /tmp/mongodb-latest.tgz`
    end

    puts `/usr/local/mongodb/bin/mongorestore /tmp/MONGOBACKUP`
  end


end

namespace "tweet" do

  desc "Recalculate the scores and ratings of all tweets"
  task :recalculate => :environment do
    Tweet.all.each do |t|
      t.calc_rating_and_score
      t.save
    end
  end
end
