require 'sequel'

DB = Sequel.connect(ENV['JUSTONEDB_DBI_URL'] || 'postgres://localhost/mydb')
