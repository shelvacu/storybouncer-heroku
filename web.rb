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

##OH NO! CHECKING MIGRATIONS
Sequel.extension :migration
error = true
while error
  begin
    Sequel::Migrator.check_current(DB, './migrations')
    error = false
  rescue Sequel::Migrator::NotCurrentError
    puts "Migration is not current"
    sleep(10)
  end
end

check_votes = Rufus::Scheduler.start_new

check_votes.every '1m' do
  Book.all.each do |book|
    next if book.fin?
    numvotes = book.pparas.all.map{|o| o.votes}.flatten.uniq.length
    num_subs = DB[:subs].where(book_id: book.id).count
    if numvotes >= (num_subs*0.8)
      winning_para = book.pparas.all.map{|o| [o,o.vote_count]}.sort_by{|o| o[1]}.last[0]
      to_del = book.pparas.all
      to_del.each do |para|
        book.pparas.delete(para)
        unless para == winning_para
         DB[:paras].where(id: para.id).delete
        end
      end
      if winning_para.chapname.nil?
        book.chaps.last.paras << winning_para
      else
        c = Chap.create(name: winning_para.chapname,
                        auth: winning_para.auth)
        book.chaps << c
        c.paras << winning_para
      end
      #Now email everyone about the new paragraph that just came out!
      DB[:subs].where(book_id: book.id).all.each do |row|
        user_id = row[:user_id]
        user = User.new(user_id)
        if user.veri
          Pony.mail(to: user.email,
                    from: "admin@storybouncer.com",
                    subject: "New paragraph in #{book.strname}",
                    body: "Hey #{user.name}, the voting has ended and a new paragraph has been added! Go to http://www.storybouncer.com/book/#{book.id}/#{book.chaps.length}/ to see it! (copy+paste the url into your browser)",
                    html_body: makehtml do |h|
                      h.head{h.title{"New paragraph in #{CGI.escapeHTML(book.strname)}"}} #is this neccesary?
                      h.body do
                        h.span do 
                          "Hey #{CGI.escapeHTML(user.name)}, the voting has ended and a new paragraph has been added! Go to <a href=\"http://www.storybouncer.com/book/#{book.id}/#{book.chaps.length}/\">http://www.storybouncer.com/book/#{book.id}/#{book.chaps.length}/</a> to see it! (if the link doesn't work, copy+paste the url into your browser)"
                        end
                      end
                    end)
          #done!?
        end
      end
    end
  end
end

if DB.tables.empty? #database has not been generated, it needs to be
  require './reset_tables.rb'
end
enable :sessions
set :session_secret, "RAGEGAMINGVIDEOSpinkflufflyunicornsdancingonrainbowsgravyandtoastcaptainsparklestobuscuspewdiepie98impossiblethepianoguyslindseystirlingHISHE"
set :show_exceptions, development?
set :sessions, :expire_after => 172800 #2 days
use Rack::Deflater

use Rack::Recaptcha, 
:public_key  => "6LdFEOYSAAAAAA_6NyMPwmh1hyr4ASVtuCxLJGly",
:private_key => "6LdFEOYSAAAAAMnPVGsLJA-a7h5hQvO-DjT-YCZc"
helpers Rack::Recaptcha::Helpers

if not development?
  puts "ASSUMING ON PRODUCTION SERVER"
  Pony.options = {
    :via => :smtp,
    :via_options => {
      :address => 'smtp.sendgrid.net',
      :port => '587',
      :domain => 'storybouncer.com',
      :user_name => ENV['SENDGRID_USERNAME'],
      :password => ENV['SENDGRID_PASSWORD'],
      :authentication => :plain,
      :enable_starttls_auto => true
    },
    :from => "admin@storybouncer.com"
  }
else
  puts "assuming dev server"
  Pony.options = {
    :via => :smtp,
    :via_options =>  {
      :address              => 'localhost',
      :port                 => '1025',
    },
    :from => "admin@storybouncer.com" 
  }
  require 'sinatra/reloader'
  also_reload './template.rb'
end 

$site_name = "www.storybouncer.com"
$development = development?

