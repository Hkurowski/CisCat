#!/usr/bin/env sh

#
# CIS-CAT Script Check Engine
# 
# Name		       Date       Description
# -------------------------------------------------------------------
# Edward Byrd 	 11/08/22   Check Bluetooth in the Menu Bar
#

UUID=$(ioreg -rd1 -c IOPlatformExpertDevice | grep "IOPlatformUUID" | sed -e 's/^.* "\(.*\)"$/\1/')

btprofile=$(
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.controlcenter')\
.objectForKey('Bluetooth').js
EOS
)

if [ "$btprofile" == "18" ]; then
	echo "PASSED: Profile installed to enable the Bluetooth status in the menu bar"
    exit "${XCCDF_RESULT_PASS:-101}"
else
for DIR in $(find /Users -type d -maxdepth 1); do
	PREF=$DIR/Library/Preferences/ByHost/com.apple.controlcenter.$UUID
	if [ -e $PREF.plist ]; then
		BTMenu=$(defaults read $PREF.plist Bluetooth 2> /dev/null)
		if  [ $BTMenu -ne 2 ] && [ -n $BTMenu ]; then
			[ -z "$output" ] && output="User: \"$DIR\" does not have the Bluetooth status in their menu bar" 
		fi
	fi
done

# If test passed, then no output would be generated. If so, we pass
if [ -z "$output" ] ; then
	echo "PASSED: All users have the Bluetooth status in the Menu Bar"
    exit "${XCCDF_RESULT_PASS:-101}"
else
    # print the reason why we are failing
    echo "FAILED: The following user(s) do not have the Bluetooth status in their Menu Bar"
    echo "$output"
    exit "${XCCDF_RESULT_FAIL:-102}"
fi
fi