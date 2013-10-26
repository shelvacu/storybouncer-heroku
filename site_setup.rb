enable :sessions
set :session_secret, "RAGEGAMINGVIDEOSpinkflufflyunicornsdancingonrainbowsgravyandtoastcaptainsparklestobuscuspewdiepie98impossiblethepianoguyslindseystirlingHISHE"
set :show_exceptions, development?
set :sessions, :expire_after => 172800 #2 days
use Rack::Deflater

use Rack::Recaptcha, 
  :public_key  => "6LdFEOYSAAAAAA_6NyMPwmh1hyr4ASVtuCxLJGly",
  :private_key => "6LdFEOYSAAAAAMnPVGsLJA-a7h5hQvO-DjT-YCZc"
helpers Rack::Recaptcha::Helpers

if not development?
  puts "ASSUMING ON PRODUCTION SERVER"
  Pony.options = {
    :via => :smtp,
    :via_options => {
      :address => 'smtp.sendgrid.net',
      :port => '587',
      :domain => 'storybouncer.com',
      :user_name => ENV['SENDGRID_USERNAME'],
      :password => ENV['SENDGRID_PASSWORD'],
      :authentication => :plain,
      :enable_starttls_auto => true
    },
    :from => "admin@storybouncer.com"
  }
else
  puts "assuming dev server"
  Pony.options = {
    :via => :smtp,
    :via_options =>  {
      :address              => 'localhost',
      :port                 => '1025',
    },
    :from => "admin@storybouncer.com" 
  }
end 

$site_name = "www.storybouncer.com"
$development = development?
