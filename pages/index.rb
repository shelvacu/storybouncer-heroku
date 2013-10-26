get '/' do
  template("Make a story!") do |h|
    h.h1{"Make a story, I dare you!"}
    h.form(action:'/addbook',method: 'post') do
      h.label(for:'bookname') do
        h.span{"NAME:"}
      end
      h.input(type:'text',name:'bookname')
      h.br
      h.textarea(name:'paratext',class:'submitParaText'){}
    end
  end
end
