# wekan
Wekan auto-installation script

Tested on Ubuntu Server 14.04.3 LTS but it schould work on all Debian based distributions

This script automates the installation process for Wekan v0.90

It automatically downloads and installs the following packages:

* make, gcc, g++, build-essential, libssl-dev (needed for wekan compilation)
* mongodb-server (NoSQL database)*
* nvm (installs NodeJS v0.10.40)
* forever (runs NodeJS applications at the background forever)
* wekan v0.90

## Installation

Run as root:

```sh
$ chmod +x autoinstall_wekan.sh
$ ./autoinstall_wekan.sh
```

As a plus, the script configures Wekan as a service which autostarts at boot.

After the installation is complete, you have the option to start the service or to reboot the system.

## Service

You can manually start the service as root by typing:

```sh
$ /etc/init.d/wekan start
```
