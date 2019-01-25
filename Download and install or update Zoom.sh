#!/bin/sh

#	Script to install or update Zoom conferencing


#set high quality video
hdvideo="true"

#single sing on prefs for future HW use
ssodefault="false"
ssohost=""


# choose language (en-US, fr, de)
lang=""


# get jamf language parameter, set english if none passed
if [ "$4" != "" ] && [ "$lang" == "" ]; then
        lang=$4
else 
        lang="en-US"
fi

#set variable names for package and log file path
pkgfile="ZoomInstallerIT.pkg"
plistfile="us.zoom.config.plist"
logfile="/Library/Logs/ZoomInstallScript.log"

#check architecture as zoom still serving power pc installer
if [ '`/usr/bin/uname -p`'="i386" -o '`/usr/bin/uname -p`'="x86_64" ]; then
        #get OS version and replace dots with underscores
        OSvers_URL=$( sw_vers -productVersion | sed 's/[.]/_/g' )

        #set user agent, chose apple webkit
        userAgent="Mozilla/5.0 (Macintosh; Intel Mac OS X ${OSvers_URL}) AppleWebKit/535.6.2 (KHTML, like Gecko) Version/5.2 Safari/535.6.2"

        #get latest version available from site
        latestver=`/usr/bin/curl -s -A "$userAgent" https://zoom.us/download | grep 'ZoomInstallerIT.pkg' | awk -F'/' '{print $3}'`
        echo "Latest Version is: $latestver"

        #check if currently installed grab version
        if [ -e "/Applications/zoom.us.app" ]; then
                currentinstalledver=`/usr/bin/defaults read /Applications/zoom.us.app/Contents/Info CFBundleShortVersionString`
                echo "Current installed version is: $currentinstalledver"
                if [ ${latestver} = ${currentinstalledver} ]; then
                        echo "Zoom is current. Exiting"
                        exit 0
                fi
        else
                currentinstalledver="none"
                echo "Zoom is not installed"
        fi

		#set URL for downloading
        url="https://zoom.us/client/${latestver}/ZoomInstallerIT.pkg"
		
		#keep log up to date
        echo "Latest version of the URL is: $url"
        echo "`date`: Download URL: $url" >> ${logfile}

        #check installed vs downloaded version and decide accordingly, contruct pref file
        if [ "${currentinstalledver}" != "${latestver}" ]; then

                # Construct the plist file for preferences
                echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
                 <!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
                 <plist version=\"1.0\">
                 <dict>
                        <key>nogoogle</key>
                        <string>1</string>
                        <key>nofacebook</key>
                        <string>1</string>
                        <key>ZDisableVideo</key>
                        <true/>
                        <key>ZAutoJoinVoip</key>
                        <true/>
                        <key>ZDualMonitorOn</key>
                        <true/>" >> /tmp/${plistfile}

                if [ "${ssohost}" != "" ]; then
                        echo "
                        <key>ZAutoSSOLogin</key>
                        <true/>
                        <key>ZSSOHost</key>
                        <string>$ssohost</string>" >> /tmp/${plistfile}
                fi

                echo "<key>ZAutoFullScreenWhenViewShare</key>
                        <true/>
                        <key>ZAutoFitWhenViewShare</key>
                        <true/>" >> /tmp/${plistfile}

                if [ "${hdvideo}" == "true" ]; then
                        echo "<key>ZUse720PByDefault</key>
                        <true/>" >> /tmp/${plistfile}
                else
                        echo "<key>ZUse720PByDefault</key>
                        <false/>" >> /tmp/${plistfile}
                fi

                echo "<key>ZRemoteControlAllApp</key>
                        <true/>
                </dict>
                </plist>" >> /tmp/${plistfile}



                #download and install new version
                /bin/echo "`date`: Current Zoom version: ${currentinstalledver}" >> ${logfile}
                /bin/echo "`date`: Available Zoom version: ${latestver}" >> ${logfile}
                /bin/echo "`date`: Downloading newer version." >> ${logfile}
                /usr/bin/curl -L -o /tmp/${pkgfile} ${url}
                /bin/echo "`date`: Installing PKG..." >> ${logfile}
                /usr/sbin/installer -allowUntrusted -pkg /tmp/${pkgfile} -target /

                /bin/sleep 10
                /bin/echo "`date`: Deleting downloaded PKG." >> ${logfile}
                /bin/rm /tmp/${pkgfile}

                #double check to see if the new version got updated
                newlyinstalledver=`/usr/bin/defaults read /Applications/zoom.us.app/Contents/Info CFBundleShortVersionString`
        if [ "${latestver}" = "${newlyinstalledver}" ]; then
                /bin/echo "`date`: SUCCESS: Zoom has been updated to version ${newlyinstalledver}" >> ${logfile}
                # /Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType hud -title "Zoom Installed" -description "Zoom has been updated." &
        else
                /bin/echo "`date`: ERROR: Zoom update unsuccessful, version remains at ${currentinstalledver}." >> ${logfile}
                /bin/echo "--" >> ${logfile}
                        exit 1
                fi

        # If Zoom is up to date already, just log it and exit.
        else
                /bin/echo "`date`: Zoom is already up to date, running ${currentinstalledver}." >> ${logfile}
        /bin/echo "--" >> ${logfile}
        fi      
else
        /bin/echo "`date`: ERROR: This script is for Intel Macs only." >> ${logfile}
fi

exit 0