Class Inquisidor.BP.XMLToLicitacion Extends Ens.BusinessProcess
{

Method OnRequest(pRequest As Ens.StreamContainer, Output pResponse As Ens.Response) As %Status
{
    set filename = pRequest.OriginalFilename

    set resultXML = ..ReadXML(filename)
    set resultEmbeddings = ""
    //set resultEmbeddings = ..GenerateEmbeddings()
    
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
            licitacion = {"titulo": "", "resumen": "", "idlicitacion": "", "url": "", "contratante": "", "urlcontratante": "", "estado": "", "valorestimado": "", "importetotal": "", "importetotalsinimpuestos": "", "clasificacion": "", "localizacion": "", "fechaadjudicacion": "", "ganador": "", "importeganadorsinimpuestos": "", "importeganador": ""}
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
                        elif detailTags.tag == "{urn:dgpe:names:draft:codice-place-ext:schema:xsd:CommonAggregateComponents-2}ContractFolderStatusCode":
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
                                elif infoResult.tag == "{urn:dgpe:names:draft:codice:schema:xsd:CommonAggregateComponents-2}WinningParty":
                                    for detailWinner in infoResult:
                                        if detailWinner.tag == "{urn:dgpe:names:draft:codice:schema:xsd:CommonAggregateComponents-2}PartyName":
                                            for detailName in detailWinner:
                                                if detailName.tag == "{urn:dgpe:names:draft:codice:schema:xsd:CommonBasicComponents-2}Name":
                                                    licitacion["ganador"] = detailName.text
                                elif infoResult.tag == "{urn:dgpe:names:draft:codice:schema:xsd:CommonAggregateComponents-2}AwardedTenderedProject":
                                    for detailTender in infoResult:
                                        if detailTender.tag == "{urn:dgpe:names:draft:codice:schema:xsd:CommonAggregateComponents-2}LegalMonetaryTotal":
                                            for detailWinnerAmount in detailTender:
                                                if detailWinnerAmount.tag == "{urn:dgpe:names:draft:codice:schema:xsd:CommonBasicComponents-2}TaxExclusiveAmount":
                                                    licitacion["importeganadorsinimpuestos"] = detailWinnerAmount.text
                                                elif detailWinnerAmount.tag == "{urn:dgpe:names:draft:codice:schema:xsd:CommonBasicComponents-2}PayableAmount":
                                                    licitacion["importeganador"] = detailWinnerAmount.text
            iris.cls("Ens.Util.Log").LogInfo("Inquisidor.BP.XMLToLicitacion", "VectorizePatient", "Terminado mapeo "+licitacion["titulo"])
            if licitacion.get("importeganador") is not None and licitacion.get("importeganador") is not "":
                iris.cls("Ens.Util.Log").LogInfo("Inquisidor.BP.XMLToLicitacion", "VectorizePatient", "Lanzando insert "+licitacion["titulo"])
                stmt = iris.sql.prepare("INSERT INTO INQUISIDOR_Object.Licitacion (Titulo, Resumen, IdLicitacion, URL, Contratante, URLContratante, Estado, ValorEstimado, ImporteTotal, ImporteTotalSinImpuestos, Clasificacion, Localizacion, FechaAdjudicacion, Ganador, ImporteGanadorSinImpuestos, ImporteGanador) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,TO_DATE(?,'YYYY-MM-DD'),?,?,?)")
                try:
                    rs = stmt.execute(licitacion["titulo"], licitacion["resumen"], licitacion["idlicitacion"], licitacion["url"], licitacion["contratante"], licitacion["urlcontratante"], licitacion["estado"], licitacion["valorestimado"], licitacion["importetotal"], licitacion["importetotalsinimpuestos"], licitacion["clasificacion"], licitacion["localizacion"], licitacion["fechaadjudicacion"], licitacion["ganador"], licitacion["importeganadorsinimpuestos"], licitacion["importeganador"])
                except Exception as err:
                    iris.cls("Ens.Util.Log").LogInfo("Inquisidor.BP.XMLToLicitacion", "VectorizePatient", repr(err))
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
        model = sentence_transformers.SentenceTransformer('sentence-transformers/all-MiniLM-L6-v2')            
        model.save('/iris-shared/model/')

    flagLoop = True
    while flagLoop:
        st = iris.sql.prepare("SELECT TOP 50 IdLicitacion, Titulo FROM INQUISIDOR_Object.Licitacion WHERE TituloVectorizado is null ORDER BY ID ASC ")
        resultSet = st.execute()
        df = resultSet.dataframe()
        
        if (df.size > 0):
            model = sentence_transformers.SentenceTransformer("/iris-shared/model/")
            embeddings = model.encode(df['titulo'].tolist(), normalize_embeddings=True)

            df['titulovectorizado'] = embeddings.tolist()

            stmt = iris.sql.prepare("UPDATE INQUISIDOR_Object.Licitacion SET TituloVectorizado = TO_VECTOR(?,DECIMAL) WHERE IdLicitacion = ?")
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
