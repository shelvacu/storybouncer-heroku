require 'sinatra'
require 'digest/md5'
require './http-maker'
require 'sequel'
require 'pony'
require 'pp'
enable :sessions
set :session_secret, "pinkflufflyunicornsdancingonrainbowsgravyandtoastcaptainsparklestobuscuspewdiepie98impossiblethepianoguyslindseystirlingHISHE"
DB =  Sequel.connect(ENV['DATABASE_URL'] || 'postgres://localhost/mydb')
Pony.options = {
  :via => :smtp,
  :via_options => {
    :address => 'smtp.sendgrid.net',
    :port => '587',
    :domain => 'heroku.com',
    :user_name => ENV['SENDGRID_USERNAME'],
    :password => ENV['SENDGRID_PASSWORD'],
    :authentication => :plain,
    :enable_starttls_auto => true
  }
}
$site_name = "protected-brushlands-7337.herokuapp.com"
def valid_email?(email)
	return true unless email.match(/^\w*@\w*\.\w{2,5}(\.\w{2,5})?$/).nil?
	return false
end
def valid_username?(name)
	return true unless name.match(/^[\w_^ ]{1,20}$/).nil?
	return false
end
def makehtml(&block)
	h = HTMLMaker.new
	h.html{block.call(h)}
	return h.to_s
end
def template(pagename="missing title!",js = [],css = [],&block)
	css << '/main.css'
	return makehtml do |h|
		h.head do
			h.title{pagename}
			css.each do |name|
				h.link(:href => name,:rel => "stylesheet",:type => "text/css")
			end
			js.each do |name|
				h.script(:type => 'text/javascript',:src => name){}
			end
		end
		h.body do
			block.call(h)
			h.span(:style => "font-size:small;font-color:gray;"){"Created by and Copyright&copy; Shelvacu Vevevende"}
			h.span(:id => "donatelink") do
				h.a(:href => "/donate.fgh"){"Donate"}
			end
		end
	end
end
get '/' do
	$h = HTMLMaker.new
	$h.html do
		$h.head{$h.title{"Awesomeness?"}}
		$h.body do
			$h.h1(:id => 'awesome'){"The book game! Currently in development"}
			#$h.img(:src => "http://thelazy.info/wp-content/uploads/2010/12/hello-world-2-600x4011.jpg")
			if rand(2) == 0
				$h.h1(:style => "font-size:big;"){"It's your lucky day!"}
			end
		end
	end
	$h.to_s
end

get '/register.fgh' do
	template('register') do |h|
		h.div(:id => "signInBox",:style => "border:3px solid black;") do
			h.form(:method => "post") do
				h.h3{"Sign up for an account"}
				
				h.span{"Username:"}
				#o =  [('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten
				#string  =  (0...50).map{ o[rand(o.length)] }.join
				h.input(:type => 'test',:name => "username")
				
				h.span{"Email:"}
				h.input(:type => 'test',:name => "email")
				
				h.span{"Password:"}
				h.input(:type => 'test',:name => "password")
			end
		end
	end
end
get  /\/invalid\/(.*)\/(.*).fgh/ do |type,value|
	template("Invalid #{type}") do |h|
		h.h1{"\"#{value}\" is invalid. Please go back and try again"}
	end
end
post '/register.fgh' do
	#make sure all parameters are there
	template('registering') do |h|
		unless params[:username].nil? || params[:email].nil? || params[:password].nil?
			redirect "/invalid/username/#{params[:username]}" unless valid_username?(params[:username])
			redirect "/invalid/email/#{params[:email]}" unless valid_email?(params[:email])
			if DB[:users].where(:username => params[:username]).empty? && DB[:users].where(:email => params[:email]).empty?
				#username && email is availible
				o =  [('a'..'z'),('A'..'Z'),('0'..'9')].map{|i| i.to_a}.flatten
				email_verify_key  =  (0...10).map{ o[rand(o.length)] }.join
				DB[:users].insert(:username => params[:username],:pass => Digest::MD5.hexdigest(params[:password]), :email => params[:email], :emailver => email_verify_key)
				session[:logged] = true
				session[:username] = params[:username]
				#email availible, all good!
				verify_link = "http://#{$site_name}/verify.fgh?key=#{email_verify_key}"
				e = HTMLMaker.new
				e.body do
					e.span{"Please visit:"}
					e.a(:href => verify_link){"Here"}
					e.span{"To verify your account. <br />Alternatively, use the key \"#{email_verify_key}\" at #{$site_name}/verify.fgh"}
				end
				Pony.mail(	:from => "admin@protected-brushlands-7337.herokuapp.com",:to => params[:email],
							:subject => "your new account!", :html_body => e.to_s, 
							:body => "Please copy+paste this url into your browser: #{verify_link}\n\nOr, go to #{$site_name}/verify.fgh and enter the code #{email_verify_key.inspect}")
				h.h2{"Success :D"}
				h.h5{"Please close this window, then check your email: #{params[:email]}"}
			else
				#username/email taken
				h.h2{"I'm sorry, that username and/or email is already registered"}
				h.h5 do
					h << "Please choose a new one or "
					h.a(:href => "/login.fgh"){"Login"}
				end
			end
		else
			h.h2{"You seem to have submitted the form incorrectly. Please refresh and try again."}
		end
	end
end

get '/donate.fgh' do
	template("Donate!") do |h|
		h.div{"You have two options for donating:"}
		h.div do |h|
			h << "Donate to the server: Funds from here will go directly into keeping the site hosted and fast."
			h << File.read('./SiteDonatebutton')
		end
		h.hr
		h.div do |h|
			h << "Or, donate directly to me. This will go to things like the server(if needed) and caffeine to stay awake working on the site"
			h << File.read('./Donatebutton')
		end
	end
end

get '/login.fgh' do
	template("Login") do |h|
		if session[:logged]
			h.h2 do
				h << "You are already logged in as #{session[:username]}. Perhaps you want to"
				h.a(:href => "/logout.fgh"){"logout?"}
			end
		else
			h.form(:method => "post") do
				h << "Username:"
				h.input(:type => "text",:name => "username")
			
				h << "Password:"
				h.input(:type => "password",:name => "password")
			end
		end
	end
end

post '/login.fgh' do
	ret = "error" #this is default value; what it will return if ret is not set
	if params[:username].nil? || params[:password].nil?
		ret = template('Error') do |h|
			h.h3{"Form submit failed. Please refresh and try again"}
		end
	elsif DB[:users].where(:username => params[:username]).empty?
		ret = template('Username Incorrect'){|h| h.h2{"Username incorrect"}}
	elsif DB[:users].where(:username => params[:username],:password => Digest::MD5.hexdigest(params[:password]) ).empty?
		ret = template('Password Incorrect'){|h| h.h2{"Password incorrect"}}
	else
		userdata = DB[:users].where(:username => params[:username],:password => Digest::MD5.hexdigest(params[:password]) ).all[0]
		session[:logged] = true
		session[:username] = userdata[:username]
		session[:userid] = userdata[:id]
		ret = template('Login successful') do |h|
			h.h4{"Success"}
			h.span{"You are now logged in as #{session[:username]}"}
		end
	end
	ret
end

get '/logout.fgh' do
	session = {}
	template('Logged out'){|h| h.h2{"Successfully logged out"}}
end

get '/userinfo.fgh' do
	template("UserCP") do |h|
		h.span{DB[:users].where(:username => session[:username]).limit(1).all.pretty_inspect}
	end
end







