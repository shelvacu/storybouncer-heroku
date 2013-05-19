require 'sequel'
require 'jdbc/postgres'
Jdbc::Postgres.load_driver
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
DB = Sequel.connect(ENV['JUSTONEDB_DBI_URL'] || 'sqlite://local.db')
