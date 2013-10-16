get '/colors' do
	template('C0L0RZ!') do |h|
    h.style{<<EEND
#main{
background: #e5e5e5; /* Old browsers */
background: -moz-linear-gradient(top,  #e5e5e5 0%, #000000 99%); /* FF3.6+ */
background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#e5e5e5), color-stop(99%,#000000)); /* Chrome,Safari4+ */
background: -webkit-linear-gradient(top,  #e5e5e5 0%,#000000 99%); /* Chrome10+,Safari5.1+ */
background: -o-linear-gradient(top,  #e5e5e5 0%,#000000 99%); /* Opera 11.10+ */
background: -ms-linear-gradient(top,  #e5e5e5 0%,#000000 99%); /* IE10+ */
background: linear-gradient(to bottom,  #e5e5e5 0%,#000000 99%); /* W3C */
filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#e5e5e5', endColorstr='#000000',GradientType=0 ); /* IE6-9 */
}
EEND
    }
		'0369cf'.split('').each do |a|
			'0369cf'.split('').each do |b|
				'0369cf'.split('').each do |c|
					h.div(:style => "background-color:##{a}#{b}#{c};width:100px;font-family:monospace;"){"#"+a+b+c}
				end
			end
		end
    nil
	end
end
