#!/bin/sh

#--------MINECRAFT/CRAFTBUKKIT installer script
#--------package maintained at pcloadletter.co.uk

if [ "${SYNOPKG_PKGNAME}" == "Minecraft" ]; then
  DOWNLOAD_PATH="http://s3.amazonaws.com/Minecraft.Download/versions/1.8.4"
  DOWNLOAD_FILE="minecraft_server.1.8.4.jar"
  UPGRADE_FILES="server.properties *.txt world"
fi
if [ "${SYNOPKG_PKGNAME}" == "Craftbukkit" ]; then
  DOWNLOAD_PATH="http://tcpr.ca/download/craftbukkit"
  DOWNLOAD_FILE="craftbukkit-1.8.3-R0.1-SNAPSHOT-latest.jar"
  UPGRADE_FILES="server.properties *.txt *.yml world world_nether world_the_end plugins bukkit_update"
fi

DOWNLOAD_URL="${DOWNLOAD_PATH}/${DOWNLOAD_FILE}"
DAEMON_USER="`echo ${SYNOPKG_PKGNAME} | awk {'print tolower($_)'}`"
DAEMON_ID="${SYNOPKG_PKGNAME} daemon user"
DAEMON_PASS="`openssl rand 12 -base64 2>/dev/null`"
MIGRATION_FOLDER="${DAEMON_USER}_data_mig"
ENGINE_SCRIPT="/var/packages/${SYNOPKG_PKGNAME}/scripts/launcher.sh"
INSTALL_FILES="${DOWNLOAD_URL}"
source /etc/profile
TEMP_FOLDER="`find / -maxdepth 2 -name '@tmp' | head -n 1`"
PRIMARY_VOLUME="/`echo $TEMP_FOLDER | cut -f2 -d'/'`"
WORLD_BACKUP="${PRIMARY_VOLUME}/public/${DAEMON_USER}world.`date +\"%d-%b\"`.bak"

preinst ()
{
  if [ -z ${JAVA_HOME} ]; then
    echo "Java is not installed or not properly configured. JAVA_HOME is not defined. "
    echo "Download and install the Java Synology package from http://wp.me/pVshC-z5"
    exit 1
  fi
  
  if [ ! -f ${JAVA_HOME}/bin/java ]; then
    echo "Java is not installed or not properly configured. The Java binary could not be located. "
    echo "Download and install the Java Synology package from http://wp.me/pVshC-z5"
    exit 1
  fi
  
  #is the User Home service enabled?
  UH_SERVICE=maybe
  synouser --add userhometest Testing123 "User Home test user" 0 "" ""
  UHT_HOMEDIR=`cat /etc/passwd | sed -r '/User Home test user/!d;s/^.*:User Home test user:(.*):.*$/\1/'`
  if echo $UHT_HOMEDIR | grep '/var/services/homes/' > /dev/null; then
    if [ ! -d $UHT_HOMEDIR ]; then
      UH_SERVICE=false
    fi
  fi
  synouser --del userhometest
  #remove home directory (needed since DSM 4.1)
  [ -e /var/services/homes/userhometest ] && rm -r /var/services/homes/userhometest
  if [ ${UH_SERVICE} == "false" ]; then
    echo "The User Home service is not enabled. Please enable this feature in the User control panel in DSM."
    exit 1
  fi

  cd ${TEMP_FOLDER}
  for WGET_URL in ${INSTALL_FILES}
  do
    WGET_FILENAME="`echo ${WGET_URL} | sed -r "s%^.*/(.*)%\1%"`"
    [ -f ${TEMP_FOLDER}/${WGET_FILENAME} ] && rm ${TEMP_FOLDER}/${WGET_FILENAME}
    wget ${WGET_URL}
    if [[ $? != 0 ]]; then
      if [ -d ${PUBLIC_FOLDER} ] && [ -f ${PUBLIC_FOLDER}/${WGET_FILENAME} ]; then
        cp ${PUBLIC_FOLDER}/${WGET_FILENAME} ${TEMP_FOLDER}
      else     
        echo "There was a problem downloading ${WGET_FILENAME} from the official download link, "
        echo "which was \"${WGET_URL}\" "
        echo "Alternatively, you may download this file manually and place it in the 'public' shared folder. "
        echo "Debug: ${DOWNLOAD_URL}"
        exit 1
      fi
    fi
  done
  
  exit 0
}


