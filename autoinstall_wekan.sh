#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo ""
   echo "This script must be run as root" 1>&2
   echo ""
   exit 1
fi

which aptitude > /dev/null
# Use aptitude if it exists
if [ $? -eq "0" ]; then
	aptitude update && aptitude install -y mongodb-server make g++ gcc build-essential libssl-dev
# else us apt-get
elif [ $? -ne "0" ]; then
	apt-get update && apt-get install -y mongodb-server make g++ gcc build-essential libssl-dev
fi

# wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.30.0/install.sh | bash

# Check if curl exists
which curl > /dev/null
# If curl does not exist, install it
if [ $? -ne "0" ]; then
    echo "curl does not exist. I will install it for you..."
    apt-get install curl
fi

#curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.30.0/install.sh | bash
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.30.2/install.sh | bash

source ~/.nvm/nvm.sh
source ~/.profile
source ~/.bashrc

# Make node, npm, available to all users
# n=$(which node);n=${n%/bin/node}; chmod -R 755 $n/bin; sudo cp -r $n/{bin,lib,share} /usr/local

NODE_VERSION="v0.10.40"

nvm install $NODE_VERSION
nvm use $NODE_VERSION
nvm alias default $NODE_VERSION

npm install -g npm
npm install forever -g

cd
wget https://github.com/wekan/wekan/releases/download/v0.10.1/wekan-0.10.1.tar.gz
rm -rf ~/bundle
tar xzvf wekan-0.10.1.tar.gz

cd bundle/programs/server && npm install

echo ""
echo "Installing wekan service..."
echo -ne '#####                     (33%)\r'
sleep 1
echo -ne '#############             (66%)\r'
sleep 1
echo -ne '#######################   (100%)\r'
echo -ne '\n'

# Cat text, but keep $ uninterpreted
cat > /etc/init.d/wekan <<'_EOF'
#!/bin/bash
#/etc/init.d/wekan

### BEGIN INIT INFO
# Provides:          wekan
# Required-Start:    $all
# Required-Stop:     $all
# Should-Start:      $mongodb
# Should-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start daemon at boot time
# Description:       Enable service provided by daemon.
### END INIT INFO

_EOF

# Cat text, but interpret $
cat >> /etc/init.d/wekan <<_EOF
export NODE_PATH=/root/.nvm/$NODE_VERSION/bin
_EOF

# Cat text, but keep $ uninterpreted
cat >> /etc/init.d/wekan <<'_EOF'
export PATH=$PATH:$NODE_PATH:/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin
export MONGO_URL="mongodb://127.0.0.1:27017/wekan"
export ROOT_URL="http://127.0.0.1"
export PORT="8080"
export MAIL_URL='smtp://user:pass@mailserver.examples.com:25/'

NAME="Wekan"
APPLICATION_DIRECTORY=/root/bundle
APPLICATION_START=main.js
PIDFILE=/var/run/$NAME.pid
LOGFILE=/var/run/$NAME.log
FOREVER=$(which forever)

f_proc="$NODE_PATH/forever list | grep Wekan | cut -d'[' -f2 | cut -d']' -f1"

start() {
	if [ -f $PIDFILE -o `bash -c "$f_proc" | wc -l` -gt 0 ]; then
		echo "$NAME is already running"
	else
		echo "Starting $NAME"
		$NODE_PATH/forever --pidFile $PIDFILE --sourceDir=$APPLICATION_DIRECTORY -a -l $LOGFILE --minUptime 5000 --spinSleepTime 2000 start $APPLICATION_START &
	fi
	RETVAL=$?

}

stop() {
	if [ -f $PIDFILE ]; then
		echo "Shutting down $NAME"
		cat $PIDFILE | xargs $NODE_PATH/forever stop
	elif [ ! -f $PIDFILE ]; then
		# Check if a wekan process is still running through forever
		if [[ `bash -c "$f_proc" | wc -l` -gt 0 ]]; then
			echo "Shutting down $NAME"
			$NODE_PATH/forever stopall
		else
			echo "$NAME is not running"
		fi
	fi
	RETVAL=$?
}

restart() {
	echo "Restarting $NAME"
	stop
	start
}

status() {
	echo "Status for $NAME"
	$NODE_PATH/forever list
	RETVAL=$?
}


case "$1" in
  start)
	start
	;;
  stop)
	stop
	;;
  status)
	status
	;;
  restart)
	restart
	;;
  *)
	echo "Usage: /etc/init.d/wekan {start|stop|status|restart}"
	exit 1
	;;
esac

exit $RETVAL
_EOF

chmod +x /etc/init.d/wekan
update-rc.d -f wekan remove
update-rc.d wekan defaults

echo ""
echo "Installing custom scripts..."

# First step
cp /etc/issue /etc/issue-standard
echo -ne '#####                     (33%)\r'
sleep 1
# Second step
cat > /usr/local/bin/get-ip-address <<'_EOF'
#!/bin/bash
/sbin/ifconfig | grep "inet addr" | grep -v "127.0.0.1" | awk '{ print $2 }' | awk -F: '{ print $2 }'

_EOF
chmod +x /usr/local/bin/get-ip-address
echo -ne '#############             (66%)\r'
sleep 1
# Third step
cat > /etc/network/if-up.d/show-ip-address <<'_EOF'
#!/bin/bash
if [ "$METHOD" = loopback ]; then
    exit
fi

# Only run from ifup
if [ "$MODE" != start ]; then
    exit 0
fi

cp /etc/issue-standard /etc/issue
#IP="`ip route get 8.8.8.8 | awk '{ $NF; exit; }'`"
IP="IP ADDRESS: `/usr/local/bin/get-ip-address` (default port 8080)"
echo -e "\e[33m$IP \e[39m " >> /etc/issue
echo "" >> /etc/issue

_EOF
chmod +x /etc/network/if-up.d/show-ip-address
echo -ne '#######################   (100%)\r'
sleep 1
echo -ne '\n'


echo ""
echo "Installation completed."
menu() {
echo ""
echo "You can run the service manually or you can reboot your system."
echo "Please select one of the following:"
echo "1) Start the wekan service"
echo "2) Reboot your system"
echo "3) Exit"
echo -n "Choice: "
read choice

case "$choice" in
1)
exec /etc/init.d/wekan start
;;
2)
echo "Rebooting the system..."
sleep 3
exec reboot
;;
3)
echo "Exiting."
sleep 1
exit 0
;;
*)
menu
;;
esac
}
menu