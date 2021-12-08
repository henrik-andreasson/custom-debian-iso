#!/bin/bash

/bin/echo -n "Creating the postintall deb..."
./make-deb-postinstall.sh
cp debian-fat-postinstall_2021.06.22_amd64.deb repos/postinstall/current/
(
  cd repos/postinstall/current/
  ../../../create-repo.sh
)

/bin/echo -n "Creating the workstation preseed..."
(
  cd workstation/
  python3 ../template-to-preseed.py --packages packages.json > ../wrk/isolinux/preseed-csws.cfg
  cd ..
)

/bin/echo -n "Updating the repos on the iso..."
./copy-repos.sh workstation/repos.json wrk/

cp isolinux.cfg wrk/isolinux/
cp csws.cfg wrk/isolinux/

/bin/echo -n "Creating the iso..."
./workstation/create-iso.sh
