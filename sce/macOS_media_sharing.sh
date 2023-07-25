#!/usr/bin/env sh

#
# CIS-CAT Script Check Engine
# 
# Name                Date       Description
# -------------------------------------------------------------------
# Edward Byrd		  11/03/22	 Check that media sharing is disabled
#

mediasharing=$(
/usr/bin/osascript -l JavaScript << EOS
function run() {
  let pref1 = ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.preferences.sharing.SharingPrefsExtension')\
  .objectForKey('homeSharingUIStatus'))
  let pref2 = ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.preferences.sharing.SharingPrefsExtension')\
  .objectForKey('legacySharingUIStatus'))
  let pref3 = ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.preferences.sharing.SharingPrefsExtension')\
  .objectForKey('mediaSharingUIStatus'))
  if ( pref1 == 0 && pref2 == 0 && pref3 == 0 ) {
    return("true")
  } else {
    return("false")
  }
}
EOS
)

if [ "$mediasharing" == "true" ]; then
	echo "PASSED: Profile installed to disable Media Sharing"
    exit "${XCCDF_RESULT_PASS:-101}"
else
	for DIR in $(find /Users -type d -maxdepth 1); do
		PREF=$DIR/Library/Preferences/com.apple.amp.mediasharingd
		if [ -e $PREF.plist ]; then
			mediasharingdisabled=$(defaults read $PREF.plist home-sharing-enabled 2>&1)
			if [ $mediasharingdisabled -eq 1 ]; then
				[ -z "$output" ] && output="User: \"$DIR\" has Media Sharing enabled" 
			fi
		fi
	done
	# If test passed, then no output would be generated. If so, we pass
if [ -z "$output" ] ; then
	echo "PASSED: All users have Media Sharing disabled"
    exit "${XCCDF_RESULT_PASS:-101}"
else
    # print the reason why we are failing
    echo "FAILED: The following user(s) do not have Media Sharing disabled:"
    echo "$output"
    exit "${XCCDF_RESULT_FAIL:-102}"
fi
fi



