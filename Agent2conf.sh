#!/bin/bash
. $HOME/.bash_profile >/dev/null 2>&1
host=192.168.239.51
user=root
passwd=hzmcdba
keyscriptdir=/etc/zabbix/scripts
keyconfdir=/etc/zabbix/zabbix_agent2.d
shopt -s expand_aliases
alias cdate='date +"%Y%m%d%H%M%S"'
arrkeyscript[0]="mysql_status.sh"
arrkeyscript[1]="mysql_datadirsize.sh"
arrkeyscript[2]="mysql_transactions.sh"
arrkeyscript[3]="mysql_lsn.sh"
arrkeyscript[4]="mysql_binlogsize.sh"
arrkeyscript[5]="mysql_innodb_rowlocks.sh"
arrkeyscript[6]="mysql_replArch.sh"
arrkeyscript[7]="mysql_MS_replArch.sh"
arrkeyscript[8]="mysql_MM_replArch.sh"
arrkeyscript[9]="mysql_replication.sh"
arrkeyscript[10]="mysql_backup_crontabs.sh"
arrkeyscript[11]="mysql_logicbak.sh"
arrkeyscript[12]="mysql_physicbak.sh"
arrkeyconf[0]="UserDefinedOSkeys.conf"
arrkeyconf[1]="UserDefinedDBkeys.conf"
if [ ! -d $keyscriptdir ];then
mkdir -p $keyscriptdir
elif [ ! -d $keyconfdir ];then
mkdir -p $keyconfdir
fi
for keyscript in ${arrkeyscript[@]}
do
if [ -e $keyscriptdir/$keyscript ];then
mv $keyscriptdir/$keyscript $keyscriptdir/$keyscript.$(cdate)
fi
sshpass -p $passwd scp $user@$host:$keyscriptdir/$keyscript $keyscriptdir
done
for keyconf in ${arrkeyconf[@]}
do
if [ -e $keyconfdir/$keyconf ];then
mv $keyconfdir/$keyconf $keyconfdir/$keyconf.$(cdate)
fi
sshpass -p $passwd scp $user@$host:$keyconfdir/$keyconf $keyconfdir
done
systemctl restart zabbix-agent2 >/dev/null 2>&1
test -e $0 && rm -f $0
