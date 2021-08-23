#!/bin/bash
. $HOME/.bash_profile >/dev/null 2>&1
zabbixURL=http://repo.zabbix.com
aliyunURL=https://mirrors.aliyun.com/zabbix
zabbixREPO=/etc/yum.repos.d/zabbix.repo
zabbixCONF=/etc/zabbix/zabbix_agent2.conf
zabbixSERVER=192.168.51.46
localhost=`hostname`
shopt -s expand_aliases
alias cdate='date +"%Y%m%d%H%M%S"'
alias repoCMD=$(echo 'sed -i '"'"'s#'$zabbixURL'#'$aliyunURL'#'"'"' '$zabbixREPO)
alias agent2CMD1=$(echo 'sed -i '"'"'s/Server=127.0.0.1/Server='$zabbixSERVER'/g'"'"' '$zabbixCONF)
alias agent2CMD2=$(echo 'sed -i '"'"'s/ServerActive=127.0.0.1/ServerActive='$zabbixSERVER'/g'"'"' '$zabbixCONF)
alias agent2CMD3=$(echo 'sed -i '"'"'s/Hostname=Zabbix server/Hostname='$localhost'/g'"'"' '$zabbixCONF)
alias agent2CMD4=$(echo 'sed -i '"'"'s/# UnsafeUserParameters=0/UnsafeUserParameters=1/g'"'"' '$zabbixCONF)
rpm -qa|grep zabbix-agent2 >/dev/null 2>&1
stdopt1=$?
rpm -qa|grep zabbix-release >/dev/null 2>&1
stdopt2=$?
if [ $stdopt1 -ne 0 ];then
if [ $stdopt2 -eq 0 ];then
yum remove -y zabbix-release >/dev/null 2>&1
fi
rpm -Uvh $aliyunURL/zabbix/5.0/rhel/7/x86_64/zabbix-release-5.0-1.el7.noarch.rpm >/dev/null 2>&1
cp $zabbixREPO $zabbixREPO.$(cdate)
repoCMD
yum install -y zabbix-agent2 >/dev/null 2>&1
fi
if [ -e $zabbixCONF ];then
cp $zabbixCONF $zabbixCONF.$(cdate)
agent2CMD1 && agent2CMD2 && agent2CMD3 && agent2CMD4
systemctl enable zabbix-agent2 >/dev/null 2>&1
systemctl restart zabbix-agent2
else
exit 1
fi
test -e $0 && rm -f $0
