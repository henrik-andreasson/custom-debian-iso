#!/bin/bash

logfile="$(mktemp -p /tmp logfile-XXXXXXX)"
isoname=""
date_ts=$(date +"%Y-%m-%d_%H.%M.%S")

if [ "x$1" != "x" ] ; then
  isoname=$1
else
  isoname="snapshot-${date_ts}"
fi

output="wrkstn-debian-iso-${isoname}-11.2.0-amd64.iso"

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
./copy-repos.sh repos.json wrkstn/ > "${logfile}" 2>&1
cp lib/isolinux.cfg wrkstn/isolinux/
cp lib/csws.cfg wrkstn/isolinux/
/bin/echo  "done."



/bin/echo -n "Creating the postintall deb..."
./bin/make-deb-postinstall.sh
cp debian-fat-postinstall_*amd64.deb repos/postinstall/current/
(
  cd repos/postinstall/current/
  ../../../bin/create-repo.sh
)

/bin/echo -n "Creating the workstation preseed..."
python3 ./lib/template-to-preseed.py --template configs/wrkstn-preseed.template --packages configs/wrkstn-packages.json > wrkstn/isolinux/preseed-csws.cfg

/bin/echo -n "Updating the repos on the iso..."
./bin/copy-repos.sh configs/wrkstn-repos.json wrkstn


/bin/echo -n "Creating the iso..."
./bin/create-iso.sh "${isoname}" > "${logfile}" 2>&1
/bin/echo  "done."


echo "Iso: ${isoname} is in output: ${output}"
