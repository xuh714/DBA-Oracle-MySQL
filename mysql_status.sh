#!/bin/bash
. $HOME/.bash_profile >/dev/null 2>&1
KEY_ARGS_ERR="ZBX_NOTSUPPORTED: There is a problem of args for the key"
connCMD="-h$1 -u$2 -p$3 -P$4"
connopt=`mysql $connCMD -e"select 1;" 2>/dev/null|awk 'NR>1'`
if [ ! -n "$connopt" ];then
echo "$KEY_ARGS_ERR"
exit 1
fi
WaitTime=1
WaitCount=3
j=1
while true
do
mysqld_status=`mysqladmin $connCMD ping 2>/dev/null`
mysql_status=`mysql $connCMD -e"select 1;" 2>/dev/null|awk 'NR>1'`
if [ "$mysqld_status" == "mysqld is alive" ] && [ $mysql_status -eq 1 ];then
echo 0
exit 0
else
if [ $j -le $WaitCount ];then
let j++
sleep $WaitTime
else
echo 1
break
fi
fi
done
