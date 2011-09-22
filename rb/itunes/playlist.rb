
require 'cgi'
require 'fileutils'
require 'pp'
require 'nokogiri'

class ITunesLibrary
  attr_reader :hash
  
  def initialize(name)
    parse(name)
  end
  
  class MyDocument < Nokogiri::XML::SAX::Document
    attr_reader :state
    attr_reader :values
    attr_reader :names
  
    def initialize(*args)
      super
    
      @names = []
      @values = [Hash.new]
      @state = [:initial]
    end
  
    def start_element name, attributes = []
      case name
        when 'key'
          state.push :inkey
        when 'dict'
          state.push :invalue
          values << {}
          names.push @current_key || :plist
        when 'array'
          state.push :invalue
          values << []
          names.push @current_key 
      else
        state.push :invalue
      end
      @current_value = ''
    end
    def cdata_block(string)
      p string
    end
    def characters(string)
      case current_state
        when :inkey
          @current_key = string.to_sym
        when :invalue
          @current_value << string
      end
    end
    def end_element name
      case name
        when 'key'
          fail "not in key" unless current_state == :inkey
          state.pop
        when 'plist'  # To prevent last plist from killing everything
      else
        if current_state == :invalue
          if name == 'dict' || name == 'array'
            @current_value = values.pop
            @current_key = names.pop
            # p [@current_key, @current_value.keys]
          end
            
          case current_value
            when Hash
              current_value[@current_key] = @current_value
            when Array
              current_value << @current_value
          end
          @current_value = ''
          
          state.pop
        end
      end
    end
  
    def current_state
      state.last
    end
    def current_value
      values.last
    end
    attr_reader :hash
  end

  def parse(name)
    # Create a new parser
    doc = MyDocument.new
    parser = Nokogiri::XML::SAX::Parser.new(doc)

    # Feed the parser some XML
    parser.parse(File.open(name, 'rb'))

    @hash = doc.current_value
  end
  
  def plist
    hash[:plist]
  end
  
  def tracks
    plist[:Tracks]
  end
  
  def playlists
    plist[:Playlists]
  end
  
  def inspect
    "<#iTunes library:#{object_id}: #{tracks.size} tracks>"
  end
end

Track = Struct.new(:artist, :name, :album, :path) do
  def initialize(track)
    super *[:Artist, :Name, :Album, :Location].map { |f| track[f] }
  end
  
  def ==(other)
    [:artist, :name, :album].all? do |field|
      self[field] == other[field]
    end
  end
  def hash
    [:artist, :name, :album].map { |f| self[f] }.hash
  end
end

if $0 == __FILE__
  $stderr.puts "Reading contents of playlist 'hochzeit'"
  lib = ITunesLibrary.new('itunes.xml')
  hochzeit = lib.playlists.find { |pl| pl[:Name] == 'hochzeit' }
  track_ids = hochzeit[:"Playlist Items"].map { |e| e[:"Track ID"] }
  tracks = track_ids.map do |tid|
    track = lib.tracks[tid.to_s.to_sym]
    Track.new(track)
  end
    
  $stderr.puts "Looking for new track ids"
  lib = ITunesLibrary.new('new.xml')
  track_map = {}
  lib.tracks.each do |tid, track|
    track = Track.new(track)

    # Do we need this track?
    old_track = tracks.find { |old| old == track }
    next unless old_track

    # Do we alredy have it? (dupes)
    next if track_map.has_key? old_track
        
    track_map[old_track] = track
  end

  $stderr.puts "#{tracks.size}/#{track_map.size}"

  $stderr.puts "Generating a playlist file"
  puts %Q(#EXTM3U)
  n = 0
  tracks.each do |track|
    path = track_map[track].path
    
    # puts track.name
    puts path
    
    if ARGV.first == '--copy'
      file = CGI.unescape(path).sub('file://localhost', '').gsub('&', '\&')
      
      FileUtils.cp(file, sprintf("hochzeit/%02d%s", n, File.extname(path)))
    end
    
    n += 1
  end
end
