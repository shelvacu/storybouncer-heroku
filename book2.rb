require './local_sequel'

name = "*TEST*"
if DB[:users].where(:user => name).empty?
  DB[:users].insert(:user => name,
                    :pass => "666",
                    :email =>"thisisa@test.com",
                    :emailver => "33rf9w0fj93qw0d8jewa0fje8wafhdsu",
                    :veri => true,
                    :subs => makearray,
                    :hist => makearray)
end
user = DB[:users].where(:user => name)


                   
