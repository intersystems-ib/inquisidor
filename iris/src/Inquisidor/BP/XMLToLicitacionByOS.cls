Class Inquisidor.BP.XMLToLicitacionByOS Extends Ens.BusinessProcess
{

Method OnRequest(pRequest As Ens.StreamContainer, Output pResponse As Ens.Response) As %Status
{
    set filename = pRequest.OriginalFilename

    set status=##class(%XML.TextReader).ParseFile(filename,.textreader)
    //check status
    if $$$ISERR(status) {do $System.Status.DisplayError(status) quit}
    set tStatement = ##class(%SQL.Statement).%New()
    //iterate through document, node by node
    while textreader.Read()
    {        

        if ((textreader.NodeType = "element") && (textreader.Depth = 2) && (textreader.Path = "/feed/entry")) {
            if ($DATA(licitacion))
            {                
                if (licitacion.ImporteGanador '= ""){
                    //set sc = licitacion.%Save()
                    set myquery = "INSERT INTO INQUISIDOR_Object.LicitacionOS (Titulo, Resumen, IdLicitacion, URL, Contratante, URLContratante, Estado, ValorEstimado, ImporteTotal, ImporteTotalSinImpuestos, Clasificacion, Localizacion, FechaAdjudicacion, Ganador, ImporteGanadorSinImpuestos, ImporteGanador) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
                    set qStatus = tStatement.%Prepare(myquery)
                    if qStatus '= 1 {
                        write "%Prepare failed:" do $System.Status.DisplayError(qStatus)
                        quit
                    }
                    set rset = tStatement.%Execute(licitacion.Titulo, licitacion.Resumen, licitacion.IdLicitacion, licitacion.URL, licitacion.Contratante, licitacion.URLContratante, licitacion.Estado, licitacion.ValorEstimado, licitacion.ImporteTotal, licitacion.ImporteTotalSinImpuestos, licitacion.Clasificacion, licitacion.Localizacion, licitacion.FechaAdjudicacion, licitacion.Ganador, licitacion.ImporteGanadorSinImpuestos, licitacion.ImporteGanador)
                }                
            }
            set licitacion = ##class(Inquisidor.Object.LicitacionOS).%New()
        }        

        if (textreader.Path = "/feed/entry/title"){
            if (textreader.Value '= ""){
                set licitacion.Titulo = textreader.Value
            }
        }
        if (textreader.Path = "/feed/entry/summary"){
            if (textreader.Value '= ""){
                set licitacion.Resumen = textreader.Value
            }
        }
        if (textreader.Path = "/feed/entry/id"){
            if (textreader.Value '= ""){
                set licitacion.IdLicitacion = textreader.Value
            }
        }
        if (textreader.Path = "/feed/entry/link"){            
            if (textreader.MoveToAttributeName("href")) {
                set licitacion.URL = textreader.Value                
            }
        }
        if (textreader.Path = "/feed/entry/cac-place-ext:ContractFolderStatus/cbc-place-ext:ContractFolderStatusCode"){
            if (textreader.Value '= ""){
                set licitacion.Estado = textreader.Value
            }
        }
        if (textreader.Path = "/feed/entry/cac-place-ext:ContractFolderStatus/cac-place-ext:LocatedContractingParty/cac:Party/cac:PartyName"){
            if (textreader.Value '= ""){
                set licitacion.Contratante = textreader.Value
            }
        }
        if (textreader.Path = "/feed/entry/cac-place-ext:ContractFolderStatus/cac-place-ext:LocatedContractingParty/cac:Party/cbc:WebsiteURI"){
            if (textreader.Value '= ""){
                set licitacion.URLContratante = textreader.Value
            }
        }
        if (textreader.Path = "/feed/entry/cac-place-ext:ContractFolderStatus/cac:ProcurementProject/cac:BudgetAmount/cbc:EstimatedOverallContractAmount"){
            if (textreader.Value '= ""){
                set licitacion.ValorEstimado = textreader.Value
            }
        }
        if (textreader.Path = "/feed/entry/cac-place-ext:ContractFolderStatus/cac:ProcurementProject/cac:BudgetAmount/cbc:TotalAmount"){
            if (textreader.Value '= ""){
                set licitacion.ImporteTotal = textreader.Value
            }
        }
        if (textreader.Path = "/feed/entry/cac-place-ext:ContractFolderStatus/cac:ProcurementProject/cac:BudgetAmount/cbc:TaxExclusiveAmount"){
            if (textreader.Value '= ""){
                set licitacion.ImporteTotalSinImpuestos = textreader.Value
            }
        }
        if (textreader.Path = "/feed/entry/cac-place-ext:ContractFolderStatus/cac:ProcurementProject/cac:RequiredCommodityClassification/cbc:ItemClassificationCode"){
            if (textreader.Value '= ""){
                set licitacion.Clasificacion = textreader.Value
            }
        }
        if (textreader.Path = "/feed/entry/cac-place-ext:ContractFolderStatus/cac:ProcurementProject/cac:RealizedLocation/cbc:CountrySubentity"){
            if (textreader.Value '= ""){
                set licitacion.Localizacion = textreader.Value
            }
        }
        if (textreader.Path = "/feed/entry/cac-place-ext:ContractFolderStatus/cac:TenderResult/cbc:AwardDate"){
            if (textreader.Value '= ""){
                set licitacion.FechaAdjudicacion = $System.SQL.Functions.TODATE(textreader.Value,"YYYY-MM-DD")
            }
        }
        if (textreader.Path = "/feed/entry/cac-place-ext:ContractFolderStatus/cac:TenderResult/cac:WinningParty/cac:PartyName/cbc:Name"){
            if (textreader.Value '= ""){
                set licitacion.Ganador = textreader.Value
            }
        }
        if (textreader.Path = "/feed/entry/cac-place-ext:ContractFolderStatus/cac:TenderResult/cac:AwardedTenderedProject/cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount"){
            if (textreader.Value '= ""){
                set licitacion.ImporteGanadorSinImpuestos = textreader.Value
            }
        }
        if (textreader.Path = "/feed/entry/cac-place-ext:ContractFolderStatus/cac:TenderResult/cac:AwardedTenderedProject/cac:LegalMonetaryTotal/cbc:PayableAmount"){
            if (textreader.Value '= ""){
                set licitacion.ImporteGanador = textreader.Value
            }
        }       
    }    
    // set resultEmbeddings = ..GenerateEmbeddings()
    Quit $$$OK
}

Method GenerateEmbeddings() As %String [ Language = python ]
{
    import iris
    import os
    import sentence_transformers

    if not os.path.isdir('/iris-shared/model/'):
        model = sentence_transformers.SentenceTransformer('sentence-transformers/all-MiniLM-L6-v2')            
        model.save('/iris-shared/model/')

    flagLoop = True
    while flagLoop:
        st = iris.sql.prepare("SELECT TOP 50 IdLicitacion, Titulo FROM INQUISIDOR_Object.LicitacionOS WHERE TituloVectorizado is null ORDER BY ID ASC ")
        resultSet = st.execute()
        df = resultSet.dataframe()
        
        if (df.size > 0):
            model = sentence_transformers.SentenceTransformer("/iris-shared/model/")
            embeddings = model.encode(df['titulo'].tolist(), normalize_embeddings=True)

            df['titulovectorizado'] = embeddings.tolist()

            stmt = iris.sql.prepare("UPDATE INQUISIDOR_Object.LicitacionOS SET TituloVectorizado = TO_VECTOR(?,DECIMAL) WHERE IdLicitacion = ?")
            for index, row in df.iterrows():
                rs = stmt.execute(str(row['titulovectorizado']), row['idlicitacion'])
        else:
            flagLoop = False
}

Storage Default
{
<Type>%Storage.Persistent</Type>
}

}
