# This repo has moved to https://github.com/wekan/wekan-autoinstall

# wekan
Wekan auto-installation script

Tested on Ubuntu Server 14.04.4 LTS but it should work on any Debian based distribution.

This scripts automates the installation process for **[Wekan v0.10.1](https://github.com/wekan/wekan/releases/tag/v0.10.1)**

It automatically downloads and installs the following packages:

* make, gcc, g++, build-essential, libssl-dev (needed for wekan compilation)
* mongodb-server (NoSQL database)
* nvm (installs NodeJS v0.10.40)
* forever (runs NodeJS applications at the background forever)
* wekan v0.10.1

## Pre-Configuration
Before you start the installation, you can edit the script to change some parameters, such as:

* *NODE_VERSION* (default is v0.10.40 which is required for running Wekan v0.10.1. I suggest **NOT CHANGING IT** since it could break the service)
* *MONGO_URL* (default is mongodb://127.0.0.1:27017/wekan)
* *ROOT_URL* (default is http://127.0.0.1)
* *PORT* (defaults is set to **8080**)
* *MAIL_URL* (the format is 'smtp://user:pass@mailserver.examples.com:25/')
* *PIDFILE* (default is /var/run/Wekan.pid)
* *LOGFILE* (default is /var/run/Wekan.log)


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

## Access your installation

After the service is started you can access your fresh wekan installation by pointing your browser to:

```
http://<your-ip>:8080
```

The default port is set to **8080** in case you have another web server running at port 80.

## Post-Configuration

In case want to reconfigure the service to run at a different port after the you run the script, you must edit the service file using your favorite file editor, for ex.

```sh
$ nano /etc/init.d/wekan
```

Change any parameters you want, save and exit. After that you must update the autostart service script. To do so run as root:

```sh
$ update-rc.d -f wekan remove && update-rc.d wekan defaults
```

For the changes to take effect you should **restart the service**. I recommend **rebooting your system**, since the previous service could be still running.

## Wekan Virtual Appliance

I have prepared a ready to run, Ubuntu based (Ubuntu 14.04.4 Server - amd64) Virtual Machine with [Wekan](https://github.com/wekan/wekan) preinstalled. All you need is a VirtualBox installation. You can download the appliance directly from https://selalmaz.xyz/t/wekanmv-0-10-1 (~689MB) or from the releases page at https://github.com/anselal/wekan/releases

* username: wekan
* password: wekan
