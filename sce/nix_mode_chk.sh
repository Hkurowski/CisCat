#!/usr/bin/env bash

#
# CIS-CAT Script Check Engine
#
# Name         Date       Description
# -------------------------------------------------------------------
# E. Pinnell   09/15/22   Check file of directory permissions (mode) follow symlinks ("complex" variable {file_path}:{mask} example: /etc/passwd:0133 verifies /etc/passwd is 0644 or more restrictive)

l_output="" l_output2=""
l_fname="$(awk -F : '{print $1}' <<< "$XCCDF_VALUE_REGEX")"
l_perm_mask="$(awk -F : '{print $2}' <<< "$XCCDF_VALUE_REGEX")"
l_maxperm="$( printf '%o' $(( 0777 & ~$l_perm_mask)) )"

if [ -e "$l_fname" ]; then
   l_mode=$(stat -Lc '%#a' "$l_fname")
   # Gather information for more verbose output
   l_slname="$(readlink "$l_fname")"
   [ -d "$l_slname" ] && l_ftype="directory"
   [ -f "$l_slname" ] && l_ftype="file"
   if [ $(( "$l_mode" & "$l_perm_mask" )) -gt 0 ]; then
      l_output2=" - $l_ftype: \"$l_fname\" is too permissive: \"$l_mode\" (should be: \"$l_maxperm\" or more restrictive)"
   else
      l_output=" - $l_ftype: \"$l_fname\" is mode: \"$l_mode\" (should be: \"$l_maxperm\" or more restrictive)"
   fi
else
   l_output=" - \"$l_fname\" doesn't exist"
fi

# If the tests produce no failing output, we pass
if [ -z "$l_output2" ]; then
	echo -e "\n- Audit Result:\n  ** PASS **\n - $l_output"
	exit "${XCCDF_RESULT_PASS:-101}"
else
	echo -e "\n- Audit Result:\n  ** FAIL **\n - $l_output2"
	exit "${XCCDF_RESULT_FAIL:-102}"
fi