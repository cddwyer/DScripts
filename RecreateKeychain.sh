#!/bin/bash


#Find out who's logged in
USER=`who | grep console | awk '{print $1}'`

#Get the name of the users keychain - some messy sed and awk to set up the correct name for security to like
KEYCHAIN=`su $USER -c "security list-keychains" | grep login | sed -e 's/\"//g' | sed -e 's/\// /g' | awk '{print $NF}'`

#Go delete the keychain in question...
su $USER -c "security delete-keychain $KEYCHAIN"

#Ask the user for their login password to create a new keychain
PASSWORD="$(/usr/bin/osascript -e 'Tell application "System Events" to display dialog "Please enter your login password:" default answer "" with title "Login Password" with text buttons {"Ok"} default button 1 with hidden answer' -e 'text returned of result')"


#Create the new login keychain
expect <<- DONE
  set timeout -1
  spawn su $USER -c "security create-keychain login.keychain"
  # Look for  prompt
  expect "*?chain:*"
  # send user entered password from CocoaDialog
  send "$PASSWORD\n"
  expect "*?chain:*"
  send "$PASSWORD\r"
  expect EOF
DONE

#Set the newly created login.keychain as the users default keychain
su $USER -c "security default-keychain -s login.keychain"