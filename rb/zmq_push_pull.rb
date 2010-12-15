
require 'zmq'

# ctx = ZMQ::Context.new
#  
# # create publisher socket, and publish to two pipes!
# pub = ctx.socket(ZMQ::PUB)
# pub.bind('tcp://127.0.0.1:5000')
# pub.bind('inproc://some.pipe')
#  
# # generate random message, ex: '1 9'
# Thread.new { loop { pub.send [rand(2), rand(10)].join(' ') } }
#  
# # create a consumer, and listen for messages whose key is '1'
# sub = ctx.socket(ZMQ::SUB)
# sub.connect('inproc://some.pipe')
# sub.setsockopt(ZMQ::SUBSCRIBE, '1')
#  
# loop { p sub.recv } # => "1 9" ...

3.times do
  fork do
    sleep 1
    puts "Sending message in #{Process.pid}..."
    ctx = ZMQ::Context.new
    source = ctx.socket(ZMQ::PUSH)
    source.connect('tcp://*:5555')
    source.send 'fubber'
    puts "Done."
  end
end

ctx = ZMQ::Context.new
sink = ctx.socket(ZMQ::PULL)
sink.bind('tcp://*:5555')

puts "Receiving messages"
while msg=sink.recv
  p msg
end
