#!/bin/sh

pid1=`pgrep CollectMarke`
cd /ZRSoftware/ZRApp

echo "start the CollectMarketData!"
if [ $pid1 ];then
  echo "kill the CollectMarketData!"
  kill $pid1
  sleep 10s
fi
./CollectMarketData &
