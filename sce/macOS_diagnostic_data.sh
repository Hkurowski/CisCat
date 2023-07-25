#!/usr/bin/env sh

#
# CIS-CAT Script Check Engine
# 
# Name                Date       Description
# -------------------------------------------------------------------
# Edward Byrd		  11/08/22	 Check if diagnostic data is being sent to Apple
#

diagnosticprofile=$(
/usr/bin/osascript -l JavaScript << EOS
function run() {
let pref1 = $.NSUserDefaults.alloc.initWithSuiteName('com.apple.SubmitDiagInfo')\
.objectForKey('AutoSubmit').js
let pref2 = $.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('allowDiagnosticSubmission').js
let pref3 = $.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
.objectForKey('Siri Data Sharing Opt-In Status').js

if ( pref1 == false && pref2 == false && pref3 == 2){
    return("true")
} else {
    return("false")
}
}
EOS
)

diagauto=$(
/usr/bin/defaults read /Library/Application\ Support/CrashReporter/DiagnosticMessagesHistory.plist AutoSubmit
)

thirdparty=$(
/usr/bin/defaults read /Library/Application\ Support/CrashReporter/DiagnosticMessagesHistory.plist ThirdPartyDataSubmit
)


if [ "$diagnosticprofile" == "true" ]; then
	echo "PASSED: Profile installed to disable sending diagnostic data to Apple"
    exit "${XCCDF_RESULT_PASS:-101}"
else if [ $diagauto != 0  ] || [ $thirdparty != 0 ]; then
	echo "FAILED: The data and diagnostics is being shared with Apple and/or Third Parties"
    echo "$output"
    exit "${XCCDF_RESULT_FAIL:-102}"
else
	for DIR in $(find /Users -type d -maxdepth 1); do
		PREF=$DIR/Library/Preferences/com.apple.assistant.support
		if [ -e $PREF.plist ]; then
			sirishare=$(defaults read $PREF.plist | grep 'Siri Data Sharing Opt-In Status' | grep -c '"Siri Data Sharing Opt-In Status" = 2;')
			if [ "$sirishare" == "0" ]; then
				[ -z "$output" ] && output="User: \"$DIR\" has the sharing Siri data enabled" 
			fi
		fi
	done
	# If test passed, then no output would be generated. If so, we pass
if [ -z "$output" ] ; then
	echo "PASSED: All users have Siri Sharing disabled"
    exit "${XCCDF_RESULT_PASS:-101}"
else
    # print the reason why we are failing
    echo "FAILED: The following user(s) do not have Siri Sharing disabled:"
    echo "$output"
    exit "${XCCDF_RESULT_FAIL:-102}"
fi
fi
fi
