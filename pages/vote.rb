get '/vote' do
  res = {status:"error"}
  return JSON(res) if params[:dir].nil? || params[:id].nil?
  direction = (params[:dir]=='1')
  if !session[:logged]
    res[:error] = 0 #not logged in
    return JSON(res)
  end
  para_id = params[:id].to_i
  begin
    para = Para.new(para_id)
  rescue ItemDoesntExist
    res[:error] = 1 #doesnt exist
  end
  user = User.new(session[:userid])
  #vote = para.re_vote(user,direction)
  para.upvotes.delete(user)
  para.downvotes.delete(user)
  if direction
    para.upvotes << user
    vote = true
  else
    para.downvotes << user
    vote = false
  end
  res[:status] = "success"
  res[:vote] = !!vote
  res[:id] = para_id
  res[:votes] = para.vote_count
  return JSON(res)
end
