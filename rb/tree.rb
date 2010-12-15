class Node
  attr_reader :name
  attr_reader :subnodes
  attr_accessor :l, :r
  
  def self.construct(nodes)
    stack = []
    current = nil
    
    loop do
      current = nodes.shift
      break unless current
      
      cons = Node(current.name)
      cons.l = current.l
      cons.r = current.r
      
      if stack.empty?
        stack.push cons
      else 
        until stack.last.include?(current)
          stack.pop
        end
        stack.last.subnodes << cons
        stack.push cons
      end
    end
    
    return stack.first
  end
  
  def initialize(name, *subnodes)
    @name = name.upcase
    @subnodes = subnodes
    @l = @r = 0
  end
  
  def to_s
    io = StringIO.new
    recurse_print io
    io.string
  end
  
  # Prints the tree to the io. 
  def recurse_print(io, flags=[])
    io.printf "#{name} %2d %2d\n", @l, @r
    each do |node|
      last = subnodes.last == node
      flags[0..-1].each do |t|
        io.print t ? "  " : "|  "
      end
      io.print last ? "`-" : "+-"
      node.recurse_print(io, flags + [last])
    end
  end
  
  # Labels the nodes left to right order.
  def label(n=1)
    @l = n
    each do |node|
      n += 1
      n = node.label(n)
    end
    @r = n+1
  end
  
  def rec
    self
  end
  # Returns a table for this tree.
  def to_table
    Table.new(to_array)
  end
  def to_array
    r = [rec]
    each do |node|
      r += node.to_array
    end
    r
  end
  
  def include?(pot_child)
    pot_child.l >= self.l && pot_child.r <= self.r
  end
  def child?(pot_child)
    pot_child.l > self.l && pot_child.r < self.r
  end
  
  def each(&block)
    subnodes.each(&block)
  end
end

class Table
  def initialize(table)
    @table = table
  end
  def each(&block)
    @table.each(&block)
  end

  # Allows to map and modify the table at the same time. Yields each node
  # in succession to the block; the result of the block replaces the node. 
  # You may also modify the node in place, as long as you still return it. 
  # If nil is returned from your block, the node is deleted. 
  #
  # Example: 
  #
  #   # deletes every second node
  #   replace do |node|
  #     n ||= 0
  #     n += 1
  #     n%2 == 0 ? node : nil
  #   end
  #
  def replace(&block)
    delete_list = []
    @table = @table.
      map(&block).
      compact.                    # remove nils
      sort_by { |node| node.l }   # restore order
  end
  
  def remove(name)
    tgt = find(name)
    d = tgt.r - tgt.l + 1
    
    replace do |any|
      if tgt.include? any
        nil
      else
        any.l -= d if any.l > tgt.r
        any.r -= d if any.r > tgt.r
        any
      end
    end
  end

  def move(from_name, to_name)
    from = find(from_name).dup
    to   = find(to_name).dup
    
    fail "cannot move inside itself" if from.include?(to)
    # fail "already there" if to.include?(from)
    
    # For removal
    d = from.r - from.l + 1
    
    # For insertion
    i = -from.l+to.r
    # Correct insertion for cases where to.r is to the right of from, meaning
    # that we need to remove from first.
    i -= d if to.r>from.r 

    replace do |any|
      oany = any.dup
      
      print "#{oany.name} #{oany.l},#{oany.r}"
      
      if from.include? any
        any.l += i
        any.r += i
        puts
      else
        print "-> #{any.l},#{any.r}"

        # Removing from in its old place
        any.l -= d if oany.l > from.r
        any.r -= d if oany.r > from.r
      
        print "-> #{any.l},#{any.r}"

        # Inserting from in its new place
        any.l += d if oany.l >= to.r
        any.r += d if oany.r >= to.r
      
        puts "-> #{any.l},#{any.r}"
      end
      
      any
    end
  end
  
  def to_s
    s = ''
    each do |entry|
      s << 't: ' << [entry.name, entry.l, entry.r].inspect << "\n"
    end
    s
  end

  def find(name)
    @table.find { |node| node.name==name.upcase }
  end

  def nodes
    @table
  end
end

def Node(name, *subnodes)
  Node.new(name, *subnodes)
end
def original_tree
  tree = Node('a', 
    Node('b', 
      Node('g'), 
      Node('h')), 
    Node('c', 
      Node('e'), 
      Node('f')))
  tree.label
  
  tree
end
  
puts "Tree: "
puts original_tree
puts

puts "Table initially:"
table = original_tree.to_table
puts table
puts

[
  'g', 'e', 
  'g', 'b', 
  'g', 'a', 
  'g', 'c', 
  
  'c', 'h'
].each_slice(2) do |src, tgt|
  table = original_tree.to_table
  
  puts "Moving nodes around... (#{src} -> #{tgt})"
  table.move(src, tgt)

  puts "Tree view"
  puts Node.construct(table.nodes)
  puts  
end

