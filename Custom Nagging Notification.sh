#!/bin/bash

######################################################################
#																	 #
# 																	 #
# Script written to nag users to agree to a policy or update used    #
# when you need to user to run the policy ASAP and want to enforce   #
# it to a point.													 #
# 																	 #
# Parameters must be used:											 #
#																	 #
# 4 - The manual trigger name of the Jamf							 # 
#     Pro policy you're trying to trigger							 #
# 5 - A URL to a company logo (must end .png)						 #
# 6 - The day of the month the deferral capability will expire on    #
# 7 - The month the deferral limit will expire on 					 #
# 8 - The year the deferral limit will expire on					 #
#																	 #
#																	 #
#		Written by Christian Dwyer 30/1/2018						 #
#																	 #
######################################################################

policyToTrigger=$4
companyLogoURL=$5
deferLimitDay=$6
deferLimitMonth=$7
deferLimitYear=$8

todayDD=$(date +%F | cut -d"-" -f3)
todayMM=$(date +%F | cut -d"-" -f2)
todayYY=$(date +%F | cut -d"-" -f1)


/usr/bin/curl -s -o /tmp/logo.png $companyLogoURL

userChoice=$(/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType hud -lockHUD -title "We need to deliver some software to your computer" -timeout 900 -defaultButton 1 -icon /tmp/logo.png -description "We need to install some important software updates on your computer. The process can take up to 40 minutes. You will receive this notification once a day and you can only defer up to $deferLimitDay/$deferLimitMonth/$deferLimitYear on which day the update will be installed regardless of your choice." -alignDescription left -alignHeading left -button1 "Continue" -button2 "Cancel")

if [ "$userChoice" == "0" ]; then
   echo "User clicked continue"
    rm -f /tmp/logo.png
    jamf policy -trigger $policyToTrigger
# If user selects "Cancel"
elif [ "$userChoice" == "2" ]; then
   echo "User clicked defer, checking eligibility"
   if [ "$deferLimitYear" -le "$todayYY" ]; then
   		echo "Deferral capability expires this year"
   		if [ "$deferLimitMonth" -le "$todayMM" ]; then
   			echo "Deferral limit expires this month"
   			if [ "$deferLimitDay" -le "$todayDD" ]; then
   				echo "Deferral limit expired! Executing policy..."
   				rm -f /tmp/logo.png
   				jamf policy -trigger $policyToTrigger
   			else
   				exit 0
   			fi
   		else
   			exit 0
   		fi
   	else
   		exit 0
   	fi
   		   
   exit 0
fi

exit 0