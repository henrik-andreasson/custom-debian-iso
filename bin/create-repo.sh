#!/bin/bash

if [ "x$1" != "x" ] ; then
  if [ -d "$1" ] ; then
    cd $1
  fi
fi

#from pkg: dpkg-dev
dpkg-scanpackages -m . | gzip -c > Packages.gz
