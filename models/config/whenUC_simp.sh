#!/bin/bash
#
# Thesis Ch4: When does UC matter Grid ARRAY Base [Manually copy & config]
#   ERCOT 2007, min 200MW gen, Year as 52 weeks
#   Full Ops w/ Maintenance, 80MW min UC integer, non-parallel
#   No B&B priority, No cheat, No cap limit helper
#
# To actually submit the job use:
#   qsub SCRIPT_NAME

#  Version History
# Ver   Date       Time  Who            What
# ---  ----------  ----- -------------- ---------------------------------
#   1  2012-08-18  01:20  bpalmintier   Adapted from plan_batch_6_rerun2.sh
#   2  2012-08-21  16:40  bpalmintier   Updated options to use thesis_* and related settings
#   3  2012-08-21  22:40  bpalmintier   Remove rps_penalty (50 to low)
#   4  2012-08-22  00:40  bpalmintier   Added skip_cap_limit to avoid infeasibility with retirement
#   5  2012-08-24  00:20  bpalmintier   template_whenUC_head.sh v1: "based on whenUC_t12 (whenUC_base v4)"
#   6  2012-08-24  23:45  bpalmintier   Convert to pbs array based setup
#   7  2012-08-25  09:02  bpalmintier   Correct renew_to_rps to match StaticCapPlan v82. It was & still is disabled.
#   8  2012-08-26  16:30  bpalmintier   Added support for tab (or comma) delimited run list
#   9  2012-08-29  16:05  bpalmintier   Adjusted -t range to use new, non-derated simple ops
#  10  2012-08-31  17:05  bpalmintier   Adjusted run range (-t) to use adj_rsrv_for_nse for 80% RPS 
#  11  2012-09-02  18:35  bpalmintier   Oops, adj_rsrv_for_nse not valid without reserves. Removed 80% cases and adjusted run range
#  12  2012-09-03  08:15  bpalmintier   Adj run range to use derate (to maint) by default for non-uc ops
#  13  2012-09-05  01:30  bpalmintier   ERGH... remove maintenance

#========= Setup Job Queue Parameters ==========
# IMPORTANT: The lines beginning #PBS set various queuing parameters, they are not simple comments
#
# Specify node type. Options on svante include: amd64, nehalem, sandy
#PBS -l nodes=1:nehalem
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
#PBS -t 1-20%10
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

#Setup output
OUT_DIR="${HOME}/projects/advpower/results/gams/whenUC_grid/"
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
#   memo:       encode some helpful run information in the summary file
#
# Plus additional user supplied OPT pasted into template

# Options shared by all runs across all files
COMMON_IO_OPT=" -errmsg=1 -lo=2  -inputdir=${MODEL_DIR} --out_dir=${OUT_DIR} "
ALL_RUN_OPT=" --sys=thesis_sys.inc --min_gen_size=0.2 --skip_cap_limit=1"
# Options common to the runs in this file
THIS_FILE_OPT="${ALL_RUN_OPT} --demand=ercot2007_dem_yr_as_52wk.inc --retire=0.5 "

# Note: 216000sec=58hrs
LONG_OPT=" --max_solve_time=6500 "
PAR_OPT=" --par_threads=3 --lp_method=6 --par_mode=-1 --probe=2 "

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
source ${CONFIG_DIR}/whenUC_run.sh `sed -n "${PBS_ARRAYID} s/[,	]/ /gp" < ${CONFIG_DIR}/whenUC_simp_list.csv`

#Let caller know that everything went fine
exit 0