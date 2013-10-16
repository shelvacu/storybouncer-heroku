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
        if not params[:p].nil?
          first_para = params[:p].to_i
          pparas.sort_by!{|o| (o.id == first_para ? 0 : 1)}
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
