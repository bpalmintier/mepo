#!/bin/bash

# =======  TEMPLATE for GAMS-CPLEX ========
#
# Simple BASH script runs a single GAMS/CPLEX job on the Svante cluster. It 
# copies the gams model file to the compute node's scratch folder such that all 
# of the GAMS/CPLEX temporary files are accessed locally without the delay of
# network traffic and without interfering with other users by potentially
# bogging down the file server
#
# To modify this script for your own use, look for the lines with >>>>>
#
# To actually submit the job use:
#   qsub SCRIPT_NAME
#
# NOTE: This is a BASH script, The magic "#!..." line above will cause this
# script to be run using the bash (Bourne Again SHell) when you submit it to the
# queue, but if you want to test  line by line and you are not using bash, you
# have to explicitly switch (temporarily) to using the bash shell by typing
# "bash" at the command line. This is only necessary for users whose default
# shell is csh (C-SHell) or tcsh (an enhanced CSH) and then only for
# line-by-line testing. You can determine which shell you are using by typing
# "echo $shell" 

#  Version History
# Ver   Date       Time  Who            What
# ---  ----------  ----- -------------- ---------------------------------
#   1  2012-04-10  11:55  bpalmintier   Adapted from plan_batch_1.sh v2

#========= Setup Job Queue Parameters ==========
# IMPORTANT: The lines beginning #PBS set various queuing parameters, they 
# are not simple comments, to disable them add a second # as in ##PBS
#
# The default job name is the name of this script, if desired you can specify
# an alternate name here
##PBS -N Other_job_name
#
# Request resources
# For GAMS/CPLEX we typically only want one machine (nodes=1) and then want 
# specify the number of processors on that node (ppn). You can also specify
# a minimum amount of free memory. This is useful to distinguish between the 8
# core nodes with 12 vs 24 gb of ram
#
# To be a good cluster citizen it is best to specify the fewest cores that you
# actually need
#>>>>> Select the number of cores & memory required here
#PBS -l nodes=1:ppn=8,mem=20gb
#
# This option merges any error messages into the output file. Output files are
# located in the same directory as the job script (this file) and will have the
# same name with .o## appended where ## is the job ID number
#PBS -j oe 
#
# Select the queue based on maximum run times. options are:
#    short    2hr
#    medium   8hr
#    long    24hr
#    xlong   48hr, extendable to 168hr using -l walltime= option below
#>>>>> Select your queue & hence max run time here
#PBS -q long
# And up the run time to the maximum of a full week (168 hrs)
##PBS -l walltime=168:00:00

#========= Add some diagnostic information to the output file ==========
# Identify & list the machine and core id's used by the job
echo "Node list:"
cat  $PBS_NODEFILE

# Snow free & used harddisk space on all of the machine's drives
echo "Disk usage:"
df -h

# Include the run date and time. Also assign to a variable for later use
DATE_TIME=`date +%y%m%d-%H%M`
echo "Date & Time:" ${DATE_TIME}

#========= Setup GAMS/CPLEX and Directories ==========
#load the list of modules
source /etc/profile.d/modules.sh

#Load recent version of GAMS
#>>>>> Change this line to the desired/most recent version of GAMS
module load gams/23.6.3

#And load CPLEX
#>>>>> Change this line to the desired/most recent version of CPLEX
module load cplex

#Establish a working directory in scratch
#Will give error if it already exists, but script continues anyway
mkdir /scratch/${USER}

#Clean anything out of our scratch folder (Assumes exclusive machine usage)
#>>>>> Comment out next line if you submit jobs that don't use a full machine
rm -r /scratch/${USER}/*

#Make a new subfolder for this job
SCRATCH="/scratch/${USER}/${PBS_JOBID}"
mkdir $SCRATCH


#========= Setup The model ==========
# Establish our model directory. This should be set to directory where the model
# file is located. This directory is used in two ways. 1) it copies the main
# model file to the run directory and 2) gams is setup to use the model
# directory when looking for any additional include/data files.
#
# Note: ${HOME}/ will expand to your home directory
#>>>>> Change to correct path with the core *.gms model
MODEL_DIR="${HOME}/models/"

# Identify the output directory. This directory will be use for the *.log file, the *.lst file, and any put files.
#>>>>> If desired change to a different output location
OUT_DIR=${MODEL_DIR}

# Identify the model. Use the root name of the main *.gms file without the gms
# exension. This name is also used to create nice file names for output
#>>>>> Change to base filename of the core *.gms model (without .gms)
GAMS_MODEL="MainModel"

# Copy the core model to the working directory
cp ${MODEL_DIR}${GAMS_MODEL}.gms   ${SCRATCH}
echo "${GAMS_MODEL} copied to temporary ${SCRATCH}"

# Default GAMS options to:
#   errmsg:     enable in-line description of errors in list file
#   lf & lo:    store the solver log (normally printed to screen) in $OUT_DIR
#   o:          rename the list file and store in $OUT_DIR
#   inputdir:   Look for $include and $batinclude files in $MODEL_DIR
GAMS_OPTIONS=" -errmsg=1  -lo=2  -inputdir=${MODEL_DIR}  -lf=${OUT_DIR}${GAMS_MODEL}_${DATE_TIME}.log -o=${OUT_DIR}${GAMS_MODEL}_${DATE_TIME}.lst"

#========= Run the model ==========
#Change back to the run directory
cd ${SCRATCH}

#Finally actually run GAMS-CPLEX
echo "Running ${GAMS_MODEL} using GAMS"
echo "  Options: ${GAMS_OPTIONS}"
echo .
gams ${GAMS_MODEL} ${GAMS_OPTIONS}
echo "GAMS Done (${RUN_CODE})"
echo .

#========= Clean up ==========
#Change back to the model directory
cd ${MODEL_DIR}

#Clean-up scratch space by deleting our scratch directory and any lingering GAMS/CPLEX temp files
echo "Cleaning up our Scratch Space"
cd
rm -r ${SCRATCH}/*
rmdir ${SCRATCH}

echo "Script Complete ${PBS_JOBID}"

