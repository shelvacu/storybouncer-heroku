require 'gserver'

Thread.abort_on_exception = true

$logfile = "/home/shelvacu/emails"
if !File.exist?($logfile)
  File.open($logfile,'w'){}
end
$f = File.open($logfile,'at')
END{$f.close}

class SMTPServer < GServer
  def initialize(port=12345,*opts)
    super(port,*opts)
  end
  def serve(io)
    $f.puts
    $f.puts "-----------------------New thingy-----------------"
    $f.puts
    io.puts "220 localhost Simple Mail Transfer Agent Service Ready"
    while io.open?
      msg = io.gets
      $f.puts msg.chomp
      if msg.start_with?("HELO")
        io.puts "250 localhost"
      elsif msg.start_with?("DATA")
        io.puts "354 Start mail input; end with <CRLF>.<CRLF>"
        while (msg = io.gets.chomp) != "."
          $f.puts msg.chomp
        end
        io.puts "250 OK"
      elsif msg.start_with?("QUIT")
        io.puts "221 localhost Service closing transmission channel"
        io.close
      else
        io.puts "250 OK"
      end
    end
  end
end

serv = SMTPServer.new
serv.start
#serv.join
