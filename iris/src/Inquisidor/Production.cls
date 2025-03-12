Class Inquisidor.Production Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="Inquisidor.Production" TestingEnabled="true" LogGeneralTraceEvents="true">
  <Description></Description>
  <ActorPoolSize>2</ActorPoolSize>
  <Item Name="Inquisidor.BP.XMLToLicitacion" Category="" ClassName="Inquisidor.BP.XMLToLicitacion" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="Inquisidor.BP.XMLToLicitacionByOS" Category="" ClassName="Inquisidor.BP.XMLToLicitacionByOS" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
  </Item>
  <Item Name="Licitaciones_IN" Category="" ClassName="EnsLib.File.PassthroughService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="TargetConfigNames">Inquisidor.BP.XMLToLicitacion</Setting>
    <Setting Target="Adapter" Name="FilePath">/iris-shared/in/</Setting>
    <Setting Target="Adapter" Name="FileSpec">*.atom</Setting>
  </Item>
  <Item Name="Licitaciones_INOS" Category="" ClassName="EnsLib.File.PassthroughService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="TargetConfigNames">Inquisidor.BP.XMLToLicitacionByOS</Setting>
    <Setting Target="Adapter" Name="FilePath">/iris-shared/inOS/</Setting>
    <Setting Target="Adapter" Name="FileSpec">*.atom</Setting>
  </Item>
</Production>
}

}
