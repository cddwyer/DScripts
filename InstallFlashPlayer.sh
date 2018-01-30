#!/bin/bash

#Get the latest flash version from internet
flash_version=`/usr/bin/curl --silent http://fpdownload2.macromedia.com/get/flashplayer/update/current/xml/version_en_mac_pl.xml | cut -d '=' -f2 | head -1 | cut -d '"' -f2 | sed 's/,/./g'`


#Construct download URL
fileURL="https://fpdownload.adobe.com/get/flashplayer/pdc/"$flash_version"/install_flash_player_osx.dmg"

#Set download file name
flash_dmg="/tmp/flash.dmg"

# Download the latest version of Flash player
/usr/bin/curl --output "$flash_dmg" "$fileURL"

#Create a mount point for the dmg
tmpMount1=`/usr/bin/mktemp -d /tmp/flashplayer.XXXX`
# Mount the latest Flash Player disk image to /tmp/flashplayer.XXXX mountpoint
hdiutil attach "$flash_dmg" -mountpoint "$tmpMount1" -nobrowse -noverify -noautoopen

# Install flash player package from dmg
/usr/sbin/installer -dumplog -verbose -pkg "$(/usr/bin/find $tmpMount1 -maxdepth 1 \( -iname \*\.pkg -o -iname \*\.mpkg \))" -target "/"

# Clean-up
/usr/bin/hdiutil detach "$tmpMount1"
/bin/rm -rf "$tmpMount1"
/bin/rm -rf "$flash_dmg"

exit 0
