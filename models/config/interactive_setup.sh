source /etc/profile.d/modules.sh
module load matlab
module load gams/23.6.3
GAMS=`which gams`
export GAMS
module load cplex
cd ~/projects/advpower/models/MATLAB
