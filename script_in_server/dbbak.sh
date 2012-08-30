#!/bin/sh
#change into the backup_agent directory where data files are stored.
cd /ZRSoftware/Tools/
/usr/bin/mysqldump --opt --user=root --password=123456 futuretest > /ZRSoftware/Tools/futuretest.sql
bzip2 -9 futuretest.sql
mv futuretest.sql.bz2 /ZRSoftware/DBbak/

/usr/bin/mysqldump --opt --user=root --password=123456 webfuturetest_101 > /ZRSoftware/Tools/webfuturetest.sql
bzip2 -9 webfuturetest.sql
mv webfuturetest.sql.bz2 /ZRSoftware/DBbak/

cp -r /ZRSoftware/tongtianshun/app/assets/xmls/ /ZRSoftware/DBbak/
cd /ZRSoftware/DBbak/
zip -r ./db-xml-$(date +%Y%m%d-%H%M%S).zip ./xmls futuretest.sql.bz2 webfuturetest.sql.bz2

rm /ZRSoftware/DBbak/xmls/* futuretest.sql.bz2 webfuturetest.sql.bz2
rmdir /ZRSoftware/DBbak/xmls

find . -ctime +10 -exec rm -fv {} \;
