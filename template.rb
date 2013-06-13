require './html-maker'

def makehtml #(&block)
	h = HTMLMaker.new
	h << "<!DOCTYPE html>\n"
	h.html{yield h}#block.call(h)}
	return h.to_s
end
#blarg
def template(pagename="missing title!",js = [],css = [],&block)
	css << '/main.css'
  js  << '/reposition.js'
  js.insert(0,"https://ajax.googleapis.com/ajax/libs/jquery/1.3/jquery.min.js")
	pagename += " - Storybouncer"
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
			h.noscript{'<span style="margin-left:auto;margin-right:auto;">This site won\'t work as well without javascript.</span>'}
      h.div(:id => 'topbar') do
				h.img(:id => "toplogo",:src => '/smalllogo.gif')
				h.span(:id => 'stateinfo') do
					if session[:logged]
						h << "#{session[:user]} | "
						h.a(:href => '/usercp.fgh', :id => 'managelink'){"UserCP"}
						h << " | "
						h.a(:href => '/logout.fgh', :id => 'logoutlink'){"Logout"}
					else
						h.a(:href => '/login.fgh', :id => 'managelink'){"Login"}
            h << " | "
            h.a(:href => '/register.fgh', :id => 'regsiterlink'){"Register"}
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
