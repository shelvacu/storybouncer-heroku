require './local_sequel'

name = "The adventure(s) of Tommy Genericname"

firstpara = <<END
Once upon a time, there was a manish boy named Tommy Jenericnaem. He lived a long full life, and died of old age at 87 with a smile on his face. As per his will, he was buried in the ground without a coffin, and he slowly degraded, and became part of the grass around him. Later, this grass was eaten by a cow, who was slaughtered, and the beef produced was then put on a truck and driven to That Store Around The Corner, where Mommy Genericname was 'shopping' one fine day.

    Mommy pushed her cart around the corner, her feet pounding against the linelium. She had to win this race, she just HAD to. Her honour depended on --

    "AAHH!" *crash*

    /Oh dear, not again./ She had crashed into the meat stand, AGAIN.

    "You're gonna pay for that!"

    "Okay..." She payed for the perfectly fine meat that she had apparently ruined, figuring she'd make dinner with it tonight. Her racing adventures over, Mommy walked back to the car with her beef, and drove home.
    
    ...

   "Bleh, what is this stuff?" spat 24-year-old Tommy Genericname.

   "Did you put spinach in it again? I feel like I'm getting stronger"
END

puts 'loaded'

authid = DB[:users].where(:user => "shelvacu").all[0][:id]
chapsid = makearray
pparas = makearray
bookid = DB[:books].insert(:auth => authid, 
                  :chaps => chapsid, 
                  :endvotes => makearray,
                  :noendvotes => makearray,
                  :pparas => makearray,
                  :fin => false,
                  :pnames => makearray,
                  :name => nameid)
paras = makearray
chap1 = DB[:chaps].insert(:name => 'Chapter 1',
                          :paras => paras)
chapsid.insert(:val => chap1)
para = DB[:paras].insert(:auth => authid,
                         :an => "I don't even know man, it was just, whatever came to my head."
                         :text => firstpara,
                         :upvotes => makearray,
                         :downvotes => makearray)
paras.insert(:val => para)

puts "almost done!"

pparas.insert(:val => DB[:paras].insert(:auth => authid, 
                                        :an => "the 'youre' instead of 'your' is on purpose, so i can test the edit feature",
                                        :text => <<END
"OH MY GOD!!" screamed Mommy, "YOU'RE MUSCLES!"

"What are you--WBLAH!"

Tommy slowly realized that his muscles were bigger than normal human beings. He had begun to wonder why the table and his mother had gotten so small
END
                                        :upvotes => makearray,
                                        :downvotes => makearray)
puts "I /think/ it's done, but i have NO idea."
