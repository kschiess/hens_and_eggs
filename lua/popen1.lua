local function  printf(...) return io.stdout:write(string.format(...)) end

local pipe = io.popen('svnserve -t', 'r')
printf("%s\n", pipe:read())
