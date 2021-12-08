#!/bin/bash

#from pkg: dpkg-dev
dpkg-scanpackages -m . | gzip -c > Packages.gz
