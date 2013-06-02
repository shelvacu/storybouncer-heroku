require './local_sequel'
DB.create_table! :paras do
	primary_key :id
	Integer 	:auth
	String		:an 		#author's note
	String		:text 		#actual paragraph text
	Integer		:upvotes  #its an ID, remember that!
	Integer		:downvotes#^
	String  	:chapname, :default => nil
end

DB.create_table! :chaps do
  primary_key :id
  Integer     :paras
  String      :name
end

DB.create_table! :books do
	primary_key :id
	Integer     :auth
  Integer     :chaps #arr
  Integer     :endvotes #arr
  Integer     :noendvotes #arr
  Integer     :pparas #arr
  TrueClass   :fin
  Integer     :pnames #arr
  Integer     :name #ID of object
end

DB.create_table! :users do
  primary_key :id
  String      :user
  String      :pass
  String      :email
  String      :emailver
  TrueClass   :veri
  Integer     :subs #arr
  Integer     :hist #arr
  Integer     :auth,:default => 0 # 0:user 1:mod 2:admin 3:owner 4+:invalid
  Time        :ban ,:default => Time.at(0) #d-fault 2 epoch
end

DB.create_table! :names do
	primary_key	:id
  Integer     :auth#or
	String      :name
 	Integer	  	:upvotes #arr
 	Integer	  	:downvotes
  TrueClass   :fin #when voting ends
end

DB.create_table! :array do
  primary_key :id
end

DB.create_table! :sessi do
  primary_key :id
  Time :usetime
  Integer :userid
  String :useragent
  String :ip
  String :data
  TrueClass :lock
end

DB.tables.each do |table_name|
  DB.drop_table(table_name) if /array\d+/ === table_name
end

# DB.create_table! :notif do
#   primary_key :id
#   String :email
# end
