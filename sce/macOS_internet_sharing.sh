#!/usr/bin/env sh

#
# CIS-CAT Script Check Engine
# 
# Name                Date       Description
# -------------------------------------------------------------------
# Edward Byrd         06/14/22   Disable Internet Sharing
# Edward Byrd		  11/02/22	 Updated name of the script and added profile check
#

internetshare=$(
defaults read /Library/Preferences/SystemConfiguration/com.apple.nat 2>&1 | grep -c "Enabled = 1;"
)

internetshareprofile=$(
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.MCX')\
.objectForKey('forceInternetSharingOff').js
EOS
)

if [ "$internetshareprofile" = "true"  ] ; then
	echo "$output"
    exit "${XCCDF_RESULT_PASS:-101}"	
elif [ $internetshare -eq 0  ] ; then
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
fi