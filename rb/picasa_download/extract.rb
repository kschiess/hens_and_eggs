require 'strscan'

while line=ARGF.gets
  scanner = StringScanner.new(line)
  while !scanner.eos? && scanner.skip_until(%r(media:content url=))
    scanner.scan       %r('https://.*?')
    
    puts scanner.matched[1..-2]
  end
end
