Class Inquisidor.BS.EndpointREST Extends (%CSP.REST, Ens.BusinessService)
{

Parameter HandleCorsRequest = 0;

Parameter CHARSET = "utf-8";

Parameter CONVERTINPUTSTREAM = 1;

XData UrlMap [ XMLNamespace = "https://www.intersystems.com/urlmap" ]
{
<Routes>
	<Route Url="/test" Method="GET" Call="Test" />
    <Route Url="/getTenders" Method="POST" Call="GetTenders" />
    <Route Url="/getStatistics" Method="POST" Call="GetStatistics" />
    <Route Url="/getDashboardStatistics" Method="POST" Call="GetDashboardStatistics" />
    <Route Url="/getWinners" Method="GET" Call="GetWinners" />
    <Route Url="/getContractors" Method="GET" Call="GetContractors" />
    <Route Url="/getStatisticsContractors" Method="POST" Call="GetStatisticsContractors" />
    <Route Url="/getYears" Method="GET" Call="GetYears" />
    <Route Url="/getCPV" Method="GET" Call="GetCPV" />
    <Route Url="/getPublished" Method="POST" Call="GetPublished" />
</Routes>
}

ClassMethod GetEncoding(sentence As %String) As %String [ Language = python ]
{
    import sentence_transformers
    # create the model and form the embeddings
    model = sentence_transformers.SentenceTransformer('/iris-shared/model/')
    embeddings = model.encode(sentence, normalize_embeddings=True).tolist() # Convert search phrase into a vector
    # convert the embeddings to a string
    return str(embeddings)
}

ClassMethod OnHandleCorsRequest(url As %String) As %Status
{
	set url = %request.GetCgiEnv("HTTP_REFERER")
    set origin = $p(url,"/",1,3) // origin = "http(s)://origin.com:port"

    // here you can check specific origins
    // otherway, it will allow all origins (useful while developing only)

	do %response.SetHeader("Access-Control-Allow-Credentials","true")
	do %response.SetHeader("Access-Control-Allow-Methods","GET,POST,PUT,DELETE,OPTIONS")
	do %response.SetHeader("Access-Control-Allow-Origin",origin)
	do %response.SetHeader("Access-Control-Allow-Headers","Access-Control-Allow-Origin, Origin, X-Requested-With, Content-Type, Accept, Authorization, Cache-Control")
	quit $$$OK
}

ClassMethod Test() As %Status
{
    Try {
        Do ##class(%REST.Impl).%SetContentType("application/json")
        If '##class(%REST.Impl).%CheckAccepts("application/json") Do ##class(%REST.Impl).%ReportRESTError(..#HTTP406NOTACCEPTABLE,$$$ERROR($$$RESTBadAccepts)) Quit
        
        Do ##class(%REST.Impl).%SetStatusCode("200")	
        
    } Catch (ex) {
        Do ##class(%REST.Impl).%SetStatusCode("400")
        return ex.DisplayString()
    }
    Quit $$$OK
}

ClassMethod GetTenders() As %Status
{
    set query = ""
    Try {
        If '##class(%REST.Impl).%CheckAccepts("application/json") Do ##class(%REST.Impl).%ReportRESTError(..#HTTP406NOTACCEPTABLE,$$$ERROR($$$RESTBadAccepts)) Quit
        
        // Reading the body of the http call with the person data
        
        set dynamicBody = {}.%FromJSON(%request.Content)

        set filtros = dynamicBody.%Get("filtros")
        set whereList = ""
        
         if ($ISOBJECT(filtros)) {
            set iterEmpresa = filtros.empresas.%GetIterator()
            set iterCPV = filtros.cpvs.%GetIterator()
            set stringEmpresa = ""
            set stringContratante = ""
            set stringCPV = ""
            while iterEmpresa.%GetNext(.keyEmpresa, .valueEmpresa) {
                set stringEmpresa = stringEmpresa_"|"_valueEmpresa.NIF
            }
            set iterContratante = filtros.contratantes.%GetIterator()
            set stringContratante = ""
            while iterContratante.%GetNext(.keyContratante, .valueContratante) {
                set stringContratante = stringContratante_"|"_valueContratante
            }
            set stringCPV = ""
            while iterCPV.%GetNext(.keyCPV, .valueCPV) {
                set stringCPV = stringCPV_"|"_valueCPV.Code
            }
            
            if ((filtros.titulo '= "") && (filtros.busquedaVectorial = 1)) {
                set description = ..GetEncoding(filtros.titulo)
                Set tArgs($i(tArgs)) = description

                set sql = 
                    "SELECT * FROM (SELECT %ID, Contratante, TO_CHAR(FechaAdjudicacion,'YYYY-MM-DD') As FechaAdjudicacion, Ganador, ImporteGanador, Titulo, VECTOR_DOT_PRODUCT(TO_VECTOR(?,DECIMAL), TituloVectorizado) As Similitud, URL, CAST((ImporteGanador*100/ImporteTotal) - 100 As Integer) As Diferencia FROM Inquisidor_Object.Licitacion "
                set endSQL = ")"_          
                    "WHERE Similitud > 0.5 "_
                    "ORDER BY Similitud DESC"
            }
            else {
                set sql =
                    "SELECT %ID, Contratante, TO_CHAR(FechaAdjudicacion,'YYYY-MM-DD') As FechaAdjudicacion, Ganador, ImporteGanador, Titulo, '1' As Similitud, URL, CAST((ImporteGanador*100/ImporteTotal) As Integer) - 100 As Diferencia FROM Inquisidor_Object.Licitacion "         
                set endSQL = " ORDER BY FechaAdjudicacion DESC"
            }
            
            set generalCondition = 0

            if ((filtros.titulo '= "") && (filtros.busquedaVectorial = 0)) {
                Set whereList = whereList_$ListBuild("%ID %FIND search_index(IndexTitulo, ?)")
                Set tArgs($i(tArgs)) = filtros.titulo
                Set generalCondition = 1
            }

            if (stringEmpresa '= "") {
                Set whereList = whereList_$ListBuild("GanadorNIF %INLIST ?")
                Set tArgs($i(tArgs)) = $LISTFROMSTRING(stringEmpresa,"|")
                Set generalCondition = 1
            }

            if (stringContratante '= "") {
                Set whereList = whereList_$ListBuild("Contratante %INLIST ?")
                Set tArgs($i(tArgs)) = $LISTFROMSTRING(stringContratante, "|")
                Set generalCondition = 1
            }

            if (stringCPV '= "") {
                Set whereList = whereList_$ListBuild("Clasificacion %INLIST ?")
                Set tArgs($i(tArgs)) = $LISTFROMSTRING(stringCPV, "|")
                Set generalCondition = 1
            }
            if (generalCondition = 0) {
                set query = sql_" "_$LISTTOSTRING(whereList," AND ")_" "_endSQL
            }
            else {
                set query = sql_"WHERE "_$LISTTOSTRING(whereList," AND ")_" "_endSQL
            }            

            set statement = ##class(%SQL.Statement).%New()
                    $$$ThrowOnError(statement.%Prepare(query))
            set rs = statement.%Execute(tArgs...)
        }
        set array = []
        while rs.%Next() {
            do array.%Push({
                    "Id": (rs.%Get("ID")),
                    "contratante": (rs.%Get("Contratante")),
                    "fecha": (rs.%Get("FechaAdjudicacion")),
                    "ganador": (rs.%Get("Ganador")),
                    "importe": (rs.%Get("ImporteGanador")),
                    "titulo": (rs.%Get("Titulo")),
                    "similitud": (rs.%Get("Similitud")),
                    "URL": (rs.%Get("URL")),
                    "diferencia":(rs.%Get("Diferencia"))
                })
        }
        set %response.Status = ..#HTTP200OK
        set tempStream = ##class(%Stream.TmpCharacter).%New()
        do array.%ToJSON(tempStream)
        // w tempStream.Read(tempStream.SizeGet())
        set len = tempStream.SizeGet()
        While len > 0 {
            set line=tempStream.Read($S(len>32656:32656,1:len))
            set len=len-$length(line)
            write line
        }

    } Catch (ex) {
        Do ##class(%REST.Impl).%SetStatusCode("400")
        Do ##class(%REST.Impl).%WriteResponse(ex.DisplayString())
    }
    Quit $$$OK
}

ClassMethod GetStatistics() As %Status
{
    Try {
        If '##class(%REST.Impl).%CheckAccepts("application/json") Do ##class(%REST.Impl).%ReportRESTError(..#HTTP406NOTACCEPTABLE,$$$ERROR($$$RESTBadAccepts)) Quit
        
        // Reading the body of the http call with the person data
        
        set dynamicBody = {}.%FromJSON(%request.Content)

        set filtros = dynamicBody.%Get("filtros")

        set linealResults = []

        set pieResults = []

        set results = {}
        
        if ($ISOBJECT(filtros)) {
            set iterEmpresa = filtros.empresas.%GetIterator()
            while iterEmpresa.%GetNext(.keyEmpresa, .valueEmpresa) {
                set statisticsEmpresa = {}
                set statisticsEmpresa.name = valueEmpresa.Name
                set statisticsEmpresa.series = []
                set iterAnyos = filtros.anios.%GetIterator()
                set stringAnyos = ""
                while iterAnyos.%GetNext(.keyAnyo, .valueAnyo)  {
                    set total = 0
                    set sql = 
                    "SELECT SUM(ImporteGanador) As ImporteTotal, Anio, Ganador "_
                    "FROM Inquisidor_Object.Licitacion WHERE GanadorNIF = ? AND Anio = ? "_
                    "GROUP BY GanadorNIF, Anio"

                    set statement = ##class(%SQL.Statement).%New()
                    $$$ThrowOnError(statement.%Prepare(sql))
                    set rs = statement.%Execute(valueEmpresa.NIF, valueAnyo)
                    while rs.%Next() {
                        set total = rs.%Get("ImporteTotal")
                    }
                    do statisticsEmpresa.series.%Push({"name":(" "_valueAnyo_" "),"value":(total)})
                    set stringAnyos = stringAnyos_"|"_valueAnyo
                }
                do linealResults.%Push(statisticsEmpresa)
                set sql = 
                    "SELECT SUM(ImporteGanador) As ImporteTotal "_
                    "FROM Inquisidor_Object.Licitacion WHERE GanadorNIF = ? AND Anio %INLIST ? "
                set statement = ##class(%SQL.Statement).%New()
                $$$ThrowOnError(statement.%Prepare(sql))
                set rs = statement.%Execute(valueEmpresa.NIF, $LISTFROMSTRING(stringAnyos, "|"))
                set totalPie = 0
                while rs.%Next() {
                    set totalPie = rs.%Get("ImporteTotal")
                }
                do pieResults.%Push({"name":(valueEmpresa.Name),"value":(totalPie)})
            }
            set results = {"lineal": (linealResults), "pie":(pieResults)}
        }
    
        set %response.Status = ..#HTTP200OK
        set tempStream = ##class(%Stream.TmpCharacter).%New()
        do results.%ToJSON(tempStream)
        write tempStream.Read()

    } Catch (ex) {
        Do ##class(%REST.Impl).%SetStatusCode("400")
        Do ##class(%REST.Impl).%WriteResponse(ex.DisplayString())
    }
    Quit $$$OK
}

ClassMethod GetWinners() As %Status
{
    Try {
        If '##class(%REST.Impl).%CheckAccepts("application/json") Do ##class(%REST.Impl).%ReportRESTError(..#HTTP406NOTACCEPTABLE,$$$ERROR($$$RESTBadAccepts)) Quit
        
        set filter = %request.Data("filter",1)
        set sql = 
            "SELECT * FROM (SELECT DISTINCT(GanadorNIF), Ganador FROM Inquisidor_Object.Licitacion WHERE Ganador like '%'_?_'%') GROUP BY GanadorNIF ORDER BY Ganador ASC"

        set statement = ##class(%SQL.Statement).%New()
        $$$ThrowOnError(statement.%Prepare(sql))
        set rs = statement.%Execute(filter)
        
        
        set array = []
        while rs.%Next() {
            do array.%Push({"Name": (rs.%Get("Ganador")), "NIF": (rs.%Get("GanadorNIF"))})
        }
        set %response.Status = ..#HTTP200OK
        set tempStream = ##class(%Stream.TmpCharacter).%New()
        do array.%ToJSON(tempStream)
        write tempStream.Read()

    } Catch (ex) {
        Do ##class(%REST.Impl).%SetStatusCode("400")
        Do ##class(%REST.Impl).%WriteResponse(ex.DisplayString())
    }
    Quit $$$OK
}

ClassMethod GetContractors() As %Status
{
    Try {
        If '##class(%REST.Impl).%CheckAccepts("application/json") Do ##class(%REST.Impl).%ReportRESTError(..#HTTP406NOTACCEPTABLE,$$$ERROR($$$RESTBadAccepts)) Quit
        
        set filter = %request.Data("filter",1)
        set sql = 
            "SELECT DISTINCT Contratante FROM Inquisidor_Object.Licitacion WHERE Contratante like '%'_?_'%'"

        set statement = ##class(%SQL.Statement).%New()
        $$$ThrowOnError(statement.%Prepare(sql))
        set rs = statement.%Execute(filter)
        
        
        set array = []
        while rs.%Next() {
            do array.%Push(rs.%Get("Contratante"))
        }
        set %response.Status = ..#HTTP200OK
        set tempStream = ##class(%Stream.TmpCharacter).%New()
        do array.%ToJSON(tempStream)
        write tempStream.Read()

    } Catch (ex) {
        Do ##class(%REST.Impl).%SetStatusCode("400")
        Do ##class(%REST.Impl).%WriteResponse(ex.DisplayString())
    }
    Quit $$$OK
}

ClassMethod GetYears() As %Status
{
    Try {
        If '##class(%REST.Impl).%CheckAccepts("application/json") Do ##class(%REST.Impl).%ReportRESTError(..#HTTP406NOTACCEPTABLE,$$$ERROR($$$RESTBadAccepts)) Quit
        
        set sql = 
            "SELECT DISTINCT Anio FROM Inquisidor_Object.Licitacion"

        set statement = ##class(%SQL.Statement).%New()
        $$$ThrowOnError(statement.%Prepare(sql))
        set rs = statement.%Execute()
        
        
        set array = []
        while rs.%Next() {
            do array.%Push({
                "Anyo": (rs.%Get("Anyo"))
            })
        }
        set %response.Status = ..#HTTP200OK
        set tempStream = ##class(%Stream.TmpCharacter).%New()
        do array.%ToJSON(tempStream)
        write tempStream.Read()

    } Catch (ex) {
        Do ##class(%REST.Impl).%SetStatusCode("400")
        Do ##class(%REST.Impl).%WriteResponse(ex.DisplayString())
    }
    Quit $$$OK
}

ClassMethod GetStatisticsContractors() As %Status
{
    Try {
        If '##class(%REST.Impl).%CheckAccepts("application/json") Do ##class(%REST.Impl).%ReportRESTError(..#HTTP406NOTACCEPTABLE,$$$ERROR($$$RESTBadAccepts)) Quit
        
        // Reading the body of the http call with the person data
        
        set dynamicBody = {}.%FromJSON(%request.Content)

        set filtros = dynamicBody.%Get("filtros")

        set linealResults = []

        set pieResults = []

        set results = {}
        
        if ($ISOBJECT(filtros)) {
            set iterEmpresa = filtros.contratantes.%GetIterator()
            while iterEmpresa.%GetNext(.keyContratante, .valueContratante) {
                set statisticsContratante = {}
                set statisticsContratante.name = valueContratante
                set statisticsContratante.series = []
                set iterAnyos = filtros.anios.%GetIterator()
                set stringAnyos = ""
                while iterAnyos.%GetNext(.keyAnyo, .valueAnyo)  {
                    set total = 0
                    set sql = 
                    "SELECT SUM(ImporteGanador) As ImporteTotal, Anio, Contratante "_
                    "FROM Inquisidor_Object.Licitacion WHERE Contratante = ? AND Anio = ? "_
                    "GROUP BY Contratante, Anio"

                    set statement = ##class(%SQL.Statement).%New()
                    $$$ThrowOnError(statement.%Prepare(sql))
                    set rs = statement.%Execute(valueContratante, valueAnyo)
                    while rs.%Next() {
                        set total = rs.%Get("ImporteTotal")
                    }
                    do statisticsContratante.series.%Push({"name":(" "_valueAnyo_" "),"value":(total)})
                    set stringAnyos = stringAnyos_"|"_valueAnyo
                }
                
                do linealResults.%Push(statisticsContratante)
                set sql = 
                    "SELECT SUM(ImporteGanador) As ImporteTotal "_
                    "FROM Inquisidor_Object.Licitacion WHERE Contratante = ? AND Anio %INLIST ? "
                set statement = ##class(%SQL.Statement).%New()
                $$$ThrowOnError(statement.%Prepare(sql))
                set rs = statement.%Execute(valueContratante, $LISTFROMSTRING(stringAnyos,"|"))
                set totalPie = 0
                while rs.%Next() {
                    set totalPie = rs.%Get("ImporteTotal")
                }
                
                do pieResults.%Push({"name":(valueContratante),"value":(totalPie)})
            }
            set results = {"lineal": (linealResults), "pie":(pieResults)}
        }
    
        set %response.Status = ..#HTTP200OK
        set tempStream = ##class(%Stream.TmpCharacter).%New()
        do results.%ToJSON(tempStream)
        write tempStream.Read()

    } Catch (ex) {
        Do ##class(%REST.Impl).%SetStatusCode("400")
        Do ##class(%REST.Impl).%WriteResponse(ex.DisplayString())
    }
    Quit $$$OK
}

ClassMethod GetCPV() As %Status
{
    Try {
        If '##class(%REST.Impl).%CheckAccepts("application/json") Do ##class(%REST.Impl).%ReportRESTError(..#HTTP406NOTACCEPTABLE,$$$ERROR($$$RESTBadAccepts)) Quit
        
        set filter = %request.Data("filter",1)
        set sql = 
            "SELECT code, description FROM Inquisidor_Object.CPV WHERE code like ?_'%'"

        set statement = ##class(%SQL.Statement).%New()
        $$$ThrowOnError(statement.%Prepare(sql))
        set rs = statement.%Execute(filter)
        
        
        set array = []
        while rs.%Next() {
            do array.%Push({"Code": (rs.%Get("code")), "Description": (rs.%Get("description"))})
        }
        set %response.Status = ..#HTTP200OK
        set tempStream = ##class(%Stream.TmpCharacter).%New()
        do array.%ToJSON(tempStream)
        write tempStream.Read()

    } Catch (ex) {
        Do ##class(%REST.Impl).%SetStatusCode("400")
        Do ##class(%REST.Impl).%WriteResponse(ex.DisplayString())
    }
    Quit $$$OK
}

ClassMethod GetDashboardStatistics() As %Status
{
    Try {
        If '##class(%REST.Impl).%CheckAccepts("application/json") Do ##class(%REST.Impl).%ReportRESTError(..#HTTP406NOTACCEPTABLE,$$$ERROR($$$RESTBadAccepts)) Quit
        
        // Reading the body of the http call with the person data
        
        set dynamicBody = {}.%FromJSON(%request.Content)

        set filtros = dynamicBody.%Get("filtros")

        set winnersResults = []
        
        set contractorsResults = []

        set totalByYear = []

        set results = {}        

        if ($ISOBJECT(filtros)) {
            set iterAnyos = filtros.%GetIterator()  
            set stringAnyos = ""      
            set statisticsTotals = {}
            set statisticsTotals.name = "Total"
            set statisticsTotals.series = []
            while iterAnyos.%GetNext(.keyAnyo, .valueAnyo)  {
                set stringAnyos = stringAnyos_"|"_valueAnyo
            }  
             
            set sql = 
            "SELECT SUM(ImporteGanador) As ImporteTotal, Anio "_ 
            "FROM Inquisidor_Object.Licitacion WHERE Anio %INLIST ? GROUP BY Anio ORDER BY Anio ASC"

            set statement = ##class(%SQL.Statement).%New()
            $$$ThrowOnError(statement.%Prepare(sql))
            
            set rs = statement.%Execute($LISTFROMSTRING(stringAnyos,"|"))
            while rs.%Next() {
                set total = rs.%Get("ImporteTotal")
                set anio = rs.%Get("Anio")
                do statisticsTotals.series.%Push({"name":(" "_anio_" "),"value":(total)})
                do totalByYear.%Push(statisticsTotals)
            }
        }
        set results = {"totals": (totalByYear)}
    
        set %response.Status = ..#HTTP200OK
        set tempStream = ##class(%Stream.TmpCharacter).%New()
        do results.%ToJSON(tempStream)
        write tempStream.Read()

    } Catch (ex) {
        Do ##class(%REST.Impl).%SetStatusCode("400")
        Do ##class(%REST.Impl).%WriteResponse(ex.DisplayString())
    }
    Quit $$$OK
}

ClassMethod GetPublished() As %Status
{
    set query = ""
    Try {
        If '##class(%REST.Impl).%CheckAccepts("application/json") Do ##class(%REST.Impl).%ReportRESTError(..#HTTP406NOTACCEPTABLE,$$$ERROR($$$RESTBadAccepts)) Quit
        
        // Reading the body of the http call with the person data
        
        set dynamicBody = {}.%FromJSON(%request.Content)

        set filtros = dynamicBody.%Get("filtros")
        set whereList = ""
        
         if ($ISOBJECT(filtros)) {
            set iterCPV = filtros.cpvs.%GetIterator()
            set stringContratante = ""
            set stringCPV = ""
            set iterContratante = filtros.contratantes.%GetIterator()
            set stringContratante = ""
            while iterContratante.%GetNext(.keyContratante, .valueContratante) {
                set stringContratante = stringContratante_"|"_valueContratante
            }
            set stringCPV = ""
            while iterCPV.%GetNext(.keyCPV, .valueCPV) {
                set stringCPV = stringCPV_"|"_valueCPV.Code
            }
            
            if ((filtros.titulo '= "") && (filtros.busquedaVectorial = 1)) {
                set description = ..GetEncoding(filtros.titulo)
                Set tArgs($i(tArgs)) = description

                set sql = 
                    "SELECT * FROM (SELECT %ID, Contratante, TO_CHAR(Actualizado,'YYYY-MM-DD') As Actualizado, TO_CHAR(FechaLimite,'YYYY-MM-DD') As FechaLimite, HoraLimite, Titulo, VECTOR_DOT_PRODUCT(TO_VECTOR(?,DECIMAL), TituloVectorizado) As Similitud, URL, ImporteTotal FROM Inquisidor_Object.LicitacionPub "
                set endSQL = ")"_          
                    "WHERE Similitud > 0.5 "_
                    "ORDER BY Similitud DESC"
            }
            else {
                set sql =
                    "SELECT %ID, Contratante, TO_CHAR(Actualizado,'YYYY-MM-DD') As Actualizado, TO_CHAR(FechaLimite,'YYYY-MM-DD') As FechaLimite, HoraLimite, Titulo, '1' As Similitud, URL, ImporteTotal FROM Inquisidor_Object.LicitacionPub "         
                set endSQL = " ORDER BY FechaLimite ASC"
            }
            
            set generalCondition = 0

            if ((filtros.titulo '= "") && (filtros.busquedaVectorial = 0)) {
                Set whereList = whereList_$ListBuild("%ID %FIND search_index(IndexTituloPub, ?)")
                Set tArgs($i(tArgs)) = filtros.titulo
                Set generalCondition = 1
            }

            if (stringContratante '= "") {
                Set whereList = whereList_$ListBuild("Contratante %INLIST ?")
                Set tArgs($i(tArgs)) = $LISTFROMSTRING(stringContratante, "|")
                Set generalCondition = 1
            }

            if (stringCPV '= "") {
                Set whereList = whereList_$ListBuild("Clasificacion %INLIST ?")
                Set tArgs($i(tArgs)) = $LISTFROMSTRING(stringCPV, "|")
                Set generalCondition = 1
            }
            if (generalCondition = 0) {
                set query = sql_" "_$LISTTOSTRING(whereList," AND ")_" "_endSQL
            }
            else {
                set query = sql_"WHERE "_$LISTTOSTRING(whereList," AND ")_" "_endSQL
            }            

            set statement = ##class(%SQL.Statement).%New()
                    $$$ThrowOnError(statement.%Prepare(query))
            set rs = statement.%Execute(tArgs...)
        }
        set array = []
        while rs.%Next() {
            do array.%Push({
                    "Id": (rs.%Get("ID")),
                    "contratante": (rs.%Get("Contratante")),
                    "actualizado": (rs.%Get("Actualizado")),
                    "fechalimite": (rs.%Get("FechaLimite")),
                    "horalimite": (rs.%Get("HoraLimite")),
                    "importe": (rs.%Get("ImporteTotal")),
                    "titulo": (rs.%Get("Titulo")),
                    "similitud": (rs.%Get("Similitud")),
                    "URL": (rs.%Get("URL"))
                })
        }
        set %response.Status = ..#HTTP200OK
        set tempStream = ##class(%Stream.TmpCharacter).%New()
        do array.%ToJSON(tempStream)
        // w tempStream.Read(tempStream.SizeGet())
        set len = tempStream.SizeGet()
        While len > 0 {
            set line=tempStream.Read($S(len>32656:32656,1:len))
            set len=len-$length(line)
            write line
        }

    } Catch (ex) {
        Do ##class(%REST.Impl).%SetStatusCode("400")
        Do ##class(%REST.Impl).%WriteResponse(ex.DisplayString())
    }
    Quit $$$OK
}

}
