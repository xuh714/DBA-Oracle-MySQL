#!/bin/bash
. $HOME/.bash_profile >/dev/null 2>&1
host=$1
port=10050
mysql_host=127.0.0.1
mysql_user=zabbix
mysql_passwd=Abcd321#
mysql_port=3306
mysql_conn="$mysql_host,$mysql_user,$mysql_passwd,$mysql_port"
replica_host=s2
replica_user=repl
replica_passwd=Abcd321#
replica_port=3306
replica_conn="$replica_host,$replica_user,$replica_passwd,$replica_port"
repl_type=MS
repl_metric=status
backup_type=logicbak
shopt -s expand_aliases
alias debugCMD=$(echo 'zabbix_get -s '$host' -p '$port' -k "$key" 2>/dev/null')
arrkey[0]="mysql.status[$mysql_conn]"
arrkey[1]="mysql.datadirsize[$mysql_conn]"
arrkey[2]="mysql.transactions[$mysql_conn]"
arrkey[3]="mysql.lsn[$mysql_conn]"
arrkey[4]="mysql.binlogsize[$mysql_conn]"
arrkey[5]="mysql.innodb.rowlocks[$mysql_conn]"
arrkey[6]="mysql.repl.arch[$mysql_conn,$replica_conn,$repl_type]"
arrkey[7]="mysql.replication[$replica_conn,$repl_metric]"
arrkey[8]="mysql.backup.crontabs[$backup_type]"
for key in ${arrkey[@]}
do
stdopt=`debugCMD`
if [ $? -ne 0 ];then
result="failed"
else
echo $stdopt|grep -w "ZBX_NOTSUPPORTED" >/dev/null 2>&1
if [ $? -eq 0 ];then
result="failed"
else
result="passed"
fi
fi
echo "{'key': '$key', 'value': '$stdopt', 'result': '$result'}"
done
