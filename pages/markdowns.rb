get '/donate/?' do
  markdown :donate
end

get '/howitworks/?' do
  markdown :howitworks
end

get '/contact/?' do
  redirect to('/development')
end

get '/development/?' do
  markdown :development
end

get '/tos/?' do
  markdown :tos
end

