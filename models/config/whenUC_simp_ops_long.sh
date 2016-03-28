#!/bin/bash
#
# Thesis Ch4: OPS RUNS for When does UC matter Grid ARRAY Base [Manually copy & config]
#   ERCOT 2007, min 200MW gen, Year as 52 weeks
#   Full Ops w/ Maintenance, 80MW min UC integer, non-parallel
#   No B&B priority, No cheat, No cap limit helper
#
# To actually submit the job use:
#   qsub SCRIPT_NAME

#  Version History
# Ver   Date       Time  Who            What
# ---  ----------  ----- -------------- ---------------------------------
#   1  2012-09-21  00:20  bpalmintier   Adapted from whenUC_simp_ops.sh v2

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
#PBS -q xlong
# And up the run time to the maximum of a full week (168 hrs)
#PBS -l walltime=62:00:00
#
# Setup Array of runs. Format is 
#   -t RANGE%MAX
#  where RANGE is any sequence of run numbers using #-# and/or #,#
#  and MAX is the maximum number of simultaneous tasks
#PBS -t 3-4,8,16
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
ALL_RUN_OPT=" --sys=thesis_sys.inc --min_gen_size=0.2 "
# Options common to the runs in this file
# Note: we explicitly allow non-served energy to help reduce reserve req'ts b/c many of the
# mixes based on simpler ops in capacity planning may otherwise be infeasible. However, this
# assumption can dramatically increase run times
THIS_FILE_OPT=" ${ALL_RUN_OPT} --adj_rsrv_for_nse=on --demand=ercot2007_dem_yr_as_52wk.inc "

# Note: 216000sec=58hrs
LONG_OPT=" --max_solve_time=216000 "
PAR_OPT=" --par_threads=${PBS_NP} --lp_method=6 --par_mode=-1 --probe=2 "

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
source ${CONFIG_DIR}/whenUC_opsrun.sh `sed -n "${PBS_ARRAYID} s/[,	]/ /gp" < ${CONFIG_DIR}/whenUC_simp_list.csv`

#Let caller know that everything went fine
exit 0
