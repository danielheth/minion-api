#!/bin/bash

#First determine if we are upgrading an existing Minion
if [ -d /opt/minion ]; then
UPDATE=true
else
UPDATE=false
fi


#Now we need to do one of two processes, install new minion or upgrade an existing one
if [ "$UPDATE" != true ]; then
	echo "Installing Fresh Minion Installation"

	echo "* Installing Python"
	apt-get install python -y

	echo "* Installing Perl"
	apt-get install perl -y

	echo "* Installing Mosquitto-Clients"
	apt-key add conf/mosquitto-repo.gpg.key
	rm conf/mosquitto-repo-gpg.key
	mv conf/mosquitto-stable.list /etc/apt/sources.list.d/
	apt-get update
	apt-get install mosquitto-clients -y

	echo "* Creating minion User Group"
	groupadd minion
	
	rm -rf /opt/minion

	echo "* Creating Minion Directory"
	mkdir /opt/minion
	mkdir /opt/minion/log
	mkdir /opt/minion/cache

else
	echo "Updating Existing Minion Installation"

	if [ ! -f /etc/apt/sources.list.d/mosquitto-stable.list ]; then
		echo "* Installing Mosquitto-Clients"
		apt-key add conf/mosquitto-repo.gpg.key
		rm conf/mosquitto-repo-gpg.key
		mv conf/mosquitto-stable.list /etc/apt/sources.list.d/
		apt-get update
		apt-get install mosquitto-clients -y
	else
		rm -f conf/mosquitto-repo-gpg.key
		rm -f conf/mosquitto-stable.list
	fi

fi

cp -f README.md /opt/minion/
touch /opt/minion/log/minion.log

echo "* Updating Message of the Day"
cp -f motd /etc/

echo "* Removing Old speedtest-cli Utility"
if [ -d /etc/speedtest ]; then
	rm -rf /etc/speedtest
	if [ -f /usr/local/bin/speedtest-cli ]; then
		rm -rf /usr/local/bin/speedtest-cli
	fi
fi

echo "* Copying Bin Utilities and Scripts"
rm -rf /opt/minion/bin
cp -rf bin/ /opt/minion/

echo "* Copying Configurations"
rm -rf /opt/minion/conf
cp -rf conf/ /opt/minion/

echo "* Configuring Cron"
cp -f cron/hourly /etc/cron.hourly/minion
chmod +x /etc/cron.hourly/minion
cp -f cron/daily /etc/cron.daily/minion
chmod +x /etc/cron.daily/minion
cp -f cron/weekly /etc/cron.weekly/minion
chmod +x /etc/cron.weekly/minion
cp -f cron/monthly /etc/cron.monthly/minion
chmod +x /etc/cron.monthly/minion


echo "* Fixing Permissions"
chgrp -R minion /opt/minion
chmod -R 775 /opt/minion



echo "* Starting Cron"
service cron restart

# Kickoff Registration Script
#/opt/minion/bin/register

echo "Enjoy your Minion!"