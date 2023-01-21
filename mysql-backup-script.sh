#!/bin/sh
# MySQL backup script
# Copyright (c) 2023 Hasssanitman
# This script is licensed under GNU GPL version 2.0 or above
# ---------------------------------------------------------------------

### System Setup ###
BACKUP=/root/backup/database  # Or put your backup directory
DATE=$(date +"%d-%b-%Y")

### MySQL Setup ###
MUSER="db-username" # Put your MySQL username here
MPASS="db-password" # Put your MySQL password here
MHOST="ftp-address" # Put your MySQL address here, for example localhost

### FTP server Setup ###
FTPD="ftp-directory" # Put your FTP directory here
FTPU="ftp-user"      # Put your FTP username here
FTPP="ftp-password"  # Put your FTP password here
FTPS="ftp-address"   # Put your FTP address here

### Binaries ###
TAR="$(which tar)"
GZIP="$(which gzip)"
FTP="$(which ftp)"
MYSQL="$(which mysql)"
MYSQLDUMP="$(which mysqldump)"

### Today + hour ###
NOW=$(date +"%d%H")

### Create hourly dir ###
mkdir $BACKUP/$NOW

### Get all databases name ###
DBS="$($MYSQL -u $MUSER -h $MHOST -p$MPASS -Bse 'show databases')"
for db in $DBS
do

### Create dir for each databases, backup database in individual files ###
mkdir $BACKUP/$NOW/$db
$MYSQLDUMP --user=$MUSER --password=$MPASS --host=$MHOST $db > $BACKUP/$NOW/$db/$db-$DATE.sql

done

### Compress all databases in one file to upload ###
ARCHIVE=$BACKUP/$NOW.tar.gz
ARCHIVED=$BACKUP/$NOW

$TAR -czvf $ARCHIVE $ARCHIVED

### Dump backup using FTP ###
cd $BACKUP
DUMPFILE=$NOW.tar.gz
$FTP -ivndp $FTPS <<END_SCRIPT
quote USER $FTPU
quote PASS $FTPP

mkdir $FTPD/$DATE
cd $FTPD/$DATE
mkdir database
cd database
binary
mput $DUMPFILE
quit
END_SCRIPT


### Delete the backup dir and keep archive ###
rm -rf $ARCHIVED