require './local_sequel'

#DB[:users].insert(	:username => "*TEST*", :pass => "666", #note that this is the 'md5' hash, hence any password entered will never match. :D
#					:email => "testemail",:emailver => "wq23iujt4erofd9wu3rj4k5rotf09ifer43erfd09iknr", :veri => true)
dataset= DB[:users].where(:username => "*TEST*")
userid = dataset.all[0][:id]
=begin
chaps = {	"Chapter I:" => ["Note: This is ABSOLUTELY NOT an example of what books should look like on this site. In fact, it is close to an exact opposite.","Warning: The next chapter(page) contains material that is possibly very very very offensive. It's not porn, it's religous talk. You have been warned. Proceed at your own risk"],
			"Chapter 1:" => ["In case you couldn't tell, this is a test paragraph. As usuall, I really don't know what to write, so I'll freewrite. Except considering many people may eventually read this ILL DO IT ANYWAY. I change my mind a lot. I have a tulpa. I haven't made very good progress, but I have an idea that may help. If you're wondering what a tulpa is, it's an imaginary friend. Theres a whole community based around it, with plenty of good guides: tulpa.info.","And heres a second paragraph, yay! WOOOOOOOOOT! anyway, orange monkey eagle. ANYBODY WHO GETS THAT REFERENCE WILL RECEICE well not much really but who cares.","You know, I'm planning on just leaving this book just sitting on the site, forever and ever, even when it becomes big WHICH IT WILL OBVIOUSLY. And then I'd get lots of emails saying \"oh you have an imaginary friend ur so childish ur insane wtf u suk\" but whatever. Hopefully the people eager enough to dig around will be willing enough to look at the concept from a slightly less biased view. Half of you, get ready to be insulted. The other half, get ready to have the truth forcefully thrown in your face. If you don't like that, leave now and stop reading. YOU HAVE BEEN WARNED. Here it is:","When 5 people do something, it's a mental illness. When 1,000,000 people do something, it's a religon. In case you hadn't guessed, I'm atheist. I realize I'm not really freewriting, but whatever."],
			"Chapter A:" => ["Why the chapter change you say? BECAUSE I FELT LIKE also like I said it's a test and need multiple chapters to test correctly. Anyway, back to what I was talking about: I think it makes sense. If you haven't at least looked into the concept of a tulpa, do that now. I was raised mormon. After turning atheist, I still honestly wondered how other people could \"Feel the spirit\" It was a horrible flaw in my anti-theism","Note: there is a difference between 'atheist' and 'anti-theist'. Atheists (literally: not theist) don't believe in god, but don't neccisarily (spellcheck.state #=> :off) hate on other religons. Anti-theists DO neccisarily hate on other religons. I guess I'm kinda in the middle. Half my family is religous(and i still love them), yet I wish religon was rid of. It takes up to much time, is the simplest way to put it. AGH.","Back to what I was going to say: God is a tulpa. It makes sense! The personality is defined rigidly in the bible, and then people are pressured to 'pray' (narrate) and-(dun dun DUN)-have faith! The exact things that make a tulpa! Now it made sense to me! When people /thought/ they were talking to some being in the sky, they were actually talking to a person in their head. Now, I'm not saying this is bad. I talk to someone in my head too. But they need to understand that THEIR BRAIN CAN'T MAGICALLY CHANGE THE WORLD. Now, this can often be confused. Sometime people will pray that the food doesn't spoil, but just to be sure, they put it in the fridge. Then, when they bring it back out, it's not spoiled! Who do they thank? Not /themselves/, the person who bought the fridge, pays the energy bill, and thought to use the fridge. No, they thank GOD! The breadwinner works for 8hrs, buys the food with hard-earned money, and when it gets to the table, who do they thank? G.O.D. Not the person who worked hard to pay for and prepare the meal.","I apologize for the rant, but it /really/ pisses me off, just cause they thank a mind-being, instead of the person who worked hard for it."]}
=end
chaps = {"Chapter A" => ["This is a test chapter for a test book of test awesome!","It really is!"],"Chapter 1" => ["This is the REAL first chapter."], "Chapter I" => ["I AM THE REAL MASTER, I AM THE REAL FIRST. I AM...... CHAPTER I","All who follow me, I promise you prosperity, wealth, and happiness until you die. I would you all immortality if I could. But no one can. So follow me, and live a happy life, and die a happy death."]}
name = "The Very First Book."
authors_note = "JuSt A gOsHdArNeD TeSt LeAvE iT aLoNe!"

ts = Time.now
DB[:books].insert(:userid => userid, :timestamp => ts)
bookid = DB[:books].where(:userid => userid, :timestamp => ts).all[0][:id]
book = DB[:books].where(:id => bookid)

chaps.each do |name, paras|
	firstpara = paras.shift
	DB[:paras].insert(:bookid => bookid,:userid => userid,:an => authors_note,:text => firstpara, :chapname => name, :newchap => true)
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