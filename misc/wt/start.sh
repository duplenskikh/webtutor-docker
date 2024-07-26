#!/bin/bash

# if [ -f .env ]; then
#   . .env
# fi

# log_file=/tmp/xhttp_stdout.log

# ./xhttp.out > $log_file 2>&1 &

# xhttp_pid=$!

# echo "xhttp.out has started with pid $xhttp_pid"

# wait_for_output() {
#     local expected_output=$1
#     echo "The main process awaits of input $expected_output"

#     tail -f "$log_file" | while IFS= read -r line
#     do
#         echo "$line"
#         if [[ "$line" == *"$expected_output"* ]]; then
#             echo "Target line found: $line"
#             # Kill the tail process
#             pkill -P $$ tail
#             break
#         fi
#     done
# }

# configure_db() {
#     echo "Database configuration has started"

#     echo "db set type mssql" > /proc/$xhttp_pid/fd/0
#     wait_for_output "Change database type"
#     # echo "y" > /tmp/mytty
#     # wait_for_output "Server"
#     # echo "host.docker.internal" > /tmp/mytty
#     # wait_for_output "Database"
#     # echo "WTDB" > /tmp/mytty
#     # wait_for_output "Username"
#     # echo "sa" > /tmp/mytty
#     # wait_for_output "Password"
#     # echo "yourStrong(!)Password" > /tmp/mytty
#     # wait_for_output "Commit changes"
#     # echo "y" > /tmp/mytty
#     # wait_for_output "Database Type mssql set"
# }

# # migrate_db() {
# #     echo "Database migration has started"
# # #     echo "db migrate from xml" > /proc/$xhttp_pid/fd/0
# # #     wait_for_output "Migrate database from"
# # #     echo "y" > /proc/$xhttp_pid/fd/0

# # }

# wait_for_output "Server started"

# configure_db
# # # migrate_db

tail -f /dev/null