#!/bin/bash

if [ -f .env ]; then
  . .env
fi

cat /tmp/wt/xHttp.ini > /WebsoftServer/xHttp.ini
cat /tmp/wt/spxml_unibridge_config.xml > /WebsoftServer/spxml_unibridge_config.xml
cat /tmp/wt/is.js > /WebsoftServer/is.js

sed -i "s/\$SQL_USERNAME/$MSSQL_USERNAME/g" /WebsoftServer/spxml_unibridge_config.xml
sed -i "s/\$SQL_PASSWORD/$MSSQL_SA_PASSWORD/g" /WebsoftServer/spxml_unibridge_config.xml

sed -i "s/\$MAILPIT_DOCKER_SMTP_PORT/$MAILPIT_DOCKER_SMTP_PORT/g" /WebsoftServer/is.js
sed -i "s/\$SMTP_LOGIN/$SMTP_LOGIN/g" /WebsoftServer/is.js
sed -i "s/\$SMTP_PASSWORD/$SMTP_PASSWORD/g" /WebsoftServer/is.js


echo "" > /WebsoftServer/fifd

./xhttp.out