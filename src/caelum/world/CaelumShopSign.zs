// El rubro se deriva del mismo índice que el comerciante, sin inventario ni Tick.
class CaelumShopSign : CaelumPhysicalScenery
{
    void RefreshCategory()
    {frame=level.MapName=="MAP03" ? CaelumShopCatalogue.SignCategory(Pos,args[0]) : args[0];}
    override void PostBeginPlay(){Super.PostBeginPlay();RefreshCategory();}
    static void RefreshAuthored()
    {
        // Migración al preparar/cargar ciudad: sólo los 64 carteles tipados,
        // sin Tick propio ni búsqueda global por comprador/combatiente.
        if(level.MapName!="MAP03")return;
        let it=ThinkerIterator.Create("CaelumShopSign");CaelumShopSign sign;
        while((sign=CaelumShopSign(it.Next()))!=null)sign.RefreshCategory();
    }
    Default { +NOINTERACTION +NOGRAVITY +WALLSPRITE Scale 0.25; RenderRadius 128; }
    States { Spawn: CSSG A -1; Stop; }
}
