#!/bin/bash
set -e

NAME="debian-fat-postinstall"
VERSION="2021.12.05"
DIRECTORIES="--directories /opt/post-install"
VENDOR="Henrik Andreasson"
MAINTAINER="Henrik Andreasson <github@han.pp.se>"
DESCRIPTION="Debian fat postinstall package"
EXTRARPMS=""
DEPENDS=""

while getopts o:v:s: flag; do
  case $flag in
    v)
	VERSION="$OPTARG";
      ;;
    o)
	OUTDIR=$OPTARG;
      ;;
    ?)
      exit;
      ;;
  esac
done

rm -rf tmp
mkdir -p tmp/opt/post-install
cp -ra debian-pkg-post-install/* tmp/opt/post-install/

fpm -s dir -t deb -n ${NAME} -v ${VERSION} ${DEPENDS}  --vendor "${VENDOR}" --maintainer "${MAINTAINER}" --description "${DESCRIPTION}" ${DIRECTORIES} --force -C tmp .

rm -rf tmp
