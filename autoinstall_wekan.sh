#!/bin/bash

apt-get update && apt-get install -y mongodb-server make g++ gcc build-essential libssl-dev

wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.29.0/install.sh | bash
# if wget fails, use curl
# curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.29.0/install.sh | bash

source ~/.nvm/nvm.sh
source ~/.profile
source ~/.bashrc

# Make node, npm, available to all users
# n=$(which node);n=${n%/bin/node}; chmod -R 755 $n/bin; sudo cp -r $n/{bin,lib,share} /usr/local

NODE_VERSION="v0.10.40"

nvm install $NODE_VERSION
nvm use $NODE_VERSION
nvm alias default $NODE_VERSION

npm install forever -g

wget https://github.com/wekan/wekan/releases/download/v0.9/wekan-v0.9.0.tar.gz
rm -rf ~/bundle
tar xzvf wekan-v0.9.0.tar.gz

cd bundle/programs/server && npm install

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

NAME="Wekan"
APPLICATION_DIRECTORY=/root/bundle
APPLICATION_START=main.js
PIDFILE=/var/run/$NAME.pid
LOGFILE=/var/run/$NAME.log
FOREVER=$(which forever)

start() {
	echo "Starting $NAME"
	$NODE_PATH/forever --pidFile $PIDFILE --sourceDir=$APPLICATION_DIRECTORY -a -l $LOGFILE --minUptime 5000 --spinSleepTime 2000 start $APPLICATION_START &
	RETVAL=$?

}

stop() {
	if [ -f $PIDFILE ]; then
		echo "Shutting down $NAME"
		rm -f $PIDFILE
		RETVAL=$?
	else
		echo "$NAME is not running."
		RETVAL=0
	fi
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