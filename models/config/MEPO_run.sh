#!/bin/bash
#
# GAMS whenUC RUN SCRIPT for use as a sub-function to pbs_array or other calls (-t option with openpbs/torque)
#
# Usage:
#   source whenUC_run.sh RUN_ID [RUN_OPTIONS...]
#
# Sets up up the enviroment, copies the model, and actually runs it.

#  Version History
# Ver   Date       Time  Who            What
# ---  ----------  ----- -------------- ---------------------------------
#   1  2013-10-14  13:00  bpalmintier   Renamed from whenUC_run.sh v1 (no changes)

#----------------------------
# Run snapshot information
#----------------------------
DATE_TIME=`date +%y%m%d-%H%M`
ADVPOWER_REPO_VER=`svnversion ~/projects/advpower`

#----------------------------
# Handle passed in arguments
#----------------------------
# first parameter is the run code
RUN_CODE="$1"
# remove the first parameter
shift
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
mkdir /scratch/$USER

#Make a new subfolder for this job
SCRATCH="/scratch/$USER/${PBS_JOBID}"
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
IO_OPT=" ${COMMON_IO_OPT} -lf=${OUT_DIR}/${RUN_CODE}_${GAMS_MODEL}.log -o=${OUT_DIR}/${RUN_CODE}_${GAMS_MODEL}.lst --out_prefix=${RUN_CODE}_ --memo=${RUN_CODE}_v${ADVPOWER_REPO_VER}_${DATE_TIME} "

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
