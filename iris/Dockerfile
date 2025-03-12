ARG IMAGE=containers.intersystems.com/intersystems/iris-community:latest-preview
FROM $IMAGE

USER root

WORKDIR /opt/irisapp
RUN chown -R irisowner:irisowner /opt/irisapp

RUN apt-get update && apt-get install -y python3

# install required packages
COPY --chown=$ISC_PACKAGE_MGRUSER:$ISC_PACKAGE_IRISGROUP /requirements.txt /
RUN chmod 777 /requirements.txt

RUN pip3 install -r /requirements.txt --break-system-packages

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

ENV ISC_CPF_MERGE_FILE=/iris.cpf

SHELL ["/irissession.sh"]

RUN \
zn "%SYS" \
do ##class(SYS.Container).QuiesceForBundling() \
do ##class(Security.Users).UnExpireUserPasswords("*") \
set sc=##class(%SYSTEM.OBJ).Load("/opt/irisapp/DemoSetup.Utilities.cls","ck") \
set helper=##class(DemoSetup.Utilities).%New() \ 
do helper.EnableSSLSuperServer() \
zn "INQUISIDOR" \
set sc = $SYSTEM.OBJ.LoadDir("/opt/irisapp/src/Inquisidor", "ck", , 1) \
set production = "Inquisidor.Production" \
set ^Ens.Configuration("csp","LastProduction") = production \
do ##class(Ens.Director).SetAutoStart(production) \