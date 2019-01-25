#!/bin/bash


#Set local admin as able to unlock session from lock screen
security authorizationdb write system.login.screensaver authenticate-session-owner-or-admin

