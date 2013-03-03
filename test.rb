require 'sequel'

DB =  Sequel.connect(ENV['DATABASE_URL'] || 'postgres://localhost/mydb')
DB.create_table :test do
	primary_key :id
	String :text
end
tg = ''
3_000_000_000.times do
	tg+='a'
end
DB[:test].insert(:text => tg)