postinst ()
{
  #create daemon user
  synouser --add ${DAEMON_USER} ${DAEMON_PASS} "${DAEMON_ID}" 0 "" ""
  
  mv ${TEMP_FOLDER}/${DAEMON_USER}*.jar ${SYNOPKG_PKGDEST}/${DAEMON_USER}.jar
  
  #determine the daemon user homedir and save that variable in the user's profile
  #this is needed because new users seem to inherit a HOME value of /root which they have no permissions for
  DAEMON_HOME="`cat /etc/passwd | grep "${DAEMON_ID}" | cut -f6 -d':'`"
  su - ${DAEMON_USER} -s /bin/sh -c "echo export HOME=\'${DAEMON_HOME}\' >> .profile"
  
  #change owner of folder tree
  chown -R ${DAEMON_USER} ${SYNOPKG_PKGDEST}
  
  exit 0
}


preuninst ()
{
  #make sure server is stopped
  su - ${DAEMON_USER} -s /bin/sh -c "${ENGINE_SCRIPT} stop ${SYNOPKG_PKGNAME} ${SYNOPKG_PKGDEST}"
  sleep 10
  
  #if a world exists, back it up to the public folder, just in case...
  if [ -d ${SYNOPKG_PKGDEST}/world ]; then
    if [ ! -d ${WORLD_BACKUP} ]; then
      mkdir -p ${WORLD_BACKUP}
    fi
    for ITEM in ${UPGRADE_FILES}; do
      mv ${SYNOPKG_PKGDEST}/${ITEM} ${WORLD_BACKUP}
    done
  fi
  
  exit 0
}


postuninst ()
{
  #remove daemon user
  synouser --del ${DAEMON_USER}
  
  #remove daemon user's home directory (needed since DSM 4.1)
  [ -e /var/services/homes/${DAEMON_USER} ] && rm -r /var/services/homes/${DAEMON_USER}
  
  exit 0
}


preupgrade ()
{
  #make sure the server is stopped
  su - ${DAEMON_USER} -s /bin/sh -c "${ENGINE_SCRIPT} stop ${SYNOPKG_PKGNAME} ${SYNOPKG_PKGDEST}"
  sleep 10
  
  #if a world exists, back it up
  if [ -d ${SYNOPKG_PKGDEST}/world ]; then
    mkdir ${SYNOPKG_PKGDEST}/../${MIGRATION_FOLDER}
    for ITEM in ${UPGRADE_FILES}; do
      if [ -e ${SYNOPKG_PKGDEST}/${ITEM} ]; then
        mv ${SYNOPKG_PKGDEST}/${ITEM} ${SYNOPKG_PKGDEST}/../${MIGRATION_FOLDER}
      fi
    done
  fi
  
  exit 0
}


postupgrade ()
{
  #use the migrated data files from the previous version
  if [ -d ${SYNOPKG_PKGDEST}/../${MIGRATION_FOLDER}/world ]; then
    for ITEM in ${UPGRADE_FILES}; do
      if [ -e ${SYNOPKG_PKGDEST}/../${MIGRATION_FOLDER}/${ITEM} ]; then
        mv ${SYNOPKG_PKGDEST}/../${MIGRATION_FOLDER}/${ITEM} ${SYNOPKG_PKGDEST}
      fi
    done
    rmdir ${SYNOPKG_PKGDEST}/../${MIGRATION_FOLDER}
    
    #daemon user has been deleted and recreated so we need to reset ownership (new UID)
    chown -R ${DAEMON_USER} ${SYNOPKG_PKGDEST}
  fi
  	
  exit 0
}
