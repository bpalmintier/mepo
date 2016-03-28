#!/bin/bash
#
# Thesis Ch4: OPS RUNS for Parallel Catch-up runs. 
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
#   1  2012-09-20  23:45  bpalmintier   Adapted from CpUc_par.sh v7 and CpUc_co2_pol_ops v4
#   2  2012-09-23  11:45  bpalmintier   Pass lp_method=6 & opportunistic run options through LONG_OPT

#========= Setup Job Queue Parameters ==========
# IMPORTANT: The lines beginning #PBS set various queuing parameters, they are not simple comments
#
# Specify node type. Options on svante include: amd64, nehalem, sandy
# Note that the ppn option must exactly match an existing machine configuration, 4, 8, 12 or 16
#PBS -l nodes=1:ppn=8,mem=40gb
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
##PBS -l walltime=168:00:00
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
MODEL_DIR="${MODEL_DIR_BASE}/ops"
GAMS_MODEL="UnitCommit"

# Plus additional user supplied OPT pasted into template

# Options shared by all runs across all files
ALL_RUN_OPT=" --sys=thesis_sys.inc --min_gen_size=0.2 "
# Options common to the runs in this file
# Note: we explicitly allow non-served energy to help reduce reserve req'ts b/c many of the
# mixes based on simpler ops in capacity planning may otherwise be infeasible. However, this
# assumption can dramatically increase run times
THIS_FILE_OPT=" ${ALL_RUN_OPT} --adj_rsrv_for_nse=on --demand=ercot2007_dem_yr_as_52wk.inc "

# Note: 169200sec=47hrs
LONG_OPT=" --max_solve_time=169200 --par_threads=${PBS_NP} --lp_method=6 --par_mode=-1 "
#PAR_OPT pass through LONG_OPT b/c that is what is used by CpUc_opsrun.sh and parallel 
# settings from base run are stripped off in the process

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
source ${CONFIG_DIR}/CpUc_opsrun.sh `sed -n "${PBS_ARRAYID} s/[,\t]/ /gp" < ${CONFIG_DIR}/CpUc_par_list.csv`

#Let caller know that everything went fine
exit 0