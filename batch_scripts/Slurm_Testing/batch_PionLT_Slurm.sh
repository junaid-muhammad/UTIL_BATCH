#! /bin/bash

#
# Description:
# ================================================================
# Time-stamp: "2021-11-05 06:38:49 trottar"
# ================================================================
#
# Author:  Richard L. Trotta III <trotta@cua.edu>
#
# Copyright (c) trottar
#

### Stephen Kay, University of Regina
### 03/03/21
### stephen.kay@uregina.ca
### A batch submission script based on an earlier version by Richard Trotta, Catholic University of America                       
##### Modify required resources as needed!

echo "Running as ${USER}"

RUNTYPE=$1
RunList=$2
MAXEVENTS=$3
if [[ -z "$1" || ! "$RUNTYPE" =~ Prod|Lumi|HeePSing|HeePCoin|fADC|Optics ]]; then # Check the 1st argument was provided and that it's one of the valid options
    echo ""
    echo "I need a valid run type"
    while true; do
	echo ""
	read -p "Please type in a run type from - Prod - Lumi - HeePSing - HeePCoin - fADC - Optics - Case sensitive! - or press ctrl-c to exit : " RUNTYPE
	case $RUNTYPE in
	    '');; # If blank, prompt again
	    'Prod'|'Lumi'|'HeePSing'|'HeePCoin'|'Optics'|'fADC') break;; # If a valid option, break the loop and continue
	esac
    done
fi
if [[ -z "$2" ]]; then
    echo "I need a run list process!"
    echo "Please provide a run list as input"
    exit 2
fi
if [[ $3 -eq "" ]]; then
    echo "Only Run Number entered...I'll assume -1 events!" 
    MAXEVENTS=-1 
fi

UTILPATH="/group/c-pionlt/online_analysis/hallc_replay_lt/UTIL_BATCH"
ANASCRIPT="'${UTILPATH}/Analysis_Scripts/run_PionLT_Slurm.sh' ${RUNTYPE}"

##Output history file##
historyfile=hist.$( date "+%Y-%m-%d_%H-%M-%S" ).log
##Input run numbers##
#inputFile="${UTILPATH}/InputRunLists/Pion_Data/${RUNTYPE}_ALL_fall21"
inputFile="/group/c-pionlt/online_analysis/hallc_replay_lt/UTIL_BATCH/InputRunLists/${RunList}"
## Tape stub
MSSstub='/mss/hallc/c-pionlt/raw/shms_all_%05d.dat'

while true; do
    read -p "Do you wish to begin a new batch submission? (Please answer yes or no) " yn
    case $yn in
        [Yy]* )
            i=-1
            (
            ##Reads in input file##
            while IFS='' read -r line || [[ -n "$line" ]]; do
                echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
                echo "Run number read from file: $line"
                echo ""
                ##Run number#
                RUNNUMBER=$line
		##Output batch job file##
		batch="${USER}_${RUNNUMBER}_FullReplay_${RUNTYPE}_Job.sh"
                tape_file=`printf $MSSstub $RUNNUMBER`
		TapeFileSize=$(($(sed -n '4 s/^[^=]*= *//p' < $tape_file)/1000000000))
		if [[ $TapeFileSize == 0 ]];then
                    TapeFileSize=1
                fi
		echo "Raw .dat file is "$TapeFileSize" GB"
		tmp=tmp
                ##Finds number of lines of input file##
                numlines=$(eval "wc -l < ${inputFile}")
                echo "Job $(( $i + 2 ))/$(( $numlines +1 ))"
                echo "Running ${batch} for ${RUNNUMBER}"
                cp /dev/null ${batch}
                ##Creation of batch script for submission##
                echo "#!/bin/bash" >> ${batch}
		echo "#SBATCH --mail-user=${USER}@jlab.org" >> ${batch}
		echo "#SBATCH --account=hallc" >> ${batch} # Or whatever your account is
                echo "#SBATCH --partition=production" >> ${batch}
                echo "#SBATCH --job-name=PionLT_${RUNNUMBER}" >> ${batch}
                # Request disk space depending upon raw file size
                echo "#SBATCH --gres=disk:"$(( $TapeFileSize * 2000 )) >> ${batch} # Factor 1000 is because the default is MB
		echo "#SBATCH --output=/farm_out/${USER}/%x-%j-%N.out" >> ${batch}
		echo "#SBATCH --error=/farm_out/${USER}/%x-%j-%N.err" >> ${batch}
		if [[ $TapeFileSize -le 45 ]]; then
		    echo "#SBATCH --mem-per-cpu=3000" >> ${batch} # In units of MB, note, this is PER CORE
		elif [[ $TapeFileSize -ge 45 ]]; then
		    echo "#SBATCH --mem-per-cpu=4000" >> ${batch}
		fi
                echo "#SBATCH --ntasks=1" >> ${batch} ### hcana single core, setting CPU higher will lower priority!
		#echo "INPUT_FILES: ${tape_file}" >> ${batch} # No input files equivalent for slurm... this is a problem!
		#echo "TIME: 1" >> ${batch} 
		echo "${ANASCRIPT} ${RUNNUMBER} ${MAXEVENTS}" >> ${batch}
                echo "Submitting batch"
                eval "sbatch ${batch} 2>/dev/null"
                echo " "
		sleep 2
		rm ${batch}
                i=$(( $i + 1 ))
		if [ $i == $numlines ]; then
		    echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
		    echo " "
		    echo "###############################################################################################################"
		    echo "############################################ END OF JOB SUBMISSIONS ###########################################"
		    echo "###############################################################################################################"
		    echo " "
		fi
	    done < "$inputFile"
	    )
	    break;;
        [Nn]* ) 
	    exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
