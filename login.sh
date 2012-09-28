#!/bin/bash

#
# Generic Login Script
# Author: Joseph J. Viscomi [joseph.viscomi@brehm.org | jjviscomi@gmail.com]
# Description: Script to automatically download and run scripts from a central server.
# Target: OS X / Linux
#



SCRIPTS="login.scripts"
BASEURL="https://myserver.com/scripts/login"
LOCALSCRIPTS="/tmp/.scripts"
SCRIPTUSER="$1"
IPADDRESS=`facter ipaddress`
PINGCOUNT=`ping -c1 $IPADDRESS 2>&1 | grep "1 packets transmitted," | awk '{ print $4}'`
HASINTERNET=0


mkdir -p "$LOCALSCRIPTS"

if [ -n "$PINGCOUNT" ]
then
  if [ $PINGCOUNT -eq 1 ]; then HASINTERNET=1; fi
fi

if [ $HASINTERNET -eq 1 ]
then
  curl -s -f -o "$LOCALSCRIPTS/$SCRIPTS" "$BASEURL/$SCRIPTS"
  if [ $? -ne 0 ]; then DOWNLOAD=0; else DOWNLOAD=1; fi
fi

if [ -e "$LOCALSCRIPTS/$SCRIPTS" ]
then
    SCRIPTLIST=`cat "$LOCALSCRIPTS/$SCRIPTS" 2>/dev/null`
  
  if [ $HASINTERNET -eq 1 ]
  then
    for script in $SCRIPTLIST; do
      if [ $DOWNLOAD -eq 1 ]; then curl -s -f -o "$LOCALSCRIPTS/$script" "$BASEURL/$script"; fi
      if [ -e "$LOCALSCRIPTS/$script" ]; then chmod a+x "$LOCALSCRIPTS/$script"; fi
    done
  fi

  for script in $SCRIPTLIST; do
    "$LOCALSCRIPTS/$script" "$SCRIPTUSER" "$LOCALSCRIPTS" "$BASEURL"
  done
fi

exit 0