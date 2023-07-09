#!/bin/bash

date_ts=$(date +"%Y-%m-%d_%H.%M.%S")
curdir=$(pwd)
logfile=$(mktemp -p "${curdir}/logs" "logfile-${date_ts}-XXXXXXX.log")
isoname=""
wrkstndir=""
configdir=""

while getopts n:w:c:o: flag; do
  case $flag in
    n) ISONAME="$OPTARG";
      ;;
    w) WRKSTNDIR=$OPTARG;
      ;;
    c) CONFIGDIR=$OPTARG;
      ;;
    o) OUTDIR=$OPTARG;
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

if [[ "x${WRKSTNDIR}" != "x" ]]; then
  wrkstndir="${WRKSTNDIR}"

elif [[ "x$srkstndir" == "x" ]] ; then
  wrkstndir="wrkstn"

fi

if [[ ! -d "$wrkstndir" ]] ; then
  echo "wrkstndir not found ($wrkstndir)"
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
  ../../../bin/create-repo.sh > "${logfile}"
)

/bin/echo -n "Removing old repos from the iso..."
for repo in "${serverdir}/repo-"* ; do
  echo "repo: $repo"
  rm -rf $repo
done
/bin/echo  "done."

/bin/echo -n "Updating the repos on the iso..."
./bin/copy-repos.sh configs/workstation.json workstation/ > "${logfile}" 2>&1
./bin/copy-repos.sh -j "${configdir}/repos.json" -s "${wrkstndir}" -r "/var/www/html/repo" >> "${logfile}" 2>&1
cp lib/isolinux.cfg "${wrkstndir}/isolinux/"
cp lib/csws.cfg "${wrkstndir}/isolinux/"
/bin/echo  "done."

/bin/echo -n  "Checking json formatting of config..."
for file in ${configdir}/*json ; do
  cat $file | jq . >/dev/null 2>&1
  if [ $? -ne 0 ] ; then
    echo "file: $file not passing json parsing"
  fi
done
/bin/echo "done"

/bin/echo -n  "Cleaning out old preseed:s ..."
for preseed in "${serverdir}/isolinux/preseed-"*".cfg" ; do
  echo "preseed: ${preseed}"
  rm -rf "${preseed}"
done
/bin/echo "done"

/bin/echo -n "Creating the workstation preseed..."
python3 ./lib/template-to-preseed.py --packages "${configdir}/workstation-packages.json" \
  --template "lib/workstation.template"  > "${wrkstndir}/isolinux/preseed-workstation.cfg"
cp lib/isolinux.cfg "${wrkstndir}/isolinux/"
/bin/echo  "done."

/bin/echo -n "Creating boot menu:s..."
./bin/create-isolinux-menu.sh "${wrkstndir}/isolinux"
./bin/create-uefi-menu.sh -i "${wrkstndir}/isolinux" -u "${wrkstndir}/boot/grub"
/bin/echo  "done."


/bin/echo -n "Creating the iso..."
isooutput="${outputdir}/custom-debian-iso-${isoname}-11.0.0-amd64.iso"
./bin/create-iso.sh -i "${isoname}" -s "${wrkstndir}"  -o "${isooutput}" >> "${logfile}" 2>&1
/bin/echo  "done."

echo "Iso: ${isoname} is at:"
echo "${output}"
echo "${isoname}" > name-of-last-built-iso.txt

echo "Logfile: ${logfile}"
