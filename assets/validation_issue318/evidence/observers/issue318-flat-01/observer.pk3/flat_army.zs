// Isolated diagnostic: real production bodies, resources, AI and collisions.
class CA318FlatArmy : EventHandler
{
    CaelumPlayer User;
    Array<CaelumCombatActor> Demons,Soldiers;
    Array<double> Ticks;
    Array<int> TickIds;
    int Start,End,Warmup,Window,Failures;
    double ActivatedMS;
    bool Started,Finished;
    ui bool Flushed;
    ui double LastFrame;
    ui Array<double> Frames,FrameTimes;
    ui Array<int> FrameTics;
    override bool InputProcess(InputEvent e){return true;}
    override void UiTick(){if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    void Check(bool ok,String label)
    {if(!ok)Failures++;Console.Printf("CA318 %s %s",ok?"PASS":"FAIL",label);}
    void Census(String label)
    {
        int actors=0,demons=0,soldiers=0,targets=0,dead=0,hurt=0,breaths=0,altered=0,totalHealth=0;
        let it=ThinkerIterator.Create("Actor");Actor body;
        while((body=Actor(it.Next()))!=null)
        {
            actors++;
            if(body is "CaelumMandinga" || body is "CaelumPortDefender")
            {
                if(body.health<=0){dead++;continue;}
                if(body is "CaelumMandinga")demons++;else soldiers++;
                if(body.target!=null && body.target.health>0)targets++;
                let combat=CaelumCombatActor(body);
                if(combat.health<combat.CombatMaximumHealth)hurt++;
                if(combat.CaelumMassAIScheduleActive || combat.CaelumDiagnosticPassiveAI || body.bThruActors || !body.bSolid)altered++;
                totalHealth+=body.health;
            }
            if(body is "CaelumDemonBreath")breaths++;
        }
        Console.Printf("CA318 CENSUS %s actors=%d mandingas=%d soldiers=%d valid_targets=%d dead=%d hurt=%d breaths=%d",label,actors,demons,soldiers,targets,dead,hurt,breaths);
        Console.Printf("CA318 COMBAT %s altered_bodies=%d total_health=%d",label,altered,totalHealth);
        Check(altered==0,"Full combat bodies retain individual AI and solid collisions");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="ca318_begin")return;
        User=CaelumPlayer(players[0].mo);
        User.CharacterCreationComplete=true;User.CreationWizardOpen=false;
        User.ApplyCharacterProfile();User.bInvulnerable=true;User.bNoGravity=true;
        User.SetOrigin(CA318FlatData.Camera(),false);
        User.Angle=CA318FlatData.YAW;User.Pitch=CA318FlatData.PITCH;
        double begin=MSTimeF();Console.Printf("CA318 SPAWN_BEGIN ms=%.6f",begin);
        int bad=0;
        for(int side=0;side<2;side++)
        {
            int count=side==0?CA318FlatData.MANDINGAS:CA318FlatData.SOLDIERS;
            for(int i=0;i<count;i++)
            {
                let body=CaelumCombatActor(Actor.Spawn(side==0?"CaelumMandinga":"CaelumPortDefender",CA318FlatData.Position(side,i)));
                if(body==null){bad++;continue;}
                body.ChangeTid(side==0?31801:31802);
                body.Angle=side==0?0:180;
                if(!body.TestMobjLocation())bad++;
                if(side==0)Demons.Push(body);else Soldiers.Push(body);
                if((i+1)%1000==0)Console.Printf("CA318 SPAWN_PROGRESS side=%d count=%d elapsed_ms=%.3f",side,i+1,MSTimeF()-begin);
            }
        }
        Check(bad==0 && Demons.Size()==CA318FlatData.MANDINGAS && Soldiers.Size()==CA318FlatData.SOLDIERS,"Requested bodies spawn with nonoverlapping physical locations");
        double spawned=MSTimeF();
        Thing_Hate(31801,31802,6);Thing_Hate(31802,31801,6);
        for(int i=0;i<Demons.Size();i++)
        {Demons[i].target=Soldiers[i%CA318FlatData.COLUMNS];Demons[i].SetState(Demons[i].SeeState);}
        for(int i=0;i<Soldiers.Size();i++)
        {Soldiers[i].target=Demons[i%CA318FlatData.COLUMNS];Soldiers[i].SetState(Soldiers[i].SeeState);}
        Console.Printf("CA318 SPAWN_END spawn_ms=%.3f activation_ms=%.3f total_ms=%.3f",spawned-begin,MSTimeF()-spawned,MSTimeF()-begin);
        Census("activated");
        Warmup=CVar.GetCVar("ca318_warmup").GetInt();Window=CVar.GetCVar("ca318_window").GetInt();
        Start=level.time;End=Start+Warmup+Window;Started=true;
        ActivatedMS=MSTimeF();
        Console.Printf("CA318 START tic=%d start=%.6f warmup=%d window=%d",Start,MSTimeF(),Warmup,Window);
    }
    override void WorldTick()
    {
        if(!Started || Finished)return;
        User.Vel=(0,0,0);User.SetOrigin(CA318FlatData.Camera(),false);
        User.Angle=CA318FlatData.YAW;User.Pitch=CA318FlatData.PITCH;
        Ticks.Push(MSTimeF());TickIds.Push(level.time);
        if(level.time==Start+1)Console.Printf("CA318 INITIAL_TIC ms_since_activation=%.3f",MSTimeF()-ActivatedMS);
        if(level.time==Start+Warmup)
        {
            Console.Printf("CA318 WINDOW tic=%d ms=%.6f",level.time,MSTimeF());Census("window");
            Console.Printf("CA318 CAMERA x=%.1f y=%.1f z=%.1f yaw=%.1f pitch=%.1f",User.Pos.X,User.Pos.Y,User.Pos.Z,User.Angle,User.Pitch);
        }
        if(level.time==End)
        {
            Finished=true;Census("end");
            for(int i=0;i<Ticks.Size();i++)Console.Printf("CA318 TICK tic=%d ms=%.6f",TickIds[i],Ticks[i]);
            Console.Printf("CA318 DONE failures=%d tic=%d ms=%.6f",Failures,level.time,MSTimeF());
        }
    }
    override void RenderOverlay(RenderEvent e)
    {
        double now=MSTimeF();
        if(Started && !Finished)
        {
            if(LastFrame>0){Frames.Push(now-LastFrame);FrameTimes.Push(now);FrameTics.Push(level.time);}
            LastFrame=now;
        }
        if(Finished && !Flushed)
        {
            Flushed=true;
            for(int i=0;i<Frames.Size();i++)Console.Printf("CA318 FRAME tic=%d ms=%.6f interval=%.6f",FrameTics[i],FrameTimes[i],Frames[i]);
        }
    }
}
