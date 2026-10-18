// Reproducción aislada del giro y de la distancia recorrida por el acompañante.
class CA322Obstacle : Actor
{
    Default { Radius 200; Height 128; +SOLID +NOGRAVITY }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA322Token : Inventory { Default { Inventory.MaxAmount 20; } }
class CA322Snapshot : Actor
{
    Array<CaelumAnchoredResident> Bodies;
    Array<int> Healths;
    Array<double> Bases;
    Default { +NOINTERACTION }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA322Probe : CA282Probe
{
    CaelumAnchoredResident Body;
    bool Measuring;
    int Age, Turns, Frames, SeeFrames;
    double PreviousAngle, Turning, Distance;
    Vector3 Previous;
    State PreviousState;
    bool Route;
    int RouteAge,Waypoint;
    Array<CaelumAnchoredResident> Followers;
    bool Overlap,WallPenetration;
    int Sidesteps;

    bool CorridorContains(vector2 point)
    {
        return (point.X>=-600 && point.X<=648 && point.Y>=-48 && point.Y<=48)
            || (point.X>=552 && point.X<=648 && point.Y>=-48 && point.Y<=600)
            || (point.X>=552 && point.X<=1048 && point.Y>=504 && point.Y<=600);
    }

    Class<CaelumAnchoredResident> Kind(int i)
    {
        Class<CaelumAnchoredResident> kinds[]={"CaelumPrisonerUnitario","CaelumPrisonerFederal","CaelumPrisonerBestia","CaelumPrisonerTarot"};
        return kinds[Clamp(i,0,3)];
    }
    Vector3 WaypointPosition(int i)
    {
        if(level.MapName=="MAP97")
        {
            if(i==0)return (600,0,0);
            if(i==1)return (600,552,0);
            if(i==2)return (960,552,0);
            if(i==3)return (576,524,0);
            if(i==4)return (576,24,0);
            return (-300,24,0);
        }
        if(i==0)return (400,220,0);
        if(i==1)return (800,220,0);
        if(i==2)return (800,0,0);
        if(i==3)return (800,220,0);
        if(i==4)return (400,220,0);
        return (400,0,0);
    }
    void RouteStep()
    {
        RouteAge++;
        User.Vel=(0,0,0);
        User.player.cmd.forwardmove=0;User.player.cmd.sidemove=0;
        if(Waypoint<6)
        {
            Vector3 point=WaypointPosition(Waypoint);vector2 delta=point.XY-User.Pos.XY;
            if(delta.Length()<=2)Waypoint++;
            else
            {
                // Expresar la intención real evita interpretar un empuje del
                // compañero como una orden de marcha contraria del jugador.
                // TryMove conserva toda la colisión del recorrido diagnóstico.
                User.Angle=VectorAngle(delta.X,delta.Y);User.player.cmd.forwardmove=1;
                if(!User.TryMove(User.Pos.XY+delta.Unit()*Min(2.0,delta.Length()),0) && level.MapName=="MAP97")
                {
                    // El conductor diagnóstico también debe apartarse para
                    // cruzar con cuerpos anchos en un corredor de 96 MU.
                    vector2 side=(-delta.Y,delta.X).Unit();
                    if(User.TryMove(User.Pos.XY+side*2,0))Sidesteps++;
                    else if(User.TryMove(User.Pos.XY-side*2,0))Sidesteps++;
                }
            }
        }
        for(int i=0;i<Followers.Size();i++)
        {
            let a=Followers[i];
            if(level.MapName=="MAP99" && a.Pos.X+a.Radius>512 && a.Pos.X-a.Radius<640 && a.Pos.Y+a.Radius>-128 && a.Pos.Y-a.Radius<128)WallPenetration=true;
            if(level.MapName=="MAP97")for(int corner=0;corner<4;corner++)
                if(!CorridorContains(a.Pos.XY+(a.Radius*(corner%2==0?-1:1),a.Radius*(corner<2?-1:1))))WallPenetration=true;
            if(abs(a.Pos.X-User.Pos.X)<a.Radius+User.Radius-0.001 && abs(a.Pos.Y-User.Pos.Y)<a.Radius+User.Radius-0.001)Overlap=true;
            for(int j=i+1;j<Followers.Size();j++)
            {
                let b=Followers[j];double r=a.Radius+b.Radius;
                if(abs(a.Pos.X-b.Pos.X)<r-0.001 && abs(a.Pos.Y-b.Pos.Y)<r-0.001)Overlap=true;
            }
        }
        if(RouteAge%140==0)
        {
            Console.Printf("CA322 ROUTEPOS tic=%d waypoint=%d user=(%.3f,%.3f) radius=%.3f",RouteAge,Waypoint,User.Pos.X,User.Pos.Y,User.Radius);
            foreach(a:Followers)Console.Printf("CA322 FOLLOWPOS id=%d pos=(%.3f,%.3f) giving=%d yield=(%.3f,%.3f) trail=%d path=%d",
                a.EscortPrisonerId,a.Pos.X,a.Pos.Y,a.EscortControl.GivingWay,a.EscortControl.YieldPoint.X,a.EscortControl.YieldPoint.Y,a.EscortControl.TrailSize(),a.EscortControl.Path!=null);
            foreach(a:Followers)Console.Printf("CA322 INTENT id=%d dir=(%.3f,%.3f) step=(%.3f,%.3f)",a.EscortPrisonerId,a.EscortControl.LeaderDirection.X,a.EscortControl.LeaderDirection.Y,a.EscortControl.LeaderStep.X,a.EscortControl.LeaderStep.Y);
        }
    }

    void ResetTrace()
    {
        Age=0;Turns=0;Frames=0;SeeFrames=0;Turning=0;Distance=0;
        Previous=Body.Pos;PreviousAngle=Body.Angle;PreviousState=Body.CurState;
        Measuring=true;
    }
    void Report()
    {
        Console.Printf("CA322 TRACE age=%d distance=%.6f turning=%.6f turns=%d states=%d see=%d base=%.6f speed=%.6f hp=%d max=%d thermal=%.6f pos=(%.3f,%.3f) angle=%.3f",
            Age,Distance,Turning,Turns,Frames,SeeFrames,Body.CombatBaseSpeed,Body.Speed,
            Body.health,Body.CombatMaximumHealth,CaelumThermalEffects.Speed(Body),Body.Pos.X,Body.Pos.Y,Body.Angle);
    }
    override void WorldTick()
    {
        if(Route)RouteStep();
        if(!Measuring || Body==null)return;
        Age++;
        double turn=abs(Body.DeltaAngle(PreviousAngle,Body.Angle));
        if(turn>0.001)Turns++;
        Turning+=turn;Distance+=(Body.Pos-Previous).Length();
        if(Body.CurState!=PreviousState)Frames++;
        if(Body.InStateSequence(Body.CurState,Body.FindState("See")))SeeFrames++;
        if(Age<=8)Console.Printf("CA322 STEP age=%d x=%.4f y=%.4f angle=%.4f vel=(%.4f,%.4f) frame=%d target=%s",
            Age,Body.Pos.X,Body.Pos.Y,Body.Angle,Body.Vel.X,Body.Vel.Y,Body.Frame,Body.Target==null?'none':Body.Target.GetClassName());
        Previous=Body.Pos;PreviousAngle=Body.Angle;PreviousState=Body.CurState;
        if(Age%35==0)Report();
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        Super.NetworkProcess(e);
        if(e.Name=="c322_seed")
        {
            Measuring=false;Route=false;if(Body!=null)Body.Destroy();
            Setup();User.SetOrigin((0,0,0),false);User.Vel=(0,0,0);
            for(int i=0;i<4;i++)User.SetPlayerPrisonerRescueState(i,CaelumConstants.PRISONER_STATE_CAPTIVE);
            Body=CaelumAnchoredResident(Actor.Spawn(Kind(e.Args[0]),(80,0,0),NO_REPLACE));
            Body.ChangeTid(322);
        }
        if(e.Name=="c322_trace") {Body.ReleaseEscortPrisoner(User);ResetTrace();}
        if(e.Name=="c322_manual")
        {
            foreach(follower:Followers)follower.ReleaseEscortPrisoner(User);
            Body=Followers[0];Manual=true;Check(Body!=null,"manual escort preview ready");
            Console.Printf("CA282 DONE passes=%d failures=%d",Passed,Failed);
        }
        if(e.Name=="c322_far") {Report();User.SetOrigin((-512,0,0),false);ResetTrace();}
        if(e.Name=="c322_noise") {Report();User.SetOrigin((0,0,0),false);Body.SetOrigin((80,40,0),false);User.SoundAlert(User);ResetTrace();}
        if(e.Name=="c322_quietcheck")
        {
            Check(Distance<0.001 && Turning<0.001 && Frames==0 && SeeFrames==0,"friendly sound cannot start wandering or walking while stopped");
            Check(Body.Target==null && Body.InStateSequence(Body.CurState,Body.FindState("EscortIdle")),"one escort owner retains idle state without enemy target");
        }
        if(e.Name=="c322_talk")
        {Measuring=false;Body.bInConversation=true;User.player.ConversationNPC=Body;ResetTrace();}
        if(e.Name=="c322_talkcheck")
        {
            Check(Distance<0.001 && Turning<0.001 && Frames==0,"conversation remains physically and visually still");
            Check(User.player.ConversationNPC==Body && Body.bInConversation,"conversation ownership survives escort ticks");
            Body.bInConversation=false;User.player.ConversationNPC=null;
        }
        if(e.Name=="c322_recovery")
        {
            Measuring=false;Body.SetOrigin((2000,0,0),false);User.SetOrigin((0,0,0),false);
            let blocked=Actor.Spawn("CA322Obstacle",User.Pos,NO_REPLACE);
            Check(!blocked.bShootable && blocked.bSolid,"recovery obstacle is solid and not shootable");
            vector3 before=Body.Pos;
            Check(!Body.EscortControl.Recover(Body,User) && Body.Pos==before,"no free candidate leaves original body unmoved");
            blocked.Destroy();
            Body.ForcedSleepTics=35;
            Check(!Body.EscortControl.Recover(Body,User) && Body.Pos==before,"sleep prevents recovery relocation");
            Body.ForcedSleepTics=0;
            Check(Body.EscortControl.Recover(Body,User),"free recovery succeeds");
            Check(Body.Distance2D(User)>Body.Radius+User.Radius && Body.TestMobjLocation(),"recovery respects player separation and native clearance");
        }
        if(e.Name=="c322_formula")
        {
            Measuring=false;
            int agility=Body.CombatAgility+Body.GetCombatArmorAttributeBonus(CaelumConstants.ATTRIBUTE_AGILITY);
            int strength=Body.CombatStrength+Body.GetCombatArmorAttributeBonus(CaelumConstants.ATTRIBUTE_STRENGTH);
            double load=Body.GetAttackCarriedWeight()/(Body.Mass*CaelumGrowthRules.Multiplier(strength,2));
            double expected=CaelumConstants.GZDOOM_BASE_MAX_WALK_SPEED*CaelumGrowthRules.Multiplier(agility,2)*(1-Clamp(load,0.0,1.0));
            double healthy=Body.EscortControl.WalkingSpeed(Body);
            Check(abs(healthy-expected)<0.00001,"healthy walk matches player base, Agility and carried load");
            Body.CurrentCombatAir=Body.MaximumCombatAir*CaelumConstants.AIR_BREATHLESS_THRESHOLD;
            Check(abs(Body.EscortControl.WalkingSpeed(Body)-healthy*CaelumConstants.BREATHLESS_PERFORMANCE_MULTIPLIER)<0.00001,"breathless penalty matches player rule");
            Body.CurrentCombatAir=Body.MaximumCombatAir;
            Body.health=Max(1,int(Body.CombatMaximumHealth*CaelumConstants.HEALTH_BADLY_WOUNDED_THRESHOLD));Body.UpdateCombatHealthEffects();
            Check(Body.EscortControl.WalkingSpeed(Body)<healthy,"wounds slow escort without changing source base speed");
            Console.Printf("CA322 SPEED kind=%d healthy=%.6f mps=%.6f load=%.6f agility=%d",Body.EscortPrisonerId,healthy,CaelumPhysicsUnits.VelocitySI(healthy),load,agility);
            Body.health=Body.CombatMaximumHealth;Body.UpdateCombatHealthEffects();
        }
        if(e.Name=="c322_edges")
        {
            Measuring=false;User.SetOrigin((5000,0,0),false);Body.SetOrigin((-300,0,0),false);
            vector3 before=Body.Pos;
            Check(!Body.EscortControl.Recover(Body,User) && Body.Pos==before,"low ceiling rejects recovery without moving body");
            User.SetOrigin((6000,0,0),false);
            Check(!Body.EscortControl.Recover(Body,User) && Body.Pos==before,"unsupported floor below candidate rejects recovery");
            User.SetOrigin((-300,24,0),false);
            let wallBlock=Actor.Spawn("CA322Obstacle",(-300,-180,0),NO_REPLACE);
            Check(!Body.EscortControl.Recover(Body,User) && Body.Pos==before,"no recovery into BSP void beyond the corridor wall");
            wallBlock.Destroy();
            User.SetOrigin((-200,0,0),false);
            Body.EscortControl.LeaderDirection=(1,0);Body.EscortControl.PreviousLeader=User.Pos;
            Body.EscortControl.GivingWay=false;User.player.cmd.forwardmove=0;User.player.cmd.sidemove=0;
            Body.EscortControl.Observe(Body,User);
            Check(!Body.EscortControl.LeaderIntendsMove && !Body.EscortControl.GiveWay(Body,User,1),"stale direction does not start a new yield when player is still");
            Body.SetOrigin((-300,0,64),false);Body.EscortControl.Acceleration=0;
            Body.EscortControl.MoveTowards(Body,(-250,0),Body.EscortControl.WalkingSpeed(Body),-1);
            Check(Body.EscortControl.Acceleration==0,"ordinary airborne movement does not increase acceleration");
            Body.SetOrigin(before,false);Body.Vel=(0,0,0);
            Body.RecoveryRevision=1;Body.RecoveryPhase=2;
            Body.CurrentCombatAir=Body.MaximumCombatAir;Body.CurrentCombatAnima=Body.MaximumCombatAnima;
        }
        if(e.Name=="c322_recovered")
        {Check(Body.RecoveryPhase==0,"full resources end quiet recovery and resume escort");}
        if(e.Name=="c322_stairs")
        {
            Measuring=false;Body.ReleaseEscortPrisoner(User);
            User.SetOrigin((128,0,64),false);User.Vel=(0,0,0);
            Body.SetOrigin((48,0,32),false);Body.Vel=(0,0,0);Previous=Body.Pos;
        }
        if(e.Name=="c322_stairscheck")
        {
            Check(Body.Pos.X>Previous.X+16,"nearby visible leader on higher floor does not stop escort below stairs");
            Check(abs(Body.FloorZ-User.FloorZ)<0.001 && Body.TestMobjLocation(),"escort climbs native steps and stops on the leader's level");
        }
        if(e.Name=="c322_snapshot")
        {
            let saved=CA322Snapshot(Actor.Spawn("CA322Snapshot",User.Pos,NO_REPLACE));
            for(int i=0;i<Followers.Size();i++)
            {
                let follower=Followers[i];follower.ReleaseEscortPrisoner(User);
                let token=follower.GiveInventoryType("CA322Token");token.Amount=3+i;
                follower.health=follower.CombatMaximumHealth-100;
                follower.bInConversation=true;
                saved.Bodies.Push(follower);saved.Healths.Push(follower.health);saved.Bases.Push(follower.CombatBaseSpeed);
            }
            User.player.ConversationNPC=Followers[0];Body=Followers[0];
        }
        if(e.Name=="c322_savedcheck")
        {
            User=CaelumPlayer(players[consoleplayer].mo);
            let saved=CA322Snapshot(ThinkerIterator.Create("CA322Snapshot").Next());
            Check(saved!=null && saved.Bodies.Size()==4,"save retains four original follower references");
            if(saved!=null)for(int i=0;i<saved.Bodies.Size();i++)
            {
                let follower=saved.Bodies[i];int count=0;let it=ActorIterator.Create(322+i);Actor found;
                while((found=it.Next())!=null){count++;Check(found==follower,"saved reference matches original world actor");}
                Check(count==1 && follower.EscortPrisonerId==i,"load retains identity without duplicating follower");
                Check(follower.health==saved.Healths[i] && follower.CombatBaseSpeed==saved.Bases[i],"load preserves exact individual health and source speed");
                let token=follower.FindInventory("CA322Token");
                Check(token!=null && token.Owner==follower && token.Amount==3+i,"load preserves individual inventory and ownership");
                Check(User.GetPrisonerRescueState(i)==CaelumConstants.PRISONER_STATE_FOLLOWING && !User.IsPlayerPrisonerRewardClaimed(i),"load preserves rescue and unpaid reward state");
                Check(follower.EscortControl!=null && follower.EscortControl.SchemaRevision==1,"current or legacy follower adopts revision once");
                let control=follower.EscortControl;follower.UpdateEscortPrisoner();follower.UpdateEscortPrisoner();
                Check(follower.EscortControl==control && follower.health==saved.Healths[i],"migration is idempotent and keeps saved body state");
                follower.bInConversation=false;
            }
            if(saved!=null)Body=saved.Bodies[0];User.player.ConversationNPC=null;
        }
        if(e.Name=="c322_route")
        {
            Measuring=false;if(Body!=null)Body.Destroy();Followers.Clear();
            Setup();User.SetOrigin(level.MapName=="MAP97"?(-300,0,0):(400,0,0),false);User.Vel=(0,0,0);
            for(int i=0;i<4;i++)
            {
                User.SetPlayerPrisonerRescueState(i,CaelumConstants.PRISONER_STATE_CAPTIVE);
                let follower=CaelumAnchoredResident(Actor.Spawn(Kind(i),((level.MapName=="MAP97"?-400:250)-i*50,0,0),NO_REPLACE));
                follower.ChangeTid(322+i);Followers.Push(follower);
            }
        }
        if(e.Name=="c322_closed")
        {
            foreach(follower:Followers)follower.ReleaseEscortPrisoner(User);
            Body=Followers[0];User.SetOrigin((150,0,0),false);
        }
        if(e.Name=="c322_closedcheck")
        {
            foreach(follower:Followers)Check(follower.Pos.X+follower.Radius<=-16,"closed sector door blocks following without relocation");
            User.A_CallSpecial(11,322,16);
        }
        if(e.Name=="c322_routestart")
        {
            foreach(follower:Followers)follower.ReleaseEscortPrisoner(User);
            Body=Followers[0];Route=true;RouteAge=0;Waypoint=0;Overlap=false;WallPenetration=false;Sidesteps=0;
        }
        if(e.Name=="c322_routecheck")
        {
            Route=false;Check(Waypoint==6,"leader completed both corners and reversal");
            Console.Printf("CA322 DRIVER sidesteps=%d",Sidesteps);
            Check(!Overlap && !WallPenetration,"four followers never overlap a body or cross the solid pillar");
            for(int i=0;i<Followers.Size();i++)
            {
                let follower=Followers[i];
                Console.Printf("CA322 ROUTE kind=%d distance=%.3f pos=(%.3f,%.3f) hp=%d",i,follower.Distance2D(User),follower.Pos.X,follower.Pos.Y,follower.health);
                Check(follower.Distance2D(User)<CaelumConstants.PRISONER_FOLLOW_DISTANCE+follower.Radius*4,"each follower reaches leader after corners/reversal");
            }
        }
        if(e.Name=="c322_loaded")
        {
            User=CaelumPlayer(players[consoleplayer].mo);Body=CaelumAnchoredResident(ActorIterator.Create(322).Next());
            Check(Body!=null && Body.EscortPrisonerId==0 && User.GetPrisonerRescueState(0)==CaelumConstants.PRISONER_STATE_FOLLOWING,"load retains original follower identity and rescue state");
            if(Body!=null)Check(Body.EscortControl!=null && Body.EscortControl.SchemaRevision==1,"existing escort initializes current controller idempotently");
        }
        if(e.Name=="c322_done") {Measuring=false;Check(Body!=null && Body.health>0,"released follower remains present");Console.Printf("CA282 DONE passes=%d failures=%d",Passed,Failed);}
    }
}
