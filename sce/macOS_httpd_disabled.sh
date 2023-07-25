#!/usr/bin/env sh

#
# CIS-CAT Script Check Engine
# 
# Name                Date       Description
# -------------------------------------------------------------------
# Edward Byrd		  01/19/20   Updated to check versus newest audit
# Edward Byrd 		  11/08/22   Updated for the new naming
#

httpd=$(
launchctl print-disabled system | /usr/bin/grep -c '"org.apache.httpd" => disabled'
)

if [ $httpd -eq 1 ] ; then
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

