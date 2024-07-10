#!/bin/bash

/opt/mssql-tools/bin/sqlcmd -S host.docker.internal -U SA -P 'yourStrong(!)Password' -Q 'RESTORE FILELISTONLY FROM DISK = "/var/opt/mssql/backup/WTDB-2024710-19-58-23.bak"' | tr -s ' ' | cut -d ' ' -f 1-2
/opt/mssql-tools/bin/sqlcmd -S host.docker.internal -U SA -P 'yourStrong(!)Password' -Q 'RESTORE DATABASE WTDB FROM DISK = "/var/opt/mssql/backup/WTDB-2024710-19-58-23.bak" WITH MOVE "WTDB" TO "/var/opt/mssql/data/WTDB.mdf", MOVE "BLOBS" TO "/var/opt/mssql/data/WTDB_blobs.mdf", MOVE "FT_IDX" TO "/var/opt/mssql/data/WTDB_ft_idx.mdf", MOVE "IDX" TO "/var/opt/mssql/data/WTDB_idx.mdf", MOVE "LOG" TO "/var/opt/mssql/data/T1_WTDB.ldf"'
