#!/bin/bash
#
# Simple MATLAB script to run part of a "2x2 scenario" matlab job on the svante cluster.
#
# To actually submit the job use:
#   qsub SCRIPT_NAME

#  Version History
# Ver   Date       Time  Who            What
# ---  ----------  ----- -------------- ---------------------------------
#   1  2012               bpalmintier   Generic MATLAB cluster script
#   2  2012-06-15  14:35  bpalmintier   Adapted for 2x2 scenario runs
#   3  2012-06-17  15:00  bpalmintier   Adjusted options: capital: upfront, co2lim:default (20% BAU)



#========= Setup Job Queue Parameters ==========
# IMPORTANT: The lines beginning #PBS set various queuing parameters, they are not simple comments
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
#PBS -q short
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
# >>>>>>>>>>>>>>>>>>>>>>>> Only need to change the following lines <<<<<<<<<<<<<<<<<<<<<<<<<<
OPS_TYPE="simple"
CO2LIM_TYPE="ev"
GEN_BIN="20"
OTHER_OPTS="''growth_base'', 0.02, ''n_periods'',2, ''coal_ccs_cost_factor'', 0.5"
#Standard Run options (probably no changes needed)
RUN_OPTS="''dp'', 1, ''adp'', 0, ''parallel'', 1, ''run_on_init'', 1"
# >>>>>>>>>>>>>>>>>>>>>>>> End Change block <<<<<<<<<<<<<<<<<<<<<<<<<<
RUN_CODE="s2x2_g${GEN_BIN}_${OPS_TYPE}_${CO2LIM_TYPE}_dp"
MATLAB_COMMAND="${RUN_CODE} = scen2by2(${RUN_OPTS},  ${OTHER_OPTS}, ''min_bin_size'', ${GEN_BIN}, ''ops_type'', ''${OPS_TYPE}'', ''co2lim_type'',''${CO2LIM_TYPE}'');"


DATE_TIME=`date +%y%m%d-%H%M`
# Note: svn does not exist on the compute nodes, so this line won't work
ADVPOWER_REPO_VER=`svnversion ~/projects/advpower`
RESULT_PATH='~/projects/advpower/results/'

RESULT_FILE="${RESULT_PATH}${DATE_TIME}_${RUN_CODE}_v${ADVPOWER_REPO_VER}_${PBS_JOBID}"

#Now run MATLAB and save the log file and results
echo "Running ${MATLAB_COMMAND} using MATLAB."
echo "Output in ${RESULT_FILE}"
matlab -r "RunSaveExit('${MATLAB_COMMAND}', '${RESULT_FILE}.mat')" -logfile "${RESULT_FILE}.log"
echo 'MATLAB Done'

#Clean-up scratch space
echo "Cleaning up our Scratch Space"
cd
rm -r /scratch/b_p/*

