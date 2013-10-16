error do
	err = env['sinatra.error']
  begin
    begin
      request
    rescue
      request = nil
    end
    error_body = <<END
Current session: #{session.pretty_inspect}

Request: #{if request;request.pretty_inspect;else;"NA";end}

Error message: #{err.message}
#{err.backtrace.join("\n")}

END
    Pony.mail(:from => '"STORYTHUDDING!" <error@storybouncer.com>',
              :to => "\"THE MASTER\" <shelvacu@gmail.com>", 
              :subject => err.class.to_s,
              :body => error_body)
    #This comment is here to make indentation a little more sane
    #see above
  rescue
  end
  begin
    template("Error") do |h|
      h.h3{"I'm sorry. There was an error. I have already been notified, so there's no need to email me. Thank you"}
    end
  rescue
    "There's been quite an error. Sadly, we can't afford to train monkeys, so some wild monkeys have been dispatched to attempt to fix the problem."
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
