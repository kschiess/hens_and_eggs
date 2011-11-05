#!/usr/bin/env ruby
require "appscript"
include Appscript
itunes = app('iTunes')

library = itunes.library_playlists.get.first

def strip_trailing_one(str)
  if md=str.match(/(.*) 1$/)
    return md[1]
  end
  return str
end


require 'set'
names_seen = Set.new

name_track_map = Hash.new { |h,k| h[k] = [] }

# Fill name_track_map with tracks that have the same name
library.tracks.get.each do |track|
  name = strip_trailing_one track.name.get

  name_track_map[name] << track
end

to_delete = []
name_track_map.each do |name, tracks|
  # Skip for tracks that have a unique name
  next if tracks.size == 1
  
  # TODO do this later
  tracks.
    reject! { |track| track.location.get == :missing_value }
  
  tracks.
    # Group tracks by their containing directory
    group_by { |track| 
      File.dirname(track.location.get.path)
    }.each { |dirname, tracks|
      # Skip tracks that only exist once in their directory by their name
      # (different albums)
      next if tracks.size < 2
      
      # Try to find the dupe track
      dupe = tracks.find do |track|
        path = File.basename(track.location.get.path)
        path.match(/^.* (1|2|3)\.(mp3|m4a|m4v)$/) ||
          path.match(/^1-.*$/)
      end
      
      # Break with debug message if we haven't found the dupe
      unless dupe
        puts "#{dirname} #{tracks.size}"
        puts tracks.map { |t| File.basename(t.location.get.path) }
        puts 
      else
        to_delete << dupe
      end
    }
end

puts "Would delete: (#{to_delete.size})"
to_delete.each do |track|
  location = track.location.get.path
  
  track.delete
  File.unlink(location)
end