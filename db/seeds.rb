# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)

School.create(:name => "University of Waterloo", :url=> "http://www.uwaterloo.ca")
School.create(:name => "University of British Columbia", :url=> "http://www.ubc.ca")
School.create(:name => "Simon Fraser University", :url=> "http://www.sfu.ca")
School.create(:name => "Case Western Reserve University", :url=> "http://www.case.edu")
