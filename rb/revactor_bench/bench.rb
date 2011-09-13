# An Actor ring example
#
# Here we construct a ring of interconnected Actors which each know the
# next Actor to send messages to.  Any message sent from the parent Actor
# is delivered around the ring and back to the parent.

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'revactor'

NCHILDREN = 10

class RingNode
  extend Actorize

  def initialize
    loop do
      Actor.receive do |filter|
        filter.when(Case::Array[:msg, Case::Any]) do |_, message|
          handle_message(message)
          @next_node << [:msg, message] if @next_node
        end
        
        filter.when(Case::Array[:next_node, Case::Any]) do |_, node|
          puts "Setting next node of #{self} to #{node}"
          @next_node = node
        end
        
        filter.when(Object) do |msg|
          puts "Unhandled: #{msg.inspect}"
        end
      end
    end
  end

  def handle_message(message)
  end
end

class CountNode < RingNode
  def initialize
    @n = 0
    @t = Time.now

    super
  end
  
  def handle_message(message)
    @n += 1
    
    if @n % 10_000 == 0
      t = Time.now
      puts "10_000 msgs in #{t-@t} secs: #{Float(10_000) / (t-@t)}"
      @t = t
      @n = 0
    end
  end
end

children = (NCHILDREN-1).times.map { RingNode.spawn }
children << CountNode.spawn

p :linking
# link up all actors
children.each_cons(2) do |a, b|
  a << [:next_node, b]
end
children.last << [:next_node, children.first]

p :start
children.first << [:msg, 'ping']

Actor.receive do |filter|
  filter.when(Object) do |obj|
    p obj
  end
end
