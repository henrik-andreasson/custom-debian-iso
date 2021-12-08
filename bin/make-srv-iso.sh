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
./make-deb-postinstall.sh  > "${logfile}" 2>&1
/bin/echo  "done."

cp debian-fat-postinstall_2021.06.22_amd64.deb repos/postinstall/current/
(
  cd repos/postinstall/current/
  ../../../create-repo.sh > "${logfile}" 2>&1
)

/bin/echo -n "Updating the repos on the iso..."
./copy-repos.sh repos.json server/ > "${logfile}" 2>&1
cp isolinux.cfg wrk/isolinux/
cp csws.cfg wrk/isolinux/
/bin/echo  "done."

/bin/echo -n  "Adding servers..."
for server in *server.json ; do
	servername=$(jq .hostname $server  | tr -d '"')
	if [ -f "$servername-packages.json" ] ; then
		packages="$servername-packages.json"
	else
		packages="packages.json"
	fi
	if [ ! -f "${servername}-network.json" ] ; then
		echo "network file must exit: ${servername}-network.json"
		exit
	fi
	python3 ./template-to-preseed.py --packages "$packages" --server "$server" --network "${servername}-network.json"  > "server/isolinux/preseed-$servername.cfg"
	echo "added server: $servername"

  /bin/echo -n "Updating the iso with server repos..."
  ./copy-repos.sh "${servername}-repos.json" server/ > "${logfile}" 2>&1
  /bin/echo  "done."

done

./create-isolinux-menu.sh

/bin/echo -n "Creating the iso..."
./create-iso.sh "${isoname}" > "${logfile}" 2>&1
/bin/echo  "done."

echo "Iso: ${isoname} is in output: ${output}"
