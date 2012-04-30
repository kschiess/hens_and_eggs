require 'appscript'

include Appscript
app = app('Things')

logbook = app.lists['Logbook'].get

log_files = Hash.new { |h,k| h[k] = File.open("todos_#{k}.txt", 'w') }

last_year = nil
now = Date.today
logbook.to_dos.get.each do |todo|
  date = todo.completion_date.get
  if date.year < now.year
    text = todo.name.get
    status = todo.status.get
    project = todo.project.get != :missing_value && todo.project.get.name.get || '(none)'
    tags   = todo.tag_names.get
    
    string = "#{project}\t#{text}\t#{status}\t#{date}\t#{tags}"
    # puts string
    log_files[date.year].puts string
    
    if !last_year || last_year != date.year
      last_year = date.year
      puts 
      print date.year
      print "  ."
    else
      print '.'
    end
  else
    print '.'
  end
end