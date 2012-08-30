#!/bin/sh

cd /ZRSoftware/ZRApp/
echo 'cd /ZRSoftware/ZRApp/'
./run_ZR_PROGRAM_WriteToMatFromDB.sh /usr/local/MATLAB/MATLAB_Compiler_Runtime/v716/ 'a' 'RO' 'p' 'l' 'v' 'y' 'TA'
cp *.mat ./Data/
echo 'end'
