#!/bin/bash
#
# Thesis Ch4: When does UC matter Grid HEADER
#   ERCOT 2007, min 200MW gen, Year as 52 weeks
#   Full Ops w/ Maintenance, 80MW min UC integer, non-parallel
#   No B&B priority, No cheat, No cap limit helper
#
# To actually submit the job use:
#   qsub SCRIPT_NAME

#+++++++++++++++++  TEMPLATE GAMS-CPLEX Header +++++++++++++++++
#    No printf parameters

#  Version History
# Ver   Date       Time  Who            What
# ---  ----------  ----- -------------- ---------------------------------
#   1  2012-08-24  00:20  bpalmintier   TEMPLATE based on whenUC_t12 (whenUC_base v4)
#   2  2012-08-25  09:25  bpalmintier   Correct renew_to_rps to match StaticCapPlan v82. It was & still is disabled.

# Simple BASH script to run and time a series of GAMS jobs to compare the run
# time of binary vs clustered unit commitment both with and without capacity
# expansion decisions
#
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
#PBS -l nodes=1:ppn=12,mem=40gb
#
# This option merges any error messages into output file
#PBS -j oe 
#
# Select the queue based on maximum run times. OPT are:
#    short    2hr
#    medium   8hr
#    long    24hr
#    xlong   48hr, extendable to 168hr using -l walltime= option below
#PBS -q xlong
# And up the run time to the maximum of a full week (168 hrs)
#PBS -l walltime=62:00:00

echo "Node list:"
cat  $PBS_NODEFILE

echo "Disk usage:"
df -h

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

