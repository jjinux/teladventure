# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)

puts "Loading seeds for environment: #{RAILS_ENV}"

if RAILS_ENV == "development"
  Node.delete_all

  # It's been a good morning so far.  You woke up before your alarm.  You got in a
  # shower and even managed to find something to eat.  Something inside you tells
  # you this is going to be a great day.  You exit the front door and start
  # singing "I Feel Lucky" by Mary Chapin Carpenter.  As you close the door, a
  # mysterious, long black limo pulls up to the curb.  The door opens, and a leg
  # confidently steps out onto the curb.
  Node.create!(:outcome => "http://api.twilio.com/2010-04-01/Accounts/ACec5bb8f63c52532cb3a8c18a1b2e85b1/Recordings/RE48c9b4391d0850546843da3d1c4f1070")
end