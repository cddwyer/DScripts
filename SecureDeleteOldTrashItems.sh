#!/bin/bash



#Add user to variable
USER=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')

#Find files in user trash more than 3 days old and secure delete them
find /Users/$USER/.Trash -mtime +3 -type f | xargs rm -fP

#Find files in system Trash older than 3 days and secure delete
find /.Trashes -mtime +3 -type f | xargs rm -fP

exit 0
