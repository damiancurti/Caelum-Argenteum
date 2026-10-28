class CA502SealChecks : CA502WeatherChecks
{
    CaelumChannelEffect Channel;
    bool SealDepartureObserved;
    void BeginSeal(CaelumPlayer u,int kind)
    {
        u.StopSealChannel(false,false);
        let seal=u.GetEquippedSeal();if(seal==null)seal=CaelumEquipmentItem(u.GiveInventoryType('CaelumSealPickup'));
        seal.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_SEAL;seal.ItemType=kind;seal.Tier=1;seal.Equipped=true;seal.InMagicBox=false;
        u.CombatChannelSealType=kind;u.CombatChannelSealTier=1;u.CombatChannelAdrenalinePerTic=0;u.CurrentAdrenaline=1000;
        Channel=CaelumChannelEffect(Actor.Spawn('CaelumChannelEffect',u.Pos,NO_REPLACE));Channel.ConfigureChannel(u,seal,1024);
        Channel.ClimateTotal=10;
        u.CombatChannelEffectActor=Channel;u.CombatChannelModeActive=true;
    }
    void Seals(CaelumPlayer u)
    {
        let stored=CaelumContaminationStorage.Get(Probe,true);let n=stored.Exposure;n.Advance();
        double natural=n.HistoryAmbient;Check(n.HistoryVariable && !n.HistoryTemporaryClimate,"natural history starts without temporary channel");
        BeginSeal(u,CaelumConstants.SEAL_FIRE);n.Advance();
        Check(CaelumSealClimate.Active(Channel) && n.HistoryReady && n.HistoryTemporaryClimate && !n.HistoryVariable,"real fire channel records bounded temporary interval");
        Check(n.HistoryAmbient>natural,"fire channel affects actual object ambient");
        Check(!CaelumSealClimate.ClearPath(Channel,Probe) && CaelumSealClimate.ClearPath(Channel,Probe,true),"surface sample skips only the receiving object without changing default trace");
        let wall=Actor.Spawn('CA502WeatherProp',(u.Pos+Probe.Pos)*.5,NO_REPLACE);wall.A_SetSize(32,128,false);
        Check(!CaelumSealClimate.ClearPath(Channel,Probe,true),"intervening solid still blocks seal surface exposure");wall.Destroy();
        double now=n.Stamp;n.HistoryStamp=now-5;stored.Concentration=0;
        double expected=CaelumContaminationObjectBalance.Evolve(0,n.HistoryAmbient,n.HistoryRain,n.HistoryArea,5);
        n.Advance();Check(Near(stored.Concentration,expected),"loaded temporary interval is charged before its next sample");
        n.Advance();Check(Near(stored.Concentration,expected),"same timestamp never reapplies channel exposure");
        u.StopSealChannel(false,false);n.Advance();
        Check(!n.HistoryTemporaryClimate && n.HistoryVariable && Near(n.HistoryAmbient,natural),"ending a channel restores natural history");
        BeginSeal(u,CaelumConstants.SEAL_WATER);n.Advance();
        Check(n.HistoryTemporaryClimate && n.HistoryReady && n.HistoryAmbient>=natural,"water channel also records temporary humidity");
        n.HistoryStamp=now-60;n.HistoryAmbient=5;n.HistoryRain=10;n.HistoryArea=.04;stored.Concentration=90;
        expected=CaelumContaminationObjectBalance.Evolve(90,5,10,.04,60);
        n.Ready=false;n.Advance();Check(Near(stored.Concentration,expected) && expected<90,"saved temporary interval preserves simultaneous rain wash");
        CaelumContaminationWorld.Get().DepartObjects();
        Check(!n.HistoryTemporaryClimate && n.HistoryVariable && Near(n.HistoryAmbient,natural),"departure replaces active channel with base regional climate");
        Check(CaelumSealClimate.Active(Channel),"departure does not need to terminate channel before sampling base climate");
        double settled=stored.Concentration;CaelumContaminationWorld.Get().DepartObjects();
        Check(Near(stored.Concentration,settled),"repeated departure is idempotent");
        n.Revision=3;n.HistoryReady=false;n.Ready=false;n.HistoryStamp=now-3600;stored.Concentration=37;n.Advance();
        Check(n.Revision==4 && Near(stored.Concentration,37),"legacy unrecorded seal interval starts now without invented exposure");
        u.StopSealChannel(false,false);n.Advance();
    }
    void SealSeed(CaelumPlayer u)
    {
        BeginSeal(u,CaelumConstants.SEAL_FIRE);
        let n=CaelumContaminationStorage.Get(Probe).Exposure;n.Advance();
        CaelumContaminationStorage.Set(Probe,60);Saved=Snapshot(n);SavedArea=n.HistoryArea;
        Check(n.HistoryReady && n.HistoryTemporaryClimate,"save seed has actual active seal history");
    }
    void ObserveDeparture()
    {
        if(Probe==null || Channel==null)return;
        let n=CaelumContaminationStorage.Get(Probe).Exposure;
        Check(!n.HistoryTemporaryClimate && n.HistoryVariable,"native unload callback captures natural history while leaving active seal");
        Saved=Snapshot(n);Saved.Concentration=CaelumContaminationStorage.Value(Probe);SavedArea=n.HistoryArea;
        SealDepartureObserved=true;
    }
    void SealLoad(CaelumPlayer u)
    {
        Check(Probe!=null && Channel!=null && Saved!=null,"save retains actual object and channel identity");
        if(Probe==null || Channel==null)return;
        let n=CaelumContaminationStorage.Get(Probe).Exposure;n.Advance();
        Check(CaelumSealClimate.Active(Channel) && n.HistoryTemporaryClimate && n.Revision==4,"load resumes actual temporary channel history");
        double first=CaelumContaminationStorage.Value(Probe);n.Advance();
        Check(Near(first,CaelumContaminationStorage.Value(Probe)),"repeated load-time sample never duplicates exposure");
        u.StopSealChannel(false,false);n.Advance();Check(n.HistoryVariable && !n.HistoryTemporaryClimate,"saved channel can end normally");
    }
    void BoundaryPerf()
    {
        Array<Actor> props;
        for(int i=0;i<1000;i++)
        {
            let body=Actor.Spawn('CA502WeatherProp',(256,256,0),NO_REPLACE);props.Push(body);
            CaelumContaminationObject.Register(body);
            let n=CaelumContaminationStorage.Get(body,true).Exposure;n.Advance();n.HistoryTemporaryClimate=true;
        }
        double started=MSTimeF();CaelumContaminationWorld.Get().DepartObjects();double elapsed=MSTimeF()-started;
        int remaining=0;for(int i=0;i<props.Size();i++)if(CaelumContaminationStorage.Get(props[i]).Exposure.HistoryTemporaryClimate)remaining++;
        Check(remaining==0,"departure flushes1000 eligible object histories");
        Console.Printf("CA502W TIMING boundary_1000_ms=%.6f",elapsed);
    }
    void LegacySeal()
    {
        Check(Probe!=null && Channel!=null,"actual prior runtime retains object and channel");if(Probe==null)return;
        let stored=CaelumContaminationStorage.Get(Probe);let n=stored.Exposure;
        Check(n.Revision==3 && !n.HistoryReady && Near(stored.Concentration,60),"actual prior seal save contains no invented historical anchor");
        n.ChangeStatNum(Thinker.STAT_DEFAULT);n.Advance();
        Check(n.Revision==4 && n.HistoryReady && Near(stored.Concentration,60),"revision4 migration starts missing interval now and preserves concentration");
        n.Advance();Check(Near(stored.Concentration,60),"repeat migration is idempotent");
    }
    void RainSave(CaelumPlayer u,bool restore)
    {
        let stored=CaelumContaminationStorage.Get(Probe);let n=stored.Exposure;
        if(!restore)
        {
            BeginSeal(u,CaelumConstants.SEAL_FIRE);n.Advance();n.HistoryRain=10;n.HistoryAmbient=5;n.HistoryArea=.04;
            n.ChangeStatNum(Thinker.STAT_FIRST_THINKING-5);stored.Concentration=90;
            Check(n.HistoryTemporaryClimate && n.HistoryRain==10,"rain save records nonzero wash in temporary interval");return;
        }
        Check(n.HistoryRain==10 && n.HistoryTemporaryClimate && Near(stored.Concentration,90),"native save retains nonzero rain and original temporary interval");
        double now=CaelumThermalRuntime.Stamp(CaelumWorldClock.Get(u));n.HistoryStamp=now-60;n.Ready=false;
        double expected=CaelumContaminationObjectBalance.Evolve(90,5,10,.04,60);n.ChangeStatNum(Thinker.STAT_DEFAULT);n.Advance();
        Check(Near(stored.Concentration,expected),"actual restored rain interval applies its saved wash exactly once");
        n.Advance();Check(Near(stored.Concentration,expected),"repeated restored rain sample is idempotent");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=='ca502h_core')Seals(u);
        else if(e.Name=='ca502h_seed')SealSeed(u);
        else if(e.Name=='ca502h_load')SealLoad(u);
        else if(e.Name=='ca502h_perf')BoundaryPerf();
        else if(e.Name=='ca502h_legacy')LegacySeal();
        else if(e.Name=='ca502h_rainseed')RainSave(u,false);
        else if(e.Name=='ca502h_rainload')RainSave(u,true);
        else {Super.NetworkProcess(e);return;}
        Console.Printf("CA502W RESULT passed=%d failed=%d",Passed,Failed);
    }
}
class CA502SealObserver : StaticEventHandler
{
    // GZDoom despacha WorldUnloaded en orden inverso al de registro.
    override void OnRegister(){SetOrder(-1000);}
    override void WorldUnloaded(WorldEvent e)
    {
        if(level.MapName!='CWH502')return;
        let checks=CA502SealChecks(EventHandler.Find('CA502SealChecks'));
        if(checks!=null)checks.ObserveDeparture();
    }
}
