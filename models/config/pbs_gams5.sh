#!/bin/bash
#
# Simple BASH script to run a GAMS job on the svante cluster.
#
# To actually submit the job use:
#   qsub SCRIPT_NAME

#  Version History
# Ver   Date       Time  Who            What
# ---  ----------  ----- -------------- ---------------------------------
#   1  2011-04-20         bpalmintier   Adapted from pbs_matlab.sh v8
#   2  2011-07-22  01:00  bpalmintier   GAMS logging and output to OUT_DIR

#========= Setup Job Queue Parameters ==========
# IMPORTANT: The lines beginning #PBS set various queuing parameters, they are not simple comments
#
# name of submitted job, also name of output file unless specified
# The default job name is the name of this script, so here we surpress the job naming so
# we get unique names for all of our jobs
##PBS -N matlab_pbs
#
# Ask for all 1 nodes with multiple processors on the node
# use 12 processors if need to ensure we have exclusive access to a full machine (& associated memory)
#PBS -l nodes=1:ppn=12
#
# This option merges any error messages into output file
#PBS -j oe 
#
# Select the queue based on maximum run times. options are:
#    short    2hr
#    medium   8hr
#    long    24hr
#    xlong   48hr, extendable to 168hr using -l walltime= option below
#PBS -q xlong
# And up the run time to the maximum of a full week
##PBS -l walltime=168:00:00

echo 'Node list:'
cat  $PBS_NODEFILE

#Set things up to load modules
source /etc/profile.d/modules.sh

#Load recent version of GAMS
module load gams/23.6.3

#Set path to gams in environment variable so MATLAB can read it
GAMS=`which gams`
export GAMS

#And load CPLEX
module load cplex

#Change to our working directory
cd ~/projects/advpower/models/capplan
pwd

#----------------------------
# Setup gams options
#----------------------------
DATE_TIME=`date +%y%m%d-%H%M`
ADVPOWER_REPO_VER=`svnversion ~/projects/advpower`
echo "Date & Time:" ${DATE_TIME}
echo "SVN Repository Version:" ${ADVPOWER_REPO_VER}

OUT_DIR="out5/"
GAMS_MODEL="StaticCapPlan"
GAMS_OPTIONS="-errmsg=1 --out_dir=${OUT_DIR}  -lf=${OUT_DIR}${GAMS_MODEL}.log -lo=2 -o=${OUT_DIR}${GAMS_MODEL}.lst --sys=ercot2009_sys.inc  --update=../data/ieee2011_update.inc --ramp=1 --unit_commit=1 --startup=1 --no_nse=1 --max_start=1 --max_solve_time=20000 --par_threads=12  --uc_ignore_unit_min=20 --flex_rsrv=1 --co2cost=0  --rps=0 --memo=UC_ops_cap_plan_c0_rps0_shed_v${ADVPOWER_REPO_VER}_${DATE_TIME}"

#Now run GAMS/CPLEX
echo "Running ${GAMS_MODEL} using GAMS"
echo "  Options: ${GAMS_OPTIONS}"
gams ${GAMS_MODEL} ${GAMS_OPTIONS}
echo 'GAMS Done'
