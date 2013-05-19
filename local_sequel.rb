require 'sequel'
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
DB = Sequel.connect(ENV['JUSTONEDB_DBI_URL'] || (RUBY_ENGINE == 'jruby' ? 'jdbc:sqlite:local.db' : 'sqlite://local.db') )
