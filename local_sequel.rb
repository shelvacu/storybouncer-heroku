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
#puts "RUBY_ENGINE = #{RUBY_ENGINE}"
#DB = Sequel.connect((RUBY_ENGINE == 'jruby' ? 'jdbc:' : "")+(ENV['JUSTONEDB_DBI_URL'] || 'sqlite:local.db'))
if (db_url = ENV['JUSTONEDB_DBI_URL'])
  parts = db_url.split("//")
  protocol = parts[0]
  user_pass_url = parts[1].split("@")
  user_pass = user_pass_url[0].split(":")
  user = user_pass[0]
  pass = user_pass[1]
  domain_path = user_pass_url[1]
  DB = Sequel.connect("jdbc:#{protocol}//#{domain_path}?user=#{user}&password=#{pass}")
else
  DB = Sequel.connect('jdbc:sqlite:local.db')
end
