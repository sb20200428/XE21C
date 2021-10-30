
#!/bin/sh
# This script assumes that user can connect using "/ as sysdba" 

export ORACLE_HOME=/opt/oracle/product/18c/dbhomeXE
#or if you're running 21c
# export ORACLE_HOME=/opt/oracle/product/21c/dbhomeXE
export ORACLE_SID=XE
export PATH=$ORACLE_HOME/bin:$PATH

TMPDIR=/tmp

rman_backup_current=<<path_to_recovery>>/oxe_backup_current.log
rman_backup_prev=<<path_to_recovery>>/oxe_backup_previous.log

rman_backup=${TMPDIR}/rman_backup$$.log
echo XE Backup Log > $rman_backup

rman target / >> $rman_backup << EOF
  set echo on;
  #You can keep more backups by changing redundancy factor to a higher number
  configure retention policy to redundancy 2;
  configure controlfile autobackup format for device type disk clear;
  configure controlfile autobackup on;
  backup as backupset device type disk database;
  configure controlfile autobackup off;
  delete noprompt obsolete;
  sql 'alter system archive log current';
EOF

if [ -f $rman_backup_current ]; then
  mv -f $rman_backup_current $rman_backup_prev
fi;

mv -f $rman_backup $rman_backup_current
