#!/bin/bash
. $HOME/.bash_profile >/dev/null 2>&1
KEY_ARGS_ERR="ZBX_NOTSUPPORTED: There is a problem of args for the key"
connCMD="-h$1 -u$2 -p$3 -P$4"
connopt=`mysql $connCMD -e"select 1;" 2>/dev/null|awk 'NR>1'`
if [ ! -n "$connopt" ];then
echo "$KEY_ARGS_ERR"
exit 1
fi
mysqlVer=`mysql $connCMD -e"select substring_index(substring_index(version(),'-',1),'.',2);" 2>/dev/null|awk 'NR>1'`
if [[ `echo "$mysqlVer >= 5.7"|bc` -eq 1 ]];then
stdopt=`mysql $connCMD -e"SELECT 
  COUNT(DISTINCT b.trx_mysql_thread_id) hold_threads 
FROM
  sys.innodb_lock_waits w 
  INNER JOIN information_schema.INNODB_TRX b 
    ON b.trx_id = w.blocking_trx_id 
  INNER JOIN information_schema.INNODB_TRX r 
    ON r.trx_id = w.waiting_trx_id 
  INNER JOIN information_schema.PROCESSLIST p 
    ON p.id = b.trx_mysql_thread_id 
  INNER JOIN information_schema.PROCESSLIST p2 
    ON p2.id = r.trx_mysql_thread_id 
    AND p.time > 5\G;" 2>/dev/null|tail -1|awk '{print $NF}'`
else
stdopt=`mysql $connCMD -e"SELECT 
  COUNT(DISTINCT b.trx_mysql_thread_id) hold_threads 
FROM
  information_schema.INNODB_LOCK_WAITS w 
  INNER JOIN information_schema.INNODB_TRX b 
    ON b.trx_id = w.blocking_trx_id 
  INNER JOIN information_schema.INNODB_TRX r 
    ON r.trx_id = w.requesting_trx_id 
  INNER JOIN information_schema.PROCESSLIST p 
    ON p.id = b.trx_mysql_thread_id 
  INNER JOIN information_schema.PROCESSLIST p2 
    ON p2.id = r.trx_mysql_thread_id 
    AND p.time > 5\G;" 2>/dev/null|tail -1|awk '{print $NF}'`
fi
echo $stdopt
