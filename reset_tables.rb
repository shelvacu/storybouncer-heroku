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
  Time        :ban => Time.at(0) #d-fault 2 epoch
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