def valid_email?(email)
  #return true unless ENV['TESTING_ENV'].nil?
	return true unless email.match(/^\w*@\w*\.\w{2,5}(\.\w{2,5})?$/).nil?
	return false
end
def valid_username?(name)
	return true unless name.match(/^[\w_^ ]{1,20}$/).nil?
	return false
end

error do
	err = env['sinatra.error']
  begin
    Pony.mail(:from => "error@storybouncer.com",
              :to => "shelvacu@gmail.com", 
              :subject => err.class.to_s,
              :body => "Current session:#{session.pretty_inspect}\nM:#{err.message}\n\n\n#{err.backtrace.join("\n")}" )
  rescue
  end
  begin
    template("Error") do |h|
      h.h3{"I'm sorry. There was an error. I have already been notified, so there's no need to email me. Thank you"}
    end
  rescue Exception => e
    "There's been a terrible error, please email me A.S.A.P. including the info below: info@storybouncer.com\nError info:\n#{e.message}\n\n#{e.backtrace}"
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
end

get '/ping/?' do
  'pong'
end

get '/' do
  redirect "/booklist"
  win = (rand(10)==0)
	h = HTMLMaker.new
  #h = h
  h << "<!DOCTYPE HTML>"
	h.html do
		h.head{
			h.title{"Storybouncer!"}
      h << "<meta charset=\"UTF-8\">"
			h.style{"img{margin:0px auto}
.desc{
		width:400px;
		margin-right:auto;
		margin-left:auto;
		font-family:sans-serif;
}"}	
		}
		h.body("style" => 'text-align:center') do
      h.div do

        h.img(:src => '/logo.gif', :alt => "Storybouncer")
        # $h.h1(:id => 'awesome'){"Currently in development"}
        #if win
        #  $h.h1(:style => "font-size:big;"){"It's your lucky day!"}
        #end
      end
      h.h1{"Writing. Crowdsourced."}
      h.a(href:'/booklist'){h.h3{"Click here to get started!"}}
		end
	end
	h.to_s
end

post '/' do
  makehtml do |h|
    h.h2 do
      if params[:email].nil?
        "YOU DID IT WRONG! D:"
      elsif params[:email] == ""
        "Oh! Your email is \"\"? Don't worry, you're already on our list!\n(you didn't enter an email)"
      elsif not /.*@.*\..*/ === params[:email]
        "That doesn't look like a valid email."
      elsif params[:email] == "@."
        "Haha, very funny."
      else
        DB[:notif].insert(:email => params[:email])
        "Thanks! You will be notified when Storybouncer is released!"
      end
    end
  end
end

get '/test/?' do
	template("Template tester 0.1") do |h|
		h.span{"This stuff appears inside the template!"}
	end
end

get '/register/?' do
	template('register') do |h|
		h.div(:id => "signInBox") do
			h.form(:method => "post") do
				h.h3{"Sign up for an account"}
				
				h.span{"Username:"}
				#o =  [('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten
				#string  =  (0...50).map{ o[rand(o.length)] }.join
				h.input(:type => 'text',:name => "user")
				h.br
				h.span{"Email:"}
				h.input(:type => 'text',:name => "email")
				h.br
				h.span{"Password:"}
				h.input(:type => 'password',:name => "pass")
				h.br
        h << recaptcha_tag(:challenge)
        h.br
        h.span(style: 'font-size:10px') do
          h << "By clicking the \"Register\" button, you agree to the "
          h.a(href: '/tos/'){"Terms of Service"}
        end
        h.br
				h.input(:type => 'submit', :value => 'Register')
			end
		end
	end
end
#get  /\/invalid\/(.*)\/(.*)\/?/ do |type,value|
#	template("Invalid #{type}") do |h|
#		h.h1{"\"#{value}\" is invalid. Please go back and try again"}
#	end
#end
post '/register/?' do
	#make sure all parameters are there
	template('Registering') do |h|
		unless params[:user].nil? || params[:email].nil? || params[:pass].nil?
      next "Invalid captcha" unless recaptcha_valid?
      next "Invalid username '#{CGI.escapeHTML(params[:user])}'" unless valid_username?(params[:user])
      next "Invalid email '#{CGI.escapeHTML(params[:email])}'" unless valid_email?(params[:email])
			if DB[:users].where("lower(user) = ?",params[:user].downcase).empty? && DB[:users].where("lower(email) = ?",params[:email].downcase).empty?
				#username && email is availible
				o =  [('a'..'z'),('A'..'Z'),('0'..'9')].map{|i| i.to_a}.flatten
				email_verify_key  =  (0...40).map{ o[rand(o.length)] }.join
				DB[:users].insert(:user => params[:user],
                          :pass => Digest::SHA256.hexdigest(params[:pass]), 
                          :email => params[:email], 
                          :emailver => email_verify_key,
                          :hist => makearray,
                          :auth => 0)
				#email availible, all good!
				verify_link = "http://#{$site_name}/verify?key=#{email_verify_key}"
				e = HTMLMaker.new
				e.body do
					e.span{"Please visit:"}
					e.a(:href => verify_link){"#{verify_link}"}
					e.span{"To verify your account. <br />Alternatively, use the key \"#{email_verify_key}\" at #{$site_name}/verify"}
				end
				Pony.mail(:from => "no-reply@storybouncer.com",
                  :to => params[:email],
                  :subject => "Your new storybouncer account!", 
                  :html_body => e.to_s, 
                  :body => "Please copy+paste this url into your browser: \
#{verify_link}\n\nOr, go to #{$site_name}/verify and enter the code \
#{email_verify_key.inspect}") #unless $development
				h.h2{"Success :D"}
				h.h5{"Please close this window, then check your email: #{params[:email]}"}
			else
				#username/email taken
				h.h2{"I'm sorry, that username and/or email is already registered"}
				h.h5 do
					h << "Please choose a new one or "
					h.a(:href => "/login"){"Login"}
				end
			end
		else
			h.h2{"You seem to have submitted the form incorrectly. Please refresh and try again, or get a different browser. If nothing works, my site is probably broken; please email me: theGuy@storybouncer.com"}
		end
	end
end

get '/colors' do
	template('C0L0RZ!') do |h|
    h.style{<<EEND
#main{
background: #e5e5e5; /* Old browsers */
background: -moz-linear-gradient(top,  #e5e5e5 0%, #000000 99%); /* FF3.6+ */
background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#e5e5e5), color-stop(99%,#000000)); /* Chrome,Safari4+ */
background: -webkit-linear-gradient(top,  #e5e5e5 0%,#000000 99%); /* Chrome10+,Safari5.1+ */
background: -o-linear-gradient(top,  #e5e5e5 0%,#000000 99%); /* Opera 11.10+ */
background: -ms-linear-gradient(top,  #e5e5e5 0%,#000000 99%); /* IE10+ */
background: linear-gradient(to bottom,  #e5e5e5 0%,#000000 99%); /* W3C */
filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#e5e5e5', endColorstr='#000000',GradientType=0 ); /* IE6-9 */
}
EEND
    }
		'0369cf'.split('').each do |a|
			'0369cf'.split('').each do |b|
				'0369cf'.split('').each do |c|
					h.div(:style => "background-color:##{a}#{b}#{c};width:100px;font-family:monospace;"){"#"+a+b+c}
				end
			end
		end
    nil
	end
end

get '/donate/?' do
  markdown :donate
end

get '/login/?' do
	template("Login") do |h|
		if session[:logged]
			h.h2 do
				h << "You are already logged in as #{session[:user]}. Perhaps you want to "
				h.a(:href => "/logout"){"logout?"}
			end
		else
			h.form(:method => "post", :id => "loginForm") do
				h.table(class:'center') do
          h.tbody do
            h.tr do
              h.td{ h.span(:class => 'stuffdoer'){"Username:"} }
              h.td{ h.input(:type => "text",:name => "user",:id => "usernameBox") }
            end
            h.tr do
              h.td{ h.span(:class => 'stuffdoer'){"Password:"} }
              h.td{ h.input(:type => "password",:name => "pass") }
            end
            h.tr do
              h.td do
                h.input(:type => "submit",:style => "float:right;")
              end
              h.td do
                h.a(:href => "/emailreset",style:'font-size:10px'){"Forgot password?"}
              end
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

post '/login/?' do
	ret = "error" #this is default value; what it will return if ret is not set
	if params[:user].nil? || params[:pass].nil?
		return template('Error') do |h|
			h.h3{"Form submit failed. Please refresh and try again"}
		end
  end
  dataset = DB[:users].where("lower(\"user\") = ?",params[:user].downcase)
	if dataset.empty?
		ret = template('Username Incorrect'){|h| h.h2{"Username incorrect"}}
	elsif dataset.where(:pass => Digest::SHA256.hexdigest(params[:pass]) ).empty?
		ret = template('Password Incorrect'){|h| h.h2{"Password incorrect"}}
	else
		userdata = dataset.first
		session[:logged] = true
		session[:user] = userdata[:user]
		session[:userid] = userdata[:id]
		ret = template('Login successful') do |h|
			h.h4{"Success"}
			h.span{"You are now logged in as #{session[:user]}"}
		end
	end
	ret
end

get '/logout/?' do
	session.clear
	template('Logged out'){|h| h.h2{"Successfully logged out"}}
end

get '/usercp/?' do
	template("UserCP") do |h|
		if session[:logged]
			userinfo = DB[:users].where(:user => session[:user]).limit(1).all.first
      if userinfo.nil?
        session.clear
        error 404
      end
			#h.span{DB[:users].where(:user => session[:user]).limit(1).all.pretty_inspect}
			h.table do
				h.tr do
					h.td(:class => 'left'){"Username:"}
					h.td(:class => 'right'){userinfo[:user]}
				end
				h.tr do
					h.td(:class => 'left'){"Password:"}
					h.td(:class => 'right') do
            h.form(method: 'post',action: '/resetpass',style:'border:2px solid black;padding-right:3px;') do
              h.table do
                h.tr do
                  h.td(class: 'left'){"Current password:"}
                  h.td do 
                    h.input(type: 'password',name: 'current')
                  end
                end
                h.tr do
                  h.td(class: 'left'){"New password:"}
                  h.td do 
                    h.input(type: 'password',name: 'new')
                  end
                end
                h.tr do
                  h.td(class: 'left'){"Repeat new password:"}
                  h.td do 
                    h.input(type: 'password',name: 'new2')
                  end
                end
                h.tr do
                  h.td do
                    h.input(type: 'submit',value:'Reset Password')
                  end
                end
              end
            end
          end
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
						#if userinfo[:ban] > Time.now
						#	userinfo[:ban].strftime("%H:%Mhrs on %B %e, %Y")
						#else
							"Not banned!"
						#end
					end
				end
			end
		else
			h.span{"You are not logged in. &nbsp;"}
			h.a(:href => '/login'){"Login?"}
		end
	end
end

post '/resetpass/?' do
  if !session[:logged]
    "you must log in!"
  else
    [:current,:new,:new2].each do |name|
      return "WeIrd Error occured. Make sure you're using the user control panel (click on your name) to access this page" if params[name].nil?
    end
    if params[:new] != params[:new2]
      return "New password and password confirmation do not match!"
    end
    user = User.new(session[:userid])
    if user.pass == Digest::SHA256.hexdigest(params[:current])
      user.pass = Digest::SHA256.hexdigest(params[:new])
      return template("Success!") do |h| 
        h << "Your password has been changed."
        h.a(href: '/usercp'){"Go back."}
      end
    else
      return "The provided password is not your current password. Please go back and try again"
    end
  end
end

get '/emailreset/?' do
  template("Reset password") do |h|
    h.div{"If you ever forget your password, you can send a reset link to your email address if your email is verified. If you have not verified your email, you can email me at theGuy@storybouncer.com"}
    h.form(method:'post',action:'/emailreset') do
      h.label(for: 'emailBox'){"Email:"}
      h.input(type:'text',name:'email',id:'emailBox')
      h.input(type:'submit',value:'Submit')
    end
  end
end

post '/emailreset/?' do
  return "Error, make sure you are accessing this page from /emailreset and have submitted the form correctly" if params[:email].nil?
  return "You're already logged in! Why do you need to recover a password?\
  If it's for a different account, please go back and logout first" if session[:logged]
  set = DB[:users].where("lower(email) = ?", params[:email].downcase)
  if set.count == 0
    return "An account under the email \"#{params[:email]}\" does not exist."
  else
    user = User.new(set.first[:id])
    if !user.veri
      return "You're not verified! (sorry)\n\
You need to either\n\
 - Find the verification email that was sent to you, and click the link. Check your spam and junk folder\n\
or\n\
 - Contact me from the email registered with your account at admin@storybouncer.com"
    end
    o = [('a'..'z'),('A'..'Z'),('0'..'9')].map{|i| i.to_a}.flatten
    reset_code = (0...50).map{ o[rand(o.length)] }.join
    user.reset = reset_code
    visit_link = "http://www.storybouncer.com/finalreset?id=#{user.id}&code=#{reset_code}"
    html_body = makehtml do |h|
      h.body do
        h.div{"Dear #{CGI.escapeHTML(user.name)},"}
        h.br
        h.div{"You have requested for you password to be reset for your account on storybouncer.com"}
        h.div{"Please visit:"}
        h.a(href: visit_link){visit_link}
        h.div{"To reset your password. (if the link doesn't work, just copy+paste the url into your browser)"}
      end
    end
    Pony.mail(to: user.email,
              from: 'admin@storybouncer.com',
              subject: "Request to reset the password for your account at storybouncer.com",
              body: "Dear #{user.name},

You have requested for your password to be reset for your account on storybouncer.com
Please copy+paste this link into your browser:
#{visit_link}",
              html_body: html_body)
    template("Success!") do |h|
      h.p{"Email successfully sent! Please close this window, then check your email, #{user.email}"}
    end
  end
end

get '/finalreset/?' do
  if params[:code].nil? || params[:id].nil?
    return "Why did you come here?"
  else
    begin
      user = User.new(params[:id].to_i)
    rescue ItemDoesntExist
      return "merg"
    end
    if user.reset != nil && user.reset == params[:code]
      template("reset") do |h|
        h.form(action:'/finalreset',method:'post') do 
          h.label(for:'new'){"New password:"}
          h.input(type:'password',name:'new',id:'new')
          h.br
          h.label(for:'new2'){"Reenter new password:"}
          h.input(type:'password',name:'new2',id:'new2')
          h.br
          h.input(type:'submit',value:'Submit!')
          h.input(type:'hidden',name:'id'  ,value: params[:id].to_i)
          h.input(type:'hidden',name:'code',value: CGI.escapeHTML(params[:code]))
        end
      end
    end
  end
end

post '/finalreset/?' do
  if params[:id].nil? || params[:code].nil? || params[:new].nil? || params[:new2].nil?
    return "merg"
  end
  if params[:new] != params[:new2]
    return template("Reset password") do |h|
      h << "The passwords you entered do not match. Please go back and try again."
    end
  end
  row = DB[:users].where(id: params[:id].to_i,reset: params[:code]).first
  if row.nil?
    return "Something went wrong. Please re-send the reset email using http://www.storybouncer.com/emailreset"
  end
  user = User.new(row[:id])
  user.pass = Digest::SHA256.hexdigest(params[:new])
  session[:userid] = user.id
  session[:user] = user.name
  session[:logged] = true
  template("Password Reset!") do |h|
    h << "Password successfully reset! You've been logged in."
  end
end

get '/verify/?' do
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
							h.a(:href => "/login"){"Login"}
						end
					end
				end
			end
		end
	end
end

get '/view/book/?' do
  red = URI('/book')
  red.query = URI.encode_www_form(params)
  redirect to(red.to_s)
end

get '/book/?' do 
  redirect to('/booklist') if params[:id].nil?
	params[:id] = params[:id].to_i
  params[:chap] ||= 1
  params[:chap] = params[:chap].to_i
  redirect to("/book/#{params[:id]}/#{params[:chap]}")
end

get '/book/*/' do |book_id|
  redirect to("/book/#{book_id}/1")
end

get '/book/*/*/?' do |book_id,chap_id| #/book/id/chap
	log = ""
  book_id = book_id.to_i
  chap_id = chap_id.to_i
  chap_num = chap_id
  
  if book_id >= 2147483648 || chap_id >= 2147483648 
    error 404
  end
  
  begin
    book = Book.new(book_id)
  rescue ItemDoesntExist
    error 404
  end
	#book = DB[:books].first(:id => params[:id])
  #chaps = getarray(book[:chaps])
  #chap_id = chaps.order_by(:val).limit(1,chap_num-1).all[0][:val]
  chap = book.chaps[chap_id - 1] #DB[:chaps].where(:id => chap_id).all.first
  error 404 if chap.nil?
  name = chap.strname
  name = CGI.escapeHTML(name)
  book_name = CGI.escapeHTML(book.strname)
  paras = chap.paras.all

  last_chapter = chap_num >= book.chaps.count-1
  pparas = book.pparas.all_order_rand# if last_chapter
  fin  = book.fin?
  
  subbed = false
  if session[:logged]
    user = User.new(session[:userid])
    subbed = (user.subs_dataset.where(book_id: book_id).count > 0)
  end

	template("#{book_name}",'/vote.js') do |h|
    h.div(:id => 'storybody') do
      prevnext = Proc.new do
        h.div(class: "prevnext") do
          if chap_num > 1
            h.a(href: "/book/#{book_id}/#{chap_num - 1}",class:"navButton prevButton"){"Prev"}
          end
          if chap_num < book.chaps.count
            h.a(href: "/book/#{book_id}/#{chap_num + 1}",class:"navButton nextButton"){"Next"}
          end
        end
      end
      bar = Proc.new do #no, not as in foobar, as in the bar at the top of the page
        h.div(class: 'storybar') do
          h.a(:class => "#{subbed ? 'subbed' : 'unsubbed'} subscribe",
              :href => "/subscribe?bookid=#{book_id}&chap=#{chap_num}",
              :style => "visibility:#{session[:logged] ? 'visible' : 'hidden'}") do
            h.img(src:"/mail-image.png",
                  height:15)
            h << "Subscribe to this book!"
          end
          h.h3(:class => 'storyname'  ){CGI.escapeHTML(book_name)}
          h.h4(:class => 'chaptername'){name}
        end
      end
      prevnext.call
      bar.call
      h.br
      paras.each do |para|
        h.div(class: 'paracontainer') do
          h.p(class:'paratext') do
            CGI.escapeHTML(para.text).gsub("\n","<br/>")
          end
          h.div(class:'paraAuthor') do
            CGI.escapeHTML(para.auth.name)
          end
        end
        h.br
      end
      h.hr
      if !fin && last_chapter
        if session[:logged]
          user = @user
        end
        pparas.each do |para|
          count = para.vote_count
          #if count > 0
          #  color = "#0f0" #green
          #else
          #end 
          h.div(class:'pparaContainer',id:"ppara#{para.id}") do
                h.p(:class => 'pparaText') do
              CGI.escapeHTML(para.text).gsub("\n","<br />")
            end
            h.br
            h.div(:class => 'pparaFooter') do 
              h.span(:class => 'pparaVote') do
                size = 25
                h.img(:src => '/upvote.png',
                      :width  => size,
                      :height => size,
                      :class => 'voteImage upVote'+(!user.nil? && para.upvotes.include?(user) ? " votedImage" : ''),
                      :onclick => "vote(#{para.id},true,this)")
                h.img(:src => '/downvote.png',
                      :width  => size,
                      :height => size,
                      :class => 'voteImage downVote'+(!user.nil? && para.downvotes.include?(user) ? " votedImage" : ''),
                      :onclick => "vote(#{para.id},false,this)")
              end
              h.div(:class => "voteCount " +
                    (count>0 ? "votePositive" : "voteNegative")) do
                count.to_s
              end
              h.div(:class => 'pparaAuthorContainer') do
                h << "by "
                h.span(:class => 'pparaAuthor') do 
                  CGI.escapeHTML(para.author.name)
                end
              end
            end
          end
        end
        
        h.div(:class => 'addsuggested') do
          if not session[:logged]
            h.h5{"Please login to suggest a new paragraph"}
          else
            h.form(:id => 'addParaForm',
                   :action => '/submitPara',
                   :method => 'post') do
              h.h5{"Suggest your own paragraph!"}
              h.textarea(:name => 'mainText',
                         :class => 'submitParaText'){}
              h.input(:type => 'submit',
                      :name => 'submit',
                      :value => 'Submit!',
                      :class => 'submitParaSubmit')
              h.input(:type => "hidden",
                      :name => "bookID",
                      :value =>"#{book_id}")
              h.input(:type => "hidden",
                      :name => "chapID",
                      :value =>"#{chap_num}")
              #thing
            end
          end
        end
      end
      bar.call
      prevnext.call
    end
  end
end

get '/book/*/?' do |book_id|
  redirect to("/book/#{book_id.to_i}/1")
end

post '/submitPara' do
  if not session[:logged]
    return "Error: not logged in"
  elsif params[:bookID].nil? || params[:mainText].nil?
    return "Error: not enough params"
  end
  user = User.new(session[:userid])
  begin
    book = Book.new(params[:bookID])
  rescue ItemDoesntExist
      return "Error: Book doesn't exist"
  end
  return "Error: Book is finished" if book.fin?
  return "Too long! (sorry!)" if params[:mainText].length > 10_000
  new_para = Para.create(:auth => user,
                         :an => "",
                         :text => params[:mainText],
                         :upvotes => makearray,
                         :downvotes => makearray)
  book.pparas << new_para
  params[:chapID] ||= 1
  params[:chapID] = params[:chapID].to_i
  redirect to("/book/#{params[:bookID]}/#{params[:chapID]}")
end

get '/subscribe' do 
  json = !params[:json].nil?
  if !session[:logged]
    return "{error:1}" if json #not logged in
    return "You're not logged in! Please use the back button and then sign in or sign up"
  elsif params[:bookid].nil? #or params[:chap].nil?
    return "{error:2}" if json #somethings terribly wrong
    return "There's something quite wrong here, most likely a broken link. Please notify me"
  else
    id = params[:bookid].to_i
    begin
      book = Book.new(id)
    rescue ItemDoesntExist
      return "{error:3}" if json
      return "That book doesn't exist#{id > 0 ? ' yet' : ''}!"
    end
    user = User.new(session[:userid])
    #user.subs << book unless user.subs.include?(book)
    DB[:subs].insert(user_id: user.id,
                     book_id: book.id) if DB[:subs].where(user_id: user.id,
                                                          book_id: book.id).count == 0
    return "{error:'none'}" if json
    redirect to "/book/#{id}#{params[:chap].nil? ? '' : '/'+params[:chap]}"
  end
end
    
    

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

get '/user/*/?' do |username| #User profiles! Oh man!
  user = User.from_name(username.downcase)
  error 404 if user.nil?
  safename = CGI.escapeHTML(user.name)
  #Get total number of votes
  total_votes = 0
  paras_written = DB[:paras].where(auth: user.id).all
  paras_written.each do |para|
    total_votes += Para.new(para[:id]).vote_count
  end
  template(safename) do |h|
    h.h1{safename}
    h.span(id:'totalVotesLabel'){"Awesomeness: "}
    h.span(id:'totalVotes'){total_votes.to_s}
    h.br
    h.h4{"More to come!"}
  end
end

get '/howitworks/?' do
  markdown :howitworks
end

get '/booklist/?' do 
  template('ALL the books!') do |h|
    h.div(class: 'booklist') do
      h.a(id: 'howitworkslink',href:'/howitworks'){"How it works"}
      h.br
      Book.all.each do |book|
        h.div(class: 'booklisting') do
          
          h.span(class:'bookimgContainer') do
            h.a(:class => '',:href => "/book/#{book.id}") do
              h.img(src: "/plain_book.png",width: 120,height: 120, class: "bookimg")
            end
          end
          h.span(class: 'booklinkContainer') do
            h.a(:class => 'fulllink booklink',:href => "/book/#{book.id}") do
              CGI.escapeHTML(book.namestr)
            end
          end
        end
      end
      nil
      if session[:logged]
        h.span{"Would you like to start your own book?"}
        h.a(href:'/addbook/'){"Click here."}
      end
    end
  end
end

get '/addbook/?' do
  template "Add Book!" do |h|
    if !session[:logged]
      h.h3 do 
        h << "You aren't logged in! Please "
        h.a(href: '/login'){"Login"}
        h << " or "
        h.a(href: '/register'){"Register"}
        h << " first."
      end
      next
    end
    h.form(action:'/addbook',method: 'post') do
      h.h2{"NEW BOOK"}
      h.br
      h.p{"What shall the extravagant appellation(name) for your narraration be?"}
      h.input(type:'text',name:'bookname',style:'width:100%')
      h.br
      h.br
      h.p{"And the designation of the primary chapter shall be?"}
      h.input(type:'text',name:'chapname',style:'width:100%')
      h.br
      h.br
      h.p{"Now, fill the introduction with the glory of your writing! (Write the beggining of the story)"}
      h.textarea(name:'paratext',class:'submitParaText'){}
      h.input(type:'submit',value:"Submit!")
    end
  end
end

post '/addbook/?' do 
  if @user.nil?
    return "You're not logged in. Please go back and login. Here's the stuff you typed in so you don't lose it:
name: #{params[:bookname]}
chapter name: #{params[:chapname]}
para: #{params[:paratext]}"
  end
  if [:bookname,:chapname,:paratext].any?{|o| params[o].nil? || params[o].empty?}
    return template("Adding failed") do |h|
      h.h3{"All forms must be filled out. Please go <a href='/addbook'>back</a>"}
      h.br
      h.span{"name: #{params[:bookname]}
chapter name: #{params[:chapname]}
para: #{params[:paratext]}"}
    end
  end
  para =
  Para.create(auth: @user,an:"",
              text: params[:paratext],
              upvotes: makearray,
              downvotes: makearray)
  chap = 
  Chap.create(paras: makearray,name: params[:chapname])
  chap.paras << para

  name =
  Name.create(auth: @user,
              name: params[:bookname],
              upvotes: makearray,
              downvotes: makearray,
              fin: false)
  book =
  Book.create(auth: @user,
              chaps: makearray,
              endvotes: makearray,
              noendvotes: makearray,
              pparas: makearray,
              fin: false,
              pnames: makearray,
              name: name)
  book.chaps << chap
  redirect to("/book/#{book.id}/1")
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

=begin
get "/routes/?" do
	routes = Sinatra::Application.routes
	pages = Hash.new{|j,k| j[k]=[]} #"blarg" => ["GET","POST"]
	routes.each do |key,val|
		val.each do |route|
			re_name = route[0]
			raw_name = re_name.inspect
			name = raw_name.gsub("/^\\/","/").gsub("(?:\\.|%2E)",".").gsub("$/",'')
			pages[name] << key
		end
	end
	Dir["./public/**/*"].each do |fn|
		fn.gsub!(/^\.\/public/,'')
		pages[fn] << "GET"
	end
	template("Index of pages") do |h|
		h.table do
		h.tbody do
			pages.each do |key,val|
				h.tr do
					h.td do
						h << key
					end
					h.td do
						h << val.join(',')
					end
				end
			end
		end
		end
	end
end
=end

get '/plain-ip' do
  "#{request.ip}"
end
get '/ip' do
  template("Your IP is #{request.ip}") do |h|
    h.h1{"#{request.ip}"}
  end
end
get '/db/dump.json' do
  error 404 unless params[:pass] == "OMGthisIsAsoupers33cr3tp4sswordOMG"
  content_type 'application/json', :encoding => "utf-8"
  tables = DB.tables
  hash_db = Hash[ tables.zip( tables.map{|t| DB[t].all} ) ]
  JSON.generate(hash_db)
end

get '/trippy/?' do
  makehtml do |h|
    h.head do 
      h.title{"OMG"}
      ['reset.css','omg.css'].each do |name|
				h.link(:href => name,:rel => "stylesheet",:type => "text/css")
			end
      nil
    end
    
    h.body do
      h.div(id:"omg1"){}
      h.div(id:"omg2"){}
    end
  end
end

#TIME TO DEMO DAY
get '/ttdd/?' do
  redirect to("/ttdd/index.html")
end

get /\/pres(entation)?\/?/ do
  redirect "https://docs.google.com/presentation/d/19O433yWFCwCEw8nBJzySqGAVNHw5y_U6_yQqoDmbq_M/edit?usp=sharing"
end
