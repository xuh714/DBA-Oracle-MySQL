#!/bin/bash
. $HOME/.bash_profile >/dev/null 2>&1
KEY_ARGS_ERR="ZBX_NOTSUPPORTED: There is a problem of args for the key"
connCMD="-h$1 -u$2 -p$3 -P$4"
connopt=`mysql $connCMD -e"select 1;" 2>/dev/null|awk 'NR>1'`
if [ ! -n "$connopt" ];then
echo "$5: $KEY_ARGS_ERR"
exit 1
fi
if [ "$5" == "status" ];then
threads=`mysql $connCMD -e"show slave status\G;" 2>/dev/null|egrep -w "Slave_IO_Running:|Slave_SQL_Running:"|awk '{print $NF}'|awk 'BEGIN{ORS=","}{print $0}'`
if [ -n "$threads" ];then
OLD_IFS="$IFS"
IFS=","
array=($threads)
IFS="$OLD_IFS"
i=0
for arr in ${array[@]}
do
if [ "$arr" != "Yes" ];then
let i++
fi
done
if [ $i -eq 0 ];then
echo "$5: 0" 
else
echo "$5: 1"
fi
else
echo "$5: 1"
fi
elif [ "$5" == "delay" ];then
delay=`mysql $connCMD -e"show slave status\G;" 2>/dev/null|egrep -w "Seconds_Behind_Master:"|awk '{print $NF}'`
if [ -n "$delay" ] && [ "$delay" != "NULL" ];then
echo "$5: $delay"
fi
else
echo "$5: $KEY_ARGS_ERR"
fi
