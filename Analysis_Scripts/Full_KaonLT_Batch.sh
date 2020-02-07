#!/bin/bash

echo "Starting Replay script"
echo "I take as arguments the Run Number and max number of events!"
RUNNUMBER=$1
MAXEVENTS=-1
### Check you've provided the an argument
if [[ $1 -eq "" ]]; then
    echo "I need a Run Number!"
    echo "Please provide a run number as input"
    exit 2
fi
if [[ ${USER} = "cdaq" ]]; then
    echo "Warning, running as cdaq."
    echo "Please be sure you want to do this."
    echo "Comment this section out and run again if you're sure."
    exit 2
fi          

# Set path depending upon hostname. Change or add more as needed  
if [[ "${HOSTNAME}" = *"farm"* ]]; then  
    CentOSVer="$(cat /etc/centos-release)"
    REPLAYPATH="/group/c-kaonlt/USERS/${USER}/hallc_replay_lt"
    if [[ "${HOSTNAME}" != *"ifarm"* ]]; then
	if [[ $CentOSVer = *"7.2"* ]]; then 
	    source /site/12gev_phys/softenv.sh 2.1
	elif [[ $CentOSVer = *"7.7"* ]]; then 
	    source /site/12gev_phys/softenv.sh 2.3
	    source /apps/root/6.10.02/setroot_CUE.bash
	fi
    fi
    cd "/group/c-kaonlt/hcana/"
    source "/group/c-kaonlt/hcana/setup.sh"
    cd "$REPLAYPATH"
    source "$REPLAYPATH/setup.sh"
elif [[ "${HOSTNAME}" = *"qcd"* ]]; then
    CentOSVer="$(cat /etc/centos-release)"
    REPLAYPATH="/group/c-kaonlt/USERS/${USER}/hallc_replay_lt"
	if [[ $CentOSVer = *"7.2"* ]]; then 
	    source /site/12gev_phys/softenv.sh 2.1
	elif [[ $CentOSVer = *"7.7"* ]]; then 
	    source /site/12gev_phys/softenv.sh 2.3
	    source /apps/root/6.10.02/setroot_CUE.bash
	fi
    cd "/group/c-kaonlt/hcana/"
    source "/group/c-kaonlt/hcana/setup.sh" 
    cd "$REPLAYPATH"
    source "$REPLAYPATH/setup.sh" 
elif [[ "${HOSTNAME}" = *"cdaq"* ]]; then
    REPLAYPATH="/home/cdaq/hallc-online/hallc_replay_lt"
elif [[ "${HOSTNAME}" = *"phys.uregina.ca"* ]]; then
    REPLAYPATH="/home/${USER}/work/JLab/hallc_replay_lt"
fi
cd $REPLAYPATH

echo -e "\n\nStarting Replay Script\n\n"
eval "$REPLAYPATH/hcana -l -q \"UTIL_KAONLT/scripts_Replay/replay_production_coin.C ($RUNNUMBER,$MAXEVENTS)\""
exit 0
