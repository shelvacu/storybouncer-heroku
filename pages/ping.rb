get '/ping/?' do
  "pong"
end

get '/ping/*/?' do |stuff|
  "pong #{stuff}"
end
