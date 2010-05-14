tree = { 'root' => {
  'a' => nil, 
  'b' => {
    'c' => nil, 
    'd' => nil
  }, 
  'e' => {
    'f' => {
      'g' => nil
    }
  }
}}


def print_node(node, curved)
  curved.each_with_index do |r, i|
    last = i==curved.size-1
    
    if r
      print last ? '`- ' : '   '
    else
      print last ? '+- ' : '|  '
    end
  end
  puts node
end

def recurse_print(node, curved=[])
  if node
    if node.instance_of?(Hash)
      keys = node.keys
      keys.each { |k|
        v = node[k]
        
        print_node(k, curved + [k==keys.last])
        recurse_print(v, curved + [k==keys.last])
      }
    else
      print_node(node, curved)
    end
  end
end

recurse_print(tree)