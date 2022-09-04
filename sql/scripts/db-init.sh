#!bin/sh

echo "#######    STARTED CONFIGURATION   #######"

SLEEP_TIME=$INIT_WAIT

#run the setup script to create the DB and the schema in the DB
#if this is the primary node, remove the certificate files.
#if docker containers are stopped, but volumes are not removed, this certificate will be persisted
echo "<#############>    IS_AOAG_PRIMARY: ${IS_AOAG_PRIMARY}"
if [ $IS_AOAG_PRIMARY = "true" ]
then
    SQL_SCRIPT="aoag_primary.sql"
    #rm /var/opt/mssql/shared/aoag_certificate.key 2> /dev/null
    #rm /var/opt/mssql/shared/aoag_certificate.cert 2> /dev/null
    rm $SHARED_PATH/aoag_certificate.key 2> /dev/null
    rm $SHARED_PATH/aoag_certificate.cert 2> /dev/null

else
    SQL_SCRIPT="aoag_secondary.sql"
fi

BAK_FILE="AdventureWorksLT2019.bak"

echo "<#############>    SQLSCRIPT: ${SQL_SCRIPT}"

echo "<#############>    Moving Backup File ${BAK_FILE} to ${BACKUP_PATH}"
mv  $BAK_FILE $BACKUP_PATH

#wait for the SQL Server to come up
echo "<#############>    Sleeping for ${SLEEP_TIME} seconds ..."
sleep ${SLEEP_TIME}

#use the SA password from the environment variable
echo "<#############>    running set up script ${SQL_SCRIPT}"
/opt/mssql-tools/bin/sqlcmd \
    -S localhost,$TCP_PORT \
    -U sa \
    -P $SA_PASSWORD \
    -d master \
    -i $SQL_SCRIPT

# create failove sql agent job
echo "<#############>    running sql agent failover job"
/opt/mssql-tools/bin/sqlcmd \
    -S localhost,$TCP_PORT \
    -U sa \
    -P $SA_PASSWORD \
    -d master \
    -i "aoag_failover_job.sql"



echo "#######     COMPLETED CONFIGURATION    #######"