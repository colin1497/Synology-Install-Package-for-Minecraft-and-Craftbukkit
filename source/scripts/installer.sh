#!/bin/sh

#--------MINECRAFT/CRAFTBUKKIT/Spigot installer script
#--------package maintained at https://github.com/colin1497/Synology-Install-Package-for-Minecraft-and-Craftbukkit

if [ "${SYNOPKG_PKGNAME}" == "Minecraft" ]; then
  DOWNLOAD_PATH="https://launcher.mojang.com/v1/objects/808be3869e2ca6b62378f9f4b33c946621620019"
  DOWNLOAD_FILE="server.jar"
  UPGRADE_FILES="server.properties *.txt world *.json"
fi
if [ "${SYNOPKG_PKGNAME}" == "Craftbukkit" ]; then
  DOWNLOAD_PATH="https://cdn.getbukkit.org/craftbukkit"
  DOWNLOAD_FILE="craftbukkit-1.14.2-r0.1-snapshot.jar"
  UPGRADE_FILES="server.properties *.txt *.yml world world_nether world_the_end plugins bukkit_update *.json"
fi
if [ "${SYNOPKG_PKGNAME}" == "Spigot" ]; then
  DOWNLOAD_PATH="https://cdn.getbukkit.org/spigot"
  DOWNLOAD_FILE="spigot-1.14.2.jar"
  UPGRADE_FILES="server.properties *.txt *.yml world world_nether world_the_end plugins spigot_update *.json"
fi
if [ "${SYNOPKG_PKGNAME}" == "NukkitX" ]; then
  DOWNLOAD_PATH="https://ci.nukkitx.com/job/NukkitX/job/Nukkit/job/master/lastSuccessfulBuild/artifact/target"
  DOWNLOAD_FILE="nukkit-1.0-SNAPSHOT.jar"
  UPGRADE_FILES="server.properties *.txt *.yml world world_nether world_the_end plugins spigot_update *.json"
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
UH_SERVICE=synogetkeyvalue /etc/synoinfo.conf userHomeEnable

if [ ${UH_SERVICE} == "no" ]; then
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
