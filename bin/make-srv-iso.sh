#!/bin/bash

date_ts=$(date +"%Y-%m-%d_%H.%M.%S")
logfile="$(mktemp -p logs logfile-${date_ts}-XXXXXXX)"
isoname=""
serverdir=""
configdir=""

while getopts n:s:c:o: flag; do
  case $flag in
    n) isoname="$OPTARG";
      ;;
    s) serverdir=$OPTARG;
      ;;
    c) configdir=$OPTARG;
      ;;
    o) outputdir=$OPTARG;
      ;;

    ?)
      exit;
      ;;
  esac
done

if [[ "x${ISONAME}" != "x" ]]; then
  isoname="${ISONAME}"

elif [[ "x$isoname" == "x" ]] ; then
  isoname="snapshot-${date_ts}"

fi

if [[ "x${SERVERDIR}" != "x" ]]; then
  serverdir="${SERVERDIR}"

elif [[ "x$serverdir" == "x" ]] ; then
  serverdir="server"

fi

if [[ ! -d "$serverdir" ]] ; then
  echo "serverdir not found ($serverdir)"
  exit -1
fi

if [[ "x${CONFIGDIR}" != "x" ]] ; then
  configdir="${CONFIGDIR}"
elif [[ "x$configdir" == "x" ]] ; then
  configdir="configs"
fi

if [[ ! -d "$configdir" ]] ; then
  echo "configdir not found ($configdir)"
  exit -1
fi

if [[ "x$OUTDIR" != "x" ]] ; then
  outputdir="${OUTDIR}"
elif [[ "x$outputdir" == "x" ]] ; then

  outputdir="."
fi

if [[ ! -d "$outputdir" ]] ; then
  echo "outputdir not found ($outputdir)"
  exit -1
fi



output="custom-debian-iso-${isoname}-11.0.0-amd64.iso"

/bin/echo -n "Creating the postintall deb..."
./bin/make-deb-postinstall.sh  > "${logfile}" 2>&1
/bin/echo  "done."
mkdir -p repos/postinstall/current
cp debian-fat-postinstall*_amd64.deb repos/postinstall/current/
(
  cd repos/postinstall/current/
  ../../../bin/create-repo.sh >> "../../../${logfile}" 2>&1
)

/bin/echo -n "Removing old repos from the iso..."
for repo in "${serverdir}/repo-"* ; do
  echo "repo: $repo"
  rm -rf $repo
done
/bin/echo  "done."

/bin/echo -n "Updating common repos on the iso..."
./bin/copy-repos.sh -j "${configdir}/repos.json" -s "${serverdir}" -r "/var/www/html/repo" >> "${logfile}" 2>&1
cp lib/isolinux.cfg "${serverdir}/isolinux/"
cp lib/csws.cfg "${serverdir}/isolinux/"
/bin/echo  "done."

/bin/echo -n  "Checking json formatting of config..."
for file in ${configdir}/*json ; do
  cat $file | jq . >/dev/null 2>&1
  if [ $? -ne 0 ] ; then
    echo "file: $file not passing json parsing"
  fi
done
/bin/echo "done"


/bin/echo -n  "Cleaning out old servers..."
for preseed in "${serverdir}/isolinux/preseed-"*".cfg" ; do
  echo "preseed: ${preseed}"
  rm -rf "${preseed}"
done
/bin/echo "done"

/bin/echo -n  "Adding servers..."
for server in ${configdir}/*server.json ; do
	servername=$(jq .hostname $server  | tr -d '"')
  packages=""
	if [ -f "${configdir}/$servername-packages.json" ] ; then
    echo "Using ${configdir}/$servername-packages.json"
		packages="${configdir}/$servername-packages.json"
	else
    echo "Using ${configdir}/default-packages.json ($servername)"
		packages="${configdir}/default-packages.json"
	fi
  support=""
  if [ -f "${configdir}/$servername-support.json" ] ; then
		support="${configdir}/$servername-support.json"
	else
		support="${configdir}/default-support.json"
	fi
  if [ ! -f "${configdir}/$servername-network.json" ] ; then
    continue
  fi

	if [ ! -f "${configdir}/${servername}-network.json" ] ; then
		echo "network file must exit: ${configdir}/${servername}-network.json"
		exit
	fi
	python3 ./lib/template-to-preseed.py --packages "$packages" \
    --server "$server" \
    --support "$support" \
    --network "${configdir}/${servername}-network.json" \
    > "${serverdir}/isolinux/preseed-$servername.cfg"

	echo "added server: $servername"

  /bin/echo -n "Updating the iso with server repos..."
  if [ -f "${configdir}/${servername}-repos.json" ] ; then
    ./bin/copy-repos.sh -j "${configdir}/${servername}-repos.json" -s "${serverdir}"  -r "/var/www/html/repo" 2>> "${logfile}"
  elif [ -f "${configdir}/default-repos.json" ] ; then
    ./bin/copy-repos.sh -j "${configdir}/default-repos.json" -s "${serverdir}" -r "/var/www/html/repo" 2>> "${logfile}"
  else
    echo "no repos config found, not: ${configdir}/${servername}-repos.json nor: ${configdir}/default-repos.json"
  fi
  /bin/echo  "done."
  #TODO: as an option
  cp /opt/custom-debian-iso/trusted-services-archive.gpg "${serverdir}"
done

./bin/create-isolinux-menu.sh "${serverdir}/isolinux"
./bin/create-uefi-menu.sh -i "${serverdir}/isolinux" -u "${serverdir}/boot/grub"

/bin/echo -n "Creating the iso..."
isooutput="${outputdir}/custom-debian-iso-${isoname}-11.0.0-amd64.iso"
./bin/create-iso.sh -i "${isoname}" -s "$serverdir" -o "${isooutput}" >> "${logfile}" 2>&1
/bin/echo  "done."

echo "Iso: ${isoname} is in output: ${isooutput}" | tee -a "${logfile}"
echo "${isoname}"
echo "${isoname}" > name-of-last-built-iso.txt
