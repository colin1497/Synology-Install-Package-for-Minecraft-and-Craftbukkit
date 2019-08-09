#!/bin/sh

#--------MINECRAFT/CRAFTBUKKIT server launcher script
#--------package maintained at blog.heatdfw.com
 
#--------Allows graceful shutdown of server without CPU-specific binaries
#--------You can send commands to the running server like so:
#--------    echo say Hello players >> /tmp/stdin.minecraft
#--------    echo say Hello players >> /tmp/stdin.craftbukkit
#--------    echo say Hello players >> /tmp/stdin.spigot
#--------    echo say Hello players >> /tmp/stdin.nukkit

DAEMON_USER=$2
SYNOPKG_PKGDEST=$3
DAEMON_USER_SHORT=`echo ${DAEMON_USER} | cut -c 1-8`
JAR_FILE=${SYNOPKG_PKGDEST}/$2.jar

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
  
        #ARM CPU lags a lot, so reduce drawing distance from 10 chunks to 6
        cat /proc/cpuinfo | grep "CPU architecture: 5TE" > /dev/null \
         && sed -i "s/^view-distance=10/view-distance=6/" server.properties
  
        #record that these mods have been made
        echo config updated > syno-marker.txt
      fi
    fi
    JAVA_OPTS='-XX:+UseConcMarkSweepGC -XX:+CMSIncrementalPacing -XX:+AggressiveOpts'
    RAM=$((`free | grep Mem: | sed -e "s/^ *Mem: *\([0-9]*\).*$/\1/"`/1024))
    if [ $RAM -le 128 ]; then
      JAVA_MAX_HEAP=80M
    elif [ $RAM -le 256 ]; then
      JAVA_MAX_HEAP=160M
    elif [ $RAM -le 512 ]; then
      JAVA_MAX_HEAP=416M
    elif [ $RAM -le 1024 ]; then
      JAVA_MAX_HEAP=832M
    elif [ $RAM -le 2048 ]; then
      JAVA_MAX_HEAP=1664M
    elif [ $RAM -le 3072 ]; then
      JAVA_MAX_HEAP=2560M
    elif [ $RAM -le 4096 ]; then 
      JAVA_MAX_HEAP=3584M
    elif [ $RAM -le 6144 ]; then 
      JAVA_MAX_HEAP=4096M
    elif [ $RAM -gt 6144 ]; then 
      JAVA_MAX_HEAP=5120M
    fi
    JAVA_START_HEAP=${JAVA_MAX_HEAP}
    tail -n 0 -f /tmp/stdin.${DAEMON_USER} | java -Xmx${JAVA_START_HEAP} -Xms${JAVA_MAX_HEAP} ${JAVA_OPTS} -jar ${JAR_FILE} nogui
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
