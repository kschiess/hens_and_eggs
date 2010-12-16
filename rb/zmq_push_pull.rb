
require 'ffi-rzmq'

1.times do
  pid = fork do
    puts "Sending message in #{Process.pid}..."
    ctx = ZMQ::Context.new
    source = ctx.socket(ZMQ::PUSH)
    source.connect('ipc://pipe')
    
    n = 0 
    loop do
      n+= 1
      source.send_string 'fubber ' + n.to_s
      
      break if n == 10
    end
    source.send_string 'done'
    puts "Done."
    
    exit 
  end
  
  Process.detach pid
end

ctx = ZMQ::Context.new
sink = ctx.socket(ZMQ::PULL)
sink.bind('ipc://pipe')

puts "Receiving messages"
while msg=sink.recv_string
  p msg
  break if msg == 'done'
end

puts "Stopping server!"
sink.close
