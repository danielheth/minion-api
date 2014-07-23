#!/bin/bash

echo "Testing internet speed..."

/opt/minion/bin/speedtest-cli > /opt/minion/log/speedtest.lastrun.log

TIMESTAMP=`date +"%s"`
DATETIME=`date +"%Y-%m-%d %H:%M:%S"`
PUBLICIP=`cat /opt/minion/log/speedtest.lastrun.log | grep 'Testing from' | awk -F'(' '{print $2}' | awk -F ')' '{print $1}'`
RESULTS=`cat /opt/minion/log/speedtest.lastrun.log | grep 'Mbits/s' | awk -F':' '{print $2}' | awk -F' ' '{print $1;}' | awk 'NR%2{printf $0"|";next;}1'`
DOWNLOAD=`echo $RESULTS | awk -F'|' '{print $1}'`
UPLOAD=`echo $RESULTS | awk -F'|' '{print $2}'`

echo "$PUBLICIP" > /opt/minion/log/publicip.log
echo "$DOWNLOAD|$UPLOAD|$DATETIME" >> /opt/minion/log/speedtest.log  

echo "Done"
