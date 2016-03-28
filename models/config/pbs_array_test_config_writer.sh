#!/bin/bash
#
# Simple script to create a config file for the  pbs array test
#
# To use:
#   source pbs_array_test_config_writer.sh 100 > pbs_array_test_config.csv

#  Version History
# Ver   Date       Time  Who            What
# ---  ----------  ----- -------------- ---------------------------------
#   1  2012-08-24  15:45  bpalmintier   Initial version

for ((myseq=0; myseq<$1; myseq++))
do
echo test_run_code_${myseq}, --my_num=${myseq} --run_on=$PBS_NODEFILE --ok
done 
