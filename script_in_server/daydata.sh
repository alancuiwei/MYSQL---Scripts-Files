#!/bin/sh

cd /ZRSoftware/Tools/
echo 'cd /ZRSoftware/Tools/'
/usr/local/rvm/bin/ruby  /ZRSoftware/Tools/daydata.rb

cd /ZRSoftware/tongtianshun/app/assets/historydatadownload/
rm ./*.zip

cd /ZRSoftware/Tools/daydata/a/
zip -q -m ./a.zip ./*
mv a.zip /ZRSoftware/tongtianshun/app/assets/historydatadownload/

cd /ZRSoftware/Tools/daydata/ag/
zip -q -m ./ag.zip ./*
mv ag.zip /ZRSoftware/tongtianshun/app/assets/historydatadownload/

cd /ZRSoftware/Tools/daydata/al/
zip -q -m ./al.zip ./*
mv al.zip /ZRSoftware/tongtianshun/app/assets/historydatadownload/

cd /ZRSoftware/Tools/daydata/au/
zip -q -m ./au.zip ./*
mv au.zip /ZRSoftware/tongtianshun/app/assets/historydatadownload/

cd /ZRSoftware/Tools/daydata/b/
zip -q -m ./b.zip ./*
mv b.zip /ZRSoftware/tongtianshun/app/assets/historydatadownload/

cd /ZRSoftware/Tools/daydata/c/
zip -q -m ./c.zip ./*
mv c.zip /ZRSoftware/tongtianshun/app/assets/historydatadownload/

cd /ZRSoftware/Tools/daydata/CF/
zip -q -m ./CF.zip ./*
mv CF.zip /ZRSoftware/tongtianshun/app/assets/historydatadownload/

cd /ZRSoftware/Tools/daydata/cu/
zip -q -m ./cu.zip ./*
mv cu.zip /ZRSoftware/tongtianshun/app/assets/historydatadownload/

cd /ZRSoftware/Tools/daydata/ER/
zip -q -m ./ER.zip ./*
mv ER.zip /ZRSoftware/tongtianshun/app/assets/historydatadownload/

cd /ZRSoftware/Tools/daydata/fu/
zip -q -m ./fu.zip ./*
mv fu.zip /ZRSoftware/tongtianshun/app/assets/historydatadownload/

cd /ZRSoftware/Tools/daydata/IF/
zip -q -m ./IF.zip ./*
mv IF.zip /ZRSoftware/tongtianshun/app/assets/historydatadownload/

cd /ZRSoftware/Tools/daydata/j/
zip -q -m ./j.zip ./*
mv j.zip /ZRSoftware/tongtianshun/app/assets/historydatadownload/

cd /ZRSoftware/Tools/daydata/l/
zip -q -m ./l.zip ./*
mv l.zip /ZRSoftware/tongtianshun/app/assets/historydatadownload/

cd /ZRSoftware/Tools/daydata/m/
zip -q -m ./m.zip ./*
mv m.zip /ZRSoftware/tongtianshun/app/assets/historydatadownload/

cd /ZRSoftware/Tools/daydata/ME/
zip -q -m ./ME.zip ./*
mv ME.zip /ZRSoftware/tongtianshun/app/assets/historydatadownload/

cd /ZRSoftware/Tools/daydata/OI/
zip -q -m ./OI.zip ./*
mv OI.zip /ZRSoftware/tongtianshun/app/assets/historydatadownload/

cd /ZRSoftware/Tools/daydata/p/
zip -q -m ./p.zip ./*
mv p.zip /ZRSoftware/tongtianshun/app/assets/historydatadownload/

cd /ZRSoftware/Tools/daydata/pb/
zip -q -m ./pb.zip ./*
mv pb.zip /ZRSoftware/tongtianshun/app/assets/historydatadownload/

cd /ZRSoftware/Tools/daydata/PM/
zip -q -m ./PM.zip ./*
mv PM.zip /ZRSoftware/tongtianshun/app/assets/historydatadownload/

cd /ZRSoftware/Tools/daydata/rb/
zip -q -m ./rb.zip ./*
mv rb.zip /ZRSoftware/tongtianshun/app/assets/historydatadownload/

cd /ZRSoftware/Tools/daydata/RI/
zip -q -m ./RI.zip ./*
mv RI.zip /ZRSoftware/tongtianshun/app/assets/historydatadownload/

cd /ZRSoftware/Tools/daydata/RO/
zip -q -m ./RO.zip ./*
mv RO.zip /ZRSoftware/tongtianshun/app/assets/historydatadownload/

cd /ZRSoftware/Tools/daydata/ru/
zip -q -m ./ru.zip ./*
mv ru.zip /ZRSoftware/tongtianshun/app/assets/historydatadownload/

cd /ZRSoftware/Tools/daydata/SR/
zip -q -m ./SR.zip ./*
mv SR.zip /ZRSoftware/tongtianshun/app/assets/historydatadownload/

cd /ZRSoftware/Tools/daydata/TA/
zip -q -m ./TA.zip ./*
mv TA.zip /ZRSoftware/tongtianshun/app/assets/historydatadownload/

cd /ZRSoftware/Tools/daydata/v/
zip -q -m ./v.zip ./*
mv v.zip /ZRSoftware/tongtianshun/app/assets/historydatadownload/

cd /ZRSoftware/Tools/daydata/WH/
zip -q -m ./WH.zip ./*
mv WH.zip /ZRSoftware/tongtianshun/app/assets/historydatadownload/

cd /ZRSoftware/Tools/daydata/wr/
zip -q -m ./wr.zip ./*
mv wr.zip /ZRSoftware/tongtianshun/app/assets/historydatadownload/

cd /ZRSoftware/Tools/daydata/WS/
zip -q -m ./WS.zip ./*
mv WS.zip /ZRSoftware/tongtianshun/app/assets/historydatadownload/

cd /ZRSoftware/Tools/daydata/WT/
zip -q -m ./WT.zip ./*
mv WT.zip /ZRSoftware/tongtianshun/app/assets/historydatadownload/

cd /ZRSoftware/Tools/daydata/y/
zip -q -m ./y.zip ./*
mv y.zip /ZRSoftware/tongtianshun/app/assets/historydatadownload/

cd /ZRSoftware/Tools/daydata/zn/
zip -q -m ./zn.zip ./*
mv zn.zip /ZRSoftware/tongtianshun/app/assets/historydatadownload/

echo 'end'