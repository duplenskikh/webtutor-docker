#!/bin/bash

# Start SQL Server
/opt/mssql/bin/sqlservr &

# Start the script to create the DB and user
/usr/config/configure-db.sh

# Call extra command
tail -F /var/opt/mssql/log/create_db_log.log
