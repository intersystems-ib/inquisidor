ARG IMAGE=containers.intersystems.com/intersystems/iris:latest-em
FROM $IMAGE

USER root

WORKDIR /opt/irisapp
RUN chown -R irisowner:irisowner /opt/irisapp


# 1. Paquetes de sistema necesarios
RUN apt-get update && \
    apt-get install -y \
        python3 \
        python3-pip \
        python3-dev \
        build-essential \
        git && \
    rm -rf /var/lib/apt/lists/*

# 2. Actualizar pip (importante para wheels recientes)
RUN python3 -m pip install --upgrade pip setuptools wheel

# 3. Instalar PyTorch explícitamente (si tu imagen es x86_64 Linux)
#    Si esto falla, es casi seguro que tu arquitectura no está soportada por las wheels de PyTorch.
RUN pip3 install --no-cache-dir \
    --index-url https://download.pytorch.org/whl/cpu \
    "torch==2.3.1"

# install required packages
COPY --chown=$ISC_PACKAGE_MGRUSER:$ISC_PACKAGE_IRISGROUP /requirements.txt /
RUN chmod 777 /requirements.txt

RUN pip3 install -r /requirements.txt --break-system-packages --no-cache-dir

USER irisowner

COPY --chown=irisowner:irisowner /iris/src src

COPY --chown=$ISC_PACKAGE_MGRUSER:$ISC_PACKAGE_IRISGROUP /iris/certificates /certificates
RUN chmod +x /certificates

COPY --chown=$ISC_PACKAGE_MGRUSER:$ISC_PACKAGE_IRISGROUP /iris/irissession.sh /
RUN chmod +x /irissession.sh

COPY --chown=$ISC_PACKAGE_MGRUSER:$ISC_PACKAGE_IRISGROUP /iris/DemoSetup.Utilities.cls . 
RUN chmod +x /opt/irisapp/DemoSetup.Utilities.cls

COPY --chown=$ISC_PACKAGE_MGRUSER:$ISC_PACKAGE_IRISGROUP /iris/iris.cpf /
RUN chmod +x /iris.cpf

COPY --chown=$ISC_PACKAGE_MGRUSER:$ISC_PACKAGE_IRISGROUP /iris/ApplicationInquisidor.xml /
RUN chmod +x /ApplicationInquisidor.xml

COPY --chown=$ISC_PACKAGE_MGRUSER:$ISC_PACKAGE_IRISGROUP /iris/sql/init.sql /
RUN chmod +x /init.sql

ENV ISC_CPF_MERGE_FILE=/iris.cpf

COPY --chown=$ISC_PACKAGE_MGRUSER:$ISC_PACKAGE_IRISGROUP /iris/iris.key /usr/irissys/mgr
RUN chmod +x /usr/irissys/mgr/iris.key

COPY /iris/iris.script /tmp/iris.script

RUN iris start IRIS \
	&& iris session IRIS < /tmp/iris.script \
    && iris stop IRIS quietly