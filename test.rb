require 'sequel'

DB =  Sequel.connect(ENV['DATABASE_URL'] || 'postgres://localhost/mydb')
#DB.create_table :test do
#	primary_key :id
#	String :text
#end
tg = ''
percent = 0.0
1_000.times do
	3_000_000.times do
		tg+='a'
	end
	percent += 0.1
	puts percent
end
DB[:test].insert(:text => tg)
