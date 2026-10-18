// Isolated diagnostic only. No production include references this file.
class CA318SoloCall : Object
{
    int Key;
    Actor Body,Other;
    Object Data;
    vector3 Point;
    double A,B,C,D,E,F,G;
}
class CA318SoloPhase : Object { Array<CA318SoloCall> Calls; }
class CA318SoloPose : Object
{
    Actor Body,Target,Enemy;
    Name BodyKind;
    vector3 Position,Velocity,Mouth;
    double Angle,Pitch,Roll,Anima,Air,Lucidity,Adrenaline,CombatTime;
    double Stun,IdleHealth,Falling;
    bool GroundTracking,WasGrounded,WasBlocked;
    int StaticClear;
    State Pose;
    int Tics,Health;
}
class CA318Solo : EventHandler
{
    bool Recording,Active,Dispatching,Running,Finished,Reported;
    transient int LoadAge;
    int Spawns,ExternalChanges,HealthLosses;
    int Age,CaptureStart,Mode,StartTic,Window,Elapsed;
    int Executed[9],Captured[9],Requested[9];
    CA318SoloPhase Phases[35];
    Array<CA318SoloPose> Poses;
    Array<double> BatchMS,RestoreMS,Times;
    Array<int> Tics;
    double Sink;
    int ActorCount,Soldiers,Demons;
    CaelumPortSiege Port;
    static clearscope CA318Solo Get(){return CA318Solo(EventHandler.Find("CA318Solo"));}
    static clearscope bool ActiveNow(){let p=Get();return p!=null && p.Active;}
    static clearscope bool BlockExternal(){let p=Get();return p!=null && p.Active && !p.Dispatching;}
    static vector3 CachedMouth(Actor owner)
    {
        let npc=CaelumCombatActor(owner);
        if(npc!=null)return npc.CA318MouthCache;
        return owner.Pos+(0,0,owner.Height/2);
    }
    override bool InputProcess(InputEvent e){return true;}
    override void UiTick()
    {
        let menu=Menu.GetCurrentMenu();
        if(menu is "ConversationMenu")ConversationMenu.SendConversationReply(-1,0);
        if(menu!=null)menu.Close();
    }
    void Record(int key,Actor body=null,Object data=null,Actor other=null,vector3 point=(0,0,0),
        double a=0,double b=0,double c=0,double d=0,double e=0,double f=0,double g=0)
    {
        if(!Recording)return;
        int phase=level.time-CaptureStart;if(phase<0 || phase>=35)return;
        if(body!=null && !(body is "CaelumCombatActor"))return;
        let call=new("CA318SoloCall");call.Key=key;call.Body=body;call.Data=data;call.Other=other;
        call.Point=point;call.A=a;call.B=b;call.C=c;call.D=d;call.E=e;call.F=f;call.G=g;
        Phases[phase].Calls.Push(call);Captured[key]++;
    }
    static CaelumElementalStatus CopyStatus(CaelumElementalStatus src)
    {
        let dst=new("CaelumElementalStatus");
        // STATUS_COPY
        return dst;
    }
    void FreezeScene()
    {
        Recording=false;
        let it=ThinkerIterator.Create("Actor");Actor body;
        while((body=Actor(it.Next()))!=null)
        {
            ActorCount++;
            if(body is "CaelumPortDefender" && body.health>0)Soldiers++;
            if(body is "CaelumMandinga" && body.health>0)Demons++;
            let pose=new("CA318SoloPose");pose.Body=body;pose.BodyKind=body.GetClassName();pose.Position=body.Pos;pose.Velocity=body.Vel;
            pose.Angle=body.Angle;pose.Pitch=body.Pitch;pose.Roll=body.Roll;pose.Pose=body.CurState;
            pose.Tics=body.tics;pose.Health=body.health;pose.Target=body.target;pose.Enemy=body.LastEnemy;
            let npc=CaelumCombatActor(body);
            if(npc!=null)
            {
                pose.Mouth=CaelumDemonBreath.Mouth(npc);npc.CA318MouthCache=pose.Mouth;pose.Anima=npc.CurrentCombatAnima;
                pose.Air=npc.CurrentCombatAir;pose.Lucidity=npc.CurrentCombatLucidity;
                pose.Adrenaline=npc.CurrentCombatAdrenaline;pose.CombatTime=npc.CombatTimeRemaining;
                pose.Stun=npc.CombatLucidityPhysicalStunRemaining;pose.IdleHealth=npc.IdleHealthAccumulator;
                pose.Falling=npc.LastImpactFallingVelocityZ;pose.GroundTracking=npc.ImpactGroundTrackingInitialized;
                pose.WasGrounded=npc.ImpactWasGroundedLastTick;pose.WasBlocked=npc.ImpactWasWallBlockedLastTick;
                pose.StaticClear=npc.ImpactStaticClearTics;
            }
            Poses.Push(pose);
        }
        Active=true;Mode=-1;level.frozen=true;
        Console.Printf("SOLO SEED tic=%d actors=%d soldiers=%d demons=%d",level.time,ActorCount,Soldiers,Demons);
        for(int i=0;i<9;i++)Console.Printf("SOLO CAPTURE key=%d calls=%d",i,Captured[i]);
        if(Soldiers!=600 || Demons<990 || Demons>1000)Console.Printf("CA282 FAIL unexpected siege population");
        else Console.Printf("CA282 DONE passes=1 failures=0");
    }
    void RestoreScene()
    {
        for(int i=0;i<Poses.Size();i++)
        {
            let p=Poses[i];let body=p.Body;if(body==null)continue;
            if(Running && body.health<p.Health)HealthLosses++;
            if(body.Pos!=p.Position)body.SetOrigin(p.Position,false);
            body.Vel=p.Velocity;body.Angle=p.Angle;body.Pitch=p.Pitch;body.Roll=p.Roll;
            if(body.CurState!=p.Pose)body.SetState(p.Pose,true);
            body.tics=p.Tics;body.health=p.Health;body.target=p.Target;body.LastEnemy=p.Enemy;
            let npc=CaelumCombatActor(body);
            if(npc!=null)
            {
                npc.CurrentCombatAnima=p.Anima;npc.CurrentCombatAir=p.Air;
                npc.CurrentCombatLucidity=p.Lucidity;npc.CurrentCombatAdrenaline=p.Adrenaline;
                npc.CombatTimeRemaining=p.CombatTime;
                npc.CombatLucidityPhysicalStunRemaining=p.Stun;npc.IdleHealthAccumulator=p.IdleHealth;
                npc.LastImpactFallingVelocityZ=p.Falling;npc.ImpactGroundTrackingInitialized=p.GroundTracking;
                npc.ImpactWasGroundedLastTick=p.WasGrounded;npc.ImpactWasWallBlockedLastTick=p.WasBlocked;
                npc.ImpactStaticClearTics=p.StaticClear;
            }
        }
    }
    int CheckScene()
    {
        int changed=0;
        for(int i=0;i<Poses.Size();i++)
        {
            let p=Poses[i];let body=p.Body;
            if(body==null || body.Pos!=p.Position || body.Vel!=p.Velocity || body.Angle!=p.Angle
                || body.Pitch!=p.Pitch || body.Roll!=p.Roll || body.CurState!=p.Pose || body.tics!=p.Tics
                || body.target!=p.Target || body.LastEnemy!=p.Enemy || body.health!=p.Health)
            {
                changed++;
                if(ExternalChanges==0 && changed==1)Console.Printf("SOLO EXTERNAL class=%s tic=%d",p.BodyKind,level.time);
            }
        }
        return changed;
    }
    void Dispatch(CA318SoloCall call)
    {
        let npc=CaelumCombatActor(call.Body);
        // Clones and traversal are common to all variants, including all-off.
        CaelumThermalState thermal;
        CaelumElementalStatus status;
        if(call.Key==2)
        {
            let original=CaelumThermalState(call.Data);
            if(original!=null){thermal=original.CopyForForecast();thermal.Coefficients=original.Coefficients;}
        }
        if(call.Key==5 && call.Data!=null)status=CopyStatus(CaelumElementalStatus(call.Data));
        if(call.Key!=Mode)return;
        Requested[Mode]++;
        if(call.Key==0 && npc!=null)
        {
            npc.tics=-1;level.frozen=false;npc.CA318SoloTick();level.frozen=true;
        }
        else if(call.Key==1 && call.Data!=null)Port.AttackerTarget(CaelumSiegeCombatant(call.Data));
        else if(call.Key==2 && thermal!=null)Sink+=CaelumThermalService.Integrate(thermal,call.A,call.B,call.C,call.D,call.E,call.F,call.G);
        else if(call.Key==3 && npc!=null)CaelumDemonService.UpdateBreath(npc);
        else if(call.Key==4 && call.Body!=null){vector3 mouth=CaelumDemonBreath.Mouth(call.Body);Sink+=mouth.X;}
        else if(call.Key==5 && status!=null && call.Body!=null)status.Tick(call.Body);
        else if(call.Key==6 && npc!=null)npc.UpdateCombatHealthEffects();
        else if(call.Key==7 && npc!=null)npc.UpdateActorOffensiveStatistics();
        else if(call.Key==8 && npc!=null && call.Other!=null)
        {level.frozen=false;CaelumPortSiege.WalkTo(npc,call.Other,call.Point);level.frozen=true;}
    }
    override void WorldThingSpawned(WorldEvent e)
    {if(Running){Spawns++;Console.Printf("SOLO SPAWN class=%s",e.Thing.GetClassName());}}
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="solo_compile")Console.Printf("CA282 DONE passes=1 failures=0");
        if(e.Name=="solo_seed_done")
        {
            if(!Active)Console.Printf("CA282 FAIL seed not frozen");
            else Console.Printf("CA282 DONE passes=1 failures=0");
        }
        if(e.Name=="solo_begin")Begin();
        if(e.Name=="solo_finish")Finish();
    }
    void Begin()
        {
            Mode=CVar.GetCVar("ca318_solo_mode").GetInt();Window=CVar.GetCVar("ca318_solo_window").GetInt();
            if(!Active || Mode< -1 || Mode>8){Console.Printf("CA282 FAIL invalid begin");return;}
            // Some transient helpers do not survive loading. Normalize once,
            // identically for every control, before any measured work begins.
            int missingBefore=0;
            for(int i=Poses.Size()-1;i>=0;i--)if(Poses[i].Body==null)
            {Console.Printf("SOLO LOAD_REMOVED class=%s",Poses[i].BodyKind);Poses.Delete(i);missingBefore++;}
            ActorCount=0;Soldiers=0;Demons=0;let inventory=ThinkerIterator.Create("Actor");Actor actor;
            while((actor=Actor(inventory.Next()))!=null)
            {ActorCount++;if(actor.PoisonDurationReceived>0)Console.Printf("CA282 FAIL native poison");if(actor is "CaelumPortDefender" && actor.health>0)Soldiers++;if(actor is "CaelumMandinga" && actor.health>0)Demons++;}
            Console.Printf("SOLO LOADED actors=%d poses=%d soldiers=%d demons=%d removed=%d",ActorCount,Poses.Size(),Soldiers,Demons,missingBefore);
            if(ActorCount!=Poses.Size() || Soldiers!=600 || Demons<990 || Demons>1000)Console.Printf("CA282 FAIL loaded population");
            let user=players[0].mo;int site=CVar.GetCVar("ca318_solo_site").GetInt();
            vector3 position=site==0?(0,320,0):(-14464,-14000,0);
            user.SetOrigin(position,false);user.FindFloorCeiling();user.SetOrigin((position.X,position.Y,user.FloorZ),false);
            user.Angle=site==0?180:270;user.Pitch=0;user.Vel=(0,0,0);
            for(int i=0;i<Poses.Size();i++)if(Poses[i].Body==user)
            {Poses[i].Position=user.Pos;Poses[i].Angle=user.Angle;Poses[i].Pitch=0;Poses[i].Velocity=(0,0,0);}
            // Save loading clears transient coefficients. Warm the original
            // cache once, outside every measured variant including all-off.
            for(int phase=0;phase<35;phase++)for(int n=0;n<Phases[phase].Calls.Size();n++)
            {
                let call=Phases[phase].Calls[n];if(call.Key!=2)continue;
                let thermal=CaelumThermalState(call.Data);if(thermal==null)continue;
                let coefficients=CaelumThermalCoefficients.Get(thermal);
                if(thermal.Available)coefficients.Prepare(thermal);
            }
            RestoreScene();Spawns=0;ExternalChanges=0;HealthLosses=0;Reported=false;StartTic=level.time;Elapsed=0;Running=true;Finished=false;BatchMS.Clear();RestoreMS.Clear();Times.Clear();Tics.Clear();
            for(int i=0;i<9;i++){Executed[i]=0;Requested[i]=0;}
            Console.Printf("SOLO BEGIN mode=%d tic=%d ms=%.6f window=%d site=%d",Mode,level.time,MSTimeF(),Window,site);
        }
    void Finish()
        {
            int changed=0,missing=0,actors=0;let it=ThinkerIterator.Create("Actor");Actor body;
            while((body=Actor(it.Next()))!=null)actors++;
            for(int i=0;i<Poses.Size();i++)
            {let p=Poses[i];if(p.Body==null)missing++;else if(p.Body.Pos!=p.Position || p.Body.Vel!=p.Velocity || p.Body.Angle!=p.Angle || p.Body.Pitch!=p.Pitch || p.Body.Roll!=p.Roll || p.Body.CurState!=p.Pose || p.Body.tics!=p.Tics || p.Body.target!=p.Target || p.Body.LastEnemy!=p.Enemy || p.Body.health!=p.Health)changed++;}
            Console.Printf("SOLO INVARIANTS actors=%d expected=%d changed=%d missing=%d frozen=%d spawns=%d",actors,ActorCount,changed,missing,level.isFrozen(),Spawns);
            Console.Printf("SOLO SIDE_EFFECTS external=%d health_losses=%d",ExternalChanges,HealthLosses);
            int failures=(!Finished || changed>0 || missing>0 || actors!=ActorCount || Spawns!=0 || ExternalChanges!=0 || HealthLosses!=0)?1:0;
            for(int i=0;i<9;i++)
            {
                Console.Printf("SOLO COUNTS key=%d requested=%d executed=%d captured=%d",i,Requested[i],Executed[i],Captured[i]);
                if((i!=Mode && Executed[i]!=0) || (i==Mode && (Requested[i]==0 || Executed[i]!=Requested[i])))failures++;
            }
            for(int i=0;i<BatchMS.Size();i++)Console.Printf("SOLO SAMPLE tic=%d ms=%.6f batch=%.6f restore=%.6f",Tics[i],Times[i],BatchMS[i],RestoreMS[i]);
            if(failures>0)Console.Printf("CA282 FAIL isolation failures=%d",failures);
            else Console.Printf("CA282 DONE passes=3 failures=0");
        }
    override void WorldTick()
    {
        Age++;let user=CaelumPlayer(players[0].mo);if(user==null)return;
        if(!Active)
        {
            if(Age==5)
            {user.CharacterCreationComplete=true;user.CreationWizardOpen=false;user.ApplyCharacterProfile();user.bInvulnerable=true;let record=user.GetPersistentCharacterState(true);record.DemoNarrativeDelivered=2047;record.DemoNarrativePending=0;}
            if(Age==135)
            {Port=CaelumPortSiege.Get();let clock=CaelumWorldClock.Get(user,true);let calendar=CaelumCalendarState.Get(user,true);calendar.EnsureCampaign(clock);calendar.SetAnchor(clock,CaelumCityWorld.SiegeDay(),CaelumCityData.SIEGE_HOUR*CaelumWorldClock.TicsPerHour()-1,false);}
            if(Age==3600)
            {CaptureStart=level.time;Recording=true;for(int i=0;i<35;i++)Phases[i]=new("CA318SoloPhase");}
            if(Recording && level.time>=CaptureStart+35)FreezeScene();
            return;
        }
        level.frozen=true;
        if(CVar.GetCVar("ca318_solo_start").GetBool() && !Running && !Finished && ++LoadAge>=70 && level.time%35==CaptureStart%35)Begin();
        if(Finished && !Reported){Finish();Reported=true;}
        if(!Running)return;
        ExternalChanges+=CheckScene();
        double stamp=MSTimeF();Times.Push(stamp);Tics.Push(level.time);
        let phase=Phases[Elapsed%35];Dispatching=true;
        for(int i=0;i<phase.Calls.Size();i++)Dispatch(phase.Calls[i]);
        Dispatching=false;level.frozen=true;
        double after=MSTimeF();RestoreScene();double restored=MSTimeF();
        BatchMS.Push(after-stamp);RestoreMS.Push(restored-after);Elapsed++;
        if(Elapsed>=Window)
        {Running=false;Finished=true;Console.Printf("SOLO END mode=%d tic=%d ms=%.6f samples=%d",Mode,level.time,MSTimeF(),Elapsed);}
    }
}
