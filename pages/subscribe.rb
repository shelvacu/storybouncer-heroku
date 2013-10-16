get '/subscribe/?' do 
  json = !params[:json].nil?
  if !session[:logged]
    return "{error:1}" if json #not logged in
    return "You're not logged in! Please use the back button and then sign in or sign up"
  elsif params[:bookid].nil? #or params[:chap].nil?
    return "{error:2}" if json #somethings terribly wrong
    return "There's something quite wrong here, most likely a broken link. Please notify me"
  else
    id = params[:bookid].to_i
    begin
      book = Book.new(id)
    rescue ItemDoesntExist
      return "{error:3}" if json
      return "That book doesn't exist#{id > 0 ? ' yet' : ''}!"
    end
    user = User.new(session[:userid])
    #user.subs << book unless user.subs.include?(book)
    DB[:subs].insert(user_id: user.id,
                     book_id: book.id) if DB[:subs].where(user_id: user.id,
                                                          book_id: book.id).count == 0
    return "{error:'none'}" if json
    redirect to "/book/#{id}#{params[:chap].nil? ? '' : '/'+params[:chap]}"
  end
end
