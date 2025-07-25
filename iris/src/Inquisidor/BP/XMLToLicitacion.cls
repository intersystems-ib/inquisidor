Class Inquisidor.BP.XMLToLicitacion Extends Ens.BusinessProcess
{

Method OnRequest(pRequest As Ens.StreamContainer, Output pResponse As Ens.Response) As %Status
{
    set filename = pRequest.OriginalFilename

    set resultXML = ..ReadXML(filename)
    set resultEmbeddings = ""
    set resultEmbeddings = ..GenerateEmbeddings()
    set sqlInsert = "INSERT INTO Inquisidor_Object.Licitacion (Titulo, TituloVectorizado, Resumen, IdLicitacion, URL, Contratante, URLContratante, Estado, ValorEstimado, ImporteTotal, ImporteTotalSinImpuestos, Clasificacion, Localizacion, FechaAdjudicacion, Ganador, ImporteGanadorSinImpuestos, ImporteGanador, GanadorNIF, Anio) "_
        "SELECT Titulo, TituloVectorizado, Resumen, IdLicitacion, URL, Contratante, URLContratante, Estado, ValorEstimado, ImporteTotal, ImporteTotalSinImpuestos, Clasificacion, Localizacion, FechaAdjudicacion, Ganador, ImporteGanadorSinImpuestos, ImporteGanador, GanadorNIF, Anio FROM Inquisidor_Object.LicitacionTemp WHERE IdLicitacion NOT IN "_
        "(SELECT IdLicitacion FROM Inquisidor_Object.Licitacion)"
    set statementInsert = ##class(%SQL.Statement).%New()
    set statusInsert = statementInsert.%Prepare(sqlInsert)
    if ($$$ISOK(statusInsert)) {
        set resultSetInsert = statementInsert.%Execute()
        set sc = statusInsert
        set sqlTruncate = "TRUNCATE TABLE Inquisidor_Object.LicitacionTemp"
        set statementTruncate = ##class(%SQL.Statement).%New()
        set statusTruncate = statementTruncate.%Prepare(sqlTruncate)
        if ($$$ISOK(statusTruncate)) {
            set resultSetTruncate = statementTruncate.%Execute()
            set sc = statusTruncate
        }
        else {
            set sc = statusTruncate
        }
    }
    else {
        set sc = statusTruncate
    }
    
    
    Quit $$$OK
}

Method ReadXML(xmlPath As %String) As %String [ Language = python ]
{
    import xml.etree.ElementTree as ET
    import iris
    import pandas as pd

    try :
        tree = ET.parse(xmlPath)
        root = tree.getroot()
        for entry in root.iter("{http://www.w3.org/2005/Atom}entry"):
            licitacion = {"titulo": "", "resumen": "", "idlicitacion": "", "url": "", "contratante": "", "urlcontratante": "", "estado": "", "valorestimado": "", "importetotal": "", "importetotalsinimpuestos": "", "clasificacion": "", "localizacion": "", "fechaadjudicacion": "", "ganador": "", "importeganadorsinimpuestos": "", "importeganador": "", "anio": ""}
            for tags in entry:
                if tags.tag == "{http://www.w3.org/2005/Atom}title":
                    licitacion["titulo"] = tags.text
                if tags.tag == "{http://www.w3.org/2005/Atom}summary":
                    licitacion["resumen"] = tags.text
                if tags.tag == "{http://www.w3.org/2005/Atom}id":
                    licitacion["idlicitacion"] = tags.text
                if tags.tag == "{http://www.w3.org/2005/Atom}link":
                    licitacion["url"] = tags.attrib["href"]
                if tags.tag == "{urn:dgpe:names:draft:codice-place-ext:schema:xsd:CommonAggregateComponents-2}ContractFolderStatus":
                    for detailTags in tags:
                        if detailTags.tag == "{urn:dgpe:names:draft:codice-place-ext:schema:xsd:CommonAggregateComponents-2}LocatedContractingParty":
                            for infoContractor in detailTags:
                                if infoContractor.tag == "{urn:dgpe:names:draft:codice:schema:xsd:CommonAggregateComponents-2}Party":
                                    for contractorDetails in infoContractor:
                                        if contractorDetails.tag == "{urn:dgpe:names:draft:codice:schema:xsd:CommonAggregateComponents-2}PartyName" :
                                            for name in contractorDetails:
                                                licitacion["contratante"] = name.text
                                        elif contractorDetails.tag == "{urn:dgpe:names:draft:codice:schema:xsd:CommonBasicComponents-2}WebsiteURI":
                                            licitacion["urlcontratante"] = contractorDetails.text
                        elif detailTags.tag == "{urn:dgpe:names:draft:codice-place-ext:schema:xsd:CommonBasicComponents-2}ContractFolderStatusCode":
                            licitacion["estado"] = detailTags.text
                        elif detailTags.tag == "{urn:dgpe:names:draft:codice:schema:xsd:CommonAggregateComponents-2}ProcurementProject":
                            for infoProcurement in detailTags:
                                if infoProcurement.tag == "{urn:dgpe:names:draft:codice:schema:xsd:CommonAggregateComponents-2}BudgetAmount":
                                    for detailBudget in infoProcurement:
                                        if detailBudget.tag == "{urn:dgpe:names:draft:codice:schema:xsd:CommonBasicComponents-2}EstimatedOverallContractAmount":
                                            licitacion["valorestimado"] = detailBudget.text
                                        elif detailBudget.tag == "{urn:dgpe:names:draft:codice:schema:xsd:CommonBasicComponents-2}TotalAmount":
                                            licitacion["importetotal"] = detailBudget.text
                                        elif detailBudget.tag == "{urn:dgpe:names:draft:codice:schema:xsd:CommonBasicComponents-2}TaxExclusiveAmount":
                                            licitacion["importetotalsinimpuestos"] = detailBudget.text
                                elif infoProcurement.tag == "{urn:dgpe:names:draft:codice:schema:xsd:CommonAggregateComponents-2}RequiredCommodityClassification":
                                    for detailClassification in infoProcurement:
                                        if detailClassification.tag == "{urn:dgpe:names:draft:codice:schema:xsd:CommonBasicComponents-2}ItemClassificationCode":
                                            licitacion["clasificacion"] = detailClassification.text
                                elif infoProcurement.tag == "{urn:dgpe:names:draft:codice:schema:xsd:CommonAggregateComponents-2}RealizedLocation":
                                    for detailLocalization in infoProcurement:
                                        if detailLocalization.tag == "{urn:dgpe:names:draft:codice:schema:xsd:CommonBasicComponents-2}CountrySubentity":
                                            licitacion["localizacion"] = detailLocalization.text
                        elif detailTags.tag == "{urn:dgpe:names:draft:codice:schema:xsd:CommonAggregateComponents-2}TenderResult":
                            for infoResult in detailTags:
                                if infoResult.tag == "{urn:dgpe:names:draft:codice:schema:xsd:CommonBasicComponents-2}AwardDate":
                                    licitacion["fechaadjudicacion"] = infoResult.text
                                    licitacion["anio"] = infoResult.text.split("-")[0]
                                elif infoResult.tag == "{urn:dgpe:names:draft:codice:schema:xsd:CommonAggregateComponents-2}WinningParty":
                                    for detailWinner in infoResult:
                                        if detailWinner.tag == "{urn:dgpe:names:draft:codice:schema:xsd:CommonAggregateComponents-2}PartyName":
                                            for detailName in detailWinner:
                                                if detailName.tag == "{urn:dgpe:names:draft:codice:schema:xsd:CommonBasicComponents-2}Name":
                                                    licitacion["ganador"] = detailName.text
                                        elif detailWinner.tag == "{urn:dgpe:names:draft:codice:schema:xsd:CommonAggregateComponents-2}PartyIdentification":
                                            for detailName in detailWinner:
                                                if detailName.tag == "{urn:dgpe:names:draft:codice:schema:xsd:CommonBasicComponents-2}ID":
                                                    licitacion["ganadornif"] = detailName.text
                                elif infoResult.tag == "{urn:dgpe:names:draft:codice:schema:xsd:CommonAggregateComponents-2}AwardedTenderedProject":
                                    for detailTender in infoResult:
                                        if detailTender.tag == "{urn:dgpe:names:draft:codice:schema:xsd:CommonAggregateComponents-2}LegalMonetaryTotal":
                                            for detailWinnerAmount in detailTender:
                                                if detailWinnerAmount.tag == "{urn:dgpe:names:draft:codice:schema:xsd:CommonBasicComponents-2}TaxExclusiveAmount":
                                                   licitacion["importeganadorsinimpuestos"] = detailWinnerAmount.text
                                                elif detailWinnerAmount.tag == "{urn:dgpe:names:draft:codice:schema:xsd:CommonBasicComponents-2}PayableAmount":
                                                    licitacion["importeganador"] = detailWinnerAmount.text
            if licitacion.get("importeganador") is not None and licitacion.get("importeganador") != "":
                stmt = iris.sql.prepare("INSERT INTO INQUISIDOR_Object.LicitacionTemp (Titulo, Resumen, IdLicitacion, URL, Contratante, URLContratante, Estado, ValorEstimado, ImporteTotal, ImporteTotalSinImpuestos, Clasificacion, Localizacion, FechaAdjudicacion, Ganador, ImporteGanadorSinImpuestos, ImporteGanador, GanadorNIF, Anio) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,TO_DATE(?,'YYYY-MM-DD'),?,?,?,?,?)")
                try:
                    rs = stmt.execute(licitacion["titulo"], licitacion["resumen"], licitacion["idlicitacion"], licitacion["url"], licitacion["contratante"], licitacion["urlcontratante"], licitacion["estado"], licitacion["valorestimado"], licitacion["importetotal"], licitacion["importetotalsinimpuestos"], licitacion["clasificacion"], licitacion["localizacion"], licitacion["fechaadjudicacion"], licitacion["ganador"], licitacion["importeganadorsinimpuestos"], licitacion["importeganador"], licitacion["ganadornif"], licitacion["anio"])
                except Exception as err:
                    iris.cls("Ens.Util.Log").LogInfo("Inquisidor.BP.XMLToLicitacion", "ParseXML", repr(err))
        return "Success"
    except Exception as err:
        iris.cls("Ens.Util.Log").LogInfo("Inquisidor.BP.XMLToLicitacion", "VectorizePatient", repr(err))
        return "Error"
}

Method GenerateEmbeddings() As %String [ Language = python ]
{
    import iris
    import os
    import sentence_transformers

    if not os.path.isdir('/iris-shared/model/'):
        model = sentence_transformers.SentenceTransformer('sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2')            
        model.save('/iris-shared/model/')

    flagLoop = True
    while flagLoop:
        st = iris.sql.prepare("SELECT IdLicitacion, Titulo FROM INQUISIDOR_Object.LicitacionTemp WHERE TituloVectorizado is null ORDER BY ID ASC ")
        resultSet = st.execute()
        df = resultSet.dataframe()
        iris.cls("Ens.Util.Log").LogInfo("Inquisidor.BP.XMLToLicitacion", "GenerateEmbeddings", "Iniciando vectorización")
        if (df.size > 0):
            model = sentence_transformers.SentenceTransformer("/iris-shared/model/")
            embeddings = model.encode(df['titulo'].tolist(), normalize_embeddings=True)

            df['titulovectorizado'] = embeddings.tolist()
            iris.cls("Ens.Util.Log").LogInfo("Inquisidor.BP.XMLToLicitacion", "GenerateEmbeddings", "Iniciando inserción")
            stmt = iris.sql.prepare("UPDATE INQUISIDOR_Object.LicitacionTemp SET TituloVectorizado = TO_VECTOR(?,DECIMAL) WHERE IdLicitacion = ?")
            for index, row in df.iterrows():
                rs = stmt.execute(str(row['titulovectorizado']), row['idlicitacion'])
            iris.cls("Ens.Util.Log").LogInfo("Inquisidor.BP.XMLToLicitacion", "GenerateEmbeddings", "Inserción concluida")
        else:
            flagLoop = False
}

Storage Default
{
<Type>%Storage.Persistent</Type>
}

}
