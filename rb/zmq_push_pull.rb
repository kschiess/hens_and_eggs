
require 'timeout'
require 'ffi-rzmq'

10.times do
  pid = fork do
    puts "Sending message in #{Process.pid}..."
    ctx = ZMQ::Context.new
    source = ctx.socket(ZMQ::PUSH)
    source.connect('ipc://pipe')
    
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
count = 0
loop do
  begin
    timeout 1 do
      msg = sink.recv_string
      count += 1
      p msg
    end
  rescue Timeout::Error
    break
  end
end

puts "Got #{count} messages."

puts "Stopping server!"
sink.close