#Clean anything out of our scratch folder (Assumes exclusive machine usage)
rm -r /scratch/b_p/*

#Make a new subfolder for this job
SCRATCH="/scratch/b_p/${PBS_JOBID}"
mkdir $SCRATCH

#Establish our model directory
MODEL_DIR="${HOME}/projects/advpower/models/capplan/"

#----------------------------
# Setup gams OPT
#----------------------------
DATE_TIME=`date +%y%m%d-%H%M`
ADVPOWER_REPO_VER=`svnversion ~/projects/advpower`
echo "Date & Time:" ${DATE_TIME}
echo "SVN Repository Version:" ${ADVPOWER_REPO_VER}

GAMS_MODEL="StaticCapPlan"

#======= Shared Setup =======
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
ALL_RUN_OPT=" --sys=thesis_sys.inc --min_gen_size=0.2 --plan_margin=on --skip_cap_limit=1"
# Options common to the runs in this file
THIS_FILE_OPT="${ALL_RUN_OPT} --maint=1  --demand=ercot2007_dem_yr_as_52wk.inc --retire=0.5 "

# Note: 210000sec=58hrs
LONG_OPT=" "
PAR_OPT=" --par_threads=3 --lp_method=6 --par_mode=-1 --probe=2 "

#+++++++++++++++++ END HEADER +++++++++++++++++
#+++++++++++++++++ Repeated GAMS running Template +++++++++++++++++
# Template requires 2 (printf style) substitutions:
#     string     run_id
#     string     gams_options
#
# See header template for version information

RUN_CODE="whenUC_simp_cmx47_r60"

#Make a temporary run directory in scratch
WORK_DIR="${SCRATCH}/tmp_${RUN_CODE}/"
mkdir ${WORK_DIR}
cp ${MODEL_DIR}${GAMS_MODEL}.gms  ${WORK_DIR}
cd ${WORK_DIR}

echo "${GAMS_MODEL} copied to temporary ${WORK_DIR}"
pwd

# Setup run specific OPT
# Note reduced planning margin b/c computing reserves directly
RUN_OPT="   --max_solve_time=216000 --co2cap=47 --rps=0.6 --maint=1 --derate=1 --plan_margin=on  "
SHARE_OPT=" ${LONG_OPT} ${THIS_FILE_OPT} "
IO_OPT=" ${COMMON_IO_OPT} -lf=${OUT_DIR}${RUN_CODE}_${GAMS_MODEL}.log -o=${OUT_DIR}${RUN_CODE}_${GAMS_MODEL}.lst --out_prefix=${RUN_CODE}_ --memo=${RUN_CODE}_v${ADVPOWER_REPO_VER}_${DATE_TIME} "

#Now run GAMS-CPLEX
echo "--- GAMS Run code ${RUN_CODE} ---"
echo "  GAMS Model ${GAMS_MODEL}"
echo "  IO OPT ${IO_OPT}"
echo "  Shared OPT: ${SHARE_OPT}"
echo "  Run OPT: ${RUN_OPT}"
echo .
gams ${GAMS_MODEL} ${IO_OPT} ${SHARE_OPT} ${RUN_OPT} &

cd ${MODEL_DIR}
pwd

#+++++++++++++++++ Repeated GAMS running Template +++++++++++++++++
# Template requires 2 (printf style) substitutions:
#     string     run_id
#     string     gams_options
#
# See header template for version information

RUN_CODE="whenUC_edRsv_cmx47_r60_sep"

#Make a temporary run directory in scratch
WORK_DIR="${SCRATCH}/tmp_${RUN_CODE}/"
mkdir ${WORK_DIR}
cp ${MODEL_DIR}${GAMS_MODEL}.gms  ${WORK_DIR}
cd ${WORK_DIR}

echo "${GAMS_MODEL} copied to temporary ${WORK_DIR}"
pwd

# Setup run specific OPT
# Note reduced planning margin b/c computing reserves directly
RUN_OPT="   --max_solve_time=216000 --uc_ignore_unit_min=Inf --co2cap=47 --rps=0.6 --maint=1 --rsrv=separate --plan_margin=0.05  "
SHARE_OPT=" ${LONG_OPT} ${THIS_FILE_OPT} "
IO_OPT=" ${COMMON_IO_OPT} -lf=${OUT_DIR}${RUN_CODE}_${GAMS_MODEL}.log -o=${OUT_DIR}${RUN_CODE}_${GAMS_MODEL}.lst --out_prefix=${RUN_CODE}_ --memo=${RUN_CODE}_v${ADVPOWER_REPO_VER}_${DATE_TIME} "

#Now run GAMS-CPLEX
echo "--- GAMS Run code ${RUN_CODE} ---"
echo "  GAMS Model ${GAMS_MODEL}"
echo "  IO OPT ${IO_OPT}"
echo "  Shared OPT: ${SHARE_OPT}"
echo "  Run OPT: ${RUN_OPT}"
echo .
gams ${GAMS_MODEL} ${IO_OPT} ${SHARE_OPT} ${RUN_OPT} &

cd ${MODEL_DIR}
pwd

#+++++++++++++++++ Repeated GAMS running Template +++++++++++++++++
# Template requires 2 (printf style) substitutions:
#     string     run_id
#     string     gams_options
#
# See header template for version information

RUN_CODE="whenUC_uclp_cmx47_r60_sep"

#Make a temporary run directory in scratch
WORK_DIR="${SCRATCH}/tmp_${RUN_CODE}/"
mkdir ${WORK_DIR}
cp ${MODEL_DIR}${GAMS_MODEL}.gms  ${WORK_DIR}
cd ${WORK_DIR}

echo "${GAMS_MODEL} copied to temporary ${WORK_DIR}"
pwd

# Setup run specific OPT
# Note reduced planning margin b/c computing reserves directly
RUN_OPT="   --max_solve_time=216000 --uc_int_unit_min=Inf --co2cap=47 --rps=0.6 --maint=1 --rsrv=separate --ramp=1 --unit_commit=1 --startup=1 --min_up_down=1 --plan_margin=0.05  "
SHARE_OPT=" ${LONG_OPT} ${THIS_FILE_OPT} "
IO_OPT=" ${COMMON_IO_OPT} -lf=${OUT_DIR}${RUN_CODE}_${GAMS_MODEL}.log -o=${OUT_DIR}${RUN_CODE}_${GAMS_MODEL}.lst --out_prefix=${RUN_CODE}_ --memo=${RUN_CODE}_v${ADVPOWER_REPO_VER}_${DATE_TIME} "

#Now run GAMS-CPLEX
echo "--- GAMS Run code ${RUN_CODE} ---"
echo "  GAMS Model ${GAMS_MODEL}"
echo "  IO OPT ${IO_OPT}"
echo "  Shared OPT: ${SHARE_OPT}"
echo "  Run OPT: ${RUN_OPT}"
echo .
gams ${GAMS_MODEL} ${IO_OPT} ${SHARE_OPT} ${RUN_OPT} &

cd ${MODEL_DIR}
pwd

#+++++++++++++++++ Repeated GAMS running Template +++++++++++++++++
# Template requires 2 (printf style) substitutions:
#     string     run_id
#     string     gams_options
#
# See header template for version information

RUN_CODE="whenUC_full_int60_cmx47_r60_sep"

#Make a temporary run directory in scratch
WORK_DIR="${SCRATCH}/tmp_${RUN_CODE}/"
mkdir ${WORK_DIR}
cp ${MODEL_DIR}${GAMS_MODEL}.gms  ${WORK_DIR}
cd ${WORK_DIR}

echo "${GAMS_MODEL} copied to temporary ${WORK_DIR}"
pwd

# Setup run specific OPT
# Note reduced planning margin b/c computing reserves directly
RUN_OPT="   --max_solve_time=216000 --uc_int_unit_min=0.06 --co2cap=47 --rps=0.6 --maint=1 --rsrv=separate --ramp=1 --unit_commit=1 --startup=1 --min_up_down=1 --plan_margin=0.05  "
SHARE_OPT=" ${LONG_OPT} ${THIS_FILE_OPT} "
IO_OPT=" ${COMMON_IO_OPT} -lf=${OUT_DIR}${RUN_CODE}_${GAMS_MODEL}.log -o=${OUT_DIR}${RUN_CODE}_${GAMS_MODEL}.lst --out_prefix=${RUN_CODE}_ --memo=${RUN_CODE}_v${ADVPOWER_REPO_VER}_${DATE_TIME} "

#Now run GAMS-CPLEX
echo "--- GAMS Run code ${RUN_CODE} ---"
echo "  GAMS Model ${GAMS_MODEL}"
echo "  IO OPT ${IO_OPT}"
echo "  Shared OPT: ${SHARE_OPT}"
echo "  Run OPT: ${RUN_OPT}"
echo .
gams ${GAMS_MODEL} ${IO_OPT} ${SHARE_OPT} ${RUN_OPT} &

cd ${MODEL_DIR}
pwd

#+++++++++++++++++ Repeated GAMS running Template +++++++++++++++++
# Template requires 2 (printf style) substitutions:
#     string     run_id
#     string     gams_options
#
# See header template for version information

RUN_CODE="whenUC_simp_cmx47_r80"

#Make a temporary run directory in scratch
WORK_DIR="${SCRATCH}/tmp_${RUN_CODE}/"
mkdir ${WORK_DIR}
cp ${MODEL_DIR}${GAMS_MODEL}.gms  ${WORK_DIR}
cd ${WORK_DIR}

echo "${GAMS_MODEL} copied to temporary ${WORK_DIR}"
pwd

# Setup run specific OPT
# Note reduced planning margin b/c computing reserves directly
RUN_OPT="   --max_solve_time=216000 --co2cap=47 --rps=0.8 --maint=1 --derate=1 --plan_margin=on  "
SHARE_OPT=" ${LONG_OPT} ${THIS_FILE_OPT} "
IO_OPT=" ${COMMON_IO_OPT} -lf=${OUT_DIR}${RUN_CODE}_${GAMS_MODEL}.log -o=${OUT_DIR}${RUN_CODE}_${GAMS_MODEL}.lst --out_prefix=${RUN_CODE}_ --memo=${RUN_CODE}_v${ADVPOWER_REPO_VER}_${DATE_TIME} "

#Now run GAMS-CPLEX
echo "--- GAMS Run code ${RUN_CODE} ---"
echo "  GAMS Model ${GAMS_MODEL}"
echo "  IO OPT ${IO_OPT}"
echo "  Shared OPT: ${SHARE_OPT}"
echo "  Run OPT: ${RUN_OPT}"
echo .
gams ${GAMS_MODEL} ${IO_OPT} ${SHARE_OPT} ${RUN_OPT} &

cd ${MODEL_DIR}
pwd

#+++++++++++++++++ Repeated GAMS running Template +++++++++++++++++
# Template requires 2 (printf style) substitutions:
#     string     run_id
#     string     gams_options
#
# See header template for version information

RUN_CODE="whenUC_edRsv_cmx47_r80_sep"

#Make a temporary run directory in scratch
WORK_DIR="${SCRATCH}/tmp_${RUN_CODE}/"
mkdir ${WORK_DIR}
cp ${MODEL_DIR}${GAMS_MODEL}.gms  ${WORK_DIR}
cd ${WORK_DIR}

echo "${GAMS_MODEL} copied to temporary ${WORK_DIR}"
pwd

# Setup run specific OPT
# Note reduced planning margin b/c computing reserves directly
RUN_OPT="   --max_solve_time=216000 --uc_ignore_unit_min=Inf --co2cap=47 --rps=0.8 --maint=1 --rsrv=separate --plan_margin=0.05  "
SHARE_OPT=" ${LONG_OPT} ${THIS_FILE_OPT} "
IO_OPT=" ${COMMON_IO_OPT} -lf=${OUT_DIR}${RUN_CODE}_${GAMS_MODEL}.log -o=${OUT_DIR}${RUN_CODE}_${GAMS_MODEL}.lst --out_prefix=${RUN_CODE}_ --memo=${RUN_CODE}_v${ADVPOWER_REPO_VER}_${DATE_TIME} "

#Now run GAMS-CPLEX
echo "--- GAMS Run code ${RUN_CODE} ---"
echo "  GAMS Model ${GAMS_MODEL}"
echo "  IO OPT ${IO_OPT}"
echo "  Shared OPT: ${SHARE_OPT}"
echo "  Run OPT: ${RUN_OPT}"
echo .
gams ${GAMS_MODEL} ${IO_OPT} ${SHARE_OPT} ${RUN_OPT} &

cd ${MODEL_DIR}
pwd

#+++++++++++++++++ Repeated GAMS running Template +++++++++++++++++
# Template requires 2 (printf style) substitutions:
#     string     run_id
#     string     gams_options
#
# See header template for version information

RUN_CODE="whenUC_uclp_cmx47_r80_sep"

#Make a temporary run directory in scratch
WORK_DIR="${SCRATCH}/tmp_${RUN_CODE}/"
mkdir ${WORK_DIR}
cp ${MODEL_DIR}${GAMS_MODEL}.gms  ${WORK_DIR}
cd ${WORK_DIR}

echo "${GAMS_MODEL} copied to temporary ${WORK_DIR}"
pwd

# Setup run specific OPT
# Note reduced planning margin b/c computing reserves directly
RUN_OPT="   --max_solve_time=216000 --uc_int_unit_min=Inf --co2cap=47 --rps=0.8 --maint=1 --rsrv=separate --ramp=1 --unit_commit=1 --startup=1 --min_up_down=1 --plan_margin=0.05  "
SHARE_OPT=" ${LONG_OPT} ${THIS_FILE_OPT} "
IO_OPT=" ${COMMON_IO_OPT} -lf=${OUT_DIR}${RUN_CODE}_${GAMS_MODEL}.log -o=${OUT_DIR}${RUN_CODE}_${GAMS_MODEL}.lst --out_prefix=${RUN_CODE}_ --memo=${RUN_CODE}_v${ADVPOWER_REPO_VER}_${DATE_TIME} "

#Now run GAMS-CPLEX
echo "--- GAMS Run code ${RUN_CODE} ---"
echo "  GAMS Model ${GAMS_MODEL}"
echo "  IO OPT ${IO_OPT}"
echo "  Shared OPT: ${SHARE_OPT}"
echo "  Run OPT: ${RUN_OPT}"
echo .
gams ${GAMS_MODEL} ${IO_OPT} ${SHARE_OPT} ${RUN_OPT} &

cd ${MODEL_DIR}
pwd

#+++++++++++++++++ Repeated GAMS running Template +++++++++++++++++
# Template requires 2 (printf style) substitutions:
#     string     run_id
#     string     gams_options
#
# See header template for version information

RUN_CODE="whenUC_full_int60_cmx47_r80_sep"

#Make a temporary run directory in scratch
WORK_DIR="${SCRATCH}/tmp_${RUN_CODE}/"
mkdir ${WORK_DIR}
cp ${MODEL_DIR}${GAMS_MODEL}.gms  ${WORK_DIR}
cd ${WORK_DIR}

echo "${GAMS_MODEL} copied to temporary ${WORK_DIR}"
pwd

# Setup run specific OPT
# Note reduced planning margin b/c computing reserves directly
RUN_OPT="   --max_solve_time=216000 --uc_int_unit_min=0.06 --co2cap=47 --rps=0.8 --maint=1 --rsrv=separate --ramp=1 --unit_commit=1 --startup=1 --min_up_down=1 --plan_margin=0.05  "
SHARE_OPT=" ${LONG_OPT} ${THIS_FILE_OPT} "
IO_OPT=" ${COMMON_IO_OPT} -lf=${OUT_DIR}${RUN_CODE}_${GAMS_MODEL}.log -o=${OUT_DIR}${RUN_CODE}_${GAMS_MODEL}.lst --out_prefix=${RUN_CODE}_ --memo=${RUN_CODE}_v${ADVPOWER_REPO_VER}_${DATE_TIME} "

#Now run GAMS-CPLEX
echo "--- GAMS Run code ${RUN_CODE} ---"
echo "  GAMS Model ${GAMS_MODEL}"
echo "  IO OPT ${IO_OPT}"
echo "  Shared OPT: ${SHARE_OPT}"
echo "  Run OPT: ${RUN_OPT}"
echo .
gams ${GAMS_MODEL} ${IO_OPT} ${SHARE_OPT} ${RUN_OPT} &

cd ${MODEL_DIR}
pwd

#=== Footer Template ====
#  No printf parameters
#
# See header template for version information

#Wait until all background jobs are complete
wait

echo "GAMS Done (All runs)"
echo .

#See how much disk space we used
df -h

#Clean-up scratch space
echo "Cleaning up our Scratch Space"
cd
rm -r /scratch/b_p/*

df -h

echo "Script Complete ${PBS_JOBID}"

