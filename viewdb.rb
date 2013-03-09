require './local_sequel'
require 'pp'
DB.tables.each do |t_name|
	puts t_name.inspect
	pp DB[t_name].all
end
