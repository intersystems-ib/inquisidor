Class Inquisidor.BS.ImportZipFile Extends Ens.BusinessService
{

Parameter ADAPTER = "Inquisidor.Adapter.ZipFileInboundAdapter";

Method OnProcessInput(pRequest As Inquisidor.Message.LicitacionRequest, pResponse As %RegisteredObject) As %Status
{
    set tSC = $$$OK

    $$$TRACE(pRequest.Message)        

    Quit tSC
}

}
