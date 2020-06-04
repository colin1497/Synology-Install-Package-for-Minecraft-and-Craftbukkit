#!/bin/sh

#--------MINECRAFT Bedrock server launcher script
#--------package maintained at blog.heatdfw.com
 
#--------Allows graceful shutdown of server without CPU-specific binaries
#--------You can send commands to the running server like so:
#--------    echo say Hello players >> /tmp/stdin.bedrock


DAEMON_USER=$2
SYNOPKG_PKGDEST=$3
DAEMON_USER_SHORT=`echo ${DAEMON_USER} | cut -c 1-8`

case $1 in
  start)
    if [ -f /tmp/stdin.${DAEMON_USER} ]; then
      rm /tmp/stdin.${DAEMON_USER}
    fi
    touch /tmp/stdin.${DAEMON_USER}
    cd ${SYNOPKG_PKGDEST}
    if [ ! -f syno-marker.txt ]; then
      if [ -f server.properties ]; then
        sed -i "s/A Minecraft Server/A Synology Minecraft Server/" server.properties
  
       #record that these mods have been made
        echo config updated > syno-marker.txt
      fi
    fi
    tail -n 0 -f /tmp/stdin.${DAEMON_USER} | LD_LIBRARY_PATH=. ./bedrock_server nogui
  ;;

  stop)
    echo say shutting down.. >> /tmp/stdin.${DAEMON_USER}
    sleep 5
    echo stop >> /tmp/stdin.${DAEMON_USER}
    sleep 10
    kill -9 `ps | grep "^ *[0-9]* ${DAEMON_USER_SHORT}.*tail -n 0 -f /tmp/stdin.${DAEMON_USER}" | sed -e "s/^ *\([0-9]*\).*$/\1/"`
    if [ -f /tmp/stdin.${DAEMON_USER} ]; then
      rm /tmp/stdin.${DAEMON_USER}
    fi
  ;;
esac
