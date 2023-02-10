#!/bin/bash
logfile="$(mktemp -p /tmp logfile-XXXXXXX)"
isoname=""
date_ts=$(date +"%Y-%m-%d_%H.%M.%S")

if [ "x$1" != "x" ] ; then
  isoname=$1
else
  isoname="wrkstn-${date_ts}"
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

/bin/echo -n "Updating the repos on the iso..."
./bin/copy-repos.sh configs/workstation.json workstation/ > "${logfile}" 2>&1
/bin/echo  "done."


/bin/echo -n "Creating the workstation preseed..."
python3 ./lib/template-to-preseed.py --packages "configs/workstation-packages.json" \
  --template "lib/workstation.template"  > "workstation/isolinux/preseed-workstation.cfg"
cp lib/isolinux.cfg workstation//isolinux/
./bin/create-isolinux-menu.sh "workstation/isolinux"
/bin/echo  "done."


./bin/copy-repos.sh configs/workstation-repos.json workstation/ > "${logfile}" 2>&1


/bin/echo -n "Creating the iso..."
./bin/create-iso.sh -i "${isoname}" -s "workstation" > "${logfile}" 2>&1
/bin/echo  "done."

echo "Iso: ${isoname} is at:"
echo "${output}"
echo "Logfile: ${logfile}"
