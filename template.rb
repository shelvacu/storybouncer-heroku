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
  js.insert(0,"//ajax.googleapis.com/ajax/libs/jquery/1.3/jquery.min.js")
  js << "//konami-js.googlecode.com/svn/trunk/konami.js"
  js << "/soundmanager/script/soundmanager2-nodebug-jsmin.js" 
  js << "/konami.js"
	pagename += " - Storybouncer"
  return makehtml do |h|
		h.head do
			h.title{pagename}

      h << '<meta name="viewport" content="width=device-width, height=device-height">'
			css.each do |name|
				h.link(:href => name,:rel => "stylesheet",:type => "text/css")
			end
      h << <<END
<script>
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-44995845-1', 'storybouncer.com');
  ga('send', 'pageview');

</script>
END
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
          #h.img(:id => "toplogo",:src => '/smalllogo.gif', alt => 'storybouncer')
          h.span(class:'toplinkbar') do
            h.a(class:'linkreset',id:'sitename',href:"/"){"Storybouncer.com"}
            h.span(class:'bar'){" | "}
            h.a(class:'linkreset toplinks',href:"/booklist"){"Browse"}
          end
          h.span(:id => 'stateinfo') do
            if session[:logged]
              #h << "#{session[:user]} | "
              h.a(:href => '/usercp', 
                  :id => 'managelink',
                  :class => 'linkreset toplinks'){"#{CGI.escapeHTML(session[:user])}"}
              h.span(class:'bar'){" | "}
              h.a(:href => '/logout', 
                  :id => 'logoutlink',
                  :class => 'linkreset toplinks'){"Logout"}
            else
              h.a(:href => '/login', 
                  :id => 'managelink',
                  :class => 'linkreset toplinks'){"Login"}
              h.span(class:'bar'){" | "}
              h.a(:href => '/register', 
                  :id => 'regsiterlink',
                  :class => 'linkreset toplinks'){"Register"}
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
