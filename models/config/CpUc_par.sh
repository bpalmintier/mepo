#!/bin/bash
#
# Thesis Ch4: Parallel Catch-up runs. 
#  IMPORTANT: configuration list file (*.csv) must contain 3 columns: Output folder, run code, GAMS options
#
#   ERCOT 2007, min 200MW gen, Year as 52 weeks
#   No B&B priority, No cheat, No cap limit helper
#
# To actually submit the job use:
#   qsub SCRIPT_NAME

#  Version History
# Ver   Date       Time  Who            What
# ---  ----------  ----- -------------- ---------------------------------
#   1  2012-08-26  16:15  bpalmintier   Adapted from whenUC_co2_policy.sh v1
#   2  2012-08-26  16:25  bpalmintier   Moved Output directory configuration to CpUc_run, increased parallel node & memory requirements
#   3  2012-08-27  15:45  bpalmintier   Increased array size to 15 for additional catch-up runs
#   4  2012-09-05  01:30  bpalmintier   ERGH... remove maintenance
#   5  2012-09-06  12:07  bpalmintier   Updated run range for corrected maintenance DNF runs
#   6  2012-09-06  12:07  bpalmintier   Updated to extract the number of threads from the number of processor nodes
#   7  2012-09-20  23:07  bpalmintier   Go big or go home... updated defaults for 1 week run times, including GAMS timeouts
#   8  2013-03-29  22:27  bpalmintier   Reduced times down to 55hr to try to sneak in before a reboot
#   9  2013-04-01  22:27  bpalmintier   Back up to full week

#========= Setup Job Queue Parameters ==========
# IMPORTANT: The lines beginning #PBS set various queuing parameters, they are not simple comments
#
# Specify node type. Options on svante include: amd64, nehalem, sandy
# Note that the ppn option must exactly match an existing machine configuration, 4, 8, 12 or 16
#PBS -l nodes=1:ppn=12,mem=18gb
#
# Merges any error messages into output file
#PBS -j oe 
#
# Select the queue based on maximum run times:
#    short    2hr
#    medium   8hr
#    long    24hr
#    xlong   48hr, extendable to 168hr using -l walltime= option below
#PBS -q xlong
# And up the run time to the maximum of a full week (168 hrs)
#PBS -l walltime=168:00:00
# #PBS -l walltime=55:00:00
#
# Setup Array of runs. Format is 
#   -t RANGE%MAX
#  where RANGE is any sequence of run numbers using #-# and/or #,#
#  and MAX is the maximum number of simultaneous tasks
#PBS -t 1-3,9-10,16-20
# The corresponding array ID number is set in ${PBS_ARRAYID}

#--------------------
# Shared Setup
#--------------------
MODEL_DIR_BASE="${HOME}/projects/advpower/models"

#Establish our model directory
CONFIG_DIR="${MODEL_DIR_BASE}/config"

#Establish our model directory
MODEL_DIR="${MODEL_DIR_BASE}/capplan"
GAMS_MODEL="StaticCapPlan"

# Plus additional user supplied OPT pasted into template

# Options shared by all runs across all files
ALL_RUN_OPT=" --sys=thesis_sys.inc --min_gen_size=0.2 --skip_cap_limit=1"
# Options common to the runs in this file
THIS_FILE_OPT="${ALL_RUN_OPT} --demand=ercot2007_dem_yr_as_52wk.inc --retire=0.5 "

# Note: 600000sec=160hrs
LONG_OPT=" --max_solve_time=600000 --par_threads=${PBS_NP} "
# # Note: 190800sec=53hrs
# LONG_OPT=" --max_solve_time=190800 --par_threads=${PBS_NP} "
#PAR_OPT must be set in the list file (enter in Excel table)
#PAR_OPT=" --lp_method=6 --par_mode=-1 --probe=2 "

#--------------------
# Run Subtasks
#--------------------

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
source ${CONFIG_DIR}/CpUc_run.sh `sed -n "${PBS_ARRAYID} s/[,\t]/ /gp" < ${CONFIG_DIR}/CpUc_par_list.csv`

#Let caller know that everything went fine
exit 0