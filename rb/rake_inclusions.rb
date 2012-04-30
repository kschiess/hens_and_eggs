require 'text/highlight'


class Module
  def output(source, from, to, trace)
    hl = Text::ANSIHighlighter.new
    rake = trace.first.match /rake/
    puts "#{rake ? '(r)' : '   '} #{source}: #{hl.bold + hl.green}#{from} += #{to}#{hl.reset} [#{trace.first[-50..-1]}]"
  end
  
  alias ruby_append_features append_features
  def append_features(klass)
    ruby_append_features(klass)
    output('af', klass, self, caller)
  end
  
  alias ruby_extend_object extend_object
  def extend_object(obj)
    ruby_extend_object(obj)
    output('eo', obj, self, caller)
  end
end

puts "Current context is #{self}@#{self.object_id.to_s(16)} (#{self.class})"
gem 'rake', '~> 0.9.2'
require 'rake'
p Object.ancestors
Object.included_modules.delete(Rake::DeprecatedObjectDSL)
p Object.ancestors
