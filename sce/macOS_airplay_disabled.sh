#!/usr/bin/env sh

#
# CIS-CAT Script Check Engine
# 
# Name                Date       Description
# -------------------------------------------------------------------
# Edward Byrd		  10/31/22	 Check that airplay receiver is disabled
#

airplayoff=$(
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowAirPlayIncomingRequests').js
EOS
)

UUID=$(ioreg -rd1 -c IOPlatformExpertDevice | grep "IOPlatformUUID" | sed -e 's/^.* "\(.*\)"$/\1/')

if [ "$airplayoff" == "false" ]; then
	echo "PASSED: Profile installed to disable AirPlay Reciever"
    exit "${XCCDF_RESULT_PASS:-101}"
else
	for DIR in $(find /Users -type d -maxdepth 1); do
		PREF=$DIR/Library/Preferences/ByHost/com.apple.controlcenter.$UUID
		if [ -e $PREF.plist ]; then
			AirPlayDisabled=$(defaults read $PREF.plist AirplayRecieverEnabled 2>&1)
			if [ $AirPlayDisabled -ne 0 ]; then
				[ -z "$output" ] && output="User: \"$DIR\" has the AirPlay Receiver disabled" 
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



