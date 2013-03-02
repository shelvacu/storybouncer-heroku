require 'sinatra'
require './http-maker'

get '/' do
	$h = HTTPMaker.new
	$h.html do
		$h.body do
			$h.h1(:id => 'awesome'){"Hello, world"}
			$h.img(:src => "http://thelazy.info/wp-content/uploads/2010/12/hello-world-2-600x4011.jpg")
			if rand(10) == 0
				$h.h1(:style => "font-size:big;"){"It's your lucky day!"}
			end
		end
	end
end
