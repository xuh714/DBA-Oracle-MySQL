#!/bin/bash
. $HOME/.bash_profile >/dev/null 2>&1
srpdir=/etc/zabbix/scripts
KEY_ARGS_ERR="ZBX_NOTSUPPORTED: There is a problem of args for the key"
if [ "$9" == "MS" ];then
$srpdir/mysql_MS_replArch.sh $1 $2 $3 $4 $5 $6 $7 $8 2>/dev/null
elif [ "$9" == "MM" ];then
$srpdir/mysql_MM_replArch.sh $1 $2 $3 $4 $5 $6 $7 $8 2>/dev/null
else
echo "$KEY_ARGS_ERR"
fi
