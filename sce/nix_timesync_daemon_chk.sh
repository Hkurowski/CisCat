#!/usr/bin/env bash

#
# CIS-CAT Script Check Engine
#
# Name         Date       Description
# -------------------------------------------------------------------
# E. Pinnell   06/24/22   check if one and only one time sync daemon is in use

output="" l_tsd="" l_sdtd="" l_chrony="" l_ntp=""

nix_package_manager_set()
{
	# echo "- Start - Determine system's package manager " | tee -a "$LOG" 2>> "$ELOG"
	if command -v rpm > /dev/null 2>&1; then
#		echo "- system is rpm based" | tee -a "$LOG" 2>> "$ELOG"
		G_PQ="rpm -q"
		command -v yum > /dev/null 2>&1 && G_PM="yum" #&& echo "- system uses yum package manager" | tee -a "$LOG" 2>> "$ELOG"
		command -v dnf > /dev/null 2>&1 && G_PM="dnf" #&& echo "- system uses dnf package manager" | tee -a "$LOG" 2>> "$ELOG"
		command -v zypper > /dev/null 2>&1 && G_PM="zypper" #&& echo "- system uses zypper package manager" | tee -a "$LOG" 2>> "$ELOG"
		G_PR="$G_PM -y remove"
#		export G_PQ G_PM G_PR
	#	echo "- End - Determine system's package manager" | tee -a "$LOG" 2>> "$ELOG"
		return "${XCCDF_RESULT_PASS:-101}"
	elif command -v dpkg-query > /dev/null 2>&1; then
	#	echo -e "- system is apt based\n- system uses apt package manager" | tee -a "$LOG" 2>> "$ELOG"
		G_PQ="dpkg-query -W"
		G_PM="apt"
		G_PR="$G_PM -y purge"
#		export G_PQ G_PM G_PR
	#	echo "- End - Determine system's package manager" | tee -a "$LOG" 2>> "$ELOG"
		return "${XCCDF_RESULT_PASS:-101}"
	else
	#	echo -e "- FAIL:\n- Unable to determine system's package manager" | tee -a "$LOG" 2>> "$ELOG"
		G_PQ="unknown"
		G_PM="unknown"
#		export G_PQ G_PM G_PR
	#	echo "- End - Determine system's package manager" | tee -a "$LOG" 2>> "$ELOG"
		return "${XCCDF_RESULT_FAIL:-102}"
	fi
}

nix_package_manager_set
if [ "$?" = "101" ]; then
	$G_PQ chrony > /dev/null 2>&1 && l_chrony="y"
	$G_PQ ntp > /dev/null 2>&1 && l_ntp="y"
	systemctl list-units --all --type=service | grep -q 'systemd-timesyncd.service' && systemctl is-enabled systemd-timesyncd.service | grep -q 'enabled' && l_sdtd="y"
#	! systemctl is-enabled systemd-timesyncd.service | grep -q 'enabled' && l_nsdtd="y" || l_nsdtd=""
	if [[ "$l_chrony" = "y" && "$l_ntp" != "y" && "$l_sdtd" != "y" ]]; then
		l_tsd="chrony"
		output="$output\n- chrony is in use on the system"
	elif [[ "$l_chrony" != "y" && "$l_ntp" = "y" && "$l_sdtd" != "y" ]]; then
		l_tsd="ntp"
		output="$output\n- ntp is in use on the system"
	elif [[ "$l_chrony" != "y" && "$l_ntp" != "y" ]]; then
		if systemctl list-units --all --type=service | grep -q 'systemd-timesyncd.service' && systemctl is-enabled systemd-timesyncd.service | grep -Eq '(enabled|disabled|masked)'; then
			l_tsd="sdtd"
			output="$output\n- systemd-timesyncd is in use on the system"
		fi
	else
		[[ "$l_chrony" = "y" && "$l_ntp" = "y" ]] && output="$output\n- both chrony and ntp are in use on the system"
		[[ "$l_chrony" = "y" && "$l_sdtd" = "y" ]] && output="$output\n- both chrony and systemd-timesyncd are in use on the system"
		[[ "$l_ntp" = "y" && "$l_sdtd" = "y" ]] && output="$output\n- both ntp and systemd-timesyncd are in use on the system"
	fi
else
	output="$output\n- Unable to confirm existence of chrony and/or ntp package on the system"
fi
	
# If only one timesyncd daemon is in use test will pass.  If so, we pass
if [ -n "$l_tsd" ]; then
	echo -e "\n- PASS:\n$output"
	exit "${XCCDF_RESULT_PASS:-101}"
else
    # print the reason why we are failing
	echo -e "\n- FAIL:\n$output"
	exit "${XCCDF_RESULT_FAIL:-102}"
fi