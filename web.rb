require 'sinatra'
require 'digest'
require './template'
require './local_sequel'
require './ping_self'
require 'pony'
require 'pp'
require 'yaml'
require 'cgi' #SOOO MANY LIBRARIEZZZZZ!
require 'json'

if DB.tables.empty? #database has not been generated, it needs to be
  require './reset_tables.rb'
end
enable :sessions
set :session_secret, "RAGEGAMINGVIDEOSpinkflufflyunicornsdancingonrainbowsgravyandtoastcaptainsparklestobuscuspewdiepie98impossiblethepianoguyslindseystirlingHISHE"
set :show_exceptions, false

if ENV['TESTING_ENV'].nil?
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
    }
  }
else
  require './smtp_serv'
  Pony.options = {
    :via => :smtp,
    :via_options =>  {
      :address              => 'localhost',
      :port                 => '12345',
    },
    :from => "iforgotoincludeafromaddressIapologize@storybouncer.com" 
  }
  require 'sinatra/reloader'
end 
$site_name = "www.storybouncer.com" #"protected-brushlands-7337.herokuapp.com"
def valid_email?(email)
  return true unless ENV['TESTING_ENV'].nil?
	return true unless email.match(/^\w*@\w*\.\w{2,5}(\.\w{2,5})?$/).nil?
	return false
end
def valid_username?(name)
	return true unless name.match(/^[\w_^ ]{1,20}$/).nil?
	return false
end

error do
	err = env['sinatra.error']
	Pony.mail(:from => "error@storybouncer.com",
            :to => "shelvacu@gmail.com", 
            :subject => err.class.to_s,
            :body => "Current session:#{session.pretty_inspect}\nM:#{err.message}\n\n\n#{err.backtrace.join("\n")}" ) if not ENV['TESTING_ENV'].nil?
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
before do
  if request.host == "storybouncer.com"
    redirect request.url.gsub("storybouncer.com","www.storybouncer.com"),301
  end
end
get '/' do
  win = (rand(10)==0)
	$h = HTMLMaker.new
  h = $h
	$h.html do
		$h.head{
			$h.title{"Storybouncer!"}
			$h.style{"img{margin:0px auto}
.desc{
		width:400px;
		margin-right:auto;
		margin-left:auto;
		font-family:sans-serif;
}"}	
		}
		$h.body("style" => 'text-align:center') do
      $h.div do
        $h.img(:src => '/logo.gif')
        # $h.h1(:id => 'awesome'){"Currently in development"}
        #if win
        #  $h.h1(:style => "font-size:big;"){"It's your lucky day!"}
        #end
      end
      $h.h1{"Writing. Crowdsourced."}
      $h.p(:class => "desc"){"How it works:"}
      $h.p(:class => "desc"){"Someone makes a \"book\" consisting of a title, and a single paragraph. Everyone reads this, and following the same idea of the story someone writes another paragraph, a suggested paragraph. And another person. And another. Then, all the suggested paragraphs are voted on by the community, and the one with the most votes is selected to be part of the story. The process then repeats, and a story is born."}
      $h.h3{"Currently being developed, sorry"}
      $h.div do
        $h.h3{"Would you like to know when it's done? Sign-up here!"}
        $h.form(:method => "post") do
          $h.span{h << "Email:";h.input(:type => 'text',:name => 'email');h.input(:type => 'submit',:value => 'submit')}
        end
      end
		end
	end
	$h.to_s
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
				h.input(:type => 'text',:name => "user")
				h.br
				h.span{"Email:"}
				h.input(:type => 'text',:name => "email")
				h.br
				h.span{"Password:"}
				h.input(:type => 'password',:name => "pass")
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
	template('Registering') do |h|
		unless params[:user].nil? || params[:email].nil? || params[:pass].nil?
			redirect "/invalid/username/#{params[:user]}" unless valid_username?(params[:user])
			redirect "/invalid/email/#{params[:email]}" unless valid_email?(params[:email])
			if DB[:users].where(:user => params[:user]).empty? && DB[:users].where(:email => params[:email]).empty?
				#username && email is availible
				o =  [('a'..'z'),('A'..'Z'),('0'..'9')].map{|i| i.to_a}.flatten
				email_verify_key  =  (0...10).map{ o[rand(o.length)] }.join
				DB[:users].insert(:user => params[:user],:pass => Digest::SHA256.hexdigest(params[:pass]), :email => params[:email], :emailver => email_verify_key,:subs => makearray, :hist => makearray,:auth => 0)
				session[:logged] = true
				session[:user] = params[:user]
				#email availible, all good!
				verify_link = "http://#{$site_name}/verify.fgh?key=#{email_verify_key}"
				e = HTMLMaker.new
				e.body do
					e.span{"Please visit:"}
					e.a(:href => verify_link){"Here"}
					e.span{"To verify your account. <br />Alternatively, use the key \"#{email_verify_key}\" at #{$site_name}/verify.fgh"}
				end
				Pony.mail(	:from => "no-reply@storybouncer.com",:to => params[:email],
							:subject => "your new account!", :html_body => e.to_s, 
							:body => "Please copy+paste this url into your browser: #{verify_link}\n\nOr, go to #{$site_name}/verify.fgh and enter the code #{email_verify_key.inspect}") if ENV["TESTING_ENV"].nil?
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
				h << "You are already logged in as #{session[:user]}. Perhaps you want to "
				h.a(:href => "/logout.fgh"){"logout?"}
			end
		else
			h.form(:method => "post", :id => "loginForm") do
				h.table do
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
	if params[:user].nil? || params[:pass].nil?
		ret = template('Error') do |h|
			h.h3{"Form submit failed. Please refresh and try again"}
		end
	elsif DB[:users].where(:user => params[:user]).empty?
		ret = template('Username Incorrect'){|h| h.h2{"Username incorrect"}}
	elsif DB[:users].where(:user => params[:user],:pass => Digest::SHA256.hexdigest(params[:pass]) ).empty? && false
		ret = template('Password Incorrect'){|h| h.h2{"Password incorrect"}}
	else
		userdata = DB[:users].where(:user => params[:user] ).all[0]
    #,:pass => Digest::SHA256.hexdigest(params[:pass])
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

get '/logout.fgh' do
	session.clear
	template('Logged out'){|h| h.h2{"Successfully logged out"}}
end

get '/usercp.fgh' do
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
            h.form do
              h.span{"SOOON"}
              #h.input(:type => 'password'
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
	#return "nup, no id" if params[:id].nil?
  redirect to('/booklist.fgh') if params[:id].nil?
	params[:id] = params[:id].to_i
	
	#return "book does not exist" if DB[:books].where(:id => params[:id]).empty? # I should change both of these later, make a more useful message.
  begin
    book = Book.new(params[:id])
  rescue ItemDoesntExist
    error 404
  end
  chap_num = (params[:chap] || 1).to_i
	#book = DB[:books].first(:id => params[:id])
  #chaps = getarray(book[:chaps])
  #chap_id = chaps.order_by(:val).limit(1,chap_num-1).all[0][:val]
  chap = book.chaps[chap_num - 1] #DB[:chaps].where(:id => chap_id).all.first
  error 404 if chap.nil?
  name = chap.strname
  name = CGI.escapeHTML(name)
  paras= chap.paras.all

  last_chapter = chap_num >= book.chaps.count-1
  pparas = book.pparas.all_order_rand# if last_chapter
  fin  = book.fin?
  
  

	template("#{book.strname}",'/vote.js') do |h|
		h.singletablerow do
			h.td(:class => 'prevContainer') do
				if chap_num > 1
					['top','bottom'].each do |s|
						h.a(:href => "/view/book.fgh?id=#{params[:id]}&chap=#{(chap_num - 1)}",:id => "#{s}PrevButton"){"Prev"}
					end
          nil
				else
					h.div(:class => 'spacefiller'){}
				end
			end
			h.td do
				h.div(:id => 'storybody') do
					h.h2(:id => 'storyname'){name}
					h.br
					paras.each do |para|
						h.p(:class => 'paratext') do
              CGI.escapeHTML(para.text).gsub("\n","<br/>")
            end
						h.br
					end
          #h << pparas.pretty_inspect
          h.hr
          if !fin && last_chapter
            if session[:logged]
              begin
                user = User.new(session[:userid])
              rescue ItemDoesntExist
                redirect to("/login.fgh")
              end
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
                          :value =>"#{params[:id]}")
                  h.input(:type => "hidden",
                          :name => "chapID",
                          :value =>"#{chap_num}")
                end
              end
            end
          end
				end
			end
			h.td(:class => 'nextContainer') do
				if chap_num < book.chaps.count
					#h.div(:class => 'nextContainer') do
					['top','bottom'].each { |s|
						h.a(:href => "/view/book.fgh?id=#{params[:id]}&chap=#{chap_num + 1}",:id => "#{s}NextButton"){"Next"}
					}
          nil
					#end
				else
					h.div(:class => 'spacefiller'){}
				end
			end
		end
	end  
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
    new_para = Para.create(:auth => user,
                           :an => "",
                           :text => params[:mainText],
                           :upvotes => makearray,
                           :downvotes => makearray)
    book.pparas << new_para
    params[:chapID] ||= 1
    params[:chapID] = params[:chapID].to_i
    redirect to("/view/book.fgh?id=#{params[:bookID]}&chap=#{params[:chapID]}")
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
  
  

