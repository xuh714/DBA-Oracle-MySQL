#!/bin/bash
. $HOME/.bash_profile >/dev/null 2>&1
host=$1
port=10050
interface=ens18
device=dev252-0
shopt -s expand_aliases
alias debugCMD=$(echo 'zabbix_get -s '$host' -p '$port' -k "$key" 2>/dev/null')
arrkey[0]="system.cpu.runq"
arrkey[1]="system.mem.swapped"
arrkey[2]="net.if.traffic.in[$interface]"
arrkey[3]="net.if.traffic.out[$interface]"
arrkey[4]="vfs.dev.io.throughput[$device]"
arrkey[5]="vfs.dev.io.responsetime[$device]"
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
