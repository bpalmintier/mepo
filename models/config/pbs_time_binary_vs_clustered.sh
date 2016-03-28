#!/bin/bash
#
# Simple BASH script to run and time a series of GAMS jobs to compare the run
# time of binary vs clustered unit commitment both with and without capacity
# expansion decisions
#
# To actually submit the job use:
#   qsub SCRIPT_NAME

#  Version History
# Ver   Date       Time  Who            What
# ---  ----------  ----- -------------- ---------------------------------
#   1  2011-07-24  19:20  bpalmintier   Adapted from pbs_gams.sh v2
#   2  2011-07-26  09:50  bpalmintier   Moved to out3 for 1.2x tests
#   3  2011-10-06  02:50  bpalmintier   Overhaul for UnitCommit tests

#========= Setup Job Queue Parameters ==========
# IMPORTANT: The lines beginning #PBS set various queuing parameters, they are not simple comments
#
# name of submitted job, also name of output file unless specified
# The default job name is the name of this script, so here we surpress the job naming so
# we get unique names for all of our jobs
##PBS -N matlab_pbs
#
# Ask for all 1 node with 8 processors. this may or may not give
# exclusive access to a machine, but typically the queueing system will
# assign the 8 core machines first
#
# By requiring 20GB we ensure we get one of the machines with 24GB (or maybe a 12 core unit)
#PBS -l nodes=1:ppn=8,mem=20gb
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
# And up the run time to the maximum of a full week (168 hrs)
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
cd ~/projects/advpower/models/ops
pwd

#----------------------------
# Setup gams options
#----------------------------
DATE_TIME=`date +%y%m%d-%H%M`
ADVPOWER_REPO_VER=`svnversion ~/projects/advpower`
echo "Date & Time:" ${DATE_TIME}
echo "SVN Repository Version:" ${ADVPOWER_REPO_VER}

OUT_DIR="out/"
GAMS_MODEL="UnitCommit"

#--Clustered 1 week IEEE RTS
RUN_CODE="RTSx1_clust_wk_"
GAMS_OPTIONS="-errmsg=1 --out_dir=${OUT_DIR} --out_prefix=${RUN_CODE} -lf=${OUT_DIR}${RUN_CODE}${GAMS_MODEL}.log -lo=2 -o=${OUT_DIR}${RUN_CODE}${GAMS_MODEL}.lst --par_threads=1 --memo=${RUN_CODE}run_time_compare_v${ADVPOWER_REPO_VER}_${DATE_TIME} --sys=ieee_rts96_sys.inc --min_up_down=1 --startup=1 --ramp=1 --rsrv=separate --no_nse=1 --demscale=0.92 --pwl_cost=1 --demand=ieee_rts96_dem_wk.inc"

#Now run CPLEX
echo "Running ${GAMS_MODEL} using GAMS"
echo "  Options: ${GAMS_OPTIONS}"
gams ${GAMS_MODEL} ${GAMS_OPTIONS}
echo 'GAMS Done'


#--Clustered 1 week IEEE RTS with Cheat
RUN_CODE="RTSx1_clust_wk_ch10"
GAMS_OPTIONS="-errmsg=1 --out_dir=${OUT_DIR} --out_prefix=${RUN_CODE} -lf=${OUT_DIR}${RUN_CODE}${GAMS_MODEL}.log -lo=2 -o=${OUT_DIR}${RUN_CODE}${GAMS_MODEL}.lst --par_threads=1 --memo=${RUN_CODE}run_time_compare_v${ADVPOWER_REPO_VER}_${DATE_TIME} --sys=ieee_rts96_sys.inc --min_up_down=1 --startup=1 --ramp=1 --rsrv=separate --no_nse=1 --demscale=0.92 --pwl_cost=1 --demand=ieee_rts96_dem_wk.inc --cheat=10"

#Now run CPLEX
echo "Running ${GAMS_MODEL} using GAMS"
echo "  Options: ${GAMS_OPTIONS}"
gams ${GAMS_MODEL} ${GAMS_OPTIONS}
echo 'GAMS Done'


#--Separate 1 week IEEE RTS with Cheat
RUN_CODE="RTSx1_sep_wk_ch10"
GAMS_OPTIONS="-errmsg=1 --out_dir=${OUT_DIR} --out_prefix=${RUN_CODE} -lf=${OUT_DIR}${RUN_CODE}${GAMS_MODEL}.log -lo=2 -o=${OUT_DIR}${RUN_CODE}${GAMS_MODEL}.lst --par_threads=1 --memo=${RUN_CODE}run_time_compare_v${ADVPOWER_REPO_VER}_${DATE_TIME} --sys=ieee_rts96_sys.inc --min_up_down=1 --startup=1 --ramp=1 --rsrv=separate --no_nse=1 --demscale=0.92 --pwl_cost=1 --demand=ieee_rts96_dem_wk.inc --gens=ieee_rts96_gens_sepunit.inc --max_solve_time=36000 --cheat=10"

#Now run CPLEX
echo "Running ${GAMS_MODEL} using GAMS"
echo "  Options: ${GAMS_OPTIONS}"
gams ${GAMS_MODEL} ${GAMS_OPTIONS}
echo 'GAMS Done'
