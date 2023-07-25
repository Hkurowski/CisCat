#!/usr/bin/env bash

#
# CIS-CAT Script Check Engine
#
# Name         Date       Description
# -------------------------------------------------------------------
# E. Pinnell   09/15/22   Verify a directory or file is group-owned by group (directory/file and group(s) as regex need to be separated by a ':')

l_output="" l_output2=""
l_fname=$(awk -F : '{print $1}' <<< "$XCCDF_VALUE_REGEX")
l_gname=$(awk -F : '{print $2}' <<< "$XCCDF_VALUE_REGEX")

if [ -e "$l_fname" ]; then
   l_fgroup="$(stat -Lc "%G" "$l_fname")"
   # Gather information for more verbose output
   l_slname="$(readlink "$l_fname")"
   [ -d "$l_slname" ] && l_ftype="directory"
   [ -f "$l_slname" ] && l_ftype="file"
	if [[ "$l_fgroup" =~ $l_gname ]] ; then
		l_output=" - $l_ftype: \"$l_fname\" is owned by group: \"$l_fgroup\""
	else
		l_output2=" - $l_ftype: \"$l_fname\" is owned by group: \"$l_fgroup\""
	fi
else
	l_output=" - $l_ftype: \"$l_fname\" doesn't exist"
fi

# If the regex matched, output would be generated.  If so, we pass
if [ -z "$l_output2" ]; then
	echo -e "\n- Audit Result:\n  ** PASS **\n$l_output"
	exit "${XCCDF_RESULT_PASS:-101}"
else
	# print the reason why we are failing
	echo -e "\n- Audit Result:\n  ** FAIL **\n$l_output2"
	exit "${XCCDF_RESULT_FAIL:-102}"
fi