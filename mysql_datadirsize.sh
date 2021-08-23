#!/bin/bash
. $HOME/.bash_profile >/dev/null 2>&1
KEY_ARGS_ERR="ZBX_NOTSUPPORTED: There is a problem of args for the key"
connCMD="-h$1 -u$2 -p$3 -P$4"
connopt=`mysql $connCMD -e"select 1;" 2>/dev/null|awk 'NR>1'`
if [ ! -n "$connopt" ];then
echo "$KEY_ARGS_ERR"
exit 1
fi
datadir=`mysql $connCMD -e"show global variables where variable_name='datadir'\G;" 2>/dev/null|tail -1|awk '{print $NF}'`
if [ -d $datadir ];then
stdopt=`df -h $datadir|tail -1|awk '{print $(NF-1)}'`
fi
echo $stdopt
