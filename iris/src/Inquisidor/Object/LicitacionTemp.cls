Class Inquisidor.Object.LicitacionTemp Extends (%Persistent, %XML.Adaptor) [ DdlAllowed ]
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

Property FechaAdjudicacion As %Date;

Property Estado As %String;

Property Ganador As %String(MAXLEN = 200);

Property GanadorNIF As %String(MAXLEN = 200);

Property ImporteGanador As %Numeric(STORAGEDEFAULT = "columnar");

Property ImporteGanadorSinImpuestos As %Numeric(STORAGEDEFAULT = "columnar");

Property Clasificacion As %String(MAXLEN = 10);

Property Localizacion As %String(MAXLEN = 200);

Property Anio As %Integer;

Index IndexContratante On Contratante;

Index IndexGanador On Ganador;

Index IndexGanadorNIF On GanadorNIF;

Index IndexClasificacion On Clasificacion;

Index IndexLocalizacion On Localizacion;

Index IndexIdLicitation On IdLicitacion [ PrimaryKey ];

Index IndexAnio On Anio;

Storage Default
{
<Data name="LicitacionTempDefaultData">
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
<Value>FechaAdjudicacion</Value>
</Value>
<Value name="10">
<Value>Estado</Value>
</Value>
<Value name="11">
<Value>Ganador</Value>
</Value>
<Value name="12">
<Value>GanadorNIF</Value>
</Value>
<Value name="13">
<Value>Clasificacion</Value>
</Value>
<Value name="14">
<Value>Localizacion</Value>
</Value>
<Value name="15">
<Value>Anio</Value>
</Value>
</Data>
<Data name="_CDM_ImporteGanador">
<Attribute>ImporteGanador</Attribute>
<Structure>vector</Structure>
</Data>
<Data name="_CDM_ImporteGanadorSinImpuestos">
<Attribute>ImporteGanadorSinImpuestos</Attribute>
<Structure>vector</Structure>
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
<DataLocation>^Inquisidor55B6.LicitacionTempD</DataLocation>
<DefaultData>LicitacionTempDefaultData</DefaultData>
<IdLocation>^Inquisidor55B6.LicitacionTempD</IdLocation>
<IndexLocation>^Inquisidor55B6.LicitacionTempI</IndexLocation>
<StreamLocation>^Inquisidor55B6.LicitacionTempS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
