### WARNING ###
# contains hideous code

get '/register/?' do
	template('register') do |h|
		h.div(:id => "signInBox") do
			h.form(:method => "post") do
				h.h3{"Sign up for an account"}
				
				h.span{"Username:"}
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
