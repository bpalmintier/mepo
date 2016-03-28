# Very basic batch scripter to call multiple commands in separate shells
#
# the command to run is tcommand from the given command template and run as a system call
#
# This script useful for basic brute-force parallel where 

#use python 3.x print function
from __future__ import print_function
import sys, subprocess

#Extract number of tasks to run from the command line
num_tasks = int(sys.argv[1])

#Treat rest of command line as the Command template (multiple pieces OK)
#Convert command line list of items to a string
#command = sys.argv[2]
params_template = " ".join(sys.argv[2:])

print("\nSimple Batch Running:")
for n in range(1, num_tasks+1):
	# and paste/template subsitution for %(id)s
	params = params_template % {'id':n}
	print(params)
	subprocess.Popen(params, shell=True)