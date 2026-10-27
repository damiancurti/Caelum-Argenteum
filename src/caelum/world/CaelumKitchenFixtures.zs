// #410: el fregadero comparte la reserva de la mansión. La alacena conserva
// el inventario, cerraduras, permisos y límites nativos del cofre pequeño.
class CaelumKitchenSink : CaelumDomesticSink
{
    Default {Tag "$CA_KITCHEN_SINK";}
}
class CaelumKitchenCupboardClosedVisual : CaelumStashChestVisual
{States {Spawn:CKCB A -1;Stop;}}
class CaelumKitchenCupboardOpenVisual : CaelumStashChestVisual
{States {Spawn:CKCB B -1;Stop;}}
class CaelumKitchenCupboardLockedVisual : CaelumStashChestVisual
{States {Spawn:CKCB C -1;Stop;}}
class CaelumKitchenCupboard : CaelumStashChest
{
    override bool CanCarryAsStorage(){return false;}
    override bool CanReachStorage(CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || user.health<=0 || user.CreationWizardOpen)return false;
        // Un mueble elevado se alcanza desde la vista, no desde los pies.
        vector3 eye=user.Pos+(0,0,user.ViewHeight);
        return (eye-(Pos+(0,0,Height/2))).Length()<=user.UseRange+Radius && user.CheckSight(self);
    }
    override double EmptyStorageWeight(){return CaelumKitchenFixtureData.CUPBOARD_KG;}
    override double StorageVisualScale(){return 1;}
    override String StorageVisualClass()
    {return IsChestLocked()?"CaelumKitchenCupboardLockedVisual":ChestOpen?"CaelumKitchenCupboardOpenVisual":"CaelumKitchenCupboardClosedVisual";}
    override void PostBeginPlay()
    {
        args[4]=CaelumContainerRules.SMALL+1;Super.PostBeginPlay();
        A_SetSize(CaelumKitchenFixtureData.CUPBOARD_RADIUS,CaelumKitchenFixtureData.CUPBOARD_HEIGHT,false);
    }
    Default {+NOGRAVITY +CANPASS Tag "$CA_KITCHEN_CUPBOARD";}
}
class CaelumMansionKitchenFixtures : Object play
{
    static bool Prepare()
    {
        if(level.MapName!="MAP01")return true;
        bool ready=true;
        for(int id=0;id<2;id++)
        {
            Vector3 position=id==0?CaelumKitchenFixtureData.SinkPosition():CaelumKitchenFixtureData.CupboardPosition();
            let it=BlockThingsIterator.CreateFromPos(position.X,position.Y,position.Z,64,64,false);
            bool found=false;
            while(it.Next())
                if((id==0?it.thing is 'CaelumKitchenSink':it.thing is 'CaelumKitchenCupboard')
                    && (it.thing.Pos-position).Length()<1){found=true;break;}
            if(found)continue;
            let fixture=Actor.Spawn(id==0?'CaelumKitchenSink':'CaelumKitchenCupboard',position,NO_REPLACE);
            if(fixture==null){ready=false;continue;}
            fixture.Angle=id==0?CaelumKitchenFixtureData.SINK_FACING:CaelumKitchenFixtureData.CUPBOARD_FACING;
            if(id==0)fixture.A_SetSize(CaelumDomesticFixtureData.Radius(0),CaelumDomesticFixtureData.Height(0),false);
            else fixture.A_SetSize(CaelumKitchenFixtureData.CUPBOARD_RADIUS,CaelumKitchenFixtureData.CUPBOARD_HEIGHT,false);
            if(!fixture.TestMobjLocation() || (id==0 && Abs(fixture.FloorZ-position.Z)>1))
            {fixture.Destroy();ready=false;continue;}
            let sink=CaelumKitchenSink(fixture);
            if(sink!=null){sink.House=CaelumDomesticWaterData.MANSION;sink.Installed=true;}
        }
        return ready;
    }
}
