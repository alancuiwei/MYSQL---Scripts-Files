#!/bin/sh

cd /ZRSoftware/ZRApp/
echo 'cd /ZRSoftware/ZRApp/'
if [ 2 -eq $# ] ;then
  ./run_ZR_PROGRAM_Optimization.sh  /usr/local/MATLAB/MATLAB_Compiler_Runtime/v716/ "'$1'" "'$2'";
elif [ 3 -eq $# ] ;then
  ./run_ZR_PROGRAM_Optimization.sh  /usr/local/MATLAB/MATLAB_Compiler_Runtime/v716/ "'$1'" "'$2'" "'$3'";
fi

#echo "'$1'"
#echo "$#"
#if [$# != 4]; then 
#  ./run_ZR_PROGRAM_BuiltTestResult.sh /usr/local/MATLAB/MATLAB_Compiler_Runtime/v716/ "'$1'" "'$2'";
#else
#  ./run_ZR_PROGRAM_BuiltTestResult.sh /usr/local/MATLAB/MATLAB_Compiler_Runtime/v716/ "'$1'" "'$2'" "'$3'" "'$4'";
#fi
echo "$*"
echo "$#"
echo 'end'

