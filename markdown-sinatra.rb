require 'sinatra/base'
require 'markdown_meta'

module Sinatra
  module MarkdownHelper
    def markdown(fn, use_template = true, title = nil)
      t = fn = fn.to_s
      fn = File.join("./views/",fn)
      fn = fn+".md" unless File.exist?(fn)
      error("error parsing markdown, file #{fn} was not found") unless File.exist?(fn)
      title ||= t
      html = MarkdownMeta.to_html(File.read(fn))
      if use_template
        return template(title,[],[],true){|h| h << html}
      else
        return html
      end
    end
  end
  
  helpers MarkdownHelper
end
