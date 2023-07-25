#!/usr/bin/env sh

#
# CIS-CAT Script Check Engine
# 
# Name                Date       Description
# -------------------------------------------------------------------
# Edward Byrd 		  11/08/22   Ensure full website addresses are shown in Safari
#

safarfulladdressprofile=$(
profiles -P -o stdout | /usr/bin/grep -c "ShowFullURLInSmartSearchField = 1;")

if [ "$safarfulladdressprofile" == "1" ]; then
	echo "PASSED: Profile installed to enabled full website addresses in Safari"
    exit "${XCCDF_RESULT_PASS:-101}"
else
for DIR in $(find /Users -type d -maxdepth 1); do
	PREF=$DIR/Library/Containers/com.apple.Safari/Data/Library/Preferences/com.apple.Safari
	if [ -e $PREF.plist ]; then
		Safarifulladdress=$(defaults read $PREF.plist 2>&1 | grep ShowFullURLInSmartSearchField | grep -c "ShowFullURLInSmartSearchField = 1;")
		if [ $Safarifulladdress == 0 ]; then
			[ -z "$output" ] && output="User: \"$DIR\" is not showing the full website address" 
		fi
	fi
done
fi

# If test passed, then no output would be generated. If so, we pass
if [ -z "$output" ] ; then
	echo "PASSED: All users have the full website addresses shown"
    exit "${XCCDF_RESULT_PASS:-101}"
else
    # print the reason why we are failing
    echo "FAILED: The following users have showing full website addresses disabled"
    echo "$output"
    exit "${XCCDF_RESULT_FAIL:-102}"
fi