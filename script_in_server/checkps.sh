#!/bin/sh
#exit
pid1=`pgrep CollectMarke`
pid2=`pgrep STG010001`
cd /ZRSoftware/ZRApp

if [ $pid1 ];then
   if [ $pid2 ];then
	  echo "keep the all process!"
   else
      date >> checkps.log
      kill $pid1
      sleep 1s
      ./CollectMarketData &
      sleep 10s 
      echo "kill&start Coll and start the STG010001test!" >> checkps.log 
      sleep 1s
      ./STG010001test > /dev/null 2>&1 & 
      echo "started the STG010001test!" >> checkps.log
   fi
else
   date >> checkps.log
   echo "start the CollectMarketData!" >> checkps.log
   ./CollectMarketData &
   sleep 10s
   if [ $pid2 ];then
      echo "kill the STG010001test!" >> checkps.log
      kill $pid2
      sleep 1s
   fi
   echo "start the STG010001test!" >> checkps.log
   ./STG010001test &
fi
