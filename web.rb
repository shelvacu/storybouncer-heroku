require 'sinatra'
require 'digest/md5'
require './html-maker'
require './local_sequel'
require 'pony'
require 'pp'
require 'cgi' #SOOO MANY LIBRARIEZZZZZ!
enable :sessions
set :session_secret, "pinkflufflyunicornsdancingonrainbowsgravyandtoastcaptainsparklestobuscuspewdiepie98impossiblethepianoguyslindseystirlingHISHE"
set :show_exceptions, false

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
def makehtml#(&block)
	h = HTMLMaker.new
	h << "<!DOCTYPE html>\n"
	h.html{yield h}#block.call(h)}
	return h.to_s
end
#blarg
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
			h.div(:id => 'topbar') do
				h.img(:id => "toplogo",:src => '/smalllogo.gif')
				h.span(:id => 'stateinfo') do
					if session[:logged]
						h << "#{session[:username]} | "
						h.a(:href => '/usercp.fgh', :id => 'managelink'){"UserCP"}
					else
						h.a(:href => '/login.fgh', :id => 'managelink'){"Login"}
					end
				end
			end
			h.div(:id => 'mainContainer'){
				h.div(:id => 'main'){
					block.call(h)
				}
			}
			h.div(:id => "bottombar") do
				h.div(:id => "innerbottombar") do
					h.span(:id => "copy"){"Created by and Copyright &copy; Shelvacu Vevevende"}
					#h.span(:id => "donatelink") do
					h.a(:id => "donatelink",:href => "/donate.fgh"){"Donate"}
					#end
				end
			end
		end
	end
end
error do
	err = env['sinatra.error']
	Pony.mail(	:from => "error@protected-brushlands-7337.herokuapp.com",:to => "shelvacu@gmail.com", :subject => err.class.to_s,
				:body => "Current session:#{session.inspect}\n#{err.message}\n\n#{err.backtrace.join("\n")}" )
	template("Error") do |h|
		h.h3{"I'm sorry. There was an error. I have already been notified, so there's no need to email me. Thank you"}
	end
end
error 404 do
	template('Not Found') do |h|
		h.h1{"Oh noes! 404 Not found"}
		h.h4 do
			h << "Monkeys stole the page you were looking for. Perhaps you want to go "
			h.a(:href => '/'){"HOME?"}
		end
	end
end
get '/' do
	$h = HTMLMaker.new
	$h.html do
		$h.head{
			$h.title{"Storybouncer!"}
			$h.style{"img{margin:0px auto}"}	
		}
		$h.body do
			$h.img(:src => '/logo.gif')
			$h.h1(:id => 'awesome'){"Currently in development"}
			#$h.img(:src => "http://thelazy.info/wp-content/uploads/2010/12/hello-world-2-600x4011.jpg")
			if rand(2) == 0
				$h.h1(:style => "font-size:big;"){"It's your lucky day!"}
			end
		end
	end
	$h.to_s
end

get '/test.fgh' do
	template("Template tester 0.1") do |h|
		h.span{"This stuff appears inside the template!"}
	end
end

