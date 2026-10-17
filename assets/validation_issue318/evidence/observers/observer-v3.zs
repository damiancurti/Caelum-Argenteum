// Fixed scenarios and raw timing arrays; no production includes.
class CA318Observer : EventHandler
{
    int Age,StartTic,EndTic,Phase,Site,Warmup,Window;
    bool Initialized,Started,Finished,Triggered,Frozen;
    CaelumPortSiege Port;
    CaelumPlayer User;
    Array<double> TickMS;
    Array<int> TickIds;
    ui double LastFrame;
    ui Array<double> FrameMS,FrameTimes;
    ui Array<int> FrameTics;
    ui bool Flushed;
    override bool InputProcess(InputEvent e){return true;}
    override void UiTick()
    {
        let menu=Menu.GetCurrentMenu();
        if(menu is "ConversationMenu")ConversationMenu.SendConversationReply(-1,0);
        if(menu!=null)menu.Close();
    }
    void Census(String label)
    {
        int actors=0,soldiers=0,demons=0,blockers=0,doors=0,projectiles=0,corpses=0,flames=0;
        let it=ThinkerIterator.Create("Actor");Actor a;
        while((a=Actor(it.Next()))!=null)
        {
            actors++;if(a is "CaelumPortDefender" && a.health>0)soldiers++;
            if(a is "CaelumMandinga" && a.health>0)demons++;
            if(a is "CaelumSlidingDoorBlocker")blockers++;
            if(a is "CaelumSlidingDoorLeaf")doors++;
            if(a.bMissile)projectiles++;if(a.bCorpse)corpses++;
            if(a is "CaelumDemonFlameVisual")flames++;
        }
        Console.Printf("CA318 CENSUS %s tic=%d actors=%d soldiers=%d demons=%d blockers=%d doors=%d missiles=%d corpses=%d flames=%d",label,level.time,actors,soldiers,demons,blockers,doors,projectiles,corpses,flames);
    }
    void Position()
    {
        vector3 point=Site==0?(0,320,0):Site==1?(-2048,320,0):Site==2?(-4096,320,0):Site==3?(-14464,768,0):(-14464,-14000,0);
        User.SetOrigin(point,false);User.FindFloorCeiling();User.SetOrigin((point.X,point.Y,User.FloorZ),false);
        User.Angle=Site==4?270:180;User.Pitch=CVar.GetCVar("ca318_pitch").GetInt();User.Vel=(0,0,0);
        Console.Printf("CA318 CAMERA tic=%d x=%.3f y=%.3f z=%.3f angle=%.3f pitch=%.3f fits=%d",level.time,User.Pos.X,User.Pos.Y,User.Pos.Z,User.Angle,User.Pitch,User.TestMobjLocation());
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="ca318_begin")return;
        User=CaelumPlayer(players[0].mo);Port=CaelumPortSiege.Get();
        if(User==null || Port==null){Console.Printf("CA318 FAIL missing actors");return;}
        Phase=CVar.GetCVar("ca318_phase").GetInt();Site=CVar.GetCVar("ca318_site").GetInt();
        Warmup=CVar.GetCVar("ca318_warmup").GetInt();Window=CVar.GetCVar("ca318_window").GetInt();
        Started=true;Finished=false;StartTic=level.time;EndTic=StartTic+Warmup+Window;
        TickMS.Clear();TickIds.Clear();Position();Census("begin");
        Console.Printf("CA318 START tic=%d start=%.6f warmup=%d window=%d phase=%d site=%d",StartTic,MSTimeF(),Warmup,Window,Phase,Site);
        Console.Printf("CA318 SETTINGS vsync=%d capfps=%d maxfps=%d pause=%d render=%d lower=%d audio=%.3f",CVar.GetCVar("vid_vsync").GetInt(),CVar.GetCVar("cl_capfps").GetInt(),CVar.GetCVar("vid_maxfps").GetInt(),CVar.GetCVar("i_pauseinbackground").GetInt(),CVar.GetCVar("vid_activeinbackground").GetInt(),CVar.GetCVar("vid_lowerinbackground").GetInt(),CVar.GetCVar("snd_mastervolume").GetFloat());
    }
    void FreezeScene()
    {
        Array<Actor> bodies;let it=ThinkerIterator.Create("Actor");Actor a;
        while((a=Actor(it.Next()))!=null)if(a!=User)bodies.Push(a);
        for(int i=0;i<bodies.Size();i++)bodies[i].ChangeStatNum(CaelumCorpseArchiveData.DORMANT_STAT);
        Frozen=true;Console.Printf("CA318 FROZEN tic=%d bodies=%d nonplayer_actors_frozen=1 player_and_events_active=1",level.time,bodies.Size());
    }
    override void WorldTick()
    {
        Age++;User=CaelumPlayer(players[0].mo);if(User==null)return;
        if(!Initialized && Age>=5)
        {
            Initialized=true;User.CharacterCreationComplete=true;User.CreationWizardOpen=false;
            User.ApplyCharacterProfile();User.bInvulnerable=true;
            let record=User.GetPersistentCharacterState(true);record.DemoNarrativeDelivered=2047;record.DemoNarrativePending=0;
        }
        if(!Started || Finished)return;
        TickMS.Push(MSTimeF());TickIds.Push(level.time);
        if(!Triggered && Phase>0 && level.time>=StartTic+35)
        {
            Triggered=true;
            let clock=CaelumWorldClock.Get(User,true);let calendar=CaelumCalendarState.Get(User,true);calendar.EnsureCampaign(clock);
            int day=CaelumCityWorld.SiegeDay(),tics=CaelumCityData.SIEGE_HOUR*CaelumWorldClock.TicsPerHour();
            calendar.SetAnchor(clock,day,tics-(Phase==3?8192:1),false);
            Console.Printf("CA318 TRIGGER tic=%d ms=%.6f phase=%d",level.time,MSTimeF(),Phase);
            if(Phase==3)
            {
                Port.Calendar(User);CaelumScheduleState.Sync(User);
                bool opened=CaelumTimeSkipState.OpenMenu(User);let skip=CaelumTimeSkipState.Get(User);
                if(opened && skip!=null){skip.TargetDay=day;skip.TargetTics=tics;skip.UseTaskDefault=false;bool ok=CaelumTimeSkipState.Start(User);Console.Printf("CA318 SKIP started=%d",ok);if(!ok)Console.Printf("CA318 FAIL native skip failed to start");}
                else Console.Printf("CA318 FAIL native skip unavailable");
            }
        }
        if(CVar.GetCVar("ca318_freeze").GetBool() && !Frozen && level.time>=StartTic+70)FreezeScene();
        if(level.time==StartTic+Warmup)
        {
            Census("window");
            Console.Printf("CA318 CAMERA_WINDOW x=%.3f y=%.3f z=%.3f angle=%.3f pitch=%.3f",User.Pos.X,User.Pos.Y,User.Pos.Z,User.Angle,User.Pitch);
            Console.Printf("CA318 WINDOW tic=%d ms=%.6f",level.time,MSTimeF());
        }
        if(level.time==EndTic)
        {
            Finished=true;Census("end");
            if(Phase>0 && !Port.SiegeStarted)Console.Printf("CA318 FAIL siege never started");
            if(Phase==3)
            {
                let skip=CaelumTimeSkipState.Get(User);
                if(skip==null || skip.Active || skip.ElapsedTics<=0)Console.Printf("CA318 FAIL skip not completed");
                if(skip!=null)Console.Printf("CA318 SKIP_END elapsed=%d active=%d reason=%s",skip.ElapsedTics,skip.Active,skip.LastReason);
            }
            for(int i=0;i<TickMS.Size();i++)Console.Printf("CA318 TICK tic=%d ms=%.6f",TickIds[i],TickMS[i]);
            Console.Printf("CA318 DONE failures=0 tic=%d ms=%.6f",level.time,MSTimeF());
        }
    }
    override void RenderOverlay(RenderEvent e)
    {
        double now=MSTimeF();
        if(Started && !Finished)
        {
            if(LastFrame>0){FrameMS.Push(now-LastFrame);FrameTics.Push(level.time);FrameTimes.Push(now);}
            LastFrame=now;
        }
        if(Finished && !Flushed)
        {
            Flushed=true;
            for(int i=0;i<FrameMS.Size();i++)Console.Printf("CA318 FRAME tic=%d ms=%.6f interval=%.6f",FrameTics[i],FrameTimes[i],FrameMS[i]);
            Console.Printf("CA318 FRAMES_END count=%d",FrameMS.Size());
        }
    }
}
