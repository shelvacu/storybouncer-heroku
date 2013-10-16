get '/plain-ip' do
  "#{request.ip}"
end

get '/ip' do
  template("Your IP is #{request.ip}") do |h|
    h.h1{"#{request.ip}"}
  end
end
