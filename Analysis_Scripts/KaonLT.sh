#! /bin/bash

#
# Description:
# ================================================================
# Time-stamp: "2023-02-15 10:39:26 trottar"
# ================================================================
#
# Author:  Richard L. Trotta III <trotta@cua.edu>
#
# Copyright (c) trottar
#

# Stephen JD Kay - University of Regina - 27/08/21
# This script should be executed on cdaql1 with the required commands to execute the relevant physics analysis
# Arguments should be run number, type of run and target type
# Anything but the valid options should be ignored and bounced back to the user as a prompt

# Flag definitions (flags: h, a)
while getopts 'ha' flag; do
    case "${flag}" in
        h) 
        echo "--------------------------------------------------------------"
        echo "./KaonLT.sh -{flags} {variable arguments, see help}"
	echo
        echo "Description: Runs scripts for batch submission"
        echo "--------------------------------------------------------------"
        echo
        echo "The following flags can be called for the heep analysis..."
	echo "    If no flags called arguments are..."
	echo "        RUNTYPE=arg1, TARGET=arg2, RunList=arg3, MAXEVENTS=arg4"
        echo "    -h, help"
        echo "    -a, Runs LTSep analysis"
	echo "        EPSILON=arg1, PHIVAL=arg2, Q2=arg3, W=arg4, target=arg5, RUNNUM=arg6"
	echo
	echo " Avaliable Kinematics..."	
	echo "                      Q2=5p5, W=3p02"
	echo "                      Q2=4p4, W=2p74"
	echo "                      Q2=3p0, W=3p14"
	echo "                      Q2=3p0, W=2p32"
	echo "                      Q2=2p1, W=2p95"
	echo "                      Q2=0p5, W=2p40"
        exit 0
        ;;
	a) a_flag='true' ;;
        *) print_usage
        exit 1 ;;
    esac
done

# Set path depending upon hostname. Change or add more as needed  
if [[ "${HOSTNAME}" = *"farm"* ]]; then  
    REPLAYPATH="/group/c-kaonlt/USERS/${USER}/hallc_replay_lt"
    LTANAPATH="/group/c-kaonlt/USERS/${USER}/lt_analysis"
    if [[ "${HOSTNAME}" != *"ifarm"* ]]; then
	#source /site/12gev_phys/softenv.sh 2.4
	source /apps/root/6.18.04/setroot_CUE.bash
    fi
    cd "$REPLAYPATH"
    source "$REPLAYPATH/setup.sh"
elif [[ "${HOSTNAME}" = *"qcd"* ]]; then
    REPLAYPATH="/group/c-kaonlt/USERS/${USER}/hallc_replay_lt"
    #source /site/12gev_phys/softenv.sh 2.4
    source /apps/root/6.18.04/setroot_CUE.bash
    cd "$REPLAYPATH"
    source "$REPLAYPATH/setup.sh" 
elif [[ "${HOSTNAME}" = *"cdaq"* ]]; then
    REPLAYPATH="/home/cdaq/hallc-online/hallc_replay_lt"
elif [[ "${HOSTNAME}" = *"phys.uregina.ca"* ]]; then
    REPLAYPATH="/home/${USER}/work/JLab/hallc_replay_lt"
fi

ls -lhtr hcana

