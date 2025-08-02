Class Inquisidor.Adapter.ZipFileInboundAdapter Extends Ens.InboundAdapter
{

Property InboundZipPath As %String(MAXLEN = 100);

Parameter SETTINGS = "InboundZipPath";

Method OnTask() As %Status
{
    $$$TRACE("Connecting")
    set tSC = $$$OK
    set currentDate = $ZDATE($HOROLOG,3)

    if ('$DATA(^$GLOBAL("^LASTZIP"))) {
        set ^LASTZIP = "0000-00-00"
    }
    if ($GET(^LASTZIP) '= currentDate){
        do ..ConnectAndDownload(..InboundZipPath)
        set msg = ##class(Inquisidor.Message.LicitacionRequest).%New()
        set tSC=..BusinessHost.ProcessInput(msg)

        set ^LASTZIP = currentDate
    }
    
    set sqlDelete = "DELETE FROM INQUISIDOR_Object.LicitacionPub WHERE FechaLimite < CURRENT_DATE"
    set statementDelete = ##class(%SQL.Statement).%New()
    set statusDelete = statementDelete.%Prepare(sqlDelete)
    if ($$$ISOK(statusDelete)) {
        set resultSetDelete = statementDelete.%Execute()
        set sc = statusDelete
        $$$TRACE("Eliminadas licitaciones pasadas")
    }
    else {
        set sc = statusDelete
        $$$TRACE("Error eliminando licitaciones pasadas")
    }
    
    $$$TRACE("Finishing connection")

    Quit tSC
}

ClassMethod ConnectAndDownload(inboundZipPath As %String) [ Language = python ]
{
    import requests
    import zipfile
    import os
    import iris
    from datetime import datetime

    try :
        fecha = datetime.now()
        sufijo = fecha.strftime('%Y%m')
        url = f'https://contrataciondelsectorpublico.gob.es/sindicacion/sindicacion_643/licitacionesPerfilesContratanteCompleto3_{sufijo}.zip'
        iris.cls("Ens.Util.Log").LogInfo("Inquisidor.Adapter.ZipFileInboundAdapter", "ConnectAndDownload", url)
        zip_path = f'licitacionesPerfilesContratanteCompleto3_{sufijo}.zip'

        response = requests.get(url, stream=True)

        if response.status_code == 200:
            with open(zip_path, 'wb') as file:
                for chunk in response.iter_content(chunk_size=8192):
                    file.write(chunk)
            iris.cls("Ens.Util.Log").LogInfo("Inquisidor.Adapter.ZipFileInboundAdapter", "ConnectAndDownload", f'Descarga completada: {zip_path}')

            # 6. Descomprimir
            os.makedirs(inboundZipPath, exist_ok=True)
            with zipfile.ZipFile(zip_path, 'r') as zip_ref:
                zip_ref.extractall(inboundZipPath)
            iris.cls("Ens.Util.Log").LogInfo("Inquisidor.Adapter.ZipFileInboundAdapter", "ConnectAndDownload", f'Contenido extraído en: {inboundZipPath}')

            # 7. Eliminar el ZIP temporal
            os.remove(zip_path)
            iris.cls("Ens.Util.Log").LogInfo("Inquisidor.Adapter.ZipFileInboundAdapter", "ConnectAndDownload", 'Archivo ZIP eliminado.')
        else:
            iris.cls("Ens.Util.Log").LogInfo("Inquisidor.Adapter.ZipFileInboundAdapter", "ConnectAndDownload", f'Error al descargar el archivo. Código HTTP: {response.status_code}')
    except Exception as err:
        iris.cls("Ens.Util.Log").LogInfo("Inquisidor.Adapter.ZipFileInboundAdapter", "ConnectAndDownload", repr(err))
    return 1
}

}
