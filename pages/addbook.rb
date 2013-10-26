get '/addbook/?' do
  template "Add Book!" do |h|
    if !session[:logged]
      h.h3 do 
        h << "You aren't logged in! Please "
        h.a(href: '/login'){"Login"}
        h << " or "
        h.a(href: '/register'){"Register"}
        h << " first."
      end
      next
    end
    h.form(action:'/addbook',method: 'post') do
      h.h2{"NEW BOOK"}
      h.br
      h.p{"What shall the extravagant name for your narraration be?"}
      h.input(type:'text',name:'bookname',style:'width:100%')
      h.br
      h.br
      h.p{"And the designation of the primary chapter shall be?"}
      h.input(type:'text',name:'chapname',style:'width:100%')
      h.br
      h.br
      h.p{"Now, fill the introduction with the glory of your writing!"}
      h.textarea(name:'paratext',class:'submitParaText'){}
      h.input(type:'submit',value:"Submit!")
    end
  end
end

post '/addbook/?' do 
  if @user.nil?
    return "You're not logged in. Please go back and login. Here's the stuff you typed in so you don't lose it:
name: #{params[:bookname]}
chapter name: #{params[:chapname]}
para: #{params[:paratext]}"
  end
  if [:bookname,:chapname,:paratext].any?{|o| params[o].nil? || params[o].empty?}
    return template("Adding failed") do |h|
      h.h3{"All forms must be filled out. Please go <a href='/addbook'>back</a>"}
      h.br
      h.span{"name: #{params[:bookname]}
chapter name: #{params[:chapname]}
para: #{params[:paratext]}"}
    end
  end
  para =
  Para.create(auth: @user,an:"",
              text: params[:paratext],
              upvotes: makearray,
              downvotes: makearray)
  chap = 
  Chap.create(paras: makearray,name: params[:chapname])
  chap.paras << para

  name =
  Name.create(auth: @user,
              name: params[:bookname],
              upvotes: makearray,
              downvotes: makearray,
              fin: false)
  book =
  Book.create(auth: @user,
              chaps: makearray,
              endvotes: makearray,
              noendvotes: makearray,
              pparas: makearray,
              fin: false,
              pnames: makearray,
              name: name)
  book.chaps << chap
  redirect to("/book/#{book.id}/1")
end
