// #581: cuatro instancias autorales viajan con su dueño de registro. El mapa
// nativo no cambia: también sirve para partidas con la ciudad ya visitada.
class CaelumArrivalHouseholdEntry : Object play
{
    Actor Body;
    int Index,OriginalTID;
    bool Parked,Invisible,Solid,Shootable,NoInteraction,NoBlock,NoSector;
    vector3 Position;
    double Facing;

    bool Busy()
    {
        let bed=CaelumRestFurniture(Body);
        if(bed!=null && bed.Occupant!=null)return true;
        for(int p=0;p<MAXPLAYERS;p++)
            if(playeringame[p])
            {let user=CaelumPlayer(players[p].mo);if(user!=null && user.CraftingTaskActive && user.ActiveCraftingStationActor==Body)return true;}
        return false;
    }
    void Park()
    {
        if(Parked || Body==null || Body.bDestroyed)return;
        CaelumContaminationObject.LeavingWorld(Body);
        let dirt=CaelumContaminationStorage.Get(Body);if(dirt!=null)dirt.Contacts=null;
        Invisible=Body.bInvisible;Solid=Body.bSolid;Shootable=Body.bShootable;
        NoInteraction=Body.bNoInteraction;NoBlock=Body.bNoBlockmap;NoSector=Body.bNoSector;
        OriginalTID=Body.TID;Body.ChangeTID(0);
        Body.bInvisible=true;Body.bSolid=false;Body.bShootable=false;Body.bNoInteraction=true;
        Body.A_ChangeLinkFlags(1,1);Body.Vel=(0,0,0);Body.A_StopAllSounds();
        Body.ChangeStatNum(CaelumHouseResidents.PARKED_STAT);
        for(Inventory item=Body.Inv;item!=null;item=item.Inv)item.ChangeStatNum(CaelumHouseResidents.PARKED_STAT);
        Parked=true;
    }
    bool Place()
    {
        if(!Parked || Body==null || Body.bDestroyed)return true;
        let probe=Actor.Spawn('CaelumSummoningProbe',Position,NO_REPLACE);
        probe.A_SetSize(Body.Radius,Body.Height);
        bool fits=probe.TestMobjLocation() && Abs(probe.FloorZ-Position.Z)<=1;
        probe.Destroy();if(!fits)return false;
        Body.SetOrigin(Position,false);Body.FindFloorCeiling();Body.ClearInterpolation();Body.Angle=Facing;
        Body.bInvisible=Invisible;Body.bSolid=Solid;Body.bShootable=Shootable;Body.bNoInteraction=NoInteraction;
        Body.A_ChangeLinkFlags(NoBlock,NoSector);Body.ChangeTID(OriginalTID);Body.ChangeStatNum(Thinker.STAT_DEFAULT);
        for(Inventory item=Body.Inv;item!=null;item=item.Inv)
        {item.SetOrigin(Position,false);item.FindFloorCeiling();item.ChangeStatNum(Thinker.STAT_INVENTORY);}
        let station=CaelumCraftingStation(Body);
        if(station!=null){station.LastCraftingNetworkScanToken=0;station.LastCraftingNetworkScanPlayer=null;}
        CaelumContaminationObject.Register(Body);Parked=false;return true;
    }
}

class CaelumArrivalHousehold : Inventory
{
    int Revision;
    Array<CaelumArrivalHouseholdEntry> Entries;
    transient bool PlacementPending;
    transient int NextPlacement;

