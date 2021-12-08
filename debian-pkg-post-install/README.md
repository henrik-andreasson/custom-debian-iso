# extra post-install package

of your ideas of stuff that need to happen after the install is bigger than a script
put them here

all files will be installed under /opt/post-install

all scripts inside scripts.d will be started 

in the preseed put this line in to start it all:


		d-i preseed/late_command string in-target /opt/post-install/post-install.sh

