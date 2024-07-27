#!/bin/bash

if [ -f .env ]; then
  . .env
fi

sed -i "s/\$SQL_USERNAME/$MSSQL_USERNAME/g" /tmp/wt/spxml_unibridge_config.xml
sed -i "s/\$SQL_PASSWORD/$MSSQL_SA_PASSWORD/g" /tmp/wt/spxml_unibridge_config.xml

sed -i "s/\$MAILPIT_DOCKER_SMTP_PORT/$MAILPIT_DOCKER_SMTP_PORT/g" /tmp/wt/is.js
sed -i "s/\$SMTP_LOGIN/$SMTP_LOGIN/g" /tmp/wt/is.js
sed -i "s/\$SMTP_PASSWORD/$SMTP_PASSWORD/g" /tmp/wt/is.js

cat /tmp/wt/xHttp.ini > /WebsoftServer/xHttp.ini
cat /tmp/wt/spxml_unibridge_config.xml > /WebsoftServer/spxml_unibridge_config.xml
cat /tmp/wt/is.js > /WebsoftServer/is.js
echo "" > /WebsoftServer/fifd

./xhttp.out