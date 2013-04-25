require './local_sequel'
puts "THIS PROGRAM IS OBSELETE AND DOESN'T WORK!"
exit
DB[:users].insert(	:username => "*TEST*", 
                    :pass => "666",
                    :email => "testemail",
                    :emailver => "wq23iujt4erofd9wu3rj4k5rotf09ifer43erfd09iknr", 
                    :veri => true)
dataset= DB[:users].where(:username => "*TEST*")
userid = dataset.all[0][:id]
name = "The Adventures of Sherlock Holmes"
authors_note = "p"

ts = Time.now
DB[:books].insert(:userid => userid, :timestamp => ts)
bookid = DB[:books].where(:userid => userid, :timestamp => ts).all[0][:id]
book = DB[:books].where(:id => bookid)

chaps.each do |name, paras|
	firstpara = paras.shift
	DB[:paras].insert(:bookid => bookid,
                    :userid => userid,
                    :an => authors_note,
                    :text => firstpara, 
                    :chapname => name, 
                    :newchap => true)
	paras.each do |text|
		DB[:paras].insert(:bookid => bookid,:userid => userid,:an => authors_note,:text => text, :chapname => name)
	end
end
raw_paras = DB[:paras].where(:bookid => bookid).all
paraids = []
raw_paras.each do |row_hash|
	paraids << row_hash[:id]
end
DB[:books].where(:id => bookid).update(:paras => paraids.join(','))
puts 'done!'
