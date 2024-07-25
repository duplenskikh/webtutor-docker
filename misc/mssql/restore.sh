#!/bin/bash

timeout=3

while true;
do
  echo "Sleep for $timeout seconds before executing test connection"
  sleep $timeout

  echo "Test connection to database"
  /opt/mssql-tools/bin/sqlcmd -S host.docker.internal -U sa -P ${MSSQL_SA_PASSWORD} -Q "SELECT 1"

  if [ $? -eq 0 ]; then
    echo "Connection established"
    break
  fi
done;

if [ -e "/tmp/backup/db.bak" ]; then
  echo "Start database restoring"
  /opt/mssql-tools/bin/sqlcmd -S host.docker.internal -U $MSSQL_USERNAME -P $MSSQL_SA_PASSWORD -Q 'RESTORE FILELISTONLY FROM DISK = "/var/opt/mssql/backup/db.bak"' | tr -s ' ' | cut -d ' ' -f 1-2 || exit 1
  /opt/mssql-tools/bin/sqlcmd -S host.docker.internal -U $MSSQL_USERNAME -P $MSSQL_SA_PASSWORD -Q 'RESTORE DATABASE WTDB FROM DISK = "/var/opt/mssql/backup/db.bak" WITH MOVE "WTDB" TO "/var/opt/mssql/data/WTDB.mdf", MOVE "BLOBS" TO "/var/opt/mssql/data/WTDB_blobs.mdf", MOVE "FT_IDX" TO "/var/opt/mssql/data/WTDB_ft_idx.mdf", MOVE "IDX" TO "/var/opt/mssql/data/WTDB_idx.mdf", MOVE "LOG" TO "/var/opt/mssql/data/T1_WTDB.ldf"' || exit 1
else
  echo "Start database creating"
  /opt/mssql-tools/bin/sqlcmd -S host.docker.internal -U $MSSQL_USERNAME -P $MSSQL_SA_PASSWORD -i "/tmp/create_db.sql" || exit 1
fi


exit 0