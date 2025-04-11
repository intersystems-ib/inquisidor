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

        set description = dynamicBody.%Get("description")
        
        if (description '= "") {
            set description = ..GetEncoding(description)
            set sql = 
            "SELECT TOP 300 * FROM (SELECT %ID, Contratante, TO_CHAR(FechaAdjudicacion,'YYYY-MM-DD') As FechaAdjudicacion, Ganador, ImporteGanador, Titulo, VECTOR_DOT_PRODUCT(TO_VECTOR(?,DECIMAL), TituloVectorizado) As Similitud, URL FROM Inquisidor_Object.Licitacion) "_            
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

        set description = dynamicBody.%Get("description")
        
        if (description '= "") {
            set description = ..GetEncoding(description)
            set sql = 
            "SELECT TOP 5 * FROM Inquisidor_Object.Licitacion) "_            
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

ClassMethod GetWinners() As %Status
{
    Try {
        If '##class(%REST.Impl).%CheckAccepts("application/json") Do ##class(%REST.Impl).%ReportRESTError(..#HTTP406NOTACCEPTABLE,$$$ERROR($$$RESTBadAccepts)) Quit
        
        set filter = %request.Data("filter",1)
        set sql = 
            "SELECT DISTINCT Ganador FROM Inquisidor_Object.Licitacion WHERE Ganador like '%'_?_'%'"

        set statement = ##class(%SQL.Statement).%New()
        $$$ThrowOnError(statement.%Prepare(sql))
        set rs = statement.%Execute(filter)
        
        
        set array = []
        while rs.%Next() {
            do array.%Push(rs.%Get("Ganador"))
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

}
