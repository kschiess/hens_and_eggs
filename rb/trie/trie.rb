
class Trie
  attr_reader :content
  def initialize
    @content = {}
  end
  
  def store(str)
    return self if str.empty?
    
    char, rest = partition(str)
    
    unless current=content[char]
      # At first, store whole strings
      content[char] = rest
    else
      # Then, store tries
      unless current.kind_of? Trie
        (content[char] = Trie.new).
          store(current)
      end
      
      content[char].store rest
    end

    return self
  end
  
  def ==(other)
    content == other.content
  end
  
  def start_with?(str)
    return true if str.empty?
    
    char, rest = partition(str)
    
    (node=content[char]) &&
      (node.start_with?(rest))
  end
  
  def min_unique_prefix
    content.map { |char, content|
      if content.kind_of?(Trie)
        1 + content.min_unique_prefix 
      else
        1
      end
    }.max || 0
  end
  
  def partition(str)
    [str[0..0], str[1..-1]]
  end
end