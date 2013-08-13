require './local_sequel'
titles = <<END.split("\n")
Deep Bridge
The Last Force
Gate of Soul
The Rainbow's Touch
The Door of the Time
Years in th Scent
Bare Door
The Wild Soul
Dreamer of Legacy
The Alien's Wizard
The Witch of the Shores
Person in the Danger
END
if (storybot = User.from_name('StoryBot')).nil?
  storybot = User.create(user: "StoryBot",
                         pass: "*", #makes sure noone can login
                         email:"shelvacu+storybot@storybouncer.com",
                         emailver: "wsdfdgiueamfdwoieaihF67ewia",
                         veri: true,
                         hist: makearray)
end
titles.each do |title|
  nameid = DB[:names].insert(auth: storybot.id,
                             name: title,
                             upvotes: makearray,
                             downvotes: makearray)
  b = Book.create(auth: storybot,
                  name: nameid,
                  chaps: makearray,
                  endvotes: makearray,
                  noendvotes: makearray,
                  pparas: makearray,
                  pnames: makearray,)
  c1 = Chap.create(name: "Chapter 1")
  p  = Para.create(auth: storybot,
                   an: '',
                   text: "Once upon a time...",
                   upvotes: makearray,
                   downvotes: makearray)
  c1.paras << p
  b.chaps << c1
end
              
