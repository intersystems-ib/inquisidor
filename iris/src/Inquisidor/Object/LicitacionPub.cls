Class Inquisidor.Object.LicitacionPub Extends (%Persistent, %XML.Adaptor) [ DdlAllowed ]
{

Property IdLicitacion As %String(MAXLEN = 200);

Property Titulo As %String(MAXLEN = 2000);

Property URL As %String(MAXLEN = 1000);

Property Resumen As %String(MAXLEN = 2000);

Property TituloVectorizado As %Vector(DATATYPE = "DECIMAL", LEN = 384);

Property Contratante As %String(MAXLEN = 2000);

Property URLContratante As %String(MAXLEN = 2000);

Property ValorEstimado As %Numeric(STORAGEDEFAULT = "columnar");

Property ImporteTotal As %Numeric(STORAGEDEFAULT = "columnar");

Property ImporteTotalSinImpuestos As %Numeric(STORAGEDEFAULT = "columnar");

Property Estado As %String;

Property Clasificacion As %String(MAXLEN = 10);

Property Localizacion As %String(MAXLEN = 200);

Property FechaLimite As %Date;

Property HoraLimite As %String(MAXLEN = 8);

Property Actualizado As %Date;

Index IndexContratantePub On Contratante;

Index IndexClasificacionPub On Clasificacion;

Index IndexLocalizacionPub On Localizacion;

Index IndexIdLicitationPub On IdLicitacion [ PrimaryKey ];

Index IndexTituloPub On (Titulo) As %iFind.Index.Basic(INDEXOPTION = 0, LANGUAGE = "es");

Index IndexFechaLimitePub On FechaLimite;

Storage Default
{
<Data name="LicitacionPubDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>IdLicitacion</Value>
</Value>
<Value name="3">
<Value>Titulo</Value>
</Value>
<Value name="4">
<Value>URL</Value>
</Value>
<Value name="5">
<Value>Resumen</Value>
</Value>
<Value name="6">
<Value>TituloVectorizado</Value>
</Value>
<Value name="7">
<Value>Contratante</Value>
</Value>
<Value name="8">
<Value>URLContratante</Value>
</Value>
<Value name="9">
<Value>Estado</Value>
</Value>
<Value name="10">
<Value>Clasificacion</Value>
</Value>
<Value name="11">
<Value>Localizacion</Value>
</Value>
<Value name="12">
<Value>FechaLimite</Value>
</Value>
<Value name="13">
<Value>HoraLimite</Value>
</Value>
<Value name="14">
<Value>Actualizado</Value>
</Value>
</Data>
<Data name="_CDM_ImporteTotal">
<Attribute>ImporteTotal</Attribute>
<Structure>vector</Structure>
</Data>
<Data name="_CDM_ImporteTotalSinImpuestos">
<Attribute>ImporteTotalSinImpuestos</Attribute>
<Structure>vector</Structure>
</Data>
<Data name="_CDM_ValorEstimado">
<Attribute>ValorEstimado</Attribute>
<Structure>vector</Structure>
</Data>
<DataLocation>^Inquisidor.O55B6.LicitacionPubD</DataLocation>
<DefaultData>LicitacionPubDefaultData</DefaultData>
<IdLocation>^Inquisidor.O55B6.LicitacionPubD</IdLocation>
<IndexLocation>^Inquisidor.O55B6.LicitacionPubI</IndexLocation>
<StreamLocation>^Inquisidor.O55B6.LicitacionPubS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
