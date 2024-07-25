#!/bin/bash

# apt-get install -y expect
apt-get install -y socat

if [ -f .env ]; then
  . .env
fi

# xhttp_fifo_in=/tmp/xhttp_fifo_in
# xhttp_fifo_out=/tmp/xhttp_fifo_out

# mkfifo $xhttp_fifo_in
# mkfifo $xhttp_fifo_out

./xhttp.out < /tmp/mytty > /tmp/mytty &
xhttp_pid=$!

echo "xhttp.out has started with pid $xhttp_pid"

wait_for_output() {
    local expected_output=$1
    echo "The main process awaits of input $expected_output"

    while read line; do
        echo $line

        if echo $line | grep -q "$expected_output"; then
            echo "Output $expected_output found"
            break
        fi
    done < /tmp/mytty
}

configure_db() {
    echo "Database configuration has started"

    echo "db set type mssql" > /tmp/mytty
    wait_for_output "Change database type"
    echo "y" > /tmp/mytty
    wait_for_output "Server"
    echo "host.docker.internal" > /tmp/mytty
    wait_for_output "Database"
    echo "WTDB" > /tmp/mytty
    wait_for_output "Username"
    echo "sa" > /tmp/mytty
    wait_for_output "Password"
    echo "yourStrong(!)Password" > /tmp/mytty
    wait_for_output "Commit changes"
    echo "y" > /tmp/mytty
    wait_for_output "Database Type mssql set"
}

# migrate_db() {
#     echo "Database migration has started"

#     echo "db migrate from xml" > /proc/$xhttp_pid/fd/0
#     wait_for_output "Migrate database from"
#     echo "y" > /proc/$xhttp_pid/fd/0
# }

echo "" >> $xhttp_fifo_in
wait_for_output "Server started"

configure_db
# migrate_db
# rm $xhttp_fifo_in $xhttp_fifo_out