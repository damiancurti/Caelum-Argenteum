class CA502SProof : Inventory
{
    CaelumContaminationTile Tile;
    double Value,Stamp;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA502SChecks : EventHandler
{
    int Passed,Failed;
    CaelumContaminationTile RainOpen,RainRoof;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA502H %s %s",ok?"PASS":"FAIL",label);}
    bool Near(double a,double b,double epsilon=0.00001){return Abs(a-b)<epsilon;}
    void Reset(CaelumPlayer u)
    {
        CaelumRestState.Cancel(u);CaelumTimeAdvanceState.Halt(u);
        CaelumCleaningTask.Cancel(u);CaelumHygieneTask.Cancel(u);CaelumBathTask.Cancel(u);
        u.Attributes.Toughness=100;u.ApplyCharacterProfile();u.health=u.CaelumMaximumHealth;u.player.health=u.health;
        u.CurrentHunger=100;u.CurrentThirst=100;u.CurrentSleep=100;u.CombatTimeRemaining=0;
        u.EquipmentMenuOpen=false;u.CraftingMenuOpen=false;u.PalomoMerchantMenuOpen=false;
        u.bNoGravity=false;u.bNoClip=false;u.Vel=(0,0,0);
        CaelumContaminationStorage.Set(u,0);
        u.SetOrigin((64,64,0),false);
        u.SetOrigin((64,64,u.FloorZ),false);u.Vel=(0,0,0);
        let thermal=CaelumThermalBody.Get(u,true);CaelumThermalEnvironment.Sample(u,thermal,0);
    }
    void Rules(CaelumPlayer u)
    {
        Check(Near(CaelumContaminationTile.Evolve(80,0,2,1800),70),"light rain removes10 in30 worldminutes");
        Check(Near(CaelumContaminationTile.Evolve(80,0,10,3600),40),"heavy rain repeatedly removes20 each30minutes");
        Check(Near(CaelumContaminationTile.Evolve(5,0,10,3600),0),"rain cannot make concentration negative");
        Check(Near(CaelumContaminationTile.Evolve(0.05,0.05,10,60),0),"rain can overcome a sub-degree environmental source");
        Check(Near(CaelumContaminationTile.Evolve(80,0,0,1800),80),"dry weather retains prior cleaning");
        Check(Near(CaelumContaminationTile.Evolve(0,15,0,100),CaelumContaminationRules.AfterContact(0,15,1,100)),"dry environmental exposure reuses approved rate");
        double whole=CaelumContaminationTile.Evolve(2,80,7,300),parts=2;
        for(int i=0;i<300;i++)parts=CaelumContaminationTile.Evolve(parts,80,7,1);
        Console.Printf("CA502S partition whole=%.10f parts=%.10f",whole,parts);
        Check(Near(whole,parts),"simultaneous rain and exposure independent of interval splitting");
        Check(Near(CaelumContaminationTile.Evolve(2,80,0.00000001,1),Sqrt(20)),"near-zero drizzle retains numerical precision");
        Check(Near(CaelumContaminationTile.Evolve(80,15,10,10000),15),"rain and urban exposure converge without clearing ambient source");
        Check(CaelumContaminationSurfaceContact.Cell(-0.1)==-1 && CaelumContaminationSurfaceContact.Cell(31.99)==0
            && CaelumContaminationSurfaceContact.Cell(32)==1,"one-metre cell identity handles negative coordinates");
        vector2 slopePoint=CaelumContaminationSurfaceContact.PlaneCoordinates((24,8),(1,0));
        Check(Near(slopePoint.X,24*Sqrt(2)) && Near(slopePoint.Y,8),"sloped support zones measure actual plane distance");
        let sheet=new('CaelumContaminationMap');let a=sheet.Find(0,1,0,1,2,true);
        Check(a==sheet.Find(0,1,0,1,2,true) && sheet.Tiles.Size()==1,"same cell reuses one persistent record");
        Check(a!=sheet.Find(0,1,0,2,2,true) && a!=sheet.Find(1,1,0,1,2,true)
            && a!=sheet.Find(0,2,0,1,2,true),"adjacent cells and stacked/other supports stay separate");
        Check(sheet.Find(2,4,0,0,0,true)!=sheet.Find(2,4,1,0,0,true),"opposite wall faces stay separate");
        sheet.Buckets.Clear();Check(sheet.Find(0,1,0,1,2)==a,"rebuilding index preserves identity and values");
        for(int i=0;i<10000;i++)sheet.Find(0,100,0,i%100,i/100,true);
        Check(sheet.Find(0,100,0,99,99)!=null && sheet.Find(0,100,0,100,100)==null,"sparse ten-thousand-zone lookup retains all cells");
        Reset(u);a.Concentration=80;CaelumContaminationStorage.Set(u,20);
        double massFactor=CaelumContaminationStorage.Dose(u);a.Contact(u,0.04,10);
        Check(Near(CaelumContaminationStorage.Value(u),CaelumContaminationRules.AfterContact(20,80,0.04,10,massFactor)) && Near(a.Concentration,80),"feet transfer uses ratio, body mass and unchanged source");
        a.Concentration=0;CaelumContaminationStorage.Set(u,80);a.Contact(u,0.04,10);
        Check(a.Concentration>0 && Near(CaelumContaminationStorage.Value(u),80),"dirty body contaminates touched cell without losing concentration");
        let clone=a.Copy();clone.Concentration=0;Check(a.Concentration>0,"forecast clone is independent");
        a.Stamp=100;a.Sync(99,0,new('CaelumWeatherSample'),new('CaelumWeatherSample'));
        Check(Near(a.Stamp,100),"backward clock never repeats exposure");
    }
    void Geometry(CaelumPlayer u)
    {
        Reset(u);let sheet=CaelumContaminationSurfaces.CurrentMap(u);
        let thermal=CaelumThermalBody.Get(u,true);let tile=CaelumContaminationSurfaceContact.FloorTile(u,sheet,true);
        Check(tile!=null && CaelumContaminationSurfaceContact.Grounded(u),"native grounded body resolves real floor cell");if(tile==null)return;
        tile.Concentration=80;tile.Stamp=CaelumContaminationSurfaces.Now(u);CaelumContaminationStorage.Set(u,0);
        let outer=CaelumContaminationSurfaceContact.Outer(u,CaelumConstants.ARMOR_SLOT_FEET);CaelumContaminationStorage.Set(outer,0);
        CaelumContaminationSurfaceContact.Step(u,thermal,10);
        Check(CaelumContaminationStorage.Value(outer)>0 && Near(tile.Concentration,80),"production surface path transmits to outer feet layer");
        u.SetOrigin(u.Pos+(32,0,0),false);let next=CaelumContaminationSurfaceContact.FloorTile(u,sheet,true);
        Check(next!=tile && Near(next.Concentration,0),"stepping one metre cannot soil the adjacent zone instantly");
        u.SetOrigin(u.Pos+(0,0,16),false);Check(CaelumContaminationSurfaceContact.FloorTile(u,sheet,true)==null,"jumping ends floor contact");
        u.SetOrigin((64,64,0),false);u.bNoClip=true;Check(CaelumContaminationSurfaceContact.FloorTile(u,sheet,true)==null,"noclip cannot contaminate support");u.bNoClip=false;
        u.SetOrigin((320-u.Radius,64,0),false);u.SetOrigin((u.Pos.X,u.Pos.Y,u.FloorZ),false);
        let wall=CaelumContaminationSurfaceContact.WallTile(u,sheet,true);
        Check(wall!=null && wall.Kind==2,"native touching wall resolves line face and vertical zone");
        if(wall!=null){wall.Concentration=90;wall.Stamp=CaelumContaminationSurfaces.Now(u);let torso=CaelumContaminationSurfaceContact.Outer(u,CaelumConstants.ARMOR_SLOT_BODY);
            CaelumContaminationStorage.Set(torso,0);CaelumContaminationSurfaceContact.Step(u,thermal,10);Check(CaelumContaminationStorage.Value(torso)>0,"wall contact reaches outer torso layer");}
        u.SetOrigin((0,64,0),false);Check(CaelumContaminationSurfaceContact.WallTile(u,sheet,true)==null,"open two-sided boundary is not a wall contact");
        u.SetOrigin((64,64,0),false);let shadow=new('CaelumContaminationSurfaceForecast');shadow.Capture(u,thermal);
        double before=tile.Concentration,stamp=tile.Stamp;let exposure=new('CaelumContaminationExposure');exposure.Capture(u,thermal);
        let illness=CaelumFoodIllness.Get(u).Copy();shadow.Advance(exposure,illness,20,15,0);
        Check(Near(tile.Concentration,before) && Near(tile.Stamp,stamp),"wait forecast leaves live tile and timestamp untouched");
        let changed=tile.Copy();changed.WeatherReady=true;bool oldRoof=thermal.Roof;thermal.Roof=!oldRoof;
        CaelumContaminationSurfaceContact.Configure(u,thermal,changed,true);thermal.Roof=oldRoof;
        Check(changed.Covered!=tile.Covered && !changed.WeatherReady && Near(changed.Concentration,tile.Concentration),"changed cover refreshes climate cache without resetting contamination");
        u.SetOrigin((200,64,0),false);double epoch=sheet.Epoch;sheet.Epoch-=1800;int count=sheet.Tiles.Size();
        let unseen=new('CaelumContaminationSurfaceForecast');unseen.Capture(u,thermal);sheet.Epoch=epoch;
        Check(unseen.Floor!=null && unseen.Floor.Concentration>0 && sheet.Tiles.Size()==count,"unvisited forecast zone ages from map epoch without creating live state");
    }
    void Weather(CaelumPlayer u)
    {
        Reset(u);let calendar=CaelumCalendarState.Get(u);let clock=CaelumWorldClock.Get(u);
        int first=calendar.DateSerial(clock);int seed=CaelumWeatherState.Get(u).Seed;let outside=new('CaelumWeatherSample');
        int wetDay=-1,wetMinute=0;
        for(int day=first;day<first+90 && wetDay<0;day++)for(int hour=6;hour<22;hour++)
        {outside.EvaluateRegion(1,day,hour*CaelumWorldClock.TicsPerHour(),seed);if(outside.PrecipitationMmPerHour>=2){wetDay=day;wetMinute=hour*60;break;}}
        Check(wetDay>=0,"real seeded climate supplies a rainy interval");if(wetDay<0)return;
        let open=new('CaelumContaminationTile');open.Concentration=100;open.Profile=5;open.Region=1;open.Seed=seed;
        open.Reference=15;open.Shelter=0;open.Stamp=0;let roof=open.Copy();roof.Covered=true;roof.Shelter=2;
        double offset=double(wetDay)*86400+wetMinute*60;let local=new('CaelumWeatherSample');
        open.Sync(1800,offset,outside,local);roof.Sync(1800,offset,outside,local);
        Check(open.Concentration<100 && Near(roof.Concentration,100),"historical rain cleans exposed zone but not roofed interior");
        double washed=open.Concentration;open.Sync(1800,offset,outside,local);
        Check(Near(washed,open.Concentration),"repeated read does not wash twice");
        let one=new('CaelumContaminationTile');one.Profile=5;one.Region=1;one.Seed=seed;one.Reference=15;
        let split=one.Copy();one.Sync(3600,offset,outside,local);
        for(int i=1;i<=60;i++)split.Sync(i*60,offset,outside,local);
        Check(Near(one.Concentration,split.Concentration),"unloaded catch-up equals continuous minute samples");
        one.Sync(30*86400,offset,outside,local);Check(one.Stamp==30*86400 && one.Concentration>=0 && one.Concentration<=100,"thirty-day catch-up retains entire elapsed interval");
    }
    void Seed(CaelumPlayer u)
    {
        Reset(u);u.SetOrigin((192,192,0),false);let tile=CaelumContaminationSurfaceContact.FloorTile(u,CaelumContaminationSurfaces.CurrentMap(u),true);
        tile.Concentration=73.25;tile.Stamp=CaelumContaminationSurfaces.Now(u);
        let proof=CA502SProof(u.GiveInventoryType('CA502SProof'));proof.Tile=tile;proof.Value=tile.Concentration;proof.Stamp=tile.Stamp;
        u.SetOrigin((128,128,0),false);Check(Near(proof.Tile.Concentration,73.25),"saved untrodden zone starts at known concentration");
    }
    void Load(CaelumPlayer u,bool hub=false)
    {
        let proof=CA502SProof(u.FindInventory('CA502SProof'));Check(proof!=null && proof.Tile!=null,"saved surface record survives inventory and map travel");if(proof==null)return;
        Check(Near(proof.Tile.Concentration,proof.Value) && Near(proof.Tile.Stamp,proof.Stamp),"untouched stored zone preserves exact contamination and pending time");
        if(!hub || level.MapName=="CAS502")
        {
            let sheet=CaelumContaminationSurfaces.CurrentMap(u);
            Check(sheet.Find(proof.Tile.Kind,proof.Tile.Surface,proof.Tile.Side,proof.Tile.X,proof.Tile.Y)==proof.Tile,"returning resolves original map cell identity");
            sheet.Sync(proof.Tile,CaelumContaminationSurfaces.Now(u));Check(proof.Tile.Stamp>=proof.Stamp,"return processes elapsed time without reset");
        }
    }
    void Manual(CaelumPlayer u)
    {
        RainOpen=null;RainRoof=null;
        Reset(u);let tile=CaelumContaminationSurfaceContact.FloorTile(u,CaelumContaminationSurfaces.CurrentMap(u),true);
        tile.Concentration=80;tile.Stamp=CaelumContaminationSurfaces.Now(u);
        Console.Printf("CA502S Zona bajo tus pies=80; cuerpo=0. F2 informa. F3 ensucia pared; F4 prepara lluvia. F6 consola.");
    }
    void Status(CaelumPlayer u)
    {
        let sheet=CaelumContaminationSurfaces.CurrentMap(u);let tile=CaelumContaminationSurfaceContact.FloorTile(u,sheet,false);
        let wall=CaelumContaminationSurfaceContact.WallTile(u,sheet,false);
        Console.Printf("CA502S Cuerpo=%.4f; suelo=%.4f; pared=%.4f; zonas=%d",CaelumContaminationStorage.Value(u),tile==null?-1:tile.Concentration,wall==null?-1:wall.Concentration,sheet.Tiles.Size());
        Console.Printf("CA502S Contacto pies=%.4f; torso=%.4f",CaelumContaminationStorage.Value(CaelumContaminationSurfaceContact.Outer(u,CaelumConstants.ARMOR_SLOT_FEET)),CaelumContaminationStorage.Value(CaelumContaminationSurfaceContact.Outer(u,CaelumConstants.ARMOR_SLOT_BODY)));
        if(RainOpen!=null && RainRoof!=null)
        {sheet.Sync(RainOpen,CaelumContaminationSurfaces.Now(u));sheet.Sync(RainRoof,CaelumContaminationSurfaces.Now(u));
            Console.Printf("CA502S Lluvia %.2f mm/h; exterior=%.4f; interior=%.4f",CaelumWeatherState.Get(u).Outside.PrecipitationMmPerHour,RainOpen.Concentration,RainRoof.Concentration);}
    }
    void RainSetup(CaelumPlayer u)
    {
        Reset(u);let calendar=CaelumCalendarState.Get(u);let clock=CaelumWorldClock.Get(u);
        let weather=CaelumWeatherState.Get(u);let outside=new('CaelumWeatherSample');int first=calendar.DateSerial(clock),day=-1,hour=0;
        for(int d=first+1;d<first+90 && day<0;d++)for(int h=6;h<22;h++)
        {outside.EvaluateRegion(1,d,h*CaelumWorldClock.TicsPerHour(),weather.Seed);if(outside.PrecipitationMmPerHour>=2){day=d;hour=h;break;}}
        if(day<0){Check(false,"rain setup found a seeded rainy day");return;}
        clock.AdvanceTics((day-first)*CaelumWorldClock.TicsPerDay()+hour*CaelumWorldClock.TicsPerHour()-calendar.CivilDayTics(clock));
        CaelumWeatherState.Sync(u,clock,calendar);let thermal=CaelumThermalBody.Get(u,true);
        let sheet=CaelumContaminationSurfaces.CurrentMap(u);
        for(int i=0;i<2;i++)
        {
            u.SetOrigin((i==0?64:-64,64,0),false);CaelumThermalEnvironment.Sample(u,thermal,0);
            let tile=CaelumContaminationSurfaceContact.FloorTile(u,sheet,true);
            CaelumContaminationSurfaceContact.Configure(u,thermal,tile);tile.Concentration=100;tile.Stamp=CaelumContaminationSurfaces.Now(u);
            if(i==0)RainOpen=tile;else RainRoof=tile;
        }
        u.SetOrigin((128,128,0),false);CaelumThermalEnvironment.Sample(u,thermal,0);
        Console.Printf("CA502S Lluvia real preparada. F5 avanza30 minutos; F2 compara exterior/interior sin pisarlos.");Status(u);
    }
    void RainLive(CaelumPlayer u)
    {
        RainSetup(u);double before=RainOpen.Concentration;
        for(int i=0;i<CaelumWorldClock.TicsPerHour()/2;i++)CaelumTimeAdvanceState.SimulatePersonalTic(u);
        Status(u);
        Check(RainOpen.Concentration<before && Near(RainRoof.Concentration,100),"real accelerated world time washes outside while interior retains contamination");
    }
    void Forecast(CaelumPlayer u)
    {
        let helper=CA502HChecks(EventHandler.Find('CA502HChecks'));let item=helper.CleanReset(u);
        let sheet=CaelumContaminationSurfaces.CurrentMap(u);let thermal=CaelumThermalBody.Get(u,true);
        thermal.Exposure=0;let tile=CaelumContaminationSurfaceContact.FloorTile(u,sheet,true);
        Check(tile!=null,"forecast test has physical support");if(tile==null)return;
        tile.Concentration=80;tile.Stamp=CaelumContaminationSurfaces.Now(u);
        CaelumContaminationStorage.Set(CaelumContaminationSurfaceContact.Outer(u,CaelumConstants.ARMOR_SLOT_FEET),20);
        CaelumCleaningTask.Begin(u,item);let projection=new('CaelumTimeSkipModel');projection.CaptureSkip(u,false);
        Console.Printf("CA502S forecast ambientref=%f thermalavailable=%d weatherprofile=%d weatheravailable=%d",projection.ContaminationWeather.Reference,thermal.Available,CaelumWeatherState.Get(u).Profile,CaelumWeatherState.Get(u).Current.Available);
        double savedC=tile.Concentration;double savedStamp=tile.Stamp;
        for(int i=0;i<100 && !projection.Done;i++)projection.RunBatch();
        Check(projection.Done && projection.Reason.Length()==0,"dirty floor waiting projection completes");
        Check(Near(tile.Concentration,savedC) && Near(tile.Stamp,savedStamp),"complete projection preserves live floor state");
        for(int i=0;i<projection.ElapsedTics;i++)CaelumTimeAdvanceState.SimulatePersonalTic(u);
        Check(Near(projection.FoodIllness.Contamination,CaelumFoodIllness.Value(u)),"dirty floor projected body dose matches live accelerated execution");
        Console.Printf("CA502S forecast body=%.10f live=%.10f floor=%.10f livefloor=%.10f",projection.FoodIllness.Contamination,CaelumFoodIllness.Value(u),projection.SurfaceContact.Floor.Concentration,tile.Concentration);
        Check(projection.SurfaceContact!=null && Near(projection.SurfaceContact.Floor.Concentration,tile.Concentration),"projected surface exchange matches live floor concentration");
        projection.ContaminationWeather.Local=null;projection.ContaminationWeather.Outside=null;projection.ContaminationWeather.Reference=-1;
        projection.Step(false);Check(true,"missing climate sample cannot dereference a null weather object");
    }
    void WetFloor(CaelumPlayer u)
    {
        Reset(u);u.SetOrigin((3736,92,-64),false);u.SetOrigin((u.Pos.X,u.Pos.Y,u.FloorZ),false);
        u.Vel=(0,0,0);u.UpdateWaterLevel(false);
        Check(u.WaterLevel>0 && CaelumContaminationSurfaceContact.Grounded(u),"actual mansion pool bottom remains physical support while immersed");
        let sheet=CaelumContaminationSurfaces.CurrentMap(u);let tile=CaelumContaminationSurfaceContact.FloorTile(u,sheet,true);
        Check(tile!=null,"submerged floor resolves its own persistent zone");if(tile==null)return;
        tile.Concentration=80;tile.Stamp=CaelumContaminationSurfaces.Now(u);
        let outer=CaelumContaminationSurfaceContact.Outer(u,CaelumConstants.ARMOR_SLOT_FEET);CaelumContaminationStorage.Set(outer,0);
        let thermal=CaelumThermalBody.Get(u,true);CaelumThermalEnvironment.Sample(u,thermal,0);
        CaelumContaminationSurfaceContact.Step(u,thermal,10);
        Check(CaelumContaminationStorage.Value(outer)>0 && Near(tile.Concentration,80),"potable immersion does not remove actual contact with a dirty bottom");
        u.SetOrigin(u.Pos+(0,0,16),false);
        Check(CaelumContaminationSurfaceContact.FloorTile(u,sheet,true)==null,"swimming above the bottom stops its contact");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=='ca502s_rules')Rules(u);
        else if(e.Name=='ca502s_native')Geometry(u);
        else if(e.Name=='ca502s_weather')Weather(u);
        else if(e.Name=='ca502s_seed')Seed(u);
        else if(e.Name=='ca502s_load')Load(u);
        else if(e.Name=='ca502s_hub')Load(u,true);
        else if(e.Name=='ca502s_manual')Manual(u);
        else if(e.Name=='ca502s_status')Status(u);
        else if(e.Name=='ca502s_rain')RainSetup(u);
        else if(e.Name=='ca502s_rain_live')RainLive(u);
        else if(e.Name=='ca502s_forecast')Forecast(u);
        else if(e.Name=='ca502s_wet_floor')WetFloor(u);
        else if(e.Name=='ca502s_wait'){for(int i=0;i<CaelumWorldClock.TicsPerHour()/2;i++)CaelumTimeAdvanceState.SimulatePersonalTic(u);Status(u);}
        else if(e.Name=='ca502s_wall')
        {u.SetOrigin((320-u.Radius,64,0),false);let tile=CaelumContaminationSurfaceContact.WallTile(u,CaelumContaminationSurfaces.CurrentMap(u),true);if(tile!=null)tile.Concentration=90;CaelumContaminationStorage.Set(u,0);Status(u);}
        else if(e.Name=='ca502s_legacy'){Check(CaelumContaminationSurfaces.Get(false)!=null,"old save initializes new ledger on first active tic");Check(CaelumCleaningTask.Attended(u),"pre-surface saved equipment cleaning stays active");}
        else return;
        Console.Printf("CA502H RESULT passes=%d failures=%d",Passed,Failed);
    }
}
