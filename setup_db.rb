require './reset_tables'
require './add_sherlock'
#The awesome arthur conan doyle has the honour of account #1. Account #2 shall be given to ME :D
shel =
User.create(user: "shelvacu",
            pass: "244c58350056e2092beb2efa9827d3a0216d2ba1f1f20efa7fb9e6d994cc8caa",
            email:"shelvacu@gmail.com",
            emailver:"fenwuyafewtgbahnkl,gkeijauyhgtsyuhgijmwehbsdxcyuzgnjekwsfdznuixvcybhewrkjagdfzoigare8fsd*",
            veri: true,
            hist: makearray,
            auth: 3)
#And, then very first story shall be by DemonSoulHunter, the very first(and only) person to submit a story!
demon = 
User.create(user: "DemonSoulHunter",
            pass: "", #nothing, so that no password will match. xe'll have to reset it
            email: "demonsoulhunting@gmail.com",
            emailver: "@\#\$\%\^&*()abdyuavdtyevfteywuafvtewyaufve",
            veri: true,
            hist: makearray,
            auth: 0)
name = 
Name.create(auth: demon,
            name: "Will Charden",
            upvotes: makearray,
            downvotes: makearray)
book =
Book.create(auth: demon,
            chaps: makearray,
            endvotes: makearray,
            noendvotes: makearray,
            pparas: makearray,
            fin: false,
            pnames: makearray,
            name: name)
chap = 
Chap.create(paras: makearray,
            name: "Chapter 1")
paratext = <<END
Will Charden was desperate. He was poor, with no living relatives, and no friends either. The only things he had to his name were either stolen or given to him by his father, who had also been a thief. Among other things, he had a dark cloak which he wore almost all of the time; a simple dagger that was almost dull from usage that Will couldn't say he was proud of; and a lockpick that was also constantly in use. The only thing he was proud of was his magic; he had taught himself spells that he used to aid in thievery, and even enchanted his cloak to allow him to become invisible to all but those who gazed at him directly. Tonight was his boldest attempt at getting money yet. He was going to steal from the kingdom's treasury. He was already inside the palace, snooping around and listening to try to find out where his goal was located.
END
para =
Para.create(auth: demon,
            an: "",
            text: paratext,
            upvotes: makearray,
            downvotes: makearray)
chap.paras << para
book.chaps << chap
#okay! now, register official-sounding-names
File.read("official-sounding-names.txt").each_line do |line|
  line.chomp!
  User.create(user: line,
              pass: '',
              email: "#{line}@storybouncer.com",
              emailver: '',
              veri: true,
              hist: makearray,
              auth: 0) unless line.empty?
end
