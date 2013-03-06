require 'cgi'
class InvalidAttribute;end
class HTMLMaker

	def initialize()
		@currentHTML = ""
	end
	
	def method_missing(method_name,raw_attr = {})
		raise 'must pass object responding to #each' unless raw_attr.respond_to?(:each)
		
		attributes = []
		raw_attr.each do |key,val|
			attr = String.try_convert(val)
			raise InvalidAttribute,"was not able to convert #{val} to string" if attr.nil?
			attributes << "#{key}=\"#{CGI::escapeHTML(val)}\""
		end
		
		if block_given?
			@currentHTML += "<#{method_name.to_s}#{attributes.empty? ? "" : " "+attributes.join(" ")}>"
			add = String.try_convert(yield self)
			@currentHTML += add unless add.nil?
			@currentHTML += "</#{method_name.to_s}>"
		else
			@currentHTML += "<#{method_name.to_s}#{attributes.empty? ? "" : " "+attributes.join(" ")} />"
		end
		return nil
	end
	
	def add_element(name)#,attr = {})
		name = name.to_sym
		method_missing(name)#,attr)
	end
	
	def <<(stuff)
		@currentHTML += String.try_convert(stuff).to_s
	end
	
	def to_s;@currentHTML;end
end
