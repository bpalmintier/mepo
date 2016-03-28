#!/bin/bash
#
# Simple MATLAB script to run a matlab job on the svante cluster.
#
# To actually submit the job use:
#   qsub SCRIPT_NAME

#  Version History
# Ver   Date       Time  Who            What
# ---  ----------  ----- -------------- ---------------------------------
#   1  2011-04-20         bpalmintier   Original version(s)
#   2  2011-06-17         bpalmintier   Added GAMS support & dynamic output filenames
#   3  2011-06-18  17:46  bpalmintier   Fixed typos
#   4  2011-07-08  09:22  bpalmintier   Added CPLEX loading
#   5  2011-07-08  11:30  bpalmintier   Converted to bash, fixed log file bug, use default job name
#   6  2011-07-11  00:30  bpalmintier   More info on queue options, add job to outfile names, corrected time bug
#   7  2011-07-11  09:45  bpalmintier   Explicitly add *.mat extension for file output
#   8  2011-07-11  15:00  bpalmintier   Switch to 8 cores, get svn repo version on-the-fly



#========= Setup Job Queue Parameters ==========
# IMPORTANT: The lines beginning #PBS set various queuing parameters, they are not simple comments
#
# Set name of submitted job, also name of output file unless specified
##PBS -N matlab_pbs
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
# And up the run time to the maximum of a full week
##PBS -l walltime=168:00:00

echo 'Node list:'
cat  $PBS_NODEFILE

#Set things up to load modules
source /etc/profile.d/modules.sh

#Load most recent version of MATLAB
module load matlab/2010a

#And most recent version of GAMS
module load gams/23.6.3

#Set path to gams in environment variable so MATLAB can read it
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
MATLAB_COMMAND="Results50=RunSimsFutureLowCO2([],[],''UnitCommit'',[],50000, true,[],[],''both'')"
COMMAND_FOR_FILENAME="RunSimsFutureLowCO2_08_50GW"
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
