require 'sequel'
require 'jdbc/postgres'

def getarray(id)
  return DB[:"array#{id}"]
end
def makearray(type = Integer,name = :val)
  id = DB[:array].insert
  DB.create_table(:"array#{id}") do
    primary_key :id
    column name, type
  end
  return id
end
#DB = Sequel.connect(ENV['JUSTONEDB_DBI_URL'].gsub("postgres:","jdbc:postgresql") || 'jdbc:sqlite:local.db')
if (url = ENV['JUSTONEDB_DBI_URL'])
  m = url.match(/:\/\/(?<user>\w+):(?<pass>\w+)@(?<else>.*)/)
  DB = Sequel.connect("jdbc:posgresql://#{m[:else]}?user=#{m[:user]}&pass=#{m[:pass]}")
else
  DB = Sequel.connect("jdbc:sqlite:local.db")
end
#
