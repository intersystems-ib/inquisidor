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
    <Route Url="/getWinners" Method="GET" Call="GetWinners" />
    <Route Url="/getContractors" Method="GET" Call="GetContractors" />
    <Route Url="/getStatisticsContractors" Method="POST" Call="GetStatisticsContractors" />
    <Route Url="/getYears" Method="GET" Call="GetYears" />
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
    Try {
        If '##class(%REST.Impl).%CheckAccepts("application/json") Do ##class(%REST.Impl).%ReportRESTError(..#HTTP406NOTACCEPTABLE,$$$ERROR($$$RESTBadAccepts)) Quit
        
        // Reading the body of the http call with the person data
        
        set dynamicBody = {}.%FromJSON(%request.Content)

        set filtros = dynamicBody.%Get("filtros")
        
         if ($ISOBJECT(filtros)) {
            set iterEmpresa = filtros.empresas.%GetIterator()
            set stringEmpresa = ""
            while iterEmpresa.%GetNext(.keyEmpresa, .valueEmpresa) {
                set stringEmpresa = stringEmpresa_","_valueEmpresa.NIF
            }
            set iterContratante = filtros.contratantes.%GetIterator()
            set stringContratante = ""
            while iterContratante.%GetNext(.keyEmpresa, .valueEmpresa) {
                set stringContratante = stringContratante_","_valueEmpresa
            }
            if ((stringEmpresa '= "") && (filtros.titulo '= "") && (stringContratante = "")) {
                set description = ..GetEncoding(filtros.titulo)
                set sql = 
                    "SELECT TOP 300 * FROM (SELECT %ID, Contratante, TO_CHAR(FechaAdjudicacion,'YYYY-MM-DD') As FechaAdjudicacion, Ganador, ImporteGanador, Titulo, VECTOR_DOT_PRODUCT(TO_VECTOR(?,DECIMAL), TituloVectorizado) As Similitud, URL FROM Inquisidor_Object.Licitacion WHERE GanadorNIF %INLIST ? ) "_            
                    "WHERE Similitud > 0.5 "_
                    "ORDER BY Similitud DESC"

                    set statement = ##class(%SQL.Statement).%New()
                    $$$ThrowOnError(statement.%Prepare(sql))
                    set rs = statement.%Execute(description, $LISTFROMSTRING(stringEmpresa))
            }
            elseif ((stringEmpresa '= "") && (filtros.titulo '= "") && (stringContratante '= "")) {
                set description = ..GetEncoding(filtros.titulo)
                set sql = 
                    "SELECT TOP 300 * FROM (SELECT %ID, Contratante, TO_CHAR(FechaAdjudicacion,'YYYY-MM-DD') As FechaAdjudicacion, Ganador, ImporteGanador, Titulo, VECTOR_DOT_PRODUCT(TO_VECTOR(?,DECIMAL), TituloVectorizado) As Similitud, URL FROM Inquisidor_Object.Licitacion "_
                    "WHERE GanadorNIF %INLIST ? and Contratante %INLIST ? ) "_            
                    "WHERE Similitud > 0.5 "_
                    "ORDER BY Similitud DESC"

                    set statement = ##class(%SQL.Statement).%New()
                    $$$ThrowOnError(statement.%Prepare(sql))
                    set rs = statement.%Execute(description, $LISTFROMSTRING(stringEmpresa),$LISTFROMSTRING(stringContratante))
            }
            elseif ((stringEmpresa '= "") && (filtros.titulo = "" && (stringContratante = ""))) {
                set sql = 
                    "SELECT TOP 300 %ID, Contratante, TO_CHAR(FechaAdjudicacion,'YYYY-MM-DD') As FechaAdjudicacion, Ganador, ImporteGanador, Titulo, '1' As Similitud, URL FROM Inquisidor_Object.Licitacion "_            
                    "WHERE GanadorNIF %INLIST ? "_
                    "ORDER BY Ganador ASC"

                    set statement = ##class(%SQL.Statement).%New()
                    $$$ThrowOnError(statement.%Prepare(sql))
                    set rs = statement.%Execute($LISTFROMSTRING(stringEmpresa))
            }
            elseif ((stringEmpresa '= "") && (filtros.titulo = "" && (stringContratante '= ""))) {
                set sql = 
                    "SELECT TOP 300 %ID, Contratante, TO_CHAR(FechaAdjudicacion,'YYYY-MM-DD') As FechaAdjudicacion, Ganador, ImporteGanador, Titulo, '1' As Similitud, URL FROM Inquisidor_Object.Licitacion "_            
                    "WHERE GanadorNIF %INLIST ? AND Contratante %INLIST ? "_
                    "ORDER BY Ganador ASC"

                    set statement = ##class(%SQL.Statement).%New()
                    $$$ThrowOnError(statement.%Prepare(sql))
                    set rs = statement.%Execute($LISTFROMSTRING(stringEmpresa), $LISTFROMSTRING(stringContratante))
            }
            elseif ((stringEmpresa = "") && (filtros.titulo '= "") && (stringContratante = "")) {
                set description = ..GetEncoding(filtros.titulo)
                set sql = 
                    "SELECT TOP 300 * FROM (SELECT %ID, Contratante, TO_CHAR(FechaAdjudicacion,'YYYY-MM-DD') As FechaAdjudicacion, Ganador, ImporteGanador, Titulo, VECTOR_DOT_PRODUCT(TO_VECTOR(?,DECIMAL), TituloVectorizado) As Similitud, URL FROM Inquisidor_Object.Licitacion) "_            
                    "WHERE Similitud > 0.5 "_
                    "ORDER BY Similitud DESC"

                    set statement = ##class(%SQL.Statement).%New()
                    $$$ThrowOnError(statement.%Prepare(sql))
                    set rs = statement.%Execute(description)
            }
            elseif ((stringEmpresa = "") && (filtros.titulo '= "") && (stringContratante '= "")) {
                set description = ..GetEncoding(filtros.titulo)
                set sql = 
                    "SELECT TOP 300 * FROM (SELECT %ID, Contratante, TO_CHAR(FechaAdjudicacion,'YYYY-MM-DD') As FechaAdjudicacion, Ganador, ImporteGanador, Titulo, VECTOR_DOT_PRODUCT(TO_VECTOR(?,DECIMAL), TituloVectorizado) As Similitud, URL FROM Inquisidor_Object.Licitacion WHERE Contratante %INLIST ?) "_            
                    "WHERE Similitud > 0.5 "_
                    "ORDER BY Similitud DESC"

                    set statement = ##class(%SQL.Statement).%New()
                    $$$ThrowOnError(statement.%Prepare(sql))
                    set rs = statement.%Execute(description)
            }
            else {
                set sql = 
                "SELECT TOP 300 %ID, Contratante, TO_CHAR(FechaAdjudicacion,'YYYY-MM-DD') As FechaAdjudicacion, Ganador, ImporteGanador, Titulo, '1' As Similitud, URL FROM Inquisidor_Object.Licitacion "_            
                "ORDER BY %ID DESC"

                set statement = ##class(%SQL.Statement).%New()
                $$$ThrowOnError(statement.%Prepare(sql))
                set rs = statement.%Execute()
            }
        
        }
        set array = []
        while rs.%Next() {
            do array.%Push({
                    "Id": (rs.%Get("ID")),
                    "Contratante": (rs.%Get("Contratante")),
                    "FechaAdjudicacion": (rs.%Get("FechaAdjudicacion")),
                    "Ganador": (rs.%Get("Ganador")),
                    "ImporteGanador": (rs.%Get("ImporteGanador")),
                    "Titulo": (rs.%Get("Titulo")),
                    "Similitud": (rs.%Get("Similitud")),
                    "URL": (rs.%Get("URL"))
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
                    "SELECT SUM(ImporteGanador) As ImporteTotal, YEAR(FechaAdjudicacion) As Anyo, Ganador "_
                    "FROM Inquisidor_Object.Licitacion WHERE GanadorNIF = ? AND YEAR(FechaAdjudicacion) = ? "_
                    "GROUP BY GanadorNIF, Anyo"

                    set statement = ##class(%SQL.Statement).%New()
                    $$$ThrowOnError(statement.%Prepare(sql))
                    set rs = statement.%Execute(valueEmpresa.NIF, valueAnyo)
                    while rs.%Next() {
                        set total = rs.%Get("ImporteTotal")
                    }
                    do statisticsEmpresa.series.%Push({"name":(valueAnyo),"value":(total)})
                    set stringAnyos = stringAnyos_","_valueAnyo
                }
                do linealResults.%Push(statisticsEmpresa)
                set sql = 
                    "SELECT SUM(ImporteGanador) As ImporteTotal "_
                    "FROM Inquisidor_Object.Licitacion WHERE GanadorNIF = ? AND YEAR(FechaAdjudicacion) %INLIST ? "
                set statement = ##class(%SQL.Statement).%New()
                $$$ThrowOnError(statement.%Prepare(sql))
                set rs = statement.%Execute(valueEmpresa.NIF, $LISTFROMSTRING(stringAnyos))
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
            "SELECT DISTINCT GanadorNIF, Ganador  FROM Inquisidor_Object.Licitacion WHERE Ganador like '%'_?_'%' GROUP BY GanadorNIF"

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
            "SELECT DISTINCT YEAR(FechaAdjudicacion) FROM Inquisidor_Object.Licitacion"

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
                    "SELECT SUM(ImporteGanador) As ImporteTotal, YEAR(FechaAdjudicacion) As Anyo, Contratante "_
                    "FROM Inquisidor_Object.Licitacion WHERE Contratante = ? AND YEAR(FechaAdjudicacion) = ? "_
                    "GROUP BY Contratante, Anyo"

                    set statement = ##class(%SQL.Statement).%New()
                    $$$ThrowOnError(statement.%Prepare(sql))
                    set rs = statement.%Execute(valueContratante, valueAnyo)
                    while rs.%Next() {
                        set total = rs.%Get("ImporteTotal")
                    }
                    do statisticsContratante.series.%Push({"name":(valueAnyo),"value":(total)})
                    set stringAnyos = stringAnyos_","_valueAnyo
                }
                
                do linealResults.%Push(statisticsContratante)
                set sql = 
                    "SELECT SUM(ImporteGanador) As ImporteTotal "_
                    "FROM Inquisidor_Object.Licitacion WHERE Contratante = ? AND YEAR(FechaAdjudicacion) %INLIST ? "
                set statement = ##class(%SQL.Statement).%New()
                $$$ThrowOnError(statement.%Prepare(sql))
                set rs = statement.%Execute(valueContratante, $LISTFROMSTRING(stringAnyos))
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

}
