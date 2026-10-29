class CA502WeatherChecks : EventHandler
{
    Actor Probe;
    CaelumContaminationTile Saved;
    double SavedArea;
    int Passed,Failed;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA502W %s %s",ok?"PASS":"FAIL",label);}
    bool Near(double a,double b){return Abs(a-b)<0.00001;}
    override void WorldLoaded(WorldEvent e)
    {
        if(!e.IsSaveGame && !e.IsReopen && level.MapName.Left(6)=="CWH502")
        {let marker=Actor.Spawn('CaelumClimateRegion',(16,16,0),NO_REPLACE);marker.args[0]=1;marker.args[1]=5;}
    }
    override void WorldTick()
    {
        let u=CaelumPlayer(players[0].mo);if(u==null)return;
        u.CharacterCreationComplete=true;u.CreationWizardOpen=false;u.bInvulnerable=true;
        u.GetPersistentCharacterState(true).SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_UNKNOWN_VOICE_HEARD);
        u.A_SetBlend("Black",0,1);
        if(level.MapName=="CWH502" && Probe==null)
            Probe=Actor.Spawn('CA502WeatherProp',(176,128,0),NO_REPLACE);
    }
    CaelumContaminationTile Snapshot(CaelumContaminationObject n)
    {
        let t=new('CaelumContaminationTile');t.Concentration=90;t.Stamp=n.HistoryStamp;
        t.Reference=n.HistoryReference;t.Profile=n.HistoryProfile;t.Region=n.HistoryRegion;
        t.Seed=n.HistorySeed;t.Shelter=n.HistoryShelter;t.Covered=n.HistoryCovered;return t;
    }
    double Oracle(CaelumContaminationTile t,double area,double offset,double end)
    {
        let outside=new('CaelumWeatherSample');let local=new('CaelumWeatherSample');
        double value=t.Concentration,stamp=t.Stamp;
        // Paso independiente de un segundo, con el minuto civil del clima real.
        int previous=-1;
        while(stamp<end)
        {
            double civil=stamp+offset;int day=int(Floor(civil/86400));
            int minute=int(Floor((civil-double(day)*86400)/60));
            double boundary=double(day)*86400+(minute+1)*60-offset;
            if(previous!=day*1440+minute)
            {outside.EvaluateRegion(t.Region,day,minute*(CaelumWorldClock.TicsPerHour()/60),t.Seed);local.ApplyShelter(outside,t.Shelter,t.Profile);previous=day*1440+minute;}
            double rain=t.Covered?0:local.PrecipitationMmPerHour;
            double ambient=CaelumContaminationRules.Ambient(t.Reference,local.AirTemperatureC,local.RelativeHumidityPercent,rain,!t.Covered);
            double step=Min(1.0,Min(end,boundary)-stamp);if(step<=0)step=Min(1.0,end-stamp);
            value=CaelumContaminationObjectBalance.Evolve(value,ambient,rain,area,step);stamp+=step;
        }
        return value;
    }
    void Core(CaelumPlayer u)
    {
        let stored=CaelumContaminationStorage.Get(Probe,true);let n=stored.Exposure;n.Advance();
        Check(n.Revision==3 && n.HistoryReady && n.HistoryVariable,"actual regional climate records revision3 weather history");
        Check(n.HistoryRegion==1 && n.HistoryProfile==5 && !n.HistoryCovered,"private outdoor geometry captures region and exposure");
        double now=n.Stamp,offset=n.HistoryCivilOffset;
        let snapshot=Snapshot(n);
        // Buscar lluvia del generador existente, sin cambiar tasas de producción.
        let weather=new('CaelumWeatherSample');int wet=-1;
        int day=CaelumCalendarRules.DaysBeforeYear(CaelumCalendarRules.CAMPAIGN_START_YEAR);
        for(int d=0;d<60 && wet<0;d++)
        {weather.EvaluateRegion(1,day+d,12*CaelumWorldClock.TicsPerHour(),n.HistorySeed);if(weather.PrecipitationMmPerHour>2)wet=day+d;}
        Check(wet>=0,"deterministic regional weather includes a real wet day");if(wet<0)return;
        n.HistoryStamp=now-21600.25;n.HistoryCivilOffset=double(wet)*86400+9*3600-n.HistoryStamp;
        snapshot.Stamp=n.HistoryStamp;snapshot.Concentration=90;
        n.HistoryArea=1;
        let tile=snapshot.Copy();tile.Sync(now,n.HistoryCivilOffset,new('CaelumWeatherSample'),new('CaelumWeatherSample'));
        double value=n.Replay(90,now);
        Check(Near(value,tile.Concentration),"one-square-meter replay agrees with existing surface weather history");
        Check(value<90,"historical rain washes prior dirt");
        Check(Near(value,Oracle(snapshot,1,n.HistoryCivilOffset,now)),"minute replay agrees with one-second integration across partial boundaries");
        n.HistoryArea=0.04;
        Check(Near(n.Replay(90,now),Oracle(snapshot,0.04,n.HistoryCivilOffset,now)),"small weapon area preserves simultaneous exposure and rain balance");
        n.HistoryCovered=true;n.HistoryShelter=CaelumWeatherRules.INDOOR;
        Check(Near(n.Replay(90,now),90),"roofed stored geometry excludes outdoor rain washing");
        n.HistoryCovered=false;n.HistoryShelter=CaelumWeatherRules.OPEN;n.HistoryArea=1;
        n.HistoryStamp=now-21600.25;stored.Concentration=90;n.Ready=false;
        double expected=n.Replay(90,now);
        Check(Near(CaelumContaminationStorage.Value(Probe),expected),"first query settles historical weather before contact");
        Check(Near(n.HistoryStamp,now) && Near(CaelumContaminationStorage.Value(Probe),expected),"repeated query does not replay already charged history");
        n.HistoryStamp=now-3600;n.Ready=false;CaelumContaminationStorage.Set(Probe,0);
        Check(Near(stored.Concentration,0) && Near(n.HistoryStamp,now),"cleaning settles absence before replacing concentration");
        Check(Near(CaelumContaminationStorage.Value(Probe),0),"settled absence cannot undo a cleaning");
        n.HistoryStamp=now-600;n.Ready=true;CaelumContaminationStorage.Set(Probe,0);
        Check(Near(n.HistoryStamp,now) && Near(CaelumContaminationStorage.Value(Probe),0),"loaded cleaning closes pending time before resetting dirt");
        n.HistoryStamp=now+60;n.Ready=false;
        Check(Near(CaelumContaminationStorage.Value(Probe),0) && Near(n.HistoryStamp,now+60),"backward clock preserves future anchor");
        n.HistoryStamp=now;n.Advance();
        stored.Concentration=7;n.Revision=2;n.HistoryReady=false;n.Ready=false;n.HistoryStamp=now-600;n.Advance();
        Check(Near(stored.Concentration,7) && n.Revision==3 && n.HistoryReady,"revision2 exterior migration begins now without inventing dirt");
        n.Revision=2;n.HistoryReady=true;n.HistoryVariable=true;n.HistoryAmbient=5.25;n.HistoryArea=1;n.HistoryStamp=now-600;n.Ready=false;stored.Concentration=0;
        n.Advance();Check(Near(stored.Concentration,5.25),"revision2 constant interval survives despite new default metadata");
        n.Revision=1;n.HistoryReady=true;n.HistoryStamp=now-600;n.Ready=false;stored.Concentration=7;n.Advance();
        Check(Near(stored.Concentration,7) && n.Revision==3,"revision1 migration retains original concentration");
        // El reloj cargado puede saltar por espera; también reproduce su clima.
        n.HistoryStamp=now-600;n.Ready=true;stored.Concentration=0;expected=n.Replay(0,now);n.Advance();
        Check(Near(stored.Concentration,expected),"loaded clock jump uses historical weather instead of frozen last sample");
        let cache=CaelumContaminationWorld.Get().HistoryWeather;
        int date=int(Floor((now+n.HistoryCivilOffset)/86400));
        let original=cache.GetDay(n,date);original.Sample(720);double originalValue=original.Ambient[720];
        for(int d=1;d<=40;d++){let row=cache.GetDay(n,date+d);row.Sample(720);}
        Check(cache.Days.Size()==CaelumContaminationWeatherCache.MAX_DAYS,"shared weather cache has bounded memory");
        let restored=cache.GetDay(n,date);restored.Sample(720);
        Check(restored!=original && Near(restored.Ambient[720],originalValue),"eviction recomputes identical weather without discarding elapsed time");
    }
    void Seed()
    {
        let n=CaelumContaminationStorage.Get(Probe).Exposure;n.Advance();
        CaelumContaminationStorage.Set(Probe,90);Saved=Snapshot(n);SavedArea=n.HistoryArea;
        Check(n.HistoryReady && n.HistoryVariable,"save/hub seed captures real regional history");
    }
    void Resume(CaelumPlayer u)
    {
        Check(Probe!=null && Saved!=null,"native restore retains probe and prior snapshot identity");if(Probe==null || Saved==null)return;
        let n=CaelumContaminationStorage.Get(Probe).Exposure;n.Advance();
        double expected=Oracle(Saved,SavedArea,n.HistoryCivilOffset,n.Stamp);
        Check(Near(CaelumContaminationStorage.Value(Probe),expected),"save/hub result matches original elapsed climate independently");
        Check(n.Revision==3 && n.HistoryReady && n.HistoryVariable,"native restore keeps revision3 regional snapshot");
    }
    void Perf()
    {
        let n=CaelumContaminationStorage.Get(Probe).Exposure;n.Advance();
        double now=n.Stamp;n.HistoryStamp=now-86400;
        double started=MSTimeF(),total=0;
        for(int i=0;i<1000;i++)total+=n.Replay(i%101,now);
        Console.Printf("CA502W TIMING thousand_day_ms=%.6f checksum=%.6f",MSTimeF()-started,total);
    }
    void Legacy()
    {
        Check(Probe!=null && Saved!=null,"old runtime restores original actor and saved concentration");if(Probe==null || Saved==null)return;
        let n=CaelumContaminationStorage.Get(Probe).Exposure;n.Advance();
        Check(Near(CaelumContaminationStorage.Value(Probe),Saved.Concentration),"old exterior save retains dirt without fabricated absence");
        Check(n.Revision==3 && n.HistoryReady && n.HistoryVariable,"old exterior save gains revision3 natural history");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=='ca502w_core')Core(u);
        else if(e.Name=='ca502w_seed')Seed();
        else if(e.Name=='ca502w_resume')Resume(u);
        else if(e.Name=='ca502w_perf')Perf();
        else if(e.Name=='ca502w_legacy')Legacy();
        else if(e.Name=='ca502w_away')CaelumWorldClock.Get(u).AdvanceTics(6*CaelumWorldClock.TicsPerHour());
        else return;
        Console.Printf("CA502W RESULT passed=%d failed=%d",Passed,Failed);
    }
}
class CA502WeatherProp : Actor
{Default {Radius 8;Height 16;+SOLID +NOGRAVITY} States {Spawn:TNT1 A -1;Stop;}}
