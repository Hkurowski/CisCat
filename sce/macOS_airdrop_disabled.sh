#!/usr/bin/env sh

#
# CIS-CAT Script Check Engine
# 
# Name                Date       Description
# -------------------------------------------------------------------
# Edward Byrd		  10/31/22	 Check that airdrop is disabled
#

airdropoff=$(
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowAirDrop').js
EOS
)


if [ "$airdropoff" == "false" ]; then
	echo "PASSED: Profile installed to disable AirDrop"
    exit "${XCCDF_RESULT_PASS:-101}"
else
	for DIR in $(find /Users -type d -maxdepth 1); do
		PREF=$DIR/Library/Preferences/com.apple.sharingd
		if [ -e $PREF.plist ]; then
			AirDropDisabled=$(defaults read $PREF.plist 2>&1 | grep DiscoverableMode | grep -c "DiscoverableMode = Off;")
			if [ $AirDropDisabled -ne 1 ]; then
				[ -z "$output" ] && output="User: \"$DIR\" has the AirDrop enabled" 
			fi
		fi
	done
	# If test passed, then no output would be generated. If so, we pass
if [ -z "$output" ] ; then
	echo "PASSED: All users have the AirPlay Receiver disabled"
    exit "${XCCDF_RESULT_PASS:-101}"
else
    # print the reason why we are failing
    echo "FAILED: The following user(s) do not have the AirPlay Receiver disabled"
    echo "$output"
    exit "${XCCDF_RESULT_FAIL:-102}"
fi
fi