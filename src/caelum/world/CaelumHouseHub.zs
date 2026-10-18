// Las fachadas mantienen colisión geométrica; Use cambia al interior del hub.
class CaelumHouseHub : Object play
{
    static bool IsCity(CaelumPortSiege port=null)
    {
        if(level.MapName!="MAP03")return false;
        if(port==null)port=CaelumPortSiege.Get();
        return port!=null && port.args[3]==1;
    }

    static bool Prepare()
    {
        int house=CaelumHouseHubData.HouseForMap(level.MapName);
        if(house<0)return true;
        let roster=CaelumHouseResidents.Get(true);if(roster==null)return false;
        int slot=CaelumCityData.FURNITURE_SLOT_BASE+house;
        bool ready=CaelumDiningWorld.Place(slot,CaelumCityData.TablePosition(house),2,90);
        if(!CaelumMansionFurniture.Bed(slot,CaelumCityData.BedPosition(house),90))ready=false;
        return ready;
    }
}

class CaelumHouseHubEvents : EventHandler
{
    bool Prepared;
    override void WorldLoaded(WorldEvent e){Prepared=false;}
    override void WorldTick(){if(!Prepared)Prepared=CaelumHouseHub.Prepare();}
}

class CaelumHouseMarker : Actor
{
    Default { +NOINTERACTION +NOSECTOR +NOBLOCKMAP +NOGRAVITY }
    States { Spawn: TNT1 A -1; Stop; }
}

class CaelumHouseDoorVisual : Actor
{
    Default { +NOINTERACTION +NOGRAVITY }
    States { Spawn: CDLS A -1; Stop; }
}

class CaelumHousePortal : Actor
{
    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        for(int side=-1;side<=1;side+=2)
        {
            let leaf=Spawn("CaelumHouseDoorVisual",Pos+(0,side*CaelumMansionDoorData.HALF_WIDTH,0),NO_REPLACE);
            leaf.Angle=side<0?90:270;
        }
    }
    override bool Used(Actor activator)
    {
        let user=CaelumPlayer(activator);
        if(user==null || user.player==null || user.health<=0 || !user.CharacterCreationComplete
            || user.FolkloreInteractionUseLatched || !CaelumUseGeometry.AimedAt(user,self))return false;
        let roster=CaelumHouseResidents.Get(true);if(roster==null)return false;
        let audio=CaelumMenuAudio(StaticEventHandler.Find("CaelumMenuAudio"));
        if(audio==null || !audio.RequestHouseDoor(user,self))return false;
        user.FolkloreInteractionUseLatched=true;
        user.FolkloreInteractionReleaseGuardTics=0;
        return true;
    }
    bool CompleteTravel(CaelumPlayer user)
    {
        if(user==null || user.player==null || user.health<=0 || !user.CharacterCreationComplete
            || !CaelumUseGeometry.AimedAt(user,self))return false;
        // Sólo el ACK de la captura vigente puede confirmar este viaje.
        user.PendingTravelWipe=CaelumConstants.TRAVEL_WIPE_HOUSE_DOOR;
        Level.ChangeLevel(DestinationMap(),
            args[1]==0?0:args[0]+1,CHANGELEVEL_NOINTERMISSION);
        return true;
    }
    String DestinationMap(){return args[1]==0?CaelumHouseHubData.MapName(args[0]):"MAP03";}
    Default { Radius 20; Height 120; +NOGRAVITY +INVISIBLE }
    States { Spawn: TNT1 A -1; Stop; }
}
