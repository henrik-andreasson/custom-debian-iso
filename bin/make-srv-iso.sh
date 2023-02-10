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

mkdir -p "repos/postinstall/current/"
cp debian-fat-postinstall_*.deb "repos/postinstall/current/"
(
  cd "repos/postinstall/current/"
  ../../../bin/create-repo.sh > "${logfile}" 2>&1
)

/bin/echo -n "Updating the repos on the iso..."
./copy-repos.sh repos.json server/ > "${logfile}" 2>&1
cp lib/isolinux.cfg server/isolinux/
cp lib/csws.cfg server/isolinux/
/bin/echo  "done."

/bin/echo -n  "Adding servers..."
for server in configs/*server.json ; do
	servername=$(jq .hostname $server  | tr -d '"')
	if [ -f "configs/$servername-packages.json" ] ; then
		packages="configs/$servername-packages.json"
	else
		packages="configs/packages.json"
	fi
  if [ -f "configs/$servername-repos.json" ] ; then
		repos="configs/$servername-repos.json"
	else
		repos="configs/repos.json"
	fi

  network="configs/${servername}-network.json"
	if [ ! -f $network ] ; then
		echo "network file must exit: ${network}"
		exit
  fi

  preseed="server/isolinux/preseed-$servername.cfg"
	python3 ./lib/template-to-preseed.py --packages "$packages" \
     --server "$server" --network "${network}"  > "$preseed"
	echo "added server: $servername"

  /bin/echo -n "Updating the iso with server repos..."
  ./bin/copy-repos.sh "${repos}" server/ > "${logfile}" 2>&1
  /bin/echo  "done."

done

./bin/create-isolinux-menu.sh

/bin/echo -n "Creating the iso..."
./bin/create-iso.sh "${isoname}" > "${logfile}" 2>&1
/bin/echo  "done."

echo "Iso: ${isoname} is in output: ${output}"
