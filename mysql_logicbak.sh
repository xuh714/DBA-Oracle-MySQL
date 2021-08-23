#!/bin/bash
. $HOME/.bash_profile >/dev/null 2>&1
cd /tmp
log=tmp${$}.txt
cat /etc/passwd | cut -f 1 -d : |egrep "root|mysql"|xargs -I {} sudo crontab -l -u {} 2>/dev/null|sed '/^#.*\|^$/d' > $log
shopt -s expand_aliases
alias keywordLmatchCMD=$(echo 'echo "$line"|awk -v RS="@#$j" '"'"'{print gsub(/'"'"'"$KEYWORD"'"'"'/,"&")}'"'")
alias keywordTmatchCMD=$(echo 'awk -v RS="@#$j" '"'"'{print gsub(/'"'"'"$KEYWORD"'"'"'/,"&")}'"'"' "$script"')
if [ ! -s $log ];then
stdopt=1
else
arrkeyword[0]="mysqldump"
arrkeyword[1]="mysqlpump"
arrkeyword[2]="mydumper"
Nlines=`cat $log|wc -l`
i=0
while read line
do
for keyword in ${arrkeyword[@]}
do
if [ "$keyword" == "mysqldump" ];then
KEYWORD="mysqldump"
MDmatchNum=`keywordLmatchCMD`
elif [ "$keyword" == "mysqlpump" ];then
KEYWORD="mysqlpump"
MPmatchNum=`keywordLmatchCMD`
elif [ "$keyword" == "mydumper" ];then
KEYWORD="mydumper"
MDPmatchNum=`keywordLmatchCMD`
fi
done
if [ $MDmatchNum -ne 0 ] || [ $MPmatchNum -ne 0 ] || [ $MDPmatchNum -ne 0 ];then
stdopt=0
break
else
let i++
if [[ $Nlines -eq $i ]];then
stdopt=1
break
fi
fi
done < $log
if [ "$stdopt" == "unmatched" ];then
arrshell[0]="sh"
arrshell[1]="bash"
arrshell[2]="/bin/sh"
arrshell[3]="/bin/bash"
arrshell[4]="/usr/bin/sh"
arrshell[5]="/usr/bin/bash"
while read line
do
shell=`echo "$line"|awk '{print $6}'`
j=0
for arr in ${arrshell[@]}
do
if [ "$arr" == "$shell" ];then
let j++
fi
done
if [ $j -eq 1 ];then
script=`echo "$line"|awk '{print $7}'`
test -e "$script"
if [ $? -eq 0 ];then
scriptNum=$(file "$script"|egrep -w "text executable|text"|wc -l)
if [ $scriptNum -eq 1 ];then
for keyword in ${arrkeyword[@]}
do
if [ "$keyword" == "mysqldump" ];then
KEYWORD="mysqldump"
MDmatchNum=`keywordTmatchCMD`
elif [ "$keyword" == "mysqlpump" ];then
KEYWORD="mysqlpump"
MPmatchNum=`keywordTmatchCMD`
elif [ "$keyword" == "mydumper" ];then
KEYWORD="mydumper"
MDPmatchNum=`keywordTmatchCMD`
fi
done
if [ $MDmatchNum -ne 0 ] || [ $MPmatchNum -ne 0 ] || [ $MDPmatchNum -ne 0 ];then
stdopt=0
break
fi
fi
fi
else
script=`echo "$line"|awk '{print $6}'`
test -e "$script"
if [ $? -eq 0 ];then
scriptNum=$(file "$script"|egrep -w "text executable|text"|wc -l)
if [ $scriptNum -eq 1 ];then
for keyword in ${arrkeyword[@]}
do
if [ "$keyword" == "mysqldump" ];then
KEYWORD="mysqldump"
MDmatchNum=`keywordTmatchCMD`
elif [ "$keyword" == "mysqlpump" ];then
KEYWORD="mysqlpump"
MPmatchNum=`keywordTmatchCMD`
elif [ "$keyword" == "mydumper" ];then
KEYWORD="mydumper"
MDPmatchNum=`keywordTmatchCMD`
fi
done
if [ $MDmatchNum -ne 0 ] || [ $MPmatchNum -ne 0 ] || [ $MDPmatchNum -ne 0 ];then
stdopt=0
break
fi
fi
fi
fi
done < $log
fi
fi
echo $stdopt
test -e $log && rm -f $log
