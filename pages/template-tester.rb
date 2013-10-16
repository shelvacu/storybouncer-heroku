get '/test/?' do
	template("Template tester 0.1") do |h|
		h.span{"This stuff appears inside the template!"}
	end
end
