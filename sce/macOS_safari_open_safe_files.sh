#!/usr/bin/env sh

#
# CIS-CAT Script Check Engine
# 
# Name                Date       Description
# -------------------------------------------------------------------
# Edward Byrd         05/12/21   6.3. - Disable Open "Safe" Files Automatically in Safari
# Edward Byrd		  11/05/21	 Fixed unexpected operator error
# Edward Byrd 		  11/08/22   Updated for the new naming and profile check
#

safarisafeprofile=$(
profiles -P -o stdout | /usr/bin/grep -c "AutoOpenSafeDownloads = 0;")

if [ "$safarisafeprofile" == "1" ]; then
	echo "PASSED: Profile installed to disable open 'safe' files in Safari"
    exit "${XCCDF_RESULT_PASS:-101}"
else
for DIR in $(find /Users -type d -maxdepth 1); do
	PREF=$DIR/Library/Containers/com.apple.Safari/Data/Library/Preferences/com.apple.Safari
	if [ -e $PREF.plist ]; then
		SafariSafeFiles=$(defaults read $PREF.plist 2>&1 | grep AutoOpenSafeDownloads | grep -c "AutoOpenSafeDownloads = 0;")
		if [ $SafariSafeFiles == 0 ]; then
			[ -z "$output" ] && output="User: \"$DIR\" is allowing 'safe' files to open automatically" 
		fi
	fi
done
fi

# If test passed, then no output would be generated. If so, we pass
if [ -z "$output" ] ; then
	echo "PASSED: All users have Open 'safe' files after downloading disabled"
    exit "${XCCDF_RESULT_PASS:-101}"
else
    # print the reason why we are failing
    echo "FAILED: The following users have Open 'safe' files after downloading enabled"
    echo "$output"
    exit "${XCCDF_RESULT_FAIL:-102}"
fi