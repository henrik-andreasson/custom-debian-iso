# debian server dvd/usb

Create custom debian ISO with custom repo's and preseed's for automatic server install.

1. Input is standard debian iso

2. Remove some unused packages (office)

3. repository management

   * adoptopenjdk8
   * adoptopenjdk11
   * adoptopenjdk16
   * ca_backend
   * debian_pkgs
   * luna6
   * tilix
   * atom
   * cs_apps
   * logsign-archive
   * luna7
   * pritunl
   * srv-debian-pkgs
   * vault

4. server config management

   * get info from inventory (or create your own json) server/network
   * activate selected repos
   * what packages to install

5. post install

   * run any number of customization
   * ansible users

6. create iso

7. install in cicd, hw or vm


## Running workstation image creation

```
./bin/make-wrk-iso.sh
Creating the postintall deb...done.
Updating the repos on the iso...done.
Creating the workstation preseed...done.
Creating the iso...done.
Iso: wrkstn-2022-07-14_12.39.32 is at:
custom-debian-iso-wrkstn-2022-07-14_12.39.32-11.0.0-amd64.iso
Logfile: /tmp/logfile-nIQLqap
```

```
./bin/make-srv-iso.sh rootca
Creating the postintall deb...done.
Updating common repos on the iso...done.
Adding servers...added server: rootca.at.crtsrv.se
Updating the iso with server repos...done.
Creating the iso...done.
Iso: rootca is in output: custom-debian-iso-rootca-11.0.0-amd64.iso
```
