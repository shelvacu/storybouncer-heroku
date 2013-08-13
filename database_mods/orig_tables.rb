require './local_sequel'

DB.drop_table(:subs) rescue nil
DB.drop_table(:book_tags) rescue nil

DB.create_table! :paras do
	primary_key :id, :index =>{:unique =>true}
	Integer 	:auth
	String		:an 		#author's note
	String		:text 		#actual paragraph text
	Integer		:upvotes  #its an ID, remember that!
	Integer		:downvotes#^
	String  	:chapname, :default => nil
end

DB.create_table! :chaps do
  primary_key :id, :index =>{:unique =>true}
  Integer     :paras
  String      :name
end

DB.create_table! :books do
	primary_key :id, :index =>{:unique =>true}
	Integer     :auth #or
  Integer     :chaps #arr
  Integer     :endvotes #arr
  Integer     :noendvotes #arr
  Integer     :pparas #arr
  TrueClass   :fin
  Integer     :pnames #arr
  Integer     :name #ID of object
end

DB.create_table! :users do
  primary_key :id, :index =>{:unique =>true}
  String      :user, :unique => true
  String      :pass
  String      :email, :unique => true
  String      :emailver
  TrueClass   :veri, :default => false
  Integer     :subs #arr
  Integer     :hist #arr
  Integer     :auth,:default => 0 # 0:user 1:mod 2:admin 3:owner 4+:invalid
  Time        :ban ,:default => Time.at(0) #d-fault 2 epoch
end

DB.create_table! :names do
	primary_key	:id, :index =>{:unique =>true}
  Integer     :auth#or
	String      :name
 	Integer	  	:upvotes #arr
 	Integer	  	:downvotes
  TrueClass   :fin, :default => false #when voting ends
end

DB.create_table! :tags do
  primary_key :id, :index =>{:unique => true}
  String :name #short, underscored name, eg 'really_awesome'
  String :fullname #eg 'Really Awesome'
  String :description, :default => "" # 'Something that is so awesome, it deserved this tag'
end

DB.create_table! :array do
  primary_key :id
end

DB.create_table! :subs do #used to manage subscriptions, ie relations of books to users.
  foreign_key :book_id, :books, :key => :id
  foreign_key :user_id, :users, :key => :id
end

DB.create_table! :book_tags do #relation between books and tags
  foreign_key :book_id, :books, :key => :id
  foreign_key :tag_id, :tags,  :key => :id
end

DB.tables.each do |table_name|
  DB.drop_table(table_name) if /array\d+/ === table_name
end

DB.create_table? :notif do
  primary_key :id
  String :email
end
