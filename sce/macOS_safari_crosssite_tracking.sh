#!/usr/bin/env sh

#
# CIS-CAT Script Check Engine
# 
# Name                Date       Description
# -------------------------------------------------------------------
# Edward Byrd 		  11/08/22   Enable Safari to prevent cross-site tracking
#

safaricrosssiteprofile1=$(
profiles -P -o stdout | /usr/bin/grep -c "BlockStoragePolicy = 2;")

safaricrosssiteprofile2=$(
profiles -P -o stdout | /usr/bin/grep -c "ebKitPreferences.storageBlockingPolicy = 1;")

safaricrosssiteprofile3=$(
profiles -P -o stdout | /usr/bin/grep -c "WebKitStorageBlockingPolicy = 1;")

if [ "$safaricrosssiteprofile1" == "1" ] && [ "$safaricrosssiteprofile2" == "1" ] && [ "$safaricrosssiteprofile3" == "1" ]; then
	echo "PASSED: Profile installed to cros-site tracking in Safari"
    exit "${XCCDF_RESULT_PASS:-101}"
else
for DIR in $(find /Users -type d -maxdepth 1); do
	PREF=$DIR/Library/Containers/com.apple.Safari/Data/Library/Preferences/com.apple.Safari
	if [ -e $PREF.plist ]; then
		Safaricrosssite1=$(defaults read $PREF.plist 2>&1 | grep BlockStoragePolicy | grep -c "BlockStoragePolicy = 2;")
		Safaricrosssite2=$(defaults read $PREF.plist 2>&1 | grep WebKitPreferences | grep -c "WebKitPreferences.storageBlockingPolicy = 1;")
		Safaricrosssite3=$(defaults read $PREF.plist 2>&1 | grep WebKitStorageBlockingPolicy | grep -c "WebKitStorageBlockingPolicy = 1;")				
		if [ $Safaricrosssite1 == 0 ]; then
			[ -z "$output" ] && output="User: \"$DIR\" is allowing cross-site tracking"
		elif [ $Safaricrosssite2 == 0 ]; then
			[ -z "$output" ] && output="User: \"$DIR\" is allowing cross-site tracking"

		elif [ $Safaricrosssite3 == 0 ]; then
			[ -z "$output" ] && output="User: \"$DIR\" is allowing cross-site tracking" 
		fi
	fi
done
fi

# If test passed, then no output would be generated. If so, we pass
if [ -z "$output" ] ; then
	echo "PASSED: All users have cross-site tracking disabled"
    exit "${XCCDF_RESULT_PASS:-101}"
else
    # print the reason why we are failing
    echo "FAILED: The following users have cross-site tracking enabled"
    echo "$output"
    exit "${XCCDF_RESULT_FAIL:-102}"
fi
