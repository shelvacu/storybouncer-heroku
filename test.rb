require 'sequel'
require 'jdbc/postgres'
DB = Sequel.connect("jdbc:postgresql://bla/bla")
DB.tables
