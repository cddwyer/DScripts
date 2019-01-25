#!/bin/bash


#########################################
# Script to remove Finder and Spotlight #
# preferences, delete the spotlight     #
# index and restart the service         #
#										#
#										#
#	Christian Dwyer - 2018				#
#										#
#										#
#########################################


currentUser=$(ls -l /dev/console | awk '{print $3}')

cdResult=$(/Applications/Utilities/cocoaDialog.app/Contents/MacOS/cocoaDialog ok-msgbox --alert 'Please ensure any open documents are saved before clicking OK!' --title "Restart pending..." --timeout 60)

if [ "$cdResult" -eq 2 ]; then
	echo "User clicked Cancel, exiting..."
    exit 0
fi


rm -rf /Users/$currentUser/Library/Preferences/com.apple.finder*

mdutil -i off

rm -rf /.Spotlight-V1*

mdutil -E

pkill -u "$currentUser"

sleep 10

mdutil -i on

reboot now

exit 0