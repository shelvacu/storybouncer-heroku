require 'sequel'
require 'jdbc/postgres'

if (url = ENV['JUSTONEDB_DBI_URL'])
  m = url.match(/:\/\/(?<user>\w+):(?<pass>\w+)@(?<else>.*)/)
  DB = Sequel.connect("jdbc:postgresql://#{m[:else]}?user=#{m[:user]}&password=#{m[:pass]}")
else
  DB = Sequel.connect("jdbc:postgresql://localhost/?user=postgres&password=inspirecreatelearn")
end

DB.test_connection
