#!/bin/bash

#############################################
#											#
# Written by Christian Dwyer - 2019			#
#											#
# This is useful for DEP  deployments		#
# where you would like to wait for the 		#
# desktop to be loaded and visible before 	#
# performing a certain action. This is 		#
# useful if input is needed from the user 	#
# and you find the input boxes are opening 	#
# behind the setup assistant window.		#
#											#
#############################################


userReady="no"

#Checks every 1 second for the console user to change
#from the mbsetup user to the named 501 user
while [[ "$userReady" != "yes" ]]
do
	loggedInUser=$(ls -l /dev/console | awk '{print $3}')
    if [[ "$loggedInUser" = "_mbsetupuser" ]]; then
		sleep 1
	else
    	userReady="yes"
	fi
done

desktopReady="no"

Gets PID of the Setup assistant
setAssPID=$(ps -ax | grep '/System/Library/CoreServices/Setup Assistant.app/Contents/MacOS/Setup Assistant' | grep -v grep | head -1 | awk '{print $1}')


#Checks every 2 seconds to see if the setup assistant is still running, once quit, the script proceeds. 
while [[ "$desktopReady" != "yes" ]]
do
	setAssPID=$(ps -ax | grep '/System/Library/CoreServices/Setup Assistant.app/Contents/MacOS/Setup Assistant' | grep -v grep | head -1 | awk '{print $1}')
    if [[ ! -z "$setAssPID" ]]; then
    	sleep 2
    else
    	desktopReady="yes"
fi
done

exit 0