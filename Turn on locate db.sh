#!/bin/bash

launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist

ldExitCode=$?


if [[ "$ldExitCode" -eq 0 ]]; then
	exit 0
else
	exit 1
fi

