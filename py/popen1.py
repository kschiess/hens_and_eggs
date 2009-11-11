import os
stdout = os.popen("svnserve -t")
print stdout.read()