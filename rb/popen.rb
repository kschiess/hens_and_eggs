require 'open4'
require 'io/wait'
include Open4

def thread
  Thread.start do
    yield
  end.abort_on_exception = true
end

# This ALMOST works with ruby 1.8 and completely works with ruby 1.9
popen4('svnserve -t') do |pid, stdin, stdout, stderr|
  thread do    
    while not stdout.eof?
      $stdout.print stdout.read(1)
    end
  end
  thread do
    while not $stdin.eof?
      stdin.write $stdin.read(1)
    end
  end
end