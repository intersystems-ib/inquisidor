Class Inquisidor.Message.LicitacionResponse Extends Ens.Response
{

/// Description
Property LicitacionesTratadas As %Integer;

Property FechaDeTratamiento As %Date [ InitialExpression = {+$h} ];

Storage Default
{
<Data name="LicitacionResponseDefaultData">
<Subscript>"LicitacionResponse"</Subscript>
<Value name="1">
<Value>LicitacionesTratadas</Value>
</Value>
<Value name="2">
<Value>FechaDeTratamiento</Value>
</Value>
</Data>
<DefaultData>LicitacionResponseDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
