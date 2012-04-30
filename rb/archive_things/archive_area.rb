require 'appscript'

include Appscript
app = app('Things')

fail "First argument to this script should be area name." if ARGV.empty?

project = app.lists["@#{ARGV.first}"].get
project.to_dos.get.each do |todo|
  date = todo.completion_date.get
  text = todo.name.get
  status = todo.status.get
  project = todo.project.get != :missing_value && todo.project.get.name.get || '(none)'
  tags   = todo.tag_names.get
  
  puts [project, text, date, status, tags].join('\t')
end