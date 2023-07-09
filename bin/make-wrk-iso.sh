#!/bin/bash

date_ts=$(date +"%Y-%m-%d_%H.%M.%S")
curdir=$(pwd)
logfile=$(mktemp -p "${curdir}/logs" "logfile-${date_ts}-XXXXXXX.log")
isoname=""
wrkstndir=""
configdir=""

while getopts n:w:c:o:r: flag; do
  case $flag in
    n) isoname="$OPTARG";
      ;;
    w) wrkstndir=$OPTARG;
      ;;
    c) configdir=$OPTARG;
      ;;
    o) outputdir=$OPTARG;
      ;;
    r) repodir=$OPTARG;
      ;;

    ?)
      exit;
      ;;
  esac
done

# env var takes presedence over command line argumants
if [[ "x${ISONAME}" != "x" ]]; then
  echo "using isoname from env var ${ISONAME}"
  isoname="${ISONAME}"

elif [[ "x$isoname" != "x" ]] ; then
  echo "using isoname from cli arg  ${isoname}"

else
  isoname="snapshot-${date_ts}"
  echo "using isoname: ${isoname} (no cli or env was supplied)"


fi

# env var takes presedence over command line argumants
if [[ "x${WRKSTNDIR}" != "x" ]]; then
  echo "using wrkstndir from env var ${WRKSTNDIR}"
  wrkstndir="${WRKSTNDIR}"

elif [[ "x$wrkstndir" != "x" ]] ; then
  echo "using wrkstndir from cli arg ${wrkstndir}"

else
  wrkstndir="wrkstn"
  echo "using wrkstndir default ${wrkstndir} no cli arg nor env supplied"

fi


if [[ "x${CONFIGDIR}" != "x" ]] ; then
  configdir="${CONFIGDIR}"
  echo "using configdir fron end ${configdir}"

elif [[ "x$configdir" != "x" ]] ; then
  echo "using configdir fron cli ${configdir}"

else
  configdir="configs"
  echo "using configdir default ${configdir} no cli arg nor env supplied"

fi

if [[ "x$OUTDIR" != "x" ]] ; then
  outputdir="${OUTDIR}"
  echo "using outputdir from env ${outputdir}"

elif [[ "x$outputdir" != "x" ]] ; then
  echo "using outputdir from cli arg ${outputdir}"

else
  outputdir="."
  echo "using outputdir default ${outputdir}"

fi

if [[ "x$REPODIR" != "x" ]] ; then
  repodir="${REPODIR}"
  echo "using repodir from env ${repodir}"

elif [[ "x$repodir" != "x" ]] ; then
  echo "using outputdir from cli arg ${repodir}"

else
  repodir="repos"
  echo "using repodir default ${repodir}"

fi

output="custom-debian-iso-${isoname}-11.0.0-amd64.iso"

/bin/echo -n "Removing old repos from the iso..."
for repo in "${wrkstndir}/repo-"* ; do
  echo "repo: $repo"
  rm -rf $repo
done
/bin/echo  "done."

/bin/echo -n "Creating the postintall deb..."
./bin/make-deb-postinstall.sh  > "${logfile}" 2>&1
mkdir -p "${repodir}/wrkstnpostinstall/current"
cp debian-fat-postinstall*_amd64.deb "${repodir}/wrkstnpostinstall/current/"
(
  cd "${repodir}/wrkstnpostinstall/current/"
  ../../../bin/create-repo.sh > "${logfile}"
)
/bin/echo  "done."

/bin/echo -n "Updating the repos on the iso..."
./bin/copy-repos.sh -j "configs/postinst-repo.json" -s "${wrkstndir}" -r "${repodir}" >> "${logfile}"
./bin/copy-repos.sh -j "${configdir}/repos.json"    -s "${wrkstndir}" -r "${repodir}" >> "${logfile}"
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
echo "${isooutput}"
echo "${isoname}" > name-of-last-built-iso.txt

echo "Logfile: ${logfile}"
