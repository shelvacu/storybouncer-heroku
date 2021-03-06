require './local_sequel'
DB.create_table :users do
	primary_key :id
	String 		:username
	String 		:pass 		#md5
	String 		:email
	String		:emailver	#code to verify email
	String		:rest,		:default => "" #HASHED reset code for reseting password.
	Integer 	:auth,  	:default => 0
	String 		:subs,  	:default => ""
	String 		:hist,  	:default => ""
	TrueClass 	:veri,  	:default => false
	Time 		:ban,		:default => Time.at(0)
	#String		:vparas,	:default => ""
	#String		:vbooks,	:default => ""
	#String		:vnames,	:default => ""
	String 		:other,		:default => ""
end

DB.create_table :paras do
	primary_key :id
	Integer 	:bookid
	Integer		:userid
	String		:an 		#author's note
	String		:text 		#actual paragraph text
	String		:chapname
	String		:upvotes  ,:default => ""			#Integer		:upvotes
	String		:downvotes,:default => ""			#Integer		:downvotes
	TrueClass	:newchap  ,:default => false
	TrueClass	:endchap  ,:default => false
	#Integer		:chapnum
end

DB.create_table :books do
	primary_key :id
	Integer		:userid
	Time		:timestamp
	String		:pparas, 	:default => ""
	String		:paras,  	:default => ""
	TrueClass	:finished,	:default => false
	String		:endvotes			#Integer		:endvotes,	:default => 0
	String		:noendvotes			#Integer 	:noendvotes,:default => 0
	String		:upvotes 	#added after; for when book is finished
	String		:downvotes	#see ^
	Integer		:numend,	:default => 99
	String		:name,		:default => ""
end

DB.create_table :names do
	primary_key	:id
	String		:name
	Integer		:bookid
	Integer		:userid
	String		:upvotes			#Integer		:upvotes	,:default => 0
	String		:downvotes			#Integer		:downvoted	,:default => 0
end
