require 'sequel'
def getarray(id)
  return DB["array#{id}"]
end
def makearray(type = Integer)
  id = DB['array'].insert
  DB.create_table("array#{id}") do
    primary_key :id
    column :id, type
  end
  return id
end
DB = Sequel.connect(ENV['JUSTONEDB_DBI_URL'] || 'postgres://localhost/mydb')
