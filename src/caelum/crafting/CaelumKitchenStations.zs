// #410: estaciones de calor y recipiente fijo de leudado. Comparten la red
// nativa, pero no exigen un banco de carpintería para preparar comida.
class CaelumKitchenStation : CaelumCraftingStation abstract
{
    virtual int KitchenKind(){return 0;}
    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        A_SetSize(CaelumKitchenFurnitureData.Radius(KitchenKind()),CaelumKitchenFurnitureData.Height(KitchenKind()),false);
        Scale=(1,1);Mass=CaelumKitchenFurnitureData.MassKg(KitchenKind());
    }
}
class CaelumKitchenStoveStation : CaelumKitchenStation
{
    Default {Tag "$CA_KITCHEN_STOVE"; +SOLID}
    override int GetCraftingStationType(){return CaelumConstants.CRAFTING_STATION_STOVE;}
    States {Spawn: CKSV A -1;Stop;}
}
class CaelumKitchenOvenStation : CaelumKitchenStation
{
    Default {Tag "$CA_KITCHEN_OVEN"; +SOLID}
    override int GetCraftingStationType(){return CaelumConstants.CRAFTING_STATION_OVEN;}
    override int KitchenKind(){return 1;}
    States {Spawn: CKOV A -1;Stop;}
}
class CaelumKitchenCounterStation : CaelumKitchenStation
{
    CaelumProofingBatch Batch;
    double MenuNow;
    int MenuRefreshTic;
    Default {Tag "$CA_KITCHEN_COUNTER"; +SOLID}
    override int GetCraftingStationType(){return CaelumConstants.CRAFTING_STATION_COUNTER;}
    override int KitchenKind(){return 2;}
    States {Spawn: CKCT A -1;Stop;}
}

class CaelumMansionKitchen : Object play
{
    static bool Prepare()
    {
        if(level.MapName!="MAP01")return true;
        bool ready=true;
        for(int id=0;id<CaelumKitchenFurnitureData.COUNT;id++)
        {
            Vector3 position=CaelumKitchenFurnitureData.Position(id);
            let it=BlockThingsIterator.CreateFromPos(position.X,position.Y,position.Z,64,64,false);
            bool found=false;
            while(it.Next())
            {
                let item=CaelumKitchenStation(it.thing);
                if(item!=null && item.KitchenKind()==id && (item.Pos-position).Length()<1){found=true;break;}
            }
            if(found)continue;
            let station=CaelumKitchenStation(Actor.Spawn(CaelumKitchenFurnitureData.ActorClass(id),position,NO_REPLACE));
            if(station==null){ready=false;continue;}
            station.Angle=CaelumKitchenFurnitureData.Facing(id);station.CraftingRoomGroup=410;
            if(!station.TestMobjLocation() || Abs(station.FloorZ-position.Z)>1)
            {station.Destroy();ready=false;}
        }
        return ready;
    }
}
