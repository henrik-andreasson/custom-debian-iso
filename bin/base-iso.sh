#!/bin/bash

while getopts i:m:d: flag; do
  case $flag in
    i) isoname="$OPTARG";
      ;;
    m) mount=$OPTARG;
      ;;
    d) dest=$OPTARG;
        ;;
    ?)
      exit;
      ;;
  esac
done


if [ "x$isoname" = "x" ] ; then
  isoname="/opt/custom-debian-iso/iso/firmware-11.5.0-amd64-DVD-1.iso"
fi

if [ "x$mount" = "x" ] ; then
  mount="/opt/custom-debian-iso/mount/firmware-11.5.0-amd64-DVD-1/"
fi

if [ "x$dest" = "x" ] ; then
  dest="/opt/custom-debian-iso/server/cs-baseiso-2022-debian-11.5.0/"
fi

if [[ ! -f "${isoname}" ]] ; then
  echo "iso: ${isoname} not found"
  exit -1
fi

mkdir -p "${mount}"

if [[ ! -d "${mount}" ]] ; then
  echo "failed to create mount dir ${mount}"
  exit -2
fi

umount "${mount}"
mount "${isoname}" "${mount}"

if [[ ! -d "${mount}/debian" ]] ; then
  echo "failed to mount debian DVD"
  exit -3
fi

rsync --recursive --progress --archive "${mount}" "${dest}"
if [[ $? -ne 0 ]] ; then
  echo "failed to run rsync from the cd to the dest directory"
  exit -4
else
  echo "rsync done"
fi
