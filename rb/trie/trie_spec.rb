require 'trie'
require 'set'

describe Trie do
  attr_reader :trie
  before(:each) do
    @trie = Trie.new
  end
  
  def gen_trie(*strs)
    strs.inject(Trie.new) { |t, s| t.store(s); t }
  end
  def start_with(expected)
    simple_matcher "a trie that starts with #{expected.inspect}" do |given|
      given.start_with?(expected)
    end
  end
  
  it "should compare equal to itself" do
    { 'a' => 'b' }.should == { 'a' => 'b' }
    gen_trie('a', 'b').should == gen_trie('a', 'b')
  end 
  it "should not store nil" do
    gen_trie('').content.should == {}
  end
   
  context "with the node 'a'" do
    before(:each) do
      trie.store 'a'
    end
    
    it "should contain { 'a' => '' }" do
      trie.content.should == { 'a' => '' }
    end
  end
  context "with the nodes 'aab' and 'aac'" do
    before(:each) do
      trie.store 'aab'
      trie.store 'aac'
    end
    
    it "should contain { 'a' => { 'a' => <'b', 'c'> } }" do
      trie.content['a'].should be_an_instance_of(Trie)
      trie.content['a'].content['a'].should == gen_trie('b', 'c')
    end
  end
  context "with a few random hex digits in it" do
    attr_reader :set
    before(:each) do
      @set = Set.new
      1000.times do
        s = rand(1000).to_s(16)
        set << s
        trie.store(s)
      end
      # puts trie.to_yaml
    end
    
    it "should contain all the strings the set contains" do
      set.each do |s|
        trie.should start_with(s)
      end
    end 
  end

  describe "#include?" do
    it "should be true for toplevel (more entries)" do
      gen_trie('a','b').should start_with('a')
      gen_trie('a','b').should start_with('b')
    end 
    it "should be true for toplevel (one entry)" do
      gen_trie('a').should start_with('a')
    end 
    it "should be true for nested tries" do
      gen_trie('aab', 'aac').should start_with('aab')
      gen_trie('aab', 'aac').should start_with('aac')
    end 
  end
  describe "#min_unique_prefix" do
    context "for aabaaaaa and aacaaaaa" do
      before(:each) do
        trie.store('aabaaaaa').store('aacaaaaa')
      end
      
      it "should be 3" do
        trie.min_unique_prefix.should == 3
      end 
      context "and aabaacaa" do
        before(:each) do
          trie.store('aabaacaa')
        end
        
        it "should be 6" do
          trie.min_unique_prefix.should == 6
        end 
      end
    end

    it "should be 1 for simple tries" do
      gen_trie('a').min_unique_prefix.should == 1
      gen_trie('a', 'b', 'c').min_unique_prefix.should == 1
    end 
    it "should always be one for tries with strings that begin distinctly" do
      'b'.upto('z') do |c|
        trie.store c 
        trie.min_unique_prefix.should == 1
      end
    end 
    it "should be last length for chains of just one char ('a', 'aa', 'aaa', ...)" do
      current = ''
      
      while current.size < 100
        trie.min_unique_prefix.should == current.size 
        current += 'a'
        trie.store current
      end
    end
  end
end