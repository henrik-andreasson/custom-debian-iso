#!/bin/bash

date_ts=$(date +"%Y-%m-%d_%H.%M.%S")
logfile="$(mktemp -p logs logfile-${date_ts}-XXXXXXX)"
isoname=""
serverdir=""

while getopts n:s: flag; do
  case $flag in
    n) isoname="$OPTARG";
      ;;
    s) serverdir=$OPTARG;
      ;;
    ?)
      exit;
      ;;
  esac
done

if [ "x$isoname" == "x" ] ; then
  isoname="snapshot-${date_ts}"
fi

if [ "x$serverdir" == "x" ] ; then
  serverdir="server"
fi

if [[ ! -d "$serverdir" ]] ; then
  echo "serverdir not found ($serverdir)"
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

/bin/echo -n "Updating common repos on the iso..."
./bin/copy-repos.sh configs/repos.json "${serverdir}" >> "${logfile}" 2>&1
cp lib/isolinux.cfg "${serverdir}/isolinux/"
cp lib/csws.cfg "${serverdir}/isolinux/"
/bin/echo  "done."

/bin/echo -n  "Adding servers..."
for server in configs/*server.json ; do
	servername=$(jq .hostname $server  | tr -d '"')
  packages=""
	if [ -f "configs/$servername-packages.json" ] ; then
    echo "Using configs/$servername-packages.json"
		packages="configs/$servername-packages.json"
	else
    echo "Using configs/default-packages.json ($servername)"
		packages="configs/default-packages.json"
	fi
  support=""
  if [ -f "configs/$servername-support.json" ] ; then
		support="configs/$servername-support.json"
	else
		support="configs/default-support.json"
	fi

	if [ ! -f "configs/${servername}-network.json" ] ; then
		echo "network file must exit: configs/${servername}-network.json"
		exit
	fi
	python3 ./lib/template-to-preseed.py --packages "$packages" \
    --server "$server" \
    --support "$support" \
    --network "configs/${servername}-network.json" \
    > "${serverdir}/isolinux/preseed-$servername.cfg"

	echo "added server: $servername"

  /bin/echo -n "Updating the iso with server repos..."
  if [ -f "configs/${servername}-repos.json" ] ; then
    ./bin/copy-repos.sh "configs/${servername}-repos.json" "${serverdir}" >> "${logfile}" 2>&1
  elif [ -f "configs/default--repos.json" ] ; then
    ./bin/copy-repos.sh "configs/default-repos.json" "${serverdir}" >> "${logfile}" 2>&1
  else
    echo "no repos config found, not: configs/${servername}-repos.json nor: configs/default-repos.json"
  fi
  /bin/echo  "done."

done

./bin/create-isolinux-menu.sh
./bin/create-uefi-menu.sh -i "${serverdir}/isolinux" -u "${serverdir}/boot/grub"

/bin/echo -n "Creating the iso..."
./bin/create-iso.sh -i "${isoname}" >> "${logfile}" 2>&1
/bin/echo  "done."

echo "Iso: ${isoname} is in output: ${output}"
