#!/usr/bin/env sh

#
# CIS-CAT Script Check Engine
# 
# Name                Date       Description
# -------------------------------------------------------------------
# Edward Byrd 		  11/08/22   Enable Safari to warn when visting fraudulent sites
#

safariwarnprofile=$(
profiles -P -o stdout | /usr/bin/grep -c "WarnAboutFraudulentWebsites = 1;")

if [ "$safariwarnprofile" == "1" ]; then
	echo "PASSED: Profile installed to warn when visiting a fraudulent site in Safari"
    exit "${XCCDF_RESULT_PASS:-101}"
else
for DIR in $(find /Users -type d -maxdepth 1); do
	PREF=$DIR/Library/Containers/com.apple.Safari/Data/Library/Preferences/com.apple.Safari
	if [ -e $PREF.plist ]; then
		Safariwarnsites=$(defaults read $PREF.plist 2>&1 | grep WarnAboutFraudulentWebsites | grep -c "WarnAboutFraudulentWebsites = 1;")
		if [ $Safariwarnsites == 0 ]; then
			[ -z "$output" ] && output="User: \"$DIR\" has disabled safari to warn when visiting a fraudulent site" 
		fi
	fi
done
fi

# If test passed, then no output would be generated. If so, we pass
if [ -z "$output" ] ; then
	echo "PASSED: All users have warn when visiting a fraudulent site enabled"
    exit "${XCCDF_RESULT_PASS:-101}"
else
    # print the reason why we are failing
    echo "FAILED: The following users have disabled warn when visiting a fraudulent site"
    echo "$output"
    exit "${XCCDF_RESULT_FAIL:-102}"
fi