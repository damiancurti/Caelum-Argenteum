// El rubro se deriva del mismo índice que el comerciante, sin inventario ni Tick.
class CaelumShopSign : Actor
{
    override void PostBeginPlay(){Super.PostBeginPlay();frame=args[0];}
    Default { +NOINTERACTION +NOGRAVITY +WALLSPRITE Scale 0.25; RenderRadius 128; }
    States { Spawn: CSSG A -1; Stop; }
}
