#!/bin/bash

# This script runs a bunch of sed commands that convert from AUGER based submission scripts to slurm based scripts

sed -i "s/MAIL: /#SBATCH --mail-user=/" run*.sh
sed -i "s/PROJECT: c-kaonlt/#SBATCH --account=hallc/" run*.sh
sed -i "s/PROJECT: c-pionlt/#SBATCH --account=hallc/" run*.sh
sed -i "s/TRACK: analysis/#SBATCH --partition=production/" run*.sh
sed -i "s/JOBNAME:/#SBATCH --job-name=/" run*.sh
sed -i "s/DISK_SPACE:/#SBATCH -gres=disk:/" run*.sh
sed -i "s/ \* 2 ))/ \* 2000 ))/" run*.sh
sed -i 's/" GB" >>/ >>/' run*.sh
sed -i "s/MEMORY: /#SBATCH --mem-per-cpu=/" run*.sh
sed -i 's/MB" >>/" >>/' run*.sh
sed -i "s/CPU: /#SBATCH --ntasks=/" run*.sh
sed -i "s/COMMAND://" run*.sh
sed -i "s/jsub/sbatch/" run*.sh
sed -i 's/echo "INPUT_FILES: \${tape_file}" >> \${batch}/#echo "INPUT_FILES: \${tape_file}" >> \${batch} # No input files equivalent for slurm/' run*.sh
# After this, the following items still need to be changed
# 1 - Need to add #!/bin/bash as the FIRST line of the batch job (${batch})
# 2 - Need to change the batch file from .txt to .sh
# 3 - Need to add error/output pathing - 
# echo "#SBATCH --output=/farm_out/${USER}/%x-%j-%N.out" >> ${batch}
# echo "#SBATCH --error=/farm_out/${USER}/%x-%j-%N.err" >> ${batch}
# 4 - Slurm CANNOT do input files like Auger, need to comment out the input file line, need a new loop implemented to check the file exists FIRST and jcache it if it does not. I need to create this loop, and then manually add it to all files...
# So far, I've changed - batch_PionLT_Slurm, CTPeak_Analysis, CalCalib, they all still need step 4 doing though - Need to decide how to replicate INPUT_FILES Auger tag behaviour
