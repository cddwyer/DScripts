#!/bin/bash


#######################################################
#### Download Google Chrome, check version against ####
#### currently installed version, if an update has #### 
#### been released it will install, otherwise the  #### 
####			script will exit.				   ####
####      Christian Dwyer   -   30/1/2018          ####
#######################################################

# Set Variables
chromeURL="https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg"
googleChrome="/tmp/chrome.dmg"
currentUser=$(stat -f "%Su" /dev/console)

# Check Connection to www.google.com
/usr/bin/curl -D- -o /dev/null -s http://www.google.com
if [[ $? != 0 ]]; then
	echo "Google.com not Reachable, Check Internet Connection"
	exit $?
# Check if Chrome is Already Installed, If not Installation will Continue
else
	echo "Google Chrome not found, Downloading & Installing"
	#Download install dmg and mount it
	/usr/bin/curl -o "$googleChrome" "$chromeURL"
	mount=`/usr/bin/mktemp -d /tmp/Chrome`
	/usr/bin/hdiutil attach "$googleChrome" -mountpoint "$mount" -nobrowse -noverify -noautoopen
	if [ -d /Applications/Google\ Chrome.app ]; then
		#Put currently installed and downloaded version numbers into variables
		curVersion=$(cat /Applications/Google\ Chrome.app/Contents/Info.plist | grep CFBundleShortVersionString -A1 | grep '<string>' | sed 's/\<string\>//g' | sed 's/\<\/string\>//g')
		dlVersion=$(cat /private/tmp/Chrome/Google\ Chrome.app/Contents/Info.plist | grep CFBundleShortVersionString -A1 | grep '<string>' | sed 's/\<string\>//g' | sed 's/\<\/string\>//g')
		#Compare verisons
		if [ "$curVersion" == "dlVersion" ]; then
			echo "You have an up to date version installed, no need to continue."
			#Remove temp files and exit
			/usr/bin/hdiutil detach "$mount"
        		/bin/rm -R /private/tmp/Chrome
        		/bin/rm -rf "$googleChrome"
			exit 5
		fi
		#Install app
		cp -R /private/tmp/Chrome/Google\ Chrome.app /Applications/
		/bin/sleep 1
		
		#Cleanup Temp Files & Mounts, Add Permissions for Current User
		/usr/bin/hdiutil detach "$mount"
		/bin/rm -R /private/tmp/Chrome
		/bin/rm -rf "$googleChrome"
		/bin/sleep 1
		#Set permissions and exit
		/bin/chmod -R +a "$currentUser allow read,write,delete" /Applications/Google\ Chrome.app
		echo "Google Chrome Installed Successfully"
		exit 0
	fi
fi