#!/bin/bash
#
# Simple MATLAB script to run a matlab job on the svante cluster.
#
# To actually submit the job use:
#   qsub SCRIPT_NAME

#  Version History
# Ver   Date       Time  Who            What
# ---  ----------  ----- -------------- ---------------------------------
#   1  2012-04-23         bpalmintier   Modified for simple 4-core call



#========= Setup Job Queue Parameters ==========
# IMPORTANT: The lines beginning #PBS set various queuing parameters, they are not simple comments
#
# Ask for all 1 nodes with multiple processors on the node
# use 12 processors if need to ensure we have exclusive access to a full machine (& associated memory)
#PBS -l nodes=1:ppn=8
#
# This option merges any error messages into output file
#PBS -j oe 
#
# Select the queue based on maximum run times. options are:
#    short    2hr
#    medium   8hr
#    long    24hr
#    xlong   48hr, extendable to 168hr using -l walltime= option below
#PBS -q long
# Adjust the wall time if needed
##PBS -l walltime=150:00:00

echo 'Node list:'
cat  $PBS_NODEFILE

#Set things up to load modules
source /etc/profile.d/modules.sh

#Load most recent version of MATLAB (2011b provides up to 12 cores in parallel)
module load matlab

#And most recent version of GAMS
module load gams/23.6.3

#Set path to gams in environment variable so MATLAB can read it
GAMS=`which gams`
export GAMS

#And load CPLEX
module load cplex

#Change to our working directory
cd ~/projects/advpower/models/MATLAB
#cd /net/fs02/d0/b_p/advpower/models/MATLAB
pwd

#----------------------------
# Setup matlab script options
#----------------------------
# >>>>>>>>>>>>>>>>>>>>>>>> Only need to change the following 2 lines <<<<<<<<<<<<<<<<<<<<<<<<<<
MATLAB_COMMAND="gcwGridTest"
COMMAND_FOR_FILENAME="gcwTestDpGridTest"
# >>>>>>>>>>>>>>>>>>>>>>>> End Change block <<<<<<<<<<<<<<<<<<<<<<<<<<

DATE_TIME=`date +%y%m%d-%H%M`
# Note: svn does not exist on the compute nodes, so this line won't work
ADVPOWER_REPO_VER=`svnversion ~/projects/advpower`
RESULT_PATH='~/projects/advpower/results/'

RESULT_FILE="${RESULT_PATH}${DATE_TIME}_${COMMAND_FOR_FILENAME}_v${ADVPOWER_REPO_VER}_${PBS_JOBID}"

#Now run MATLAB and save the log file and results
echo "Running ${MATLAB_COMMAND} using MATLAB."
echo "Output in ${RESULT_FILE}"
matlab -r "RunSaveExit('${MATLAB_COMMAND}', '${RESULT_FILE}.mat')" -logfile "${RESULT_FILE}.log"
echo 'MATLAB Done'

#Clean-up scratch space
echo "Cleaning up our Scratch Space"
cd
rm -r /scratch/b_p/*

