#!/bin/bash
. $HOME/.bash_profile >/dev/null 2>&1
DEBUG_FLG='DeBuG'
test $# = 0 || my_debug_flg=`echo $*| awk '{print $NF}'`
if [[ "$my_debug_flg" = "$DEBUG_FLG" ]]; then
export PS4='+{$LINENO:${FUNCNAME[0]}} '
set -x
echo args=$@
fi
cd /tmp
log=tmp${$}.txt
KEY_ARGS_ERR="ZBX_NOTSUPPORTED: There is a problem of args for the key"
connCMD1="-h$1 -u$2 -p$3 -P$4"
connCMD2="-h$5 -u$6 -p$7 -P$8"
connopt=`mysql $connCMD1 -e"select 1;" 2>/dev/null|awk 'NR>1'`
if [ ! -n "$connopt" ];then
echo "$KEY_ARGS_ERR"
exit 1
fi
connopt=`mysql $connCMD2 -e"select 1;" 2>/dev/null|awk 'NR>1'`
if [ ! -n "$connopt" ];then
echo "$KEY_ARGS_ERR"
exit 1
fi
shopt -s expand_aliases
alias mastertagCMD=$(echo 'mysql $connCMD -e"select Command from information_schema.processlist where Command in ('"'"Binlog Dump"'"','"'"Binlog Dump GTID"'"','"'"Connect"'"') order by Command ASC;" 2>/dev/null|awk '"'"NR\>1"'"'|uniq
|awk '"'"'{for(i=1;i<=NF;i++)printf $i " ";printf "\n"}'"'"'|sed -e '"'"'s/[ ]*$//g'"'"'|awk '"'"'BEGIN{ORS=","}{print $0}'"'")
alias masteruuidsCMD=$(echo 'mysql $connCMD -e"show slave hosts;" 2>/dev/null|awk '"'"NR\>1"'"'|awk '"'"'{print $NF}'"'"' > $log')
alias masteruuidCMD=$(echo 'mysql $connCMD -e"show global variables where variable_name='"'"server_uuid"'"';" 2>/dev/null|awk '"'"NR\>1"'"'|awk '"'"'{print $NF}'"'")
alias masterseridsCMD=$(echo 'mysql $connCMD -e"show slave hosts;" 2>/dev/null|awk '"'"NR\>1"'"'|awk '"'"'{print $1}'"'"' > $log')
alias masterseridCMD=$(echo 'mysql $connCMD -e"show global variables where variable_name='"'"server_id"'"';" 2>/dev/null|awk '"'"NR\>1"'"'|awk '"'"'{print $NF}'"'")
mysqlVer1=`mysql $connCMD1 -e"select substring_index(substring_index(version(),'-',1),'.',2);" 2>/dev/null|awk '{print $1}'|awk 'NR>1'`
mysqlVer2=`mysql $connCMD2 -e"select substring_index(substring_index(version(),'-',1),'.',2);" 2>/dev/null|awk '{print $1}'|awk 'NR>1'`
if [ `echo "$mysqlVer1 == 5.5"|bc` -eq 1 ] || [ `echo "$mysqlVer2 == 5.5"|bc` -eq 1 ];then
connCMD=$connCMD1
mastertag=`mastertagCMD`
OLD_IFS="$IFS"
IFS=","
array=($mastertag)
IFS="$OLD_IFS"
if [ -n "$mastertag" ] && [ "${array[0]}" == "Binlog Dump" ] || [ "${array[0]}" == "Binlog Dump GTID" ] && [ "${array[1]}" == "Connect" ];then
masterseridsCMD
arrmaster1=($(awk '{print $NF}' $log))
master1serid=`masterseridCMD`
connCMD=$connCMD2
mastertag=`mastertagCMD`
OLD_IFS="$IFS"
IFS=","
array=($mastertag)
IFS="$OLD_IFS"
if [ -n "$mastertag" ] && [ "${array[0]}" == "Binlog Dump" ] || [ "${array[0]}" == "Binlog Dump GTID" ] && [ "${array[1]}" == "Connect" ];then
masterseridsCMD
arrmaster2=($(awk '{print $NF}' $log))
master2serid=`masterseridCMD`
i=0
for arr in ${arrmaster1[@]}
do
if [ "$arr" == "$master2serid" ];then
let i++
fi
done
j=0
for arr in ${arrmaster2[@]}
do
if [ "$arr" == "$master1serid" ];then
let j++
fi
done
if [ $i -eq 1 ] && [ $j -eq 1 ];then
stdopt=0
else
stdopt=1
fi
else
stdopt=1
fi
else
stdopt=1
fi
else
connCMD=$connCMD1
mastertag=`mastertagCMD`
OLD_IFS="$IFS"
IFS=","
array=($mastertag)
IFS="$OLD_IFS"
if [ -n "$mastertag" ] && [ "${array[0]}" == "Binlog Dump" ] || [ "${array[0]}" == "Binlog Dump GTID" ] && [ "${array[1]}" == "Connect" ];then
masteruuidsCMD
arrmaster1=($(awk '{print $NF}' $log))
master1uuid=`masteruuidCMD`
connCMD=$connCMD2
mastertag=`mastertagCMD`
OLD_IFS="$IFS"
IFS=","
array=($mastertag)
IFS="$OLD_IFS"
if [ -n "$mastertag" ] && [ "${array[0]}" == "Binlog Dump" ] || [ "${array[0]}" == "Binlog Dump GTID" ] && [ "${array[1]}" == "Connect" ];then
masteruuidsCMD
arrmaster2=($(awk '{print $NF}' $log))
master2uuid=`masteruuidCMD`
i=0
for arr in ${arrmaster1[@]}
do
if [ "$arr" == "$master2uuid" ];then
let i++
fi
done
j=0
for arr in ${arrmaster2[@]}
do
if [ "$arr" == "$master1uuid" ];then
let j++
fi
done
if [ $i -eq 1 ] && [ $j -eq 1 ];then
stdopt=0
else
stdopt=1
fi
else
stdopt=1
fi
else
stdopt=1
fi
fi
echo $stdopt
test -e $log && rm -f $log

7. 创建MySQL复制度量指标检测脚本
shell> vi mysql_replication.sh
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
