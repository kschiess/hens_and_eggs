
class LogFile
  PATH = '/var/tmp/'
  
  def initialize
    @name = generate_name
  end
  
  def needs_change?
    return false unless File.exist?(@name)
    
    File.stat(@name).size > 10 * 1024**2
  end
  
  def open
    File.open(@name, 'a') do |io|
      yield io
    end
  end
  
  def generate_name
    File.join(PATH, Time.now.strftime("%Y%m%d%H%M"+".log"))
  end
  
  def to_s
    @name
  end
end

class LogInfo
  attr_reader :logfile
  
  def initialize
    @logfile = LogFile.new
  end
  
  def with_logfile
    if logfile.needs_change?
      @logfile = LogFile.new
    end
    
    logfile.open do |io|
      yield io
    end
  end
  
  def execute(io, command)
    fork do
      STDIN.close
      STDOUT.reopen(io)
      STDERR.reopen(io)
      
      exec(command)
      fail "EXEC FAILED; NEVER HAPPENS"
    end
    Process.waitall
  end
  
  def do_log
    with_logfile do |io|
      
      io.puts "log data at #{Time.now} -------------------------- "
      io.flush
      ['ps -ef', 'uptime', 'prstat 1 1'].each do |command|
        # puts "Executing #{command} -> #{logfile}"
        io.puts "#{command}: >>>>"; io.flush
        execute(io, command)
        io.puts "#{command} <<<<"; io.flush
      end
    end
  end
  
  def run
    loop do
      do_log
      sleep 30
    end
  end
  
  def self.run
    new.run
  end
end


LogInfo.run