get '/booklist.fgh' do 
  template('ALL the books!') do |h|
    h.div(:class => 'booklist') do
      # DB[:books].all.each do |book|
      #   h.span(:class => 'booklisting') do
      #     nameid = book[:name]
      #     namething = DB[:names].first(:id => nameid)
      #     name = namething[:name]
      #     h.a(:href => "/view/book.fgh?id=#{book[:id]}"){name}
      #   end
      #   h.br
      # end
      Book.all.each do |book|
        h.span(:class => 'booklisting') do
          h.a(:href => "/view/book.fgh?id=#{book.id}"){book.namestr}
        end
        h.br
      end
      nil
    end
  end
end
  
=begin
get "/routes.txt" do
	content_type 'plain/text'
	#template("Actual Index!") do |h|
		#h.p(:style => "text-align:left;font-family:monospace;white-space:nowrap;") do
			#CGI::escapeHTML(
			Sinatra::Application.routes.pretty_inspect#).gsub("\n","<br/>").gsub(' ',"<span> </span>")
		#end
	#end
end
=end
  
get "/routes.fgh" do
	routes = Sinatra::Application.routes
	pages = Hash.new{|j,k| j[k]=[]} #"blarg.fgh" => ["GET","POST"]
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
  
get '/plain-ip.fgh' do
  "#{request.ip}"
end
get '/ip.fgh' do
  template("Your IP is #{request.ip}") do |h|
    h.h1{"#{request.ip}"}
  end
end
get '/db/dump.yaml' do
  error 404 unless params[:pass] == "OMGthisIsAsoupers33cr3tp4sswordOMG"
  content_type 'application/x-yaml', :encoding => "utf-8"
  tables = DB.tables
  hash_db = Hash[ tables.zip( tables.map{|t| DB[t].all} ) ]
  hash_db.to_yaml
end

#TIME TO DEMO DAY
get '/ttdd/?' do
  redirect to("/ttdd/index.html")
end
#get '/except.fgh' do
#	this_is_not_a_real_method_and_will_raise_an_error
#end
  
