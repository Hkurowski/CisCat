#!/usr/bin/env sh

#
# CIS-CAT Script Check Engine
# 
# Name                Date       Description
# -------------------------------------------------------------------
# Edward Byrd		  11/03/22	 Check that if Time Machine is enabled then auto back is enabled
#

autotimemachine=$(
/usr/bin/osascript -l JavaScript << EOS
function run() {
  let pref1 = ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.TimeMachine')\
  .objectForKey('AutoBackup'))
  let pref2 = ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.TimeMachine')\
  .objectForKey('LastDestinationID'))
  if ( pref2  == null ) {
    return("Preference Not Set")
  }  else if ( pref1 == 1 ) {
    return("true")
  }  else {
    return("false")
  }
}
EOS
)


if [ "$autotimemachine" == "Preference Not Set" ]; then
	echo "Time Machine is not enabled so the computer is compliant"
    exit "${XCCDF_RESULT_PASS:-101}"
else if [ "$autotimemachine" == "true" ]; then
  output=True
else
  output=False
fi
fi

# If result returns 0 pass, otherwise fail.
if [ "$output" == True ] ; then
	echo "$output"
    exit "${XCCDF_RESULT_PASS:-101}"
else
    # print the reason why we are failing
    echo "$output"
    exit "${XCCDF_RESULT_FAIL:-102}"
fi