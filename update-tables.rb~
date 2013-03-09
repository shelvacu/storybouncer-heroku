require './local_sequel'

DB.alter_table :users do
	#drop_column :vparas
	#drop_column :vbooks
	#drop_column :vnames
end

DB.alter_table :paras do
	[:upvotes,:downvotes].each do |o|
		drop_column o
		add_column o,String
		set_column_default o,""
	end
	set_column_default :newchap, false
	#set_column_default :chapname, ""
	set_column_default :endchap, false
	#drop_column :chapnum
end

DB.alter_table :books do
	[:endvotes,:noendvotes].each do |o|
		drop_column o
		add_column o,String
	end
	[:upvotes,:downvotes].each{|o| add_column o,String}
end

DB.alter_table :names do
	[:upvotes,:downvotes].each{|o| 
		drop_column o if DB[:names].columns.include?(o)
		add_column o,String
	}
end
