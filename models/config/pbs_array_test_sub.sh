#!/bin/bash
#
# Simple sub script to test pbs array (-t option with openpbs/torque)
#
# Simply echoes a bit about the commands passed to it to a file

#  Version History
# Ver   Date       Time  Who            What
# ---  ----------  ----- -------------- ---------------------------------
#   1  2012-08-24  16:35  bpalmintier   Initial version

echo param1: $1 run on `cat $PBS_NODEFILE`
# remove the first parameter
shift
echo "   other params: $*"