#!/bin/bash
#
# Simple MATLAB script to run a matlab job on the svante cluster.
#
# To actually submit the job use:
#   qsub SCRIPT_NAME

#  Version History
# Ver   Date       Time  Who            What
# ---  ----------  ----- -------------- ---------------------------------
#   1  2011-07-08  09:20  bpalmintier   Adapted from pbs_matlab.sh v3
#   2  2011-07-08  11:30  bpalmintier   Converted to bash, fixed log file bug, use default job name
#   3  2011-07-08  11:50  bpalmintier   only request 8 cores
#   4  2011-07-11  00:30  bpalmintier   More info on queue options, add job to outfile names, corrected time bug
#   5  2011-07-11  09:45  bpalmintier   Explicitly add *.mat extension for file output
#   6  2011-07-11  14:00  bpalmintier   get svn repo version on-the-fly


#========= Setup Job Queue Parameters ==========
# IMPORTANT: The lines beginning #PBS various queuing parameters, they are not simple comments
#
# name of submitted job, also name of output file unless specified
# The default job name is the name of this script, so here we surpress the job naming so
# we get unique names for all of our jobs
##PBS -N matlab_pbs
#
# Ask for all 1 node with 8 processors (the max MATLAB can use) this may or may not give
# exclusive access to a machine, since there are some nodes with 12 cores, but the 12 core nodes
# have so much memory, we should be fine sharing
#PBS -l nodes=1:ppn=12,mem=20gb
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
# And up the run time to the maximum of a full week (xlong queue only)
##PBS -l walltime=120:00:00

echo 'Node list:'
cat  $PBS_NODEFILE

#things up to load modules
source /etc/profile.d/modules.sh

#Load most recent version of MATLAB (now defaults to 2011a)
module load matlab

#And most recent version of GAMS
module load gams/23.6.3

#path to gams in environment variable so MATLAB can read it
GAMS=`which gams`
export GAMS

#And load CPLEX
module load cplex

#Change to our working directory
cd ~/projects/advpower/models/MATLAB
pwd

#----------------------------
# Setup matlab script options
#----------------------------
#Manually change OUR_NUM over the range 1:10 to submit similar jobs in parallel
#OUR_NUM="1"
#MATLAB_COMMAND="tic, AutomateOpsRuns('../data/EnvPolScen_state_list_rps05_20_50',10,${OUR_NUM},'svante:3306'), toc"
#COMMAND_FOR_FILENAME="AutomateOpsRuns_${OUR_NUM}"
COMMAND_FOR_FILENAME="EnvPolicyScenarios_r20_4gw_RsrvOps"
MATLAB_COMMAND="RunSaveExit('[SpSummary, SpParams, SpValues, SpBuild, OpsCache] = RunEnvPolicyScenarios(1:7, [], ''OpsLp'', 0.20, 4000, true)','${COMMAND_FOR_FILENAME}_${PBS_JOBID}.mat')"
DATE_TIME=`date +%y%m%d-%H%M`
# Yay svnversion now works
ADVPOWER_REPO_VER=`svnversion ~/projects/advpower`
RESULT_PATH='~/projects/advpower/results/'

RESULT_FILE="${RESULT_PATH}${DATE_TIME}_${COMMAND_FOR_FILENAME}_v${ADVPOWER_REPO_VER}_${PBS_JOBID}"

#Now run MATLAB and save the log file and results
echo "Running ${MATLAB_COMMAND} using MATLAB."
echo "Output in ${RESULT_FILE}"
matlab -r "${MATLAB_COMMAND}" -logfile "${RESULT_FILE}.log"
echo 'MATLAB Done'
