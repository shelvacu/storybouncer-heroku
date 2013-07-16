require 'sinatra'
require 'pp'

get '/' do
  params.pretty_inspect
end
