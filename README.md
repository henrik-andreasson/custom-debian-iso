# debian server dvd/usb

Create custom debian ISO with custom repo's and preseed's for automatic server install.

1. Input is standard debian iso, it is copied to a directory that is the base for the iso
   This command will mount the iso located at `/opt/custom-debian-iso/iso/debian-13.0.0-amd64-DVD-1.iso` at `/opt/custom-debian-iso/mount/debian-13.0.0/`  then copy all files with rsync to `/opt/custom-debian-iso/server/acert-iso-2025.8-debian-13.0.0/` where the iso creation tools will use the files in later stages.

`Please note: This next command needs to be run as root, due to the need to mount the iso`

```bash
./bin/base-iso.sh  -i /opt/custom-debian-iso/iso/debian-13.0.0-amd64-DVD-1.iso \
                    -m /opt/custom-debian-iso/mount/debian-13.0.0/ \
                    -d /opt/custom-debian-iso/server/acert-iso-2025.8-debian-13.0.0/
```

2. Remove some unused packages (office)

    Say we create server iso and we need to keep the size small, we can then remove some packages that are not needed for a server.
    A list of packages to get started is bundled at `.\bin\clean-not-used-packages.sh`
    To use it run:

```bash
.\bin\clean-not-used-pkgs.sh /opt/custom-debian-iso/server/acert-iso-2025.8-debian-13.0.0/
```

3. repository management

  * add repos via custom-deian-repo or other repo management
  * available repos should be configured in the json file as displayed below

```
{
  "postinstall": "current",
  "srv-debian-pkgs": "2021-09-28",
  "adoptopenjdk8": "adoptopenjdk-8-hotspot-u292"
}
```

4. server config management

   * get info from inventory (or create your own json) server/network
   * activate selected repos
   * what packages to install


5. post install

   * run any number of customization
   * ansible users

6. create iso

7. install in cicd, hw or vm

han@knack:/opt/custom-debian-iso$ find  /opt/custom-debian-iso/server/acert-iso-2025.8-debian-13.0.0/  -type d  -exec chmod 755 {} \;
han@knack:/opt/custom-debian-iso$ find  /opt/custom-debian-iso/server/acert-iso-2025.8-debian-13.0.0/  -type f  -exec chmod u+w {} \;


## Running workstation image creation

```
./bin/make-wrk-iso.sh
Creating the postintall deb...done.
Updating the repos on the iso...done.
Creating the workstation preseed...done.
Creating the iso...done.
Iso: wrkstn-2022-07-14_12.39.32 is at:
custom-debian-iso-wrkstn-2022-07-14_12.39.32.iso
Logfile: /tmp/logfile-nIQLqap
```

```
./bin/make-srv-iso.sh rootca
Creating the postintall deb...done.
Updating common repos on the iso...done.
Adding servers...added server: rootca.at.crtsrv.se
Updating the iso with server repos...done.
Creating the iso...done.
Iso: rootca is in output: custom-debian-iso-rootca.iso
```
