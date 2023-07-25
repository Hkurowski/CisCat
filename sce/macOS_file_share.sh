#!/usr/bin/env sh

#
# CIS-CAT Script Check Engine
# 
# Name                Date       Description
# -------------------------------------------------------------------
# Edward Byrd         01/07/21   Ensure screen sharing is disabled
# Edward Byrd		  11/02/22	 Updated for to remove AFP and update name
# 

smbshare=$(
/bin/launchctl list | grep -c "com.apple.smbd"
)


if [ $smbshare -eq 0 ] ; then
  output=True
else
  output=False
fi

# If result returns 0 pass, otherwise fail.
if [ "$output" == True ] ; then
	echo "$output"
    exit "${XCCDF_RESULT_PASS:-101}"
else
    # print the reason why we are failing
    echo "$output"
    exit "${XCCDF_RESULT_FAIL:-102}"
fi

