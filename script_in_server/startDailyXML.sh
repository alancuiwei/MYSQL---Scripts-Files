#!/bin/sh

pid1=`pgrep DailyXMLs`
cd /ZRSoftware/ZRApp

echo "start the DailyXML!"
if [ $pid1 ];then
  echo "kill the DailyXML!"
  kill $pid1
  sleep 10s
fi
./DailyXML &
