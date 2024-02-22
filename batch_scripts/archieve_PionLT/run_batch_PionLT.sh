#! /bin/bash

### Muhammad Junaid, University of Regina
### 18/12/23
### A batch submission script based on an earlier version by Richard Trotta, Catholic University of America

echo "Running as ${USER}"
### Check if an argument was provided, if not assume -1, if yes, this is max events

RUNTYPE=$1
RunList=$2
MAXEVENTS=$3

if [[ -z "$1" || ! "$RUNTYPE" =~ Prod|Lumi|LumiCoin|HeePSingHMS|HeePSingSHMS|HeePCoin|pTRIG6|fADC|Optics ]]; then # Check the 2nd argument was provided and that it's one of the valid options
    echo ""
    echo "I need a valid run type"
    while true; do
        echo ""
        read -p "Please type in a run type from - Prod - Lumi - LumiCoin - HeePSingHMS - HeePSingSHMS - HeePCoin - pTRIG6 - fADC - Optics  Case sensitive! - or press ctrl-c to exit : " RUNTYPE
        case $RUNTYPE in
            '');; # If blank, prompt again
            'Prod'|'Lumi'|'LumiCoin'|'HeePSingHMS'|'HeePSingSHMS'|'HeePCoin'|'pTRIG6'|'Optics'|'fADC') break;; # If a valid option, break the loop and continue
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

# 15/02/22 - SJDK - Added the swif2 workflow as a variable you can specify here
Workflow="LTSep_${USER}" # Change this as desired
# Input run numbers, this just points to a file which is a list of run numbers, one number per line
inputFile="/group/c-pionlt/USERS/${USER}/hallc_replay_lt/UTIL_BATCH/InputRunLists/Production/${RunList}"

if [[ $RUNTYPE -eq "Prod" ]]; then
    echo "Running production analysis script - ${RUNTYPE}"
    ANASCRIPT="/group/c-pionlt/USERS/${USER}/hallc_replay_lt/UTIL_BATCH/Analysis_Scripts/FullReplay_PionLT_Phys_Prod_Batch.sh"
elif [[ $RUNTYPE -eq "Lumi" ]]; then
    echo "Running production analysis script - ${RUNTYPE}"
    ANASCRIPT="/group/c-pionlt/USERS/${USER}/hallc_replay_lt/UTIL_BATCH/Analysis_Scripts/FullReplay_PionLT_Lumi_Batch.sh"
elif [[ $RUNTYPE -eq "LumiCoin" ]]; then
    echo "Running production analysis script - ${RUNTYPE}"
    ANASCRIPT="/group/c-pionlt/USERS/${USER}/hallc_replay_lt/UTIL_BATCH/Analysis_Scripts/FullReplay_PionLT_Lumi_Coin_Batch.sh"
elif [[ $RUNTYPE -eq "HeePSingHMS" ]]; then
    echo "Running production analysis script - ${RUNTYPE}"
    ANASCRIPT="/group/c-pionlt/USERS/${USER}/hallc_replay_lt/UTIL_BATCH/Analysis_Scripts/FullReplay_PionLT_HeeP_Sing_HMS_Batch.sh"
elif [[ $RUNTYPE -eq "HeePSingSHMS" ]]; then
    echo "Running production analysis script - ${RUNTYPE}"
    ANASCRIPT="/group/c-pionlt/USERS/${USER}/hallc_replay_lt/UTIL_BATCH/Analysis_Scripts/FullReplay_PionLT_HeeP_Sing_SHMS_Batch.sh"
elif [[ $RUNTYPE -eq "HeePCoin" ]]; then
    echo "Running production analysis script - ${RUNTYPE}"
    ANASCRIPT="/group/c-pionlt/USERS/${USER}/hallc_replay_lt/UTIL_BATCH/Analysis_Scripts/FullReplay_PionLT_HeeP_Coin_Batch.sh"
