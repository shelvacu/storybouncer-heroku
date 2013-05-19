require 'sequel'
require 'jdbc-postgres'
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
puts "RUBY_ENGINE = #{RUBY_ENGINE}"
DB = Sequel.connect((RUBY_ENGINE == 'jruby' ? 'jdbc:' : "")+(ENV['JUSTONEDB_DBI_URL'] || 'sqlite:local.db'))
