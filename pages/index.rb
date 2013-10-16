get '/' do
  redirect "/booklist"
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
