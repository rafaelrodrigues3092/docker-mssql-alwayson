FROM mcr.microsoft.com/mssql/server:2019-latest

ARG INSTALL_TOOLS=False

COPY ./scripts /
USER root
RUN chmod +x db-init.sh
RUN chmod +x install-tools.sh

RUN ./install-tools.sh $INSTALL_TOOLS

RUN /opt/mssql/bin/mssql-conf set sqlagent.enabled true
RUN /opt/mssql/bin/mssql-conf set hadr.hadrenabled  1
RUN /opt/mssql/bin/mssql-conf set memory.memorylimitmb 2048


CMD /bin/bash ./entrypoint.sh
