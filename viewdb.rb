require './local_sequel'
require 'pp'
DB.tables.each do |t_name|
	puts t_name.inspect
	#pp DB[t_name].all
	lengths = {}
	DB[t_name].columns.each{|col_name| lengths[col_name] = col_name.length}
	DB[t_name].all.each do |row|
		row.each do |key,val|
			lengths[key] = val.to_s.length if val.to_s.length > lengths[key]
		end
	end
	pp lengths
	print '|'
	DB[t_name].columns.each do |col_name|
		print col_name.to_s.center(lengths[col_name]) + '|'
	end
	puts
	DB[t_name].all.each do |row|
		print '|'
		row.each do |key,val|
			print val.to_s.center(lengths[key])+'|'
		end
		puts
	end
end
