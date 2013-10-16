post '/submitPara/?' do
  if not session[:logged]
    return "Error: not logged in"
  elsif params[:bookID].nil? || params[:mainText].nil?
    return "Error: not enough params"
  end
  user = User.new(session[:userid])
  begin
    book = Book.new(params[:bookID])
  rescue ItemDoesntExist
      return "Error: Book doesn't exist"
  end
  return "Error: Book is finished" if book.fin?
  return "Too long! (sorry!)" if params[:mainText].length > 10_000
  new_para = Para.create(:auth => user,
                         :an => "",
                         :text => params[:mainText],
                         :upvotes => makearray,
                         :downvotes => makearray)
  book.pparas << new_para
  params[:chapID] ||= 1
  params[:chapID] = params[:chapID].to_i
  redirect to("/book/#{params[:bookID]}/#{params[:chapID]}")
end

