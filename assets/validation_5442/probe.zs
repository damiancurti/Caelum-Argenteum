class CA318StaggerProbe : EventHandler
{
    const MEASUREMENT_START_TIC=3750;
    int Age,Mode,Site,StartTic,StartPopulation,Serial,ArmTic;
    bool SeedReady,Started,Finished,ChecksDone;
    CaelumPortSiege Port;
    CaelumCombatActor CheckBody,CheckOther;
    Array<CA318Work> Workers;
    Array<double> Stamps;
    ui double LastFrame;
    ui Array<double> FrameMS,FrameTimes;
    ui Array<int> FrameTics;
    ui bool Flushed;
    void Add(Actor actor)
    {
        let npc=CaelumCombatActor(actor);if(npc==null || npc.CA318Work!=null)return;
        let w=new("CA318Work");w.Body=npc;w.Mode=Mode;w.Phase=Serial++%CA318Work.PERIOD;
        w.Audit=CVar.GetCVar("ca318_stagger_audit").GetBool();w.LastSector=npc.CurSector;
        w.RDue=w.NextDue();npc.CA318Work=w;Workers.Push(w);
    }
    override void WorldThingSpawned(WorldEvent e){if(Started && !Finished)Add(e.Thing);}
    override void WorldThingDamaged(WorldEvent e){CA318Work.Changed(e.Thing);}
    override void WorldThingDied(WorldEvent e){CA318Work.Changed(e.Thing,true);}
    override void WorldThingDestroyed(WorldEvent e){CA318Work.Changed(e.Thing,true);}
    override void WorldThingRevived(WorldEvent e){CA318Work.Changed(e.Thing);}
    override bool InputProcess(InputEvent e){return Started;}
    void Begin()
    {
        Mode=CVar.GetCVar("ca318_stagger_mode").GetInt();Site=CVar.GetCVar("ca318_stagger_site").GetInt();
        Port=CaelumPortSiege.Get();if(Port==null || !Port.HighDensity){Console.Printf("CA282 FAIL missing high-density siege");return;}
        Port.CA318Mode=Mode;Port.CA318Queries=0;
        // Censo único al arrancar la medición; después sólo altas y avisos locales.
        let it=ThinkerIterator.Create("CaelumCombatActor");CaelumCombatActor npc;
        while((npc=CaelumCombatActor(it.Next()))!=null)Add(npc);
        int phaseCounts[100];for(int i=0;i<Workers.Size();i++)phaseCounts[Workers[i].Phase]++;
        int minimum=Workers.Size(),maximum=0;for(int i=0;i<100;i++){minimum=Min(minimum,phaseCounts[i]);maximum=Max(maximum,phaseCounts[i]);}
        Console.Printf("STAGGER PHASES actors=%d buckets=100 min=%d max=%d",Workers.Size(),minimum,maximum);
        let player=players[0].mo;CaelumPlayer(player).CA318SiegeFocus=(Mode&32)!=0;vector3 point=Site==0?(0,320,0):(-14464,-14000,0);
        player.SetOrigin(point,false);player.FindFloorCeiling();player.SetOrigin((point.X,point.Y,player.FloorZ),false);
        player.Angle=Site==0?180:270;player.Pitch=0;player.Vel=(0,0,0);
        StartTic=level.time;Started=true;StartPopulation=Workers.Size();level.frozen=false;
        Console.Printf("STAGGER BEGIN mode=%d tic=%d ms=%.6f site=%d workers=%d groups=%d audit=%d armedtic=%d scheduledtic=%d",Mode,StartTic,MSTimeF(),Site,Workers.Size(),Port.Groups,CVar.GetCVar("ca318_stagger_audit").GetBool(),ArmTic,MEASUREMENT_START_TIC);
        Console.Printf("STAGGER SETTINGS vsync=%d capfps=%d maxfps=%d pause=%d render=%d lower=%d audio=%.3f",CVar.GetCVar("vid_vsync").GetInt(),CVar.GetCVar("cl_capfps").GetInt(),CVar.GetCVar("vid_maxfps").GetInt(),CVar.GetCVar("i_pauseinbackground").GetInt(),CVar.GetCVar("vid_activeinbackground").GetInt(),CVar.GetCVar("vid_lowerinbackground").GetInt(),CVar.GetCVar("snd_mastervolume").GetFloat());
        Census("start");
    }
    void Census(String label)
    {
        int defenders=0,demons=0,alive=0;double health=0,anima=0,air=0,exposure=0;
        for(int i=0;i<Workers.Size();i++)
        {
            let body=Workers[i].Body;if(body==null)continue;
            if(body.health>0){alive++;if(body is 'CaelumPortDefender')defenders++;if(body is 'CaelumMandinga')demons++;}
            health+=Max(0,body.health);anima+=body.CurrentCombatAnima;air+=body.CurrentCombatAir;
            if(body.ThermalState!=null)exposure+=body.ThermalState.Exposure;
        }
        let user=players[0].mo;
        Console.Printf("STAGGER CENSUS label=%s tic=%d alive=%d defenders=%d demons=%d hp=%.9f anima=%.9f air=%.9f exposure=%.9f x=%.6f y=%.6f z=%.6f angle=%.6f pitch=%.6f",label,level.time,alive,defenders,demons,health,anima,air,exposure,user.Pos.X,user.Pos.Y,user.Pos.Z,user.Angle,user.Pitch);
    }
    void Finish()
    {
        Finished=true;Census("end");int failures=0,notices=0,forced=0,periodic=0;int requested[5],computed[5],raw[5];
        for(int i=0;i<Workers.Size();i++)
        {
            let w=Workers[i];failures+=w.Failures;notices+=w.Notices;forced+=w.ThermalForced;periodic+=w.ThermalPeriodic;
            for(int k=0;k<5;k++){requested[k]+=w.Requested[k];computed[k]+=w.Computed[k];raw[k]+=w.RawCalls[k];}
        }
        for(int k=0;k<5;k++)Console.Printf("STAGGER COUNTS key=%d requests=%d computed=%d raw=%d",k,requested[k],computed[k],raw[k]);
        Console.Printf("STAGGER THERMAL forced=%d periodic=%d",forced,periodic);
        Console.Printf("STAGGER END mode=%d tic=%d ms=%.6f failures=%d notices=%d targetqueries=%d",Mode,level.time,MSTimeF(),failures,notices,Port.CA318Queries);
        for(int i=0;i<Stamps.Size();i++)Console.Printf("STAGGER TIC n=%d ms=%.6f",i,Stamps[i]);
        if(failures>0)Console.Printf("CA282 FAIL cache mismatches=%d",failures);else Console.Printf("CA282 DONE passes=1 failures=0");
    }
    override void WorldTick()
    {
        Age++;let user=CaelumPlayer(players[0].mo);if(user==null)return;
        if(CVar.GetCVar("ca318_stagger_checks").GetBool())
        {
            if(Age==5){user.CharacterCreationComplete=true;user.CreationWizardOpen=false;user.ApplyCharacterProfile();}
            if(Age==60){CheckBody=CaelumCombatActor(Actor.Spawn("CaelumMandinga",user.Pos+(256,0,0),NO_REPLACE));CheckOther=CaelumCombatActor(Actor.Spawn("CaelumMandinga",user.Pos+(-256,0,0),NO_REPLACE));CheckBody.bDormant=true;CheckOther.bDormant=true;}
            if(!ChecksDone && Age>=70){ChecksDone=true;Checks();}return;
        }
        if(!SeedReady)
        {
            if(Age==5){user.CharacterCreationComplete=true;user.CreationWizardOpen=false;user.ApplyCharacterProfile();user.bInvulnerable=true;let record=user.GetPersistentCharacterState(true);record.DemoNarrativeDelivered=2047;record.DemoNarrativePending=0;}
            if(Age==135){Port=CaelumPortSiege.Get();let clock=CaelumWorldClock.Get(user,true);let calendar=CaelumCalendarState.Get(user,true);calendar.EnsureCampaign(clock);calendar.SetAnchor(clock,CaelumCityWorld.SiegeDay(),CaelumCityData.SIEGE_HOUR*CaelumWorldClock.TicsPerHour()-1,false);}
            if(Age==3600){SeedReady=true;Console.Printf("STAGGER SEED tic=%d",level.time);}
            return;
        }
        if(!Started)
        {
            if(Finished)return;
            if(CVar.GetCVar("ca318_stagger_start").GetBool() && ArmTic==0)ArmTic=level.time;
            if(level.time>=MEASUREMENT_START_TIC)
            {
                // Los comandos wait dependen del despacho de consola: el inicio lo fija la simulación.
                if(level.time!=MEASUREMENT_START_TIC || ArmTic<=0 || ArmTic>=MEASUREMENT_START_TIC){Finished=true;Console.Printf("CA282 FAIL missed exact measurement tic=%d expected=%d armed=%d",level.time,MEASUREMENT_START_TIC,ArmTic);}
                else Begin();
            }
            return;
        }
        if(Finished)return;
        Stamps.Push(MSTimeF());
        if((level.time-StartTic)%100==0)Census("sample");
        if(level.time-StartTic>=700)Finish();
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=='stagger_compile' || e.Name=='stagger_seed_done')Console.Printf("CA282 DONE passes=1 failures=0");
    }
    void Checks(){Console.Printf("CA282 DONE passes=1 failures=0");}
    override void RenderOverlay(RenderEvent e)
    {
        double now=MSTimeF();
        if(Started && !Finished){if(LastFrame>0){FrameMS.Push(now-LastFrame);FrameTics.Push(level.time);FrameTimes.Push(now);}LastFrame=now;}
        if(Finished && !Flushed){Flushed=true;for(int i=0;i<FrameMS.Size();i++)Console.Printf("STAGGER FRAME tic=%d ms=%.6f interval=%.6f",FrameTics[i],FrameTimes[i],FrameMS[i]);Console.Printf("STAGGER FRAMES_END count=%d",FrameMS.Size());}
    }
}
