#!/bin/bash
. $HOME/.bash_profile >/dev/null 2>&1
srpdir=/etc/zabbix/scripts
KEY_ARGS_ERR="ZBX_NOTSUPPORTED: There is a problem of args for the key"
if [ "$1" == "logicbak" ];then
$srpdir/mysql_logicbak.sh 2>/dev/null
elif [ "$1" == "physicbak" ];then
$srpdir/mysql_physicbak.sh 2>/dev/null
else
echo "$KEY_ARGS_ERR"
fi
