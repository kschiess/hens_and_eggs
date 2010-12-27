require 'appscript'

class IPhoto
  include Appscript
  
  attr_reader :application
  def initialize
    @application = app('iPhoto')
  end
  
  def albums
    application.albums.get.map { |a| Album.new(a) }
  end
  
  def album(name)
    Album.new(application.albums['Events'])
  end


  module AppscriptObject
    def appscript_getter(*syms)
      syms.each do |sym|
        define_method sym do
          object.send(sym).get
        end
      end
    end
    
    def appscript_setter(*syms)
      syms.each do |sym|
        define_method "set_#{sym}" do |value|
          object.send(sym).set(value)
        end
      end
    end
  end
  
  class Album < Struct.new(:object)
    extend AppscriptObject
    appscript_getter :name, :children
    
    def photos
      object.photos.get.reverse.map { |p| Photo.new(p) }
    end
  end
  
  class Photo < Struct.new(:object)
    extend AppscriptObject
    appscript_getter :comment, :date_, :dimensions, :height, :id, :image_filename, 
      :image_path, :name, :original_path, :rating, :title, :width
      
    appscript_setter :date_
  end
end

iphoto = IPhoto.new
album = iphoto.album('Last Import')
$stdout.sync = true
album.photos.each do |photo|
  if photo.date_ < Time.now
    print '.'
    next
  end

  puts
  print photo.date_.to_s + " -> "
  photo.set_date_(
    Time.new(
      Time.now.year, 
      photo.date_.month, 
      photo.date_.day, 
      photo.date_.hour, 
      photo.date_.min, 
      photo.date_.sec))
  puts photo.date_
end