if [[ $a_flag = 'true' ]]; then
    EPSILON=$(echo "$2" | tr '[:upper:]' '[:lower:]')
    PHIVAL=$(echo "$3" | tr '[:upper:]' '[:lower:]')
    Q2=$4
    W=$5
    TARGET=$(echo "$6" | tr '[:upper:]' '[:lower:]')
    RUNNUMBER=$7

    if [[ -z "$2" || ! "$EPSILON" =~ high|low ]]; then # Check the 1st argument was provided and that it's one of the valid options
	echo ""
	echo "I need a valid epsilon..."
	while true; do
	    echo ""
	    read -p "Press ctrl-c to exit : " EPSILON
	    case $EPSILON in
		'');; # If blank, prompt again
		'high'|'low') break;; # If a valid option, break the loop and continue
	    esac
	done
    fi
    if [[ -z "$3" || ! "$PHIVAL" =~ right|left|center ]]; then # Check the 1st argument was provided and that it's one of the valid options
	echo ""
	echo "I need a valid phi value..."
	while true; do
	    echo ""
	    read -p "Press ctrl-c to exit : " PHIVAL
	    case $PHIVAL in
		'');; # If blank, prompt again
		'right'|'left'|'center') break;; # If a valid option, break the loop and continue
	    esac
	done
    fi
    if [[ -z "$4" || ! "$Q2" =~ 5p5|4p4|3p0|2p1|0p5 ]]; then # Check the 2nd argument was provided and that it's one of the valid options
	echo ""
	echo "I need a valid Q2..."
	while true; do
	    echo ""
	    read -p "Q2 must be one of - [5p5 - 4p4 - 3p0 - 2p1 - 0p5] - or press ctrl-c to exit : " Q2
	    case $Q2 in
		'');; # If blank, prompt again
		'5p5'|'4p4'|'3p0'|'2p1'|'0p5') break;; # If a valid option, break the loop and continue
	    esac
	done
    fi
    if [[ -z "$5" || ! "$W" =~ 3p02|2p74|3p14|2p32|2p95|2p40 ]]; then # Check the 3rd argument was provided and that it's one of the valid options
	echo ""
	echo "I need a valid W..."
	while true; do
	    echo ""
	    read -p "W must be one of - [3p02 - 2p74 - 3p14 - 2p32 - 2p95 - 2p40] - or press ctrl-c to exit : " W
	    case $W in
		'');; # If blank, prompt again
		'3p02'|'2p74'|'3p14'|'2p32'|'2p95'|'2p40') break;; # If a valid option, break the loop and continue
	    esac
	done
    fi
    if [[ -z "$6" || ! "$TARGET" =~ lh2|dummy ]]; then # Check the 3rd argument was provided and that it's one of the valid options
	echo ""
	echo "I need a valid target type..."
	while true; do
	    echo ""
	    read -p "Target type must be one of - [lh2 - dummy] - or press ctrl-c to exit : " TARGET
	    case $TARGET in
		'');; # If blank, prompt again
		'lh2'|'dummy') break;; # If a valid option, break the loop and continue
	    esac
	done
    fi
    if [[ -z "$7" || ! "$RUNNUMBER" =~ ^-?[0-9]+$ ]]; then # Check an argument was provided and that it is a positive integer, if not, prompt for one
	echo ""
	echo "I need a valid run number - MUST be a positive integer"
	while true; do
	    echo ""
	    read -p "Please type in a run number (positive integer) as input or press ctrl-c to exit : " RUNNUMBER
	    case $RUNNUMBER in
		'' | *[!0-9]*);; # If the input is NOT a positive integer (or it's just an empty string), don't break the loop
		*) break;;
	    esac
	done
    fi

else

    UTILPATH="${REPLAYPATH}/UTIL_KAONLT"
    cd $REPLAYPATH

    RUNTYPE=$1
    TARGET=$2
    RUNNUMBER=$3
    MAXEVENTS=$4
    # Need to change these a little, should check whether arguments are good or not REGARDLESS of whether they're blank
    if [[ -z "$1" || ! "$RUNTYPE" =~ Prod|Lumi|HeePSing|HeePCoin|fADC|Optics|HGCer ]]; then # Check the 2nd argument was provided and that it's one of the valid options
	echo ""
	echo "I need a valid run type"
	while true; do
	    echo ""
	    read -p "Please type in a run type from - Prod - Lumi - HeePSing - HeePCoin - fADC - Optics - HGCer - Case sensitive! - or press ctrl-c to exit : " RUNTYPE
	    case $RUNTYPE in
		'');; # If blank, prompt again
		'Prod'|'Lumi'|'HeePSing'|'HeePCoin'|'Optics'|'fADC'|'HGCer') break;; # If a valid option, break the loop and continue
	    esac
	done
    fi
    if [[ -z "$2" || ! "$TARGET" =~ LH2|LD2|Dummy10cm|Carbon0p5|AuFoil|Optics1|Optics2|CarbonHole ]]; then # Check the 3rd argument was provided and that it's one of the valid options
	echo ""
	echo "I need a valid target"
	while true; do	
	    echo ""
	    read -p "Please type in a target from - LH2 - LD2 - Dummy10cm - Carbon0p5 - AuFoil - Optics1 - Optics2 - CarbonHole - Case sensitive! - or press ctrl-c to exit : " TARGET
	    case $TARGET in
		'');; # If blank, prompt again
		'LH2'|'LD2'|'Dummy10cm'|'Carbon0p5'|'AuFoil'|'Optics1'|'Optics2'|'CarbonHole') break;; # If a valid option, break the loop and continue
	    esac
	done
    fi
    if [[ -z "$3" || ! "$RUNNUMBER" =~ ^-?[0-9]+$ ]]; then # Check an argument was provided and that it is a positive integer, if not, prompt for one
	echo ""
	echo "I need a valid run number - MUST be a positive integer"
	while true; do
	    echo ""
	    read -p "Please type in a run number (positive integer) as input or press ctrl-c to exit : " RUNNUMBER
	    case $RUNNUMBER in
		'' | *[!0-9]*);; # If the input is NOT a positive integer (or it's just an empty string), don't break the loop
		*) break;;
	    esac
	done
    fi
    if [[ $4 -eq "" ]]; then
	echo "Only Run Number entered...I'll assume -1 events!" 
	MAXEVENTS=-1 
    fi
