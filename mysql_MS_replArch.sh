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
connopt=`mysql $connCMD1 -e"select 1;" 2>/dev/null |awk 'NR>1'`
if [ ! -n "$connopt" ];then
echo "$KEY_ARGS_ERR"
exit 1
fi
connopt=`mysql $connCMD2 -e"select 1;" 2>/dev/null |awk 'NR>1'`
if [ ! -n "$connopt" ];then
echo "$KEY_ARGS_ERR"
exit 1
fi
shopt -s expand_aliases
alias mastertagCMD=$(echo 'mysql $connCMD -e"select Command from information_schema.processlist where Command in ('"'"Binlog Dump"'"','"'"Binlog Dump GTID"'"');" 2>/dev/null|awk '"'"NR\>1"'"'|uniq|awk '"'"'{for(i=1;i<=NF;i++)printf $i " ";printf "\n"}'"'"'|sed -e '"'"'s/[ ]*$//g'"'")
alias slavetagCMD=$(echo 'mysql $connCMD -e"select Command from information_schema.processlist where Command='"'"Connect"'"';" 2>/dev/null|awk '"'"NR\>1"'"'|awk '"'"'{print $NF}'"'"'|uniq')
alias slaveuuidsCMD=$(echo 'mysql $connCMD -e"show slave hosts;" 2>/dev/null|awk '"'"NR\>1"'"'|awk '"'"'{print $NF}'"'"' > $log')
alias slaveuuidCMD=$(echo 'mysql $connCMD -e"show global variables where variable_name='"'"server_uuid"'"';" 2>/dev/null|awk '"'"NR\>1"'"'|awk '"'"'{print $NF}'"'")
alias slaveseridsCMD=$(echo 'mysql $connCMD -e"show slave hosts;" 2>/dev/null|awk '"'"NR\>1"'"'|awk '"'"'{print $1}'"'"' > $log')
alias slaveseridCMD=$(echo 'mysql $connCMD -e"show global variables where variable_name='"'"server_id"'"';" 2>/dev/null|awk '"'"NR\>1"'"'|awk '"'"'{print $NF}'"'")
mysqlVer1=`mysql $connCMD1 -e"select substring_index(substring_index(version(),'-',1),'.',2);" 2>/dev/null|awk '{print $1}'|awk 'NR>1'`
mysqlVer2=`mysql $connCMD2 -e"select substring_index(substring_index(version(),'-',1),'.',2);" 2>/dev/null|awk '{print $1}'|awk 'NR>1'`
if [ `echo "$mysqlVer1 == 5.5"|bc` -eq 1 ] || [ `echo "$mysqlVer2 == 5.5"|bc` -eq 1 ];then
connCMD=$connCMD1
mastertag=`mastertagCMD`
if [ "$mastertag" == "Binlog Dump" ] || [ "$mastertag" == "Binlog Dump GTID" ];then
slaveseridsCMD
connCMD=$connCMD2
slavetag=`slavetagCMD`
if [ "$slavetag" == "Connect" ];then
slaveserid=`slaveseridCMD`
while read line
do
if [ "$line" == "$slaveserid" ];then
stdopt=0
break
fi
done < $log
if [ ! -n "$stdopt" ];then
stdopt=1
fi
else
stdopt=1
fi
elif [ ! -n "$mastertag" ];then
slavetag=`slavetagCMD`
if [ "$slavetag" == "Connect" ];then
slaveserid=`slaveseridCMD`
connCMD=$connCMD2
mastertag=`mastertagCMD`
if [ "$mastertag" == "Binlog Dump" ] || [ "$mastertag" == "Binlog Dump GTID" ];then
slaveseridsCMD
while read line
do
if [ "$line" == "$slaveserid" ];then
stdopt=0
break
fi
done < $log
if [ ! -n "$stdopt" ];then
stdopt=1
fi
else
stdopt=1
fi
else
stdopt=1
fi
else
stdopt=""
fi
else
connCMD=$connCMD1
mastertag=`mastertagCMD`
if [ "$mastertag" == "Binlog Dump" ] || [ "$mastertag" == "Binlog Dump GTID" ];then
slaveuuidsCMD
connCMD=$connCMD2
slavetag=`slavetagCMD`
if [ "$slavetag" == "Connect" ];then
slaveuuid=`slaveuuidCMD`
while read line
do
if [ "$line" == "$slaveuuid" ];then
stdopt=0
break
fi
done < $log
if [ ! -n "$stdopt" ];then
stdopt=1
fi
else
stdopt=1
fi
elif [ ! -n "$mastertag" ];then
slavetag=`slavetagCMD`
if [ "$slavetag" == "Connect" ];then
slaveuuid=`slaveuuidCMD`
connCMD=$connCMD2
mastertag=`mastertagCMD`
if [ "$mastertag" == "Binlog Dump" ] || [ "$mastertag" == "Binlog Dump GTID" ];then
slaveuuidsCMD
while read line
do
if [ "$line" == "$slaveuuid" ];then
stdopt=0
break
fi
done < $log
if [ ! -n "$stdopt" ];then
stdopt=1
fi
else
stdopt=1
fi
else
stdopt=1
fi
else
stdopt=""
fi
fi
echo $stdopt
test -e $log && rm -f $log
