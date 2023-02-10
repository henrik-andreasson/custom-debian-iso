#!/bin/bash

rm -rf /home/cs/.local/share/gnome-shell/extensions/gnomesome@chwick.github.com
rm -rf /etc/skel/.local/share/gnome-shell/extensions/gnomesome@chwick.github.com
mkdir -p /home/cs/.local/share/gnome-shell/extensions/gnomesome@chwick.github.com
mkdir -p /etc/skel/.local/share/gnome-shell/extensions/
cd /opt/
unzip /opt/post-install/gnomesome.zip
ln -s /opt/gnomesome-master /etc/skel/.local/share/gnome-shell/extensions/gnomesome@chwick.github.com
ln -s /opt/gnomesome-master /home/cs/.local/share/gnome-shell/extensions/gnomesome@chwick.github.com
