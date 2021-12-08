#!/bin/bash

PACKAGES="ansible ansible-doc"

for pkg in ${PACKAGES} ; do
  echo "downloading $pkg"
  apt-get download "$pkg"
  depends=$(apt-rdepends "$pkg" | grep -v "^ ")
#  depends=$(apt-cache depends --recurse --no-recommends --no-suggests \
#    --no-conflicts --no-breaks --no-replaces --no-enhances \
#    --no-pre-depends "${pkg}"​​​​​​​ | grep "^\w" | )

  for dep in $depends ; do
    echo "Downloading dependencies for $pkg: $dep"
    apt-get download "${dep}"
  done
done

#from pkg: dpkg-dev
dpkg-scanpackages -m . | gzip -c > Packages.gz

