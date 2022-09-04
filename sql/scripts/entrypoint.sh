#!bin/sh

#Set the defaultbackupdir (needs to be done here after the volume from docker-compose has been mapped)
#run db-init.sh script
#run sqlservr service so docker container does not stop
if [ -z ${TCP_PORT+x} ]; then eset TCP_PORT=1433; fi

/opt/mssql/bin/mssql-conf set filelocation.defaultbackupdir $BACKUP_PATH &
/opt/mssql/bin/mssql-conf set network.tcpport $TCP_PORT &
sh ./db-init.sh &
/opt/mssql/bin/sqlservr