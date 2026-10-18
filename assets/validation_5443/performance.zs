// Observador idéntico sobre paquetes normales anterior/actual; sin puertas de diagnóstico.
class CA353Performance : EventHandler
{
    const SITE=0;
    int Age,StartTic;
    bool SeedReady,Started,Finished;
    transient bool HasTicked;
    CaelumPortSiege Port;
    Array<CaelumCombatActor> Bodies;
    Array<double> Stamps;
    ui double LastFrame;
    ui Array<double> FrameMS,FrameTimes;
    ui Array<int> FrameTics;
    ui bool Flushed;
    override bool InputProcess(InputEvent e){return true;}
    override void WorldThingSpawned(WorldEvent e)
    {let body=CaelumCombatActor(e.Thing);if(Started && !Finished && body!=null)Bodies.Push(body);}
    void Pose()
    {
        let user=players[0].mo;vector3 point=SITE==0?(0,320,0):(-14464,-14000,0);
        user.SetOrigin(point,false);user.FindFloorCeiling();user.SetOrigin((point.X,point.Y,user.FloorZ),false);
        user.Angle=SITE==0?180:270;user.Pitch=0;user.Vel=(0,0,0);
    }
    void Begin()
    {
        Port=CaelumPortSiege.Get();
        if(Port==null || !Port.SiegeStarted){Console.Printf("CA282 FAIL no siege");return;}
        Bodies.Clear();let it=ThinkerIterator.Create("CaelumCombatActor");CaelumCombatActor body;
        while((body=CaelumCombatActor(it.Next()))!=null)Bodies.Push(body);
        Pose();StartTic=level.time;Started=true;
        Console.Printf("CACHE BEGIN tic=%d ms=%.6f site=%d workers=%d groups=%d",StartTic,MSTimeF(),SITE,Bodies.Size(),Port.Groups);
        Census("start");
    }
    void BeginPresentationWindow()
    {
        Console.Printf("CACHE FPS_BEGIN tic=%d ms=%.6f",level.time,MSTimeF());
        Console.Printf("CACHE SETTINGS vsync=%d capfps=%d maxfps=%d pause=%d render=%d lower=%d audio=%.3f",CVar.GetCVar("vid_vsync").GetInt(),CVar.GetCVar("cl_capfps").GetInt(),CVar.GetCVar("vid_maxfps").GetInt(),CVar.GetCVar("i_pauseinbackground").GetInt(),CVar.GetCVar("vid_activeinbackground").GetInt(),CVar.GetCVar("vid_lowerinbackground").GetInt(),CVar.GetCVar("snd_mastervolume").GetFloat());
    }
    void Census(String label)
    {
        int defenders=0,demons=0,alive=0;double hp=0,anima=0,air=0,exposure=0;
        for(int i=0;i<Bodies.Size();i++)
        {
            let body=Bodies[i];if(body==null)continue;
            if(body.health>0){alive++;if(body is 'CaelumPortDefender')defenders++;if(body is 'CaelumMandinga')demons++;}
            hp+=Max(0,body.health);anima+=body.CurrentCombatAnima;air+=body.CurrentCombatAir;
            if(body.ThermalState!=null)exposure+=body.ThermalState.Exposure;
        }
        let user=players[0].mo;
        Console.Printf("CACHE CENSUS label=%s tic=%d alive=%d defenders=%d demons=%d hp=%.9f anima=%.9f air=%.9f exposure=%.9f x=%.6f y=%.6f z=%.6f angle=%.6f pitch=%.6f",label,level.time,alive,defenders,demons,hp,anima,air,exposure,user.Pos.X,user.Pos.Y,user.Pos.Z,user.Angle,user.Pitch);
    }
    void Finish()
    {
        Finished=true;Census("end");
        Console.Printf("CACHE END tic=%d ms=%.6f",level.time,MSTimeF());
        for(int i=0;i<Stamps.Size();i++)Console.Printf("CACHE TIC n=%d ms=%.6f",i,Stamps[i]);
        Console.Printf("CA282 DONE passes=1 failures=0");
    }
    override void WorldTick()
    {
        if(!HasTicked){HasTicked=true;if(SeedReady && !Started)Begin();}
        Age++;let user=CaelumPlayer(players[0].mo);if(user==null)return;
        if(!SeedReady)
        {
            if(Age==5)
            {
                user.CharacterCreationComplete=true;user.CreationWizardOpen=false;user.ApplyCharacterProfile();user.bInvulnerable=true;
                let record=user.GetPersistentCharacterState(true);record.DemoNarrativeDelivered=2047;record.DemoNarrativePending=0;
            }
            if(Age==135)
            {
                let clock=CaelumWorldClock.Get(user,true);let calendar=CaelumCalendarState.Get(user,true);calendar.EnsureCampaign(clock);
                calendar.SetAnchor(clock,CaelumCityWorld.SiegeDay(),CaelumCityData.SIEGE_HOUR*CaelumWorldClock.TicsPerHour()-1,false);
            }
            if(Age==3600){SeedReady=true;Console.Printf("CACHE SEED_READY tic=%d",level.time);}
            return;
        }
        if(!Started || Finished)return;
        Stamps.Push(MSTimeF());
        if(level.time-StartTic==70)BeginPresentationWindow();
        if(level.time>StartTic && (level.time-StartTic)%100==0)Census("sample");
        if(level.time-StartTic==700)Finish();
    }
    override void NetworkProcess(ConsoleEvent e)
    {if(e.Name=='ca353_seed_done')Console.Printf("CA282 DONE passes=1 failures=0");}
    override void RenderOverlay(RenderEvent e)
    {
        double now=MSTimeF();
        if(Started && !Finished){if(LastFrame>0){FrameMS.Push(now-LastFrame);FrameTics.Push(level.time);FrameTimes.Push(now);}LastFrame=now;}
        if(Finished && !Flushed){Flushed=true;for(int i=0;i<FrameMS.Size();i++)Console.Printf("CACHE FRAME tic=%d ms=%.6f interval=%.6f",FrameTics[i],FrameTimes[i],FrameMS[i]);Console.Printf("CACHE FRAMES_END count=%d",FrameMS.Size());}
    }
}
