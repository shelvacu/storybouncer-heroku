require 'sinatra'
require 'pp'
enable :session

get '/' do
	pp session
	"Hi"
end
