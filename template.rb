require './html-maker'

def makehtml #(&block)
	h = HTMLMaker.new
	h << "<!DOCTYPE html>\n"
	h.html{yield h}#block.call(h)}
	return h.to_s
end
#blarg
def template(pagename="Missing title!",js = [],css = [],markdown = false,&block)
  js = [js] unless  js.is_a?(Array)
  css=[css] unless css.is_a?(Array)
	css.insert(0,'/reset.css') unless markdown
  css << '/main.css'
  css << '/markdown.css' if markdown
  #js  << '/reposition.js'
  js.insert(0,"https://ajax.googleapis.com/ajax/libs/jquery/1.3/jquery.min.js")
  js << "http://konami-js.googlecode.com/svn/trunk/konami.js"
  js << "/soundmanager/script/soundmanager2-nodebug-jsmin.js" 
  js << "/konami.js"
	pagename += " - Storybouncer"
  return makehtml do |h|
		h.head do
			h.title{pagename}
      h << '<meta name="viewport" content="width=device-width, initial-scale=1">'
			css.each do |name|
				h.link(:href => name,:rel => "stylesheet",:type => "text/css")
			end
			js.each do |name|
				h.script(:type => 'text/javascript',:src => name){}
			end
      nil
		end
		h.body do
      h.div(:id => "notFooter") do
        h.noscript{'<span style="margin-left:auto;margin-right:auto;">\
This site won\'t work without javascript. Sorry!</span>'}
        h.div(:id => 'topbar') do
          h.img(:id => "toplogo",:src => '/smalllogo.gif')
          h.span(:id => 'stateinfo') do
            if session[:logged]
              h << "#{session[:user]} | "
              h.a(:href => '/usercp', 
                  :id => 'managelink',
                  :class => 'blacklink'){"UserCP"}
              h << " | "
              h.a(:href => '/logout', 
                  :id => 'logoutlink',
                  :class => 'blacklink'){"Logout"}
            else
              h.a(:href => '/login', 
                  :id => 'managelink',
                  :class => 'blacklink'){"Login"}
              h << " | "
              h.a(:href => '/register', 
                  :id => 'regsiterlink',
                  :class => 'blacklink'){"Register"}
            end
          end
        end
        h.div(:id => 'mainContainer'){
          h.div(:id => 'main'){
            block.call(h)
          }
          h.div(:id => 'push'){}
        }
      end
			h.div(:id => "bottombar") do
				h.div(:id => "innerbottombar") do
					h.span(:id => "copy"){"Site design created by and Copyright &copy; Shelvacu Tebbs 2013"}
					h.span(:class => "bottomlinks") do
            h.a(:class => 'blacklink',
                :href => "/development"){"Contact / Status"}
            h << " | "
            h.a(:id => "donatelink",
                :href => "/donate",
                :class => 'blacklink'){"Donate"}
					end
				end
			end
		end
	end
end
