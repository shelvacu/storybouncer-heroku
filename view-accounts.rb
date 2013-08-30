require './local_sequel'
puts "getting users"
users = User.all
puts "#{users.length - 7} users registered"
users.each do |user|
  puts "\"#{user.name}\": #{user.email}#{user.veri? ? '!' : ''}"
end 
