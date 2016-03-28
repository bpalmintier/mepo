#!/bin/bash
#
# GAMS whenUC FULL OPERATIONS run script for use as a sub-function to pbs_array or other calls 
#  (-t option with openpbs/torque)
#  Steps involved:
#   1) Create a capacity update file for GAMS based on the Extracted total capacity results
#        from the corresponding planning run. Store in the output directory.
#   2) Copy this update file to scratch
#   3) Run the planning model as a full unit commitment model with the planning model in fixed
#       capacity mode.
#
#
# Usage:
#   source whenUC_opsrun.sh RUN_ID [RUN_OPTIONS...]
#
# Sets up up the enviroment, copies the model, and actually runs it.

#  Version History
# Ver   Date       Time  Who            What
# ---  ----------  ----- -------------- ---------------------------------
#   1  2012-08-30         bpalmintier   Adapted from whenUC_run.sh v1
#   2  2012-08-30         bpalmintier   Overhaul to adjust run codes, write update file, etc.
#   3  2012-08-25  17:15  bpalmintier   BUGFIX: correct keeping co2 & rps data (setting SCEN_OPT)

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

# Strip off run options except RPS & CO2 price/cap info
#  IMPORTANT assumes co2 info precedes rps
# echo ... | pass the value of the variable to the next command to a pipe
#
# perl
#  -p implicit while loop & print results
#  -e single line expression
# regular expression substitution
#  s/OLD/NEW/
#  OLD matches the entire string as follows:
#    .*      everything before co2cap or co2cost. This eliminates from output
#    ((?:--co2cap=[^ ]+)|(?:--co2cost=[^ ]+))
#       extract either the co2cap or co2cost options
#    		(?:)    group but don't assign to variable
#    		|       this group or that
#    		()      assign to variable \1
#    .*      everything between co2 and rps.
#    (--rps=[^ ]+)
#		rps option & level & save as \2
#    .*      everything after rps.
#
# As a result NEW will have only
#    \1    the co2 info
#    \2    the rps info
SCEN_OPT=`echo "$RUN_OPT" | perl -pe "s/.*((?:--co2cap=[^ ]+)|(?:--co2cost=[^ ]+)).*(--rps=[^ ]+).*/ \1 \2 / "`

# Create update file
CAP_FILE="${OUT_DIR}/${RUN_CODE}_summary.csv"
UPDATE_FILE="${OUT_DIR}/${RUN_CODE}_update.inc"

# Check that summary file exists
if [ ! -f ${CAP_FILE} ]; then
	echo "ABORT: Summary file not available to extract capacities (${CAP_FILE})"
else
	echo "Creating Update file (${UPDATE_FILE})"
	perl -ne "s/cap_total_GW_([^,]+),\s+(.+)/pGen('\1','cap_cur',S)=\2;/ && print" \
		< ${CAP_FILE} \
		> ${UPDATE_FILE}
	
	#Set BEFORE updating run code
	SHARE_OPT=" ${LONG_OPT} ${THIS_FILE_OPT} "
	
	# Update run code and options for this Ops Run
	RUN_OPT=" ${SCEN_OPT} --update=${OUT_DIR}/${RUN_CODE}_update.inc --uc_int_unit_min=0.06 --maint=1 --rsrv=separate --ramp=1 --unit_commit=1 --startup=1 --min_up_down=1 "
	RUN_CODE="${RUN_CODE}_ops"
	
	#Set AFTER updating run code
	IO_OPT=" ${COMMON_IO_OPT} -lf=${OUT_DIR}${RUN_CODE}_${GAMS_MODEL}.log -o=${OUT_DIR}${RUN_CODE}_${GAMS_MODEL}.lst --out_prefix=${RUN_CODE}_ --memo=${RUN_CODE}_v${ADVPOWER_REPO_VER}_${DATE_TIME} "
	
	# Copy files to work directory
	cp ${MODEL_DIR}/${GAMS_MODEL}.gms  ${WORK_DIR}
	echo "${GAMS_MODEL} copied to temporary ${WORK_DIR}"
	cp ${UPDATE_FILE}  ${WORK_DIR}
	echo "${UPDATE_FILE} copied to temporary ${WORK_DIR}"
	
	# Change to working directory
	cd ${WORK_DIR}
	pwd
	
	#----------------------------
	# Now run GAMS-CPLEX
	#----------------------------
	echo ""
	echo "Running GAMS (#${PBS_ARRAYID}: ${RUN_CODE} )"
	echo "  IO OPT ${IO_OPT}"
	echo "  Shared OPT: ${SHARE_OPT}"
	echo "  (Ops) Run OPT: ${RUN_OPT}"
	echo ""
	gams ${GAMS_MODEL} ${IO_OPT} ${SHARE_OPT} ${RUN_OPT}
	
	echo "GAMS Done! (#${PBS_ARRAYID}: ${RUN_CODE} )"
fi
echo ""
