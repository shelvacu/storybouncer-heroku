check_votes = Rufus::Scheduler.start_new

check_votes.every '1m' do
  Book.all.each do |book|
    next if book.fin?
    numvotes = book.pparas.all.map{|o| o.votes}.flatten.uniq.length
    num_subs = DB[:subs].where(book_id: book.id).count
    if numvotes > (num_subs) && numvotes > 1
      winning_para = book.pparas.all.map{|o| [o,o.vote_count]}.sort_by{|o| o[1]}.last[0]
      to_del = book.pparas.all
      to_del.each do |para|
        book.pparas.delete(para)
        unless para == winning_para
         DB[:paras].where(id: para.id).delete
        end
      end
      if winning_para.chapname.nil?
        book.chaps.last.paras << winning_para
      else
        c = Chap.create(name: winning_para.chapname,
                        auth: winning_para.auth)
        book.chaps << c
        c.paras << winning_para
      end
      #Now email everyone about the new paragraph that just came out!
      DB[:subs].where(book_id: book.id).all.each do |row|
        user_id = row[:user_id]
        user = User.new(user_id)
        if user.veri
          Pony.mail(to: user.email,
                    from: "admin@storybouncer.com",
                    subject: "New paragraph in #{book.strname}",
                    body: "Hey #{user.name}, the voting has ended and a new paragraph has been added! Go to http://www.storybouncer.com/book/#{book.id}/#{book.chaps.length}/ to see it! (copy+paste the url into your browser)",
                    html_body: makehtml do |h|
                      h.head{h.title{"New paragraph in #{CGI.escapeHTML(book.strname)}"}} #is this neccesary?
                      h.body do
                        h.span do 
                          "Hey #{CGI.escapeHTML(user.name)}, the voting has ended and a new paragraph has been added! Go to <a href=\"http://www.storybouncer.com/book/#{book.id}/#{book.chaps.length}/\">http://www.storybouncer.com/book/#{book.id}/#{book.chaps.length}/</a> to see it! (if the link doesn't work, copy+paste the url into your browser)"
                        end
                      end
                    end)
          #done!?
        end
      end
    end
  end
end
