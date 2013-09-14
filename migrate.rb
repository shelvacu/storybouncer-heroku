to = ARGV[0]
to = to.to_i unless to.nil?
require 'pp'
puts 'loading local_db.rb'
require './local_db'
puts 'loading migration extension'
Sequel.extension :migration
puts "Attempting migration to #{to.nil? ? 'most recent migration.' :'migration #'+to.to_s}"
begin
  pp Sequel::Migrator.apply(DB, './migrations', to)
rescue Sequel::Migrator::Error => e
  puts "AAH! Error!"
  p e
end
puts "Success!"
