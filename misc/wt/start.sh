#!/bin/bash

if [ -f .env ]; then
  . .env
fi

sed -i "s/\$SQL_USERNAME/$MSSQL_USERNAME/g" /tmp/wt/spxml_unibridge_config.xml
sed -i "s/\$SQL_PASSWORD/$MSSQL_SA_PASSWORD/g" /tmp/wt/spxml_unibridge_config.xml

cat /tmp/wt/xHttp.ini > /WebsoftServer/xHttp.ini
cat /tmp/wt/spxml_unibridge_config.xml > /WebsoftServer/spxml_unibridge_config.xml
echo "" > /WebsoftServer/fifd
./xhttp.out