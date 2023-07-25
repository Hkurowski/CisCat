#!/usr/bin/env sh

#
# CIS-CAT Script Check Engine
# 
# Name                Date       Description
# -------------------------------------------------------------------
# Edward Byrd 		  11/08/22   Enable Advertising Privacy in Safari
#


for DIR in $(find /Users -type d -maxdepth 1); do
	PREF=$DIR/Library/Containers/com.apple.Safari/Data/Library/Preferences/com.apple.Safari
	if [ -e $PREF.plist ]; then
		Safariadprivacy=$(defaults read $PREF.plist 2>&1 | grep WebKitPreferences.privateClickMeasurementEnabled | grep -c ' "WebKitPreferences.privateClickMeasurementEnabled" = 1;')
		if [ $Safariadprivacy == 0 ]; then
			[ -z "$output" ] && output="User: \"$DIR\" has ad privacy disabled" 
		fi
	fi
done

# If test passed, then no output would be generated. If so, we pass
if [ -z "$output" ] ; then
	echo "PASSED: All users have advertising privacy enabled in Safari"
    exit "${XCCDF_RESULT_PASS:-101}"
else
    # print the reason why we are failing
    echo "FAILED: The following users have ad privacy disabled"
    echo "$output"
    exit "${XCCDF_RESULT_FAIL:-102}"
fi