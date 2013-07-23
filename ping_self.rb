require 'rufus/scheduler'
require "net/http"
require "uri"
scheduler = Rufus::Scheduler.start_new
 
scheduler.every '10m' do
  require 'net/http'
  require 'uri'
  url = 'http://www.storybouncer.com'
  Net::HTTP.get_response(URI.parse(url))
end
