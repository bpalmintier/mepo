#!/bin/bash
#
# GAMS whenUC FULL OPERATIONS run script for use as a sub-function to pbs_array or other calls 
#  IMPORTANT: first option must be the output directory
#
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
#   source whenUC_opsrun.sh OUT_DIR RUN_ID [RUN_OPTIONS...]
#
# Sets up up the enviroment, copies the model, and actually runs it.

#  Version History
# Ver   Date       Time  Who            What
# ---  ----------  ----- -------------- ---------------------------------
#   1  2012-09-20  23:35  bpalmintier   Adapted from whenUC_runops.sh v3
#   2  2012-10-05  11:20  bpalmintier   Strip off _rerun from RUN_CODE if needed for capacity file

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

# Strip rerun suffix from RUN_CODE if needed
CAP_RUN_CODE=`echo "$RUN_CODE" | sed "s/_rerun//"`

# Create update file
CAP_FILE="${OUT_DIR}/${CAP_RUN_CODE}_summary.csv"
UPDATE_FILE="${OUT_DIR}/${CAP_RUN_CODE}_update.inc"

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
	RUN_OPT=" ${SCEN_OPT} --update=${OUT_DIR}/${CAP_RUN_CODE}_update.inc --uc_int_unit_min=0.06 --maint=1 --rsrv=separate --ramp=1 --unit_commit=1 --startup=1 --min_up_down=1 "
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