elif [[ $RUNTYPE -eq "pTRIG6" ]]; then
    echo "Running production analysis script - ${RUNTYPE}"
    ANASCRIPT="/group/c-pionlt/USERS/${USER}/hallc_replay_lt/UTIL_BATCH/Analysis_Scripts/FullReplay_PionLT_Phys_Prod_pTRIG6_Batch.sh"

#elif [[ $RUNTYPE -eq "fADC" ]]; then
#    ANASCRIPT="/group/c-pionlt/USERS/${USER}/hallc_replay_lt/UTIL_BATCH/Analysis_Scripts/FullReplay_PionLT_HeeP_Coin_Batch.sh"
#elif [[ $RUNTYPE -eq "Optics" ]]; then
#    ANASCRIPT="/group/c-pionlt/USERS/${USER}/hallc_replay_lt/UTIL_BATCH/Analysis_Scripts/FullReplay_PionLT_HeeP_Coin_Batch.sh"
else
    echo "${RUNTYPE} is not a valid run type"
    exit 1
fi

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
                runNum=$line
		if [[ $runNum -ge 10000 ]]; then
		    MSSstub='/mss/hallc/c-pionlt/raw/shms_all_%05d.dat'
		elif [[ $runNum -lt 10000 ]]; then
		    MSSstub='/mss/hallc/spring17/raw/coin_all_%05d.dat'
		fi
		##Output batch job text file##
		batch="${USER}_${runNum}_FullReplay_${RUNTYPE}_PionLT_Job.txt"
                tape_file=`printf $MSSstub $runNum`
		# Print the size of the raw .dat file (converted to GB) to screen. sed command reads line 3 of the tape stub without the leading size=
	        TapeFileSize=$(($(sed -n '4 s/^[^=]*= *//p' < $tape_file)/1000000000))
		if [[ $TapeFileSize == 0 ]];then
		    TapeFileSize=2
                fi
		echo "Raw .dat file is "$TapeFileSize" GB"
                tmp=tmp
                ##Finds number of lines of input file##                                  
                numlines=$(eval "wc -l < ${inputFile}")
                echo "Job $(( $i + 2 ))/$(( $numlines +1 ))"
                echo "Running ${batch} for ${runNum}"
                cp /dev/null ${batch}
                ##Creation of batch script for submission##
                echo "PROJECT: c-kaonlt" >> ${batch} # Or whatever your project is!
		echo "TRACK: analysis" >> ${batch} ## Use this track for production running
		#echo "TRACK: debug" >> ${batch} ### Use this track for testing, higher priority
                echo "JOBNAME: PionLT_${RUNTYPE}_${runNum}" >> ${batch} ## Change to be more specific if you want
		# Request double the tape file size in space, for trunctuated replays edit down as needed
		# Note, unless this is set typically replays will produce broken root files
		echo "DISK_SPACE: "$(( $TapeFileSize * 2 ))" GB" >> ${batch}
		if [[ $TapeFileSize -le 45 ]]; then # Assign memory based on size of tape file, should keep this as low as possible!
                    echo "MEMORY: 4000 MB" >> ${batch}
                elif [[ $TapeFileSize -ge 45 ]]; then
                    echo "MEMORY: 6000 MB" >> ${batch}
                fi
		echo "CPU: 1" >> ${batch} ### hcana is single core, setting CPU higher will lower priority and gain you nothing!
		echo "INPUT_FILES: ${tape_file}" >> ${batch}
		echo "COMMAND:${ANASCRIPT} ${runNum} ${MAXEVENTS}" >> ${batch}
                echo "MAIL: ${USER}@jlab.org" >> ${batch}
                echo "Submitting batch"
                eval "swif2 add-jsub ${Workflow} -script ${batch} 2>/dev/null"
                echo " "
                i=$(( $i + 1 ))
		sleep 2
		rm ${batch}
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
	    eval 'swif2 run ${Workflow}'
	    break;;
        [Nn]* ) 
	        exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

