#!/bin/bash

logfile="$(mktemp -p /tmp logfile-XXXXXXX)"
isoname=""
date_ts=$(date +"%Y-%m-%d_%H.%M.%S")

if [ "x$1" != "x" ] ; then
  isoname=$1
else
  isoname="snapshot-${date_ts}"
fi

output="custom-debian-iso-${isoname}-11.0.0-amd64.iso"

/bin/echo -n "Creating the postintall deb..."
./bin/make-deb-postinstall.sh  > "${logfile}" 2>&1
/bin/echo  "done."
mkdir -p repos/postinstall/current
cp debian-fat-postinstall*_amd64.deb repos/postinstall/current/
(
  cd repos/postinstall/current/
  ../../../bin/create-repo.sh > "${logfile}" 2>&1
)

/bin/echo -n "Updating common repos on the iso..."
./bin/copy-repos.sh configs/repos.json server/ > "${logfile}" 2>&1
cp lib/isolinux.cfg server/isolinux/
cp lib/csws.cfg server/isolinux/
/bin/echo  "done."

/bin/echo -n  "Adding servers..."
for server in configs/*server.json ; do
	servername=$(jq .hostname $server  | tr -d '"')
	if [ -f "configs/$servername-packages.json" ] ; then
		packages="configs/$servername-packages.json"
	else
		packages="configs/default-packages.json"
	fi
	if [ ! -f "configs/${servername}-network.json" ] ; then
		echo "network file must exit: configs/${servername}-network.json"
		exit
	fi
	python3 ./lib/template-to-preseed.py --packages "$packages" --server "$server" --network "configs/${servername}-network.json"  > "server/isolinux/preseed-$servername.cfg"
	echo "added server: $servername"

  /bin/echo -n "Updating the iso with server repos..."
  if [ -f "configs/${servername}-repos.json" ] ; then
    ./bin/copy-repos.sh "configs/${servername}-repos.json" server/ > "${logfile}" 2>&1
  elif [ -f "configs/default--repos.json" ] ; then
    ./bin/copy-repos.sh "configs/default-repos.json" server/ > "${logfile}" 2>&1
  else
    echo "no repos conffi found, not: configs/${servername}-repos.json nor: configs/default-repos.json"
  fi
  /bin/echo  "done."

done

./bin/create-isolinux-menu.sh
./bin/create-uefi-menu.sh

/bin/echo -n "Creating the iso..."
./bin/create-iso.sh -i "${isoname}" > "${logfile}" 2>&1
/bin/echo  "done."

echo "Iso: ${isoname} is in output: ${output}"
