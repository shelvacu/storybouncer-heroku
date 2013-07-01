require './local_sequel'

DB[:notif].all.each do |row|
  puts row[:email]
end