    static CaelumArrivalHousehold Get(bool create=false)
    {
        CaelumPlayer first=null;
        for(int p=0;p<MAXPLAYERS;p++)if(playeringame[p])
        {
            let user=CaelumPlayer(players[p].mo);if(user==null)continue;
            if(first==null)first=user;
            let found=CaelumArrivalHousehold(user.FindInventory('CaelumArrivalHousehold'));
            if(found!=null)return found;
        }
        return create && first!=null?CaelumArrivalHousehold(first.GiveInventoryType('CaelumArrivalHousehold')):null;
    }
    static Actor Original(int index)
    {
        vector3 point=CaelumArrivalHouseholdData.Origin(index);
        // Cuatro consultas locales durante instalación/carga, no censo global.
        let it=BlockThingsIterator.CreateFromPos(point.X,point.Y,point.Z,128,1,false);
        while(it.Next())if(it.thing.GetClassName()==CaelumArrivalHouseholdData.Kind(index)
            && (it.thing.Pos-point).Length()<1)return it.thing;
        return null;
    }
    void MoveBatch(CaelumFermentationStation barrel,vector3 destination)
    {
        let user=CaelumPlayer(Owner);CaelumFermentationService.Bind(user,barrel);
        for(int p=0;p<MAXPLAYERS;p++)if(playeringame[p])
        {
            let other=CaelumPlayer(players[p].mo);let record=other!=null?other.GetPersistentCharacterState(false):null;
            if(record==null)continue;
            for(int i=0;i<record.FermentationBatches.Size();i++)
            {
                let row=record.FermentationBatches[i];
                if(row.MapName!=level.MapName || row.Position!=barrel.Pos)continue;
                row.MapName=CaelumHouseHubData.MapName(CaelumArrivalHouseholdData.HOUSE);row.Position=destination;
            }
        }
    }
    bool Capture()
    {
        if(level.MapName!=CaelumArrivalHouseholdData.SourceMap())return true;
        // Esperar a los instaladores anteriores para conservar su misma alta.
        let chemistry=CaelumAlchemyEvents(StaticEventHandler.Find('CaelumAlchemyEvents'));
        let ferment=CaelumFermentationEvents(StaticEventHandler.Find('CaelumFermentationEvents'));
        if(chemistry==null || chemistry.Roster==null || !chemistry.Roster.Issued
            || ferment==null || ferment.Roster==null || !ferment.Roster.Issued)return false;
        for(int i=0;i<CaelumArrivalHouseholdData.COUNT;i++)
        {
            let body=Original(i);if(body==null)continue;
            if(Revision>=CaelumArrivalHouseholdData.REVISION)
            {
                // Un mapa reconstruido puede volver a emitir el thing original.
                // Las instancias trasladadas están aparcadas y fuera del blockmap.
                body.Destroy();continue;
            }
            let row=new('CaelumArrivalHouseholdEntry');row.Body=body;row.Index=i;
            if(row.Busy())return false;
        }
        if(Revision>=CaelumArrivalHouseholdData.REVISION)return true;
        for(int i=0;i<CaelumArrivalHouseholdData.COUNT;i++)
        {
            let body=Original(i);if(body==null)continue;
            let row=new('CaelumArrivalHouseholdEntry');row.Body=body;row.Index=i;
            row.Position=CaelumCityData.HouseOrigin(CaelumArrivalHouseholdData.HOUSE)+CaelumArrivalHouseholdData.Offset(i);
            row.Facing=CaelumArrivalHouseholdData.Facing(i);
            let barrel=CaelumFermentationStation(body);if(barrel!=null)MoveBatch(barrel,row.Position);
            row.Park();Entries.Push(row);
        }
        Revision=CaelumArrivalHouseholdData.REVISION;return true;
    }
    static bool Prepare()
    {
        bool source=level.MapName==CaelumArrivalHouseholdData.SourceMap();
        let store=Get(source);if(store==null)return !source;
        if(!store.Capture())return false;
        store.PlacementPending=level.MapName==CaelumHouseHubData.MapName(CaelumArrivalHouseholdData.HOUSE);
        store.PlaceAll();return true;
    }
    void PlaceAll()
    {
        if(!PlacementPending)return;
        PlacementPending=false;
        for(int i=0;i<Entries.Size();i++)if(!Entries[i].Place())PlacementPending=true;
        NextPlacement=level.time+TICRATE;
    }
    override void Tick()
    {Super.Tick();if(PlacementPending && level.time>=NextPlacement)PlaceAll();}
    override void PreTravelled()
    {
        for(int i=0;i<Entries.Size();i++)
        {
            let row=Entries[i];let body=row.Body;if(body==null || body.bDestroyed)continue;
            if(!row.Parked){row.Position=body.Pos;row.Facing=body.Angle;row.Park();}
            body.ChangeStatNum(STAT_TRAVELLING);
            for(Inventory item=body.Inv;item!=null;item=item.Inv)
            {item.UnlinkFromWorld();item.ChangeStatNum(STAT_TRAVELLING);}
        }
    }
    override void Travelled()
    {
        for(int i=0;i<Entries.Size();i++)
        {
            let body=Entries[i].Body;if(body==null || body.bDestroyed)continue;
            body.ChangeStatNum(CaelumHouseResidents.PARKED_STAT);body.SetOrigin(Owner.Pos,false);body.FindFloorCeiling();
            for(Inventory item=body.Inv;item!=null;item=item.Inv)
            {item.ChangeStatNum(CaelumHouseResidents.PARKED_STAT);item.SetOrigin(Owner.Pos,false);item.FindFloorCeiling();}
        }
        PlacementPending=level.MapName==CaelumHouseHubData.MapName(CaelumArrivalHouseholdData.HOUSE);
        PlaceAll();
    }
    Default { Inventory.MaxAmount 1; Inventory.InterHubAmount 1; +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE }
    States { Spawn: TNT1 A -1; Stop; }
}
