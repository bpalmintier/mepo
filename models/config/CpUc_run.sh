#!/bin/bash
#
# GAMS whenUC RUN SCRIPT for use as a sub-function to pbs_array or other calls (-t option with openpbs/torque)
#  IMPORTANT: first option must be the output directory
#
# Usage:
#   source whenUC_run.sh OUT_DIR RUN_ID [RUN_OPTIONS...]
#
# Sets up up the enviroment, copies the model, and actually runs it.

#  Version History
# Ver   Date       Time  Who            What
# ---  ----------  ----- -------------- ---------------------------------
#   1  2012-08-26  16:18  bpalmintier   Adapted from whenUC_run.sh v1
#   1  2012-08-26  16:25  bpalmintier   Added support for output directory from first column

#----------------------------
# Run snapshot information
#----------------------------
DATE_TIME=`date +%y%m%d-%H%M`
ADVPOWER_REPO_VER=`svnversion ~/projects/advpower`

#----------------------------
# Handle passed in arguments
#----------------------------
#Setup output directory based on FIRST parameter
OUT_DIR="${HOME}/projects/advpower/results/gams/$1"
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
COMMON_IO_OPT=" -errmsg=1 -lo=2  -inputdir=${MODEL_DIR} --out_dir=${OUT_DIR} "

# SECOND parameter is the run code
RUN_CODE="$2"
# remove the first two parameters
shift 2
# Use all other command line parameters as run specific OPT
RUN_OPT=" $* "

echo "-----------------------------------------------------"
echo " GAMS Run code ${RUN_CODE} (array ID: ${PBS_ARRAYID})"
echo "-----------------------------------------------------"
echo "Date & Time:" ${DATE_TIME}
echo "SVN Repository Version:" ${ADVPOWER_REPO_VER}

#----------------------------
# Setup environment
#----------------------------
echo "Compute Node list:"
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

#Establish a working directory in scratch
#Will give error if it already exists, but script continues anyway
mkdir /scratch/b_p

#Make a new subfolder for this job
SCRATCH="/scratch/b_p/${PBS_JOBID}"
mkdir $SCRATCH

#Make a temporary run directory in scratch
WORK_DIR="${SCRATCH}/tmp_${RUN_CODE}/"
mkdir ${WORK_DIR}

#----------------------------
# Setup the actual run
#----------------------------

cp ${MODEL_DIR}/${GAMS_MODEL}.gms  ${WORK_DIR}
cd ${WORK_DIR}

echo "${GAMS_MODEL} copied to temporary ${WORK_DIR}"
pwd

SHARE_OPT=" ${LONG_OPT} ${THIS_FILE_OPT} "
IO_OPT=" ${COMMON_IO_OPT} -lf=${OUT_DIR}${RUN_CODE}_${GAMS_MODEL}.log -o=${OUT_DIR}${RUN_CODE}_${GAMS_MODEL}.lst --out_prefix=${RUN_CODE}_ --memo=${RUN_CODE}_v${ADVPOWER_REPO_VER}_${DATE_TIME} "

#----------------------------
# Now run GAMS-CPLEX
#----------------------------
echo .
echo "Running GAMS (#${PBS_ARRAYID}: ${RUN_CODE} )"
echo "  IO OPT ${IO_OPT}"
echo "  Shared OPT: ${SHARE_OPT}"
echo "  Run OPT: ${RUN_OPT}"
echo .
gams ${GAMS_MODEL} ${IO_OPT} ${SHARE_OPT} ${RUN_OPT}

echo "GAMS Done! (#${PBS_ARRAYID}: ${RUN_CODE} )"
echo .
