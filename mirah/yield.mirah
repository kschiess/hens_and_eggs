def foo
  yield 1
  yield 2
  yield 3
end

foo do |el|
  puts el
end
