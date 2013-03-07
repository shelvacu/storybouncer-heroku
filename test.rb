require './html-maker'

def makehtml#(&block)
	h = HTMLMaker.new
	h << "<!DOCTYPE html>\n"
	h.html{yield h}#block.call(h)}
	return h.to_s
end
def template(pagename="missing title!",js = [],css = [])#,&block)
	css << '/main.css'
	return makehtml do |h|
		#h.head do
		#	h.title{pagename}
		#	css.each do |name|
		#		h.link(:href => name,:rel => "stylesheet",:type => "text/css")
		#	end
		#	js.each do |name|
		#		h.script(:type => 'text/javascript',:src => name){}
		#	end
		#end
		#h.body do
			#h.div(:id => 'main'){
				yield h#block.call(h)
			#}
			#h.div(:id => "bottombar") do
			#	h.div(:id => "innerbottombar") do
			#		h.span(:id => "copy"){"Created by and Copyright &copy; Shelvacu Vevevende"}
			#		#h.span(:id => "donatelink") do
			#		h.a(:id => "donatelink",:href => "/donate.fgh"){"Donate"}
			#		#end
			#	end
			#end
		#end
	end
end

stuff = template("Donate!") do |h|
	#h.div{"You have two options for donating:"}
	#h.div do
		h << "bla."
		#h << File.read('./SiteDonatebutton')
	#end
	#h.hr
	#h.div do
	#	h << "Or, donate directly to me. This will go to things like the server(if needed) and caffeine to stay awake working on the site"
	#	#h << File.read('./Donatebutton')
	#end
end

puts stuff
