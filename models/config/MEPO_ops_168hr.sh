#!/bin/bash
#
# General purpose MEPO model runs for ops-only (UnitCommit) model. 
#
# Features: 
#  - Handles directory, model, and runcode/svn manipulation
#  - Setups full week for max run time of 168hr (1 week) with 160hr for solver
#  - Still uses Nehalem nodes for fair time comparisons
#
# Notes:
#  - All run options are assumed to be included in MEPO_ops_list.csv file
#  - Use in non-planning context. Does not extract capacity info from planning
#     result outputs.
#
# To actually submit the job use:
#   qsub SCRIPT_NAME -t [specify items/lines from csv to run]

#  Version History
# Ver   Date       Time  Who            What
# ---  ----------  ----- -------------- ---------------------------------
#   1  2013-10-14  10:35  bpalmintier   Adapted from whenUC_full_long.sh v1 and CpUc_co2_pol_run.sh v5
#   2  2013-10-15  13:35  bpalmintier   Revert to nehalem nodes for fair comparisons

#========= Setup Job Queue Parameters ==========
# IMPORTANT: The lines beginning #PBS set various queuing parameters, they are not simple comments
#
# Specify node type. Options on svante include: amd64, nehalem, sandy
#PBS -l nodes=1:nehalem,mem=10gb
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
#
# Setup Array of runs. Format is 
#   -t RANGE%MAX
#  where RANGE is any sequence of run numbers using #-# and/or #,#
#  and MAX is the maximum number of simultaneous tasks
#PBS -t 2-4,13-17
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

#Setup output
# IMPORTANT: Include trailing directory separator
OUT_DIR="${HOME}/projects/advpower/results/gams/mepo/"
#Make sure output directory exists
mkdir ${OUT_DIR}

# Default GAMS OPT to:
#   errmsg:     enable in-line description of errors in list file
#   lf & lo:    store the solver log (normally printed to screen) in $OUT_DIR
#   o:          rename the list file and store in $OUT_DIR
#   inputdir:   Look for $include and $batinclude files in $WORK_DIR
# And Advanced Power Model OPT to:
#   out_dir:    specify directory for CSV output files 
#   out_prefix: add a unique run_id to all output files
#
# Plus additional user supplied OPT pasted into template

# Options shared by all runs across all files
COMMON_IO_OPT=" -errmsg=1 -lo=2  -inputdir=${MODEL_DIR} --out_dir=${OUT_DIR} "
ALL_RUN_OPT=" "
# Options common to the runs in this file
THIS_FILE_OPT=" ${ALL_RUN_OPT} "

# Note: 600000sec=160hrs
LONG_OPT=" --max_solve_time=600000 "

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
source ${CONFIG_DIR}/MEPO_run.sh `sed -n "${PBS_ARRAYID} s/[,	]/ /gp" < ${CONFIG_DIR}/MEPO_ops_list.csv`

#Let caller know that everything seems fine
exit 0
