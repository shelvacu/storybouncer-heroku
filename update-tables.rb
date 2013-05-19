require './local_sequel'
# DB.create_table! :paras do
# 	primary_key :id
# 	Integer 	:auth
# 	String		:an 		#author's note
# 	String		:text 		#actual paragraph text
# 	Integer		:upvotes  #its an ID, remember that!
# 	Integer		:downvotes#^
# 	String  	:chapname, :default => nil
# end

DB.create_table :sessi do
  primary_key :id
  String      :key
  Time        :usetime
  Integer     :userid
  String      :useragent
  String      :ip
end