get '/register.fgh' do
	template('register') do |h|
		h.div(:id => "signInBox") do
			h.form(:method => "post") do
				h.h3{"Sign up for an account"}
				
				h.span{"Username:"}
				#o =  [('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten
				#string  =  (0...50).map{ o[rand(o.length)] }.join
				h.input(:type => 'text',:name => "username")
				h.br
				h.span{"Email:"}
				h.input(:type => 'text',:name => "email")
				h.br
				h.span{"Password:"}
				h.input(:type => 'password',:name => "password")
				h.br
				h.input(:type => 'submit', :value => 'Register')
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
				Pony.mail(	:from => "no-reply@protected-brushlands-7337.herokuapp.com",:to => params[:email],
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
=begin
get '/colors.fgh' do
	template('C0L0RZ!') do |h|
		'0369cf'.split('').each do |a|
			'0369cf'.split('').each do |b|
				'0369cf'.split('').each do |c|
					h.div(:style => 'background-color:#{a}#{b}#{c}'){a+b+c}
				end
			end
		end
	end
end
=end
get '/donate.fgh' do
	template("Donate!") do |h|
		h.style{"li{margin:5px;}ul{width:400px}"}
		h.h4(:style => 'width:300px;'){"You have two options for donating:"}
		h.ul do
			h.li do
				h << "Donate to the server: Funds from here will go directly into keeping the site hosted and fast."
				h << File.read('./SiteDonatebutton')
			end
			
			h.li do
				h << "Or, donate directly to me. This will go to things like the server(if needed) and caffeine to stay awake working on the site"
				h << File.read('./Donatebutton')
			end#templat
		end
	end
end

get '/login.fgh' do
	template("Login") do |h|
		if session[:logged]
			h.h2 do
				h << "You are already logged in as #{session[:username]}. Perhaps you want to "
				h.a(:href => "/logout.fgh"){"logout?"}
			end
		else
			h.form(:method => "post", :id => "loginForm") do
				h.table do
				h.tbody do
					h.tr do
						h.td{ h.span(:class => 'stuffdoer'){"Username:"} }
						h.td{ h.input(:type => "text",:name => "username",:id => "usernameBox") }
					end
					h.tr do
						h.td{ h.span(:class => 'stuffdoer'){"Password:"} }
						h.td{ h.input(:type => "password",:name => "password") }
					end
					h.tr do
						h.td{ h.input(:type => "submit") }
					end
				end
				end
			end
			h.script(:type => 'text/javascript') do
				h << "document.getElementById('usernameBox').focus();"
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
	elsif DB[:users].where(:username => params[:username],:pass => Digest::MD5.hexdigest(params[:password]) ).empty?
		ret = template('Password Incorrect'){|h| h.h2{"Password incorrect"}}
	else
		userdata = DB[:users].where(:username => params[:username],:pass => Digest::MD5.hexdigest(params[:password]) ).all[0]
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
	session.clear
	template('Logged out'){|h| h.h2{"Successfully logged out"}}
end

get '/usercp.fgh' do
	template("UserCP") do |h|
		if session[:logged]
			userinfo = DB[:users].where(:username => session[:username]).limit(1).all.first
			#h.span{DB[:users].where(:username => session[:username]).limit(1).all.pretty_inspect}
			h.table do
				h.tr do
					h.td(:class => 'left'){"Username:"}
					h.td(:class => 'right'){userinfo[:username]}
				end
				h.tr do
					h.td(:class => 'left'){"Password:"}
					h.td(:class => 'right'){"TODO - Reset"}
				end
				h.tr do
					h.td(:class => 'left'){"Email:"}
					h.td(:class => 'right'){userinfo[:email]}
				end
				h.tr do
					h.td(:class => 'left'){"Auth level:"}
					h.td(:class => 'right'){{0 => 'User',1 => 'Mod',2 => 'Admin',3 => 'Owner'}[userinfo[:auth]]}
				end
				h.tr do
					h.td(:class => 'left'){"Email Verified?:"}
					h.td(:class => 'right'){(userinfo[:veri] ? 'Yes' : 'No')}
				end
				h.tr do
					h.td(:class => 'left'){"Ban release date:"}
					h.td(:class => 'right') do
						if userinfo[:ban] > Time.now
							userinfo[:ban].strftime("%H:%Mhrs on %B %e, %Y")
						else
							"Not banned!"
						end
					end
				end
			end
		else
			h.span{"You are not logged in. &nbsp;"}
			h.a(:href => '/login.fgh'){"Login?"}
		end
	end
end

get '/verify.fgh' do
	template("Verify Email") do |h|
		if params[:key].nil?
			h.form(:method => 'get') do
				h.span{"Verification Key:"}
				h.input(:type => 'text',:name => 'key')
				h.input(:type => 'submit')
			end
		else
			users = DB[:users].where(:emailver => params[:key]).all
			if users.empty?
				h.h1{"Incorrect verification code"}
			else
				user = users.first
				if user[:veri]
					h.h1{"Already verified"}
				else
					DB[:users].where(:id => user[:id]).update(:veri => true)
					h.h2{"You have successfully been verified"}
					unless session[:logged]
						h.h4 do
							h << "You may want to "
							h.a(:href => "/login.fgh"){"Login"}
						end
					end
				end
			end
		end
	end
end
#=begin
get '/view/book.fgh' do #/view/book.fgh?id=blabla&chap=1
	log = ""
	error 404 if params[:id].nil?
	params[:id] = params[:id].to_i
	
	error 404 if DB[:books].where(:id => params[:id]).empty? # I should change both of these later, make a more useful message.
	params[:chap] = 1 if params[:chap].nil?
	params[:chap] = params[:chap].to_i
#log += "Assuming chap##{params[:chap]}\n"	
	book = DB[:books].where(:id => params[:id]).all.first
	paraids = book[:paras].split(',')
#log += "paraids = #{paraids.inspect}\n"
	paraids.collect!{|a| a.to_i}
#log += "paraids = #{paraids.inspect}\n"
	all_paras = DB[:paras].where(:id => paraids).all
	chap_num = 1
	paras = []
	chapname = 'nothing?'
	all_paras.each do |parainfo|
		paras << parainfo[:text] if chap_num == params[:chap]
		chapname = parainfo[:chapname]
		chap_num += 1 if parainfo[:newchap]
	end
	if book[:name].nil?
		name = 'book of awesome'
	else
		name = book[:name]
	end
	
	template("#{name} - Storybouncer") do |h|
		h.singletablerow do
			h.td(:class => 'prevContainer') do
				if params[:chap] > 1
					#h.div(:class => 'prevContainer') do
					['top','bottom'].each { |s|
						h.a(:href => "/view/book.fgh?id=#{params[:id]}&chap=#{params[:chap] - 1}",:id => "#{s}PrevButton"){"Prev"}
					}
					#end
				else
					h.div(:class => 'spacefiller'){}
				end
			end
			h.td do
				h.div(:id => 'storybody') do
					h.h2{CGI.escapeHTML(chapname)}
					h.br
					paras.each do |para|
						h.p(:class => 'paratext'){para}
						h.br
					end
				end
			end
			h.td(:class => 'nextContainer') do
				if params[:chap] < chap_num
					#h.div(:class => 'nextContainer') do
					['top','bottom'].each { |s|
						h.a(:href => "/view/book.fgh?id=#{params[:id]}&chap=#{params[:chap] + 1}",:id => "#{s}NextButton"){"Next"}
					}
					#end
				else
					h.div(:class => 'spacefiller'){}
				end
			end
		end
	end
end
#=end

#get '/except.fgh' do
#	this_is_not_a_real_method_and_will_raise_an_error
#end







