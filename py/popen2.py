
# http://coding.derkeiler.com/Archive/Python/comp.lang.python/2004-09/3273.html

# It gets complicated. Popen4 is not an easy way to make 
# two processes talk to each other except in very limited 
# circumstances. If you can use disk files, do.
import os
import subprocess

process = subprocess.Popen('svnserve -t', shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE)

stdout, stdin = process.stdout, process.stdin
print stdout.read()
