FROM mcr.microsoft.com/azure-sql-edge

ENV ACCEPT_EULA Y
ENV SA_PASSWORD "yourStrong(!)Password"

COPY ./*.sql .
COPY ./entrypoint.sh .

EXPOSE 1433

CMD /bin/bash ./entrypoint.sh