fi

if [[ $a_flag = 'true' ]]; then
    echo "Running production analysis script - ${LTANAPATH}/applyCuts_Prod.sh"
    eval '"${LTANAPATH}/applyCuts_Prod.sh" ${EPSILON} ${PHIVAL} ${Q2} ${W} ${TARGET} ${RUNNUMBER}'
else
    if [[ $RUNTYPE == "Prod" ]]; then
	echo "Running production analysis script - ${UTILPATH}/scripts/online_physics/KaonLT/kaon_prod_replay_analysis_sw.sh"
	eval '"${UTILPATH}/scripts/online_physics/KaonLT/kaon_prod_replay_analysis_sw.sh" ${RUNNUMBER} ${TARGET} ${MAXEVENTS}'
    elif [[ $RUNTYPE == "Lumi" ]]; then
	echo "Running luminosity analysis script - ${UTILPATH}/scripts/luminosity/replay_lumi.sh"
	eval '"${UTILPATH}/scripts/luminosity/replay_lumi.sh" -t ${RUNNUMBER} ${MAXEVENTS}'
    elif [[ $RUNTYPE == "HeePSing" ]]; then
	echo "Running HeeP Singles analysis script - ${UTILPATH}/scripts/heep/sing_heepYield.sh"
	eval '"${UTILPATH}/scripts/heep/sing_heepYield.sh" hms ${RUNNUMBER} ${MAXEVENTS}'
	eval '"${UTILPATH}/scripts/heep/sing_heepYield.sh" shms ${RUNNUMBER} ${MAXEVENTS}'
    elif [[ $RUNTYPE == "HeePCoin" ]]; then
	echo "Running HeeP Coin analysis script - ${UTILPATH}/scripts/heep/coin_heepYield.sh"
	eval '"${UTILPATH}/scripts/heep/coin_heepYield.sh" ${RUNNUMBER} ${MAXEVENTS}'
    elif [[ $RUNTYPE == "fADC" ]]; then
	echo "Running fADC Coin analysis script - ${UTILPATH}/scripts/fADC_SIDIS/fADC_Analysis.sh"
	eval '"${UTILPATH}/scripts/fADC_SIDIS/fADC_Analysis.sh" ${RUNNUMBER} ${MAXEVENTS}'
    elif [[ $RUNTYPE == "Optics" ]]; then
	echo "Running optics analysis script - "
	eval '"${UTILPATH}/scripts/optics/run_optics.sh" ${RUNNUMBER} ${MAXEVENTS}'
    elif [[ $RUNTYPE == "HGCer" ]]; then
	echo "Running HGCer analysis script - "
	echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	echo "Run number read from file: $RUNNUMBER"
	echo ""
	cd "${UTILPATH}/scripts/efficiency/src/hgcer"
	python3 hgcer.py Kaon_coin_replay_production $RUNNUMBER $MAXEVENTS
    fi
fi
