#!/usr/bin/env sh

#
# CIS-CAT Script Check Engine
# 
# Name		       Date       Description
# -------------------------------------------------------------------
# Edward Byrd 	 11/08/22   Check if Limit Ad Tracking is enabled
#

adprofile=$(
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowApplePersonalizedAdvertising').js
EOS)

if [ "$adprofile" == "false" ]; then
	echo "PASSED: Profile installed to enable Limited Ad Tracking"
    exit "${XCCDF_RESULT_PASS:-101}"
else
	for DIR in $(find /Users -type d -maxdepth 1); do
		PREF=$DIR/Library/Preferences/com.apple.AdLib
		if [ -e $PREF.plist ]; then
			limitad=$(defaults read $PREF.plist 2>/dev/null | grep allowApplePersonalizedAdvertising | grep -c "allowApplePersonalizedAdvertising = 0;" )
			if [ "$limitad" == "1" ]; then
				[ -z "$output" ] 
			else 
				[ -z "$output" ] && output="User: \"$DIR\" has Personalized Ad data enabled" 
			fi
		fi
	done

# If test passed, then no output would be generated. If so, we pass
if [ -z "$output" ] ; then
	echo "PASSED: All users have the Personalized Ads disabled"
    exit "${XCCDF_RESULT_PASS:-101}"
else
    # print the reason why we are failing
    echo "FAILED: The following user(s) do not have Personalized Ads disabled"
    echo "$output"
    exit "${XCCDF_RESULT_FAIL:-102}"
fi
fi