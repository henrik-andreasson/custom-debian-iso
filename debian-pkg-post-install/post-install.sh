#!/bin/bash

for file in /opt/post-install/scripts.d/*sh ; do

  $file

done
