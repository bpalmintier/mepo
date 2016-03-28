#!/bin/bash
#
# Simple test of pbs array (-t option with openpbs/torque)
#
# To actually submit the job use:
#   qsub SCRIPT_NAME
#
# Look for results in the run output file

#  Version History
# Ver   Date       Time  Who            What
# ---  ----------  ----- -------------- ---------------------------------
#   1  2012-08-24  15:45  bpalmintier   Initial version
#   2  2012-08-26  16:30  bpalmintier   Added support for tab (or comma) delimited run list

#========= Setup Job Queue Parameters ==========
# IMPORTANT: The lines beginning #PBS set various queuing parameters, they are not simple comments
#
# Specify node type. Options on svante include: amd64, nehalem, sandy
#PBS -l nodes=1:nehalem,mem=5gb
#
# Merges any error messages into output file
#PBS -j oe 
#
# Select the queue based on maximum run times:
#    short    2hr
#    medium   8hr
#    long    24hr
#    xlong   48hr, extendable to 168hr using -l walltime= option below
#PBS -q short
# And up the run time to the maximum of a full week (168 hrs)
##PBS -l walltime=62:00:00
#
# Setup Array of runs. Format is 
#   -t RANGE%MAX
#  where RANGE is any sequence of run numbers using #-# and/or #,#
#  and MAX is the maximum number of simultaneous tasks
#PBS -t 1-100%10
# The corresponding array ID number is set in ${PBS_ARRAYID}

# Additional setup goes here
# Change to calling directory
cd $PBS_O_WORKDIR

# Array command
echo Array ID:${PBS_ARRAYID}.
# Here we use the sed utility to extract the given line from a configuration file
#  source: calls an external script
#  the back ticks ``: pass the result of the command inside to build up the command line
#  sed: does the line extraction and search and replace
#    -n          Prevents printing lines unless requested
#    #           specifies which line in the file to use
#    s/old/new/  does a regular expression substitution for this line, in this case removing commas
#    g           Make this search "global" to replace all occurrences on the line
#    p           Prints the result
#    <           Specifies the input config file to extract the line from
source pbs_array_test_sub.sh `sed -n "${PBS_ARRAYID} s/[,	]/ /gp" < pbs_array_test_config.csv`

#Let caller know that everything went fine
exit 0