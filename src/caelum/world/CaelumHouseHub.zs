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
        // Migración única al preparar/cargar; no depende del próximo turno
        // del trabajador ni cambia el contenido de los cofres existentes.
        let events=CaelumHouseHubEvents(EventHandler.Find('CaelumHouseHubEvents'));
        if(events!=null && events.Housekeeping!=null && events.Housekeeping.Initialized
            && events.Housekeeping.Chest!=null && events.Housekeeping.Chest.DomesticStorage==null)
        {CaelumHouseStorage.Register(events.Housekeeping.Chest,house);}
        CaelumHouseStorage.RestoreCurrent();
        int slot=CaelumCityData.FURNITURE_SLOT_BASE+house;
        bool ready=CaelumDiningWorld.Place(slot,CaelumCityData.TablePosition(house),2,90);
        if(!CaelumMansionFurniture.Bed(slot,CaelumCityData.BedPosition(house),90))ready=false;
        if(!CaelumHouseChestRules.Prepare())ready=false;
        if(!CaelumBathroomInstallation.Prepare(house))ready=false;
        if(ready && events!=null && events.Housekeeping!=null && events.Housekeeping.Chest!=null)
        {
            let entry=events.Housekeeping.Chest.DomesticStorage;
            if(entry!=null)entry.RestoreFurnishings(events.Housekeeping,CaelumPlayer(roster.Owner));
        }
        return ready;
    }
}

class CaelumHouseHubEvents : EventHandler
{
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca_clean_open" && e.Player>=0 && e.Player<MAXPLAYERS && playeringame[e.Player])
        {CaelumCleaningSession.Show(CaelumPlayer(players[e.Player].mo));return;}
        if(e.Name=="ca_clean_action" && e.Player>=0 && e.Player<MAXPLAYERS && playeringame[e.Player])
        {let user=CaelumPlayer(players[e.Player].mo);let session=CaelumCleaningSession.Find(user);if(session!=null)session.Act(user,e.Args[0]);return;}
        if(e.Name=="ca_bath_open" && e.Player>=0 && e.Player<MAXPLAYERS && playeringame[e.Player])
        {CaelumBathSession.Show(CaelumPlayer(players[e.Player].mo));return;}
        if(e.Name=="ca_bath_action" && e.Player>=0 && e.Player<MAXPLAYERS && playeringame[e.Player])
        {let user=CaelumPlayer(players[e.Player].mo);let bath=CaelumBathSession.Find(user);if(bath!=null)bath.Act(user,e.Args[0]);return;}
        if(e.Name!="ca_property_action" || e.Player<0 || e.Player>=MAXPLAYERS || !playeringame[e.Player])return;
        let session=CaelumPropertySession.Get(CaelumPlayer(players[e.Player].mo));
        if(session!=null)session.Act(e.Args[0]);
    }
    bool Prepared;
    transient bool BathroomReady;
    transient bool MarketReady;
    int NextPrepareTic;
    CaelumHousekeepingWork Housekeeping;
    override void WorldUnloaded(WorldEvent e)
    {
        if(Housekeeping==null || Housekeeping.Chest==null)return;
        CaelumHouseStorage.Register(Housekeeping.Chest,Housekeeping.House);
        let entry=Housekeeping.Chest.DomesticStorage;
        if(entry!=null)
        {
            entry.CaptureProgress(Housekeeping);
            let store=CaelumHouseStorage.Get();
            if(store!=null)entry.CaptureFurnishings(Housekeeping,CaelumPlayer(store.Owner));
        }
    }
    override void WorldLoaded(WorldEvent e)
    {
        Prepared=false;BathroomReady=false;MarketReady=false;NextPrepareTic=0;
        if(Housekeeping!=null)Housekeeping.ClockReady=false;
    }
    override void WorldTick()
    {
        // Travelled debe retirar los viajeros del estado nativo antes de
        // restaurarlos; la migración acotada sólo se hace una vez por carga.
        if(!MarketReady && level.MapName=="MAP03" && CaelumHouseResidents.Get()!=null)
        {CaelumDomesticMarket.RebindLoaded();MarketReady=true;}
        // Un guardado anterior puede restaurar Prepared=true. Esta comprobación
        // transitoria revalida la instalación aditiva al cargar, sin duplicarla.
        if((!Prepared || !BathroomReady) && level.time>=NextPrepareTic)
        {
            Prepared=CaelumHouseHub.Prepare();BathroomReady=Prepared;NextPrepareTic=level.time+TICRATE;
            // Los muebles recién creados reciben PostBeginPlay/enlace nativo
            // al terminar el tic antes de censar el interior para limpiarlo.
            return;
        }
        if(Prepared && CaelumHouseHubData.HouseForMap(level.MapName)>=0)
        {
            if(Housekeeping==null)Housekeeping=new('CaelumHousekeepingWork');
            Housekeeping.Tick();
        }
    }
}

// #382: un alta por vivienda, incluso si el cofre sale del mapa o se destruye.
class CaelumHouseChestRules : Object play
{
    const GOLD_COINS=10;
    static bool Prepare()
    {
        int house=CaelumHouseHubData.HouseForMap(level.MapName);
        if(house<0)return true;
        let roster=CaelumHouseResidents.Get(true);if(roster==null)return false;
        if(house==CaelumPropertyData.CENTRAL_HOUSE)return roster.RelocatePropertyChest();
        bool ready=PrepareFor(house,CaelumCityData.ChestPosition(house));
        if(house==CaelumPropertyData.RELOCATION_HOUSE)
        {
            if(!roster.PlaceRelocatedChest())ready=false;
            if(!PrepareFor(CaelumPropertyData.CENTRAL_HOUSE,CaelumPropertyData.RelocatedChestPosition()))ready=false;
        }
        return ready;
    }
    static bool PrepareFor(int house,vector3 point)
    {
        let roster=CaelumHouseResidents.Get(true);
        if(roster!=null && roster.HouseChestIssued[house])return true;
        if(roster==null || !roster.Ready)return false;
        CaelumPortDefender resident=null;
        for(int i=house;i<roster.Residents.Size();i+=CaelumCityData.HOUSE_COUNT)
            if(roster.Residents[i].Body!=null){resident=roster.Residents[i].Body;break;}
        let chest=CaelumStashChest(Actor.Spawn("CaelumStashChest",point,NO_REPLACE));
        if(chest==null)return false;
        chest.EnsureStorage();chest.StorageTier=CaelumContainerRules.SMALL;chest.ApplyStorageSize();
        // Una posición ocupada no consume el alta ni crea llaves/botín huérfanos.
        if(!chest.TestMobjLocation()){chest.Destroy();return false;}
        let pair=new("CaelumLockIdentity");
        let padlock=CaelumLockRules.Create(CaelumContainerRules.SMALL,point,pair);
        CaelumLockItem key=null;
        if(resident!=null)key=CaelumLockRules.Create(CaelumContainerRules.SMALL+3,point,pair);
        let coins=Inventory(Actor.Spawn(CaelumEconomyRules.GetCurrencyClassName(CaelumConstants.CURRENCY_GOLD),point,NO_REPLACE));
        if(padlock==null || (resident!=null && key==null) || coins==null)
        {
            if(padlock!=null)padlock.Destroy();if(key!=null)key.Destroy();if(coins!=null)coins.Destroy();
            chest.Destroy();return false;
        }
        chest.LawfulOwner=new("CaelumLawfulIdentity");
        chest.LawfulOwner.Token="house:"..CaelumHouseHubData.MapName(house);
        padlock.AttachToOwner(chest);chest.InstalledPadlock=padlock;chest.bShootable=true;
        coins.Amount=GOLD_COINS;coins.AttachToOwner(chest);
        if(key!=null)key.AttachToOwner(resident);
        chest.RefreshChestVisual();
        roster.HouseChestIssued[house]=true;
        return true;
    }
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
        if(CaelumPropertyData.Offered(args[0]))
        {
            if(!CaelumPropertySession.Open(user,self))return false;
        }
        else
        {
            let audio=CaelumMenuAudio(StaticEventHandler.Find("CaelumMenuAudio"));
            if(audio==null || !audio.RequestHouseDoor(user,self))return false;
        }
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
