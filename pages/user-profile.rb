get '/user/*/?' do |username| #User profiles! Oh man!
  user = User.from_name(username.downcase)
  error 404 if user.nil?
  safename = CGI.escapeHTML(user.name)
  #Get total number of votes
  rep = user.calc_reputation
  template(safename) do |h|
    h.span(id:'totalVotes'){rep.to_s}
    h.h1{safename}
    h.br
    h.h4{"More to come!"}
  end
end

