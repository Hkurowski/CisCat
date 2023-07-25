#!/usr/bin/env sh

#
# CIS-CAT Script Check Engine
# 
# Name                Date       Description
# -------------------------------------------------------------------
# Edward Byrd 		  11/08/22   Enable Secure Keyboard in Terminal
#

terminalprofile=$(
/usr/bin/osascript -l JavaScript << EOS
$.NSUserDefaults.alloc.initWithSuiteName('com.apple.Terminal')\
.objectForKey('SecureKeyboardEntry').js
EOS
)

if [ "$terminalprofile" == "true" ]; then
	echo "PASSED: Profile installed to secure keyboard entries in Terminal"
    exit "${XCCDF_RESULT_PASS:-101}"
else
for DIR in $(find /Users -type d -maxdepth 1); do
	PREF=$DIR/Library/Preferences/com.apple.Terminal
	if [ -e $PREF.plist ]; then
		terminalsecure=$(defaults read $PREF.plist 2>&1 | grep SecureKeyboardEntry | grep -c "SecureKeyboardEntry = 0;")
		if [ $terminalsecure == 1 ]; then
			[ -z "$output" ] && output="User: \"$DIR\" is not securing the keyboard in Terminal" 
		fi
	fi
done
fi

# If test passed, then no output would be generated. If so, we pass
if [ -z "$output" ] ; then
	echo "PASSED: All users have secure keyboard entries in Terminal"
    exit "${XCCDF_RESULT_PASS:-101}"
else
    # print the reason why we are failing
    echo "FAILED: The following users are not securing the keyboard in Terminal"
    echo "$output"
    exit "${XCCDF_RESULT_FAIL:-102}"
fi