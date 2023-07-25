#!/usr/bin/env sh

#
# CIS-CAT Script Check Engine
# 
# Name                Date       Description
# -------------------------------------------------------------------
# Edward Byrd         07/10/20   Ensure software updates are not deferred
# Edward Byrd		  10/31/22	 Update name and new audit that is more accurate
#

softwaredeferment=$(
/usr/bin/osascript -l JavaScript << EOS
function run() {
  let pref1 = ObjC.unwrap($.NSUserDefaults.alloc.initWithSuiteName('com.apple.applicationaccess')\
  .objectForKey('enforcedSoftwareUpdateDelay'))
  if ( pref1  == null ) {
    return("true")
  }  else if ( pref1 <= 30 ) {
    return("true")
  }  else {
    return("false")
  }
}
EOS
)


if [ "$softwaredeferment" == "true" ]; then
  output=True
else
  output=False
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