require './local_sequel'
require 'yaml'
# puts "THIS PROGRAM IS OBSELETE AND DOESN'T WORK!" 
username = "Arthur Conan Doyle"
dataset= DB[:users].where(:user => username)
DB[:users].insert(	:user => username, 
                    :pass => "666",
                    :email => "emailofadeadman",
                    :emailver => "wq23iujt4erofd9wu3rj4k5rotf09ifer43erfd09iknr", 
                    :veri => false) if dataset.empty?

userid = dataset.all[0][:id]
name = "The Adventures of Sherlock Holmes"
authors_note = ""

chaps = YAML::load(File.read('sherlock.yaml'))
chapsarr = makearray
nameid = DB[:names].insert(:auth => userid, :name => name, :fin => true)
bookid = DB[:books].insert(:auth => userid, 
                  :chaps => chapsarr, 
                  :endvotes => makearray,
                  :noendvotes => makearray,
                  :pparas => makearray,
                  :fin => true,
                  :pnames => makearray,
                  :name => nameid)
chapids = []
chaps.each do |key,val|
  paraid = DB[:paras].insert(:auth => userid,:an =>"",:text => val.join("\n"),:upvotes => makearray, :downvotes => makearray)
  paraarray = makearray
  getarray(paraarray).insert(:val => paraid)
  chapids << {:val => DB[:chaps].insert(:paras => paraarray, :name => key)}
end
getarray(DB[:books].where(:id => bookid).select(:chaps).all[0][:chaps]).multi_insert(chapids)
puts "all done!"
=begin
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
=end
