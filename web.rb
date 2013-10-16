require 'sinatra'
require 'digest'
require 'rufus/scheduler'
require './template'
require './local_sequel'
require './ping_self'
require './markdown-sinatra'
require 'pony'
require 'pp'
require 'yaml'
require 'cgi' #SOOO MANY LIBRARIEZZZZZ!
require 'json'
require 'rack/recaptcha'
require './check_migrations' #OH NO! CHECKING MIGRATIONS!
require './check_votes'
require './site_setup'

def valid_email?(email)
  #return true unless ENV['TESTING_ENV'].nil?
	return true unless email.match(/^\w*@\w*\.\w{2,5}(\.\w{2,5})?$/).nil?
	return false
end
def valid_username?(name)
	return true unless name.match(/^[\w_^\- ]{1,20}$/).nil?
	return false
end

before do
  if request.host == "storybouncer.com"
    redirect request.url.gsub("storybouncer.com","www.storybouncer.com"),301
  end
  @user = nil
  if session[:userid]
    begin
      user  = User.new(session[:userid])
      @user = user
      session[:user] = user.name
      session[:logged] = true
    rescue ItemDoesntExist
      session.clear
    end
  elsif session[:logged] #but NO userid!
    session.clear
  end
  if @user and @user.name.downcase == "epicricekakes"
    redirect to("/fuck-you-youre-banned")
  end
end

get '/fuck-you-youre-banned' do
  error 404 unless @user and @user.name.downcase == "epicricekakes"
  template("You are now banned.") do |h|
    h.h1("You are now banned.")
    h.p("If you wish to repeal your ban, please contact theGuy@storybouncer.com")
  end
end

Dir['./pages/*.rb'].each do |f|
  puts "Loading #{f}"
  require f
end
