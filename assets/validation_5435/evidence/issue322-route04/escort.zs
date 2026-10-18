// Reproducción aislada del giro y de la distancia recorrida por el acompañante.
class CA322Obstacle : Actor
{
    Default { Radius 200; Height 128; +SOLID +NOGRAVITY }
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

    Class<CaelumAnchoredResident> Kind(int i)
    {
        Class<CaelumAnchoredResident> kinds[]={"CaelumPrisonerUnitario","CaelumPrisonerFederal","CaelumPrisonerBestia","CaelumPrisonerTarot"};
        return kinds[Clamp(i,0,3)];
    }
    Vector3 WaypointPosition(int i)
    {
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
        if(Waypoint<6)
        {
            Vector3 point=WaypointPosition(Waypoint);vector2 delta=point.XY-User.Pos.XY;
            if(delta.Length()<=2)Waypoint++;
            else User.TryMove(User.Pos.XY+delta.Unit()*Min(2.0,delta.Length()),0);
        }
        for(int i=0;i<Followers.Size();i++)
        {
            let a=Followers[i];
            if(a.Pos.X+a.Radius>512 && a.Pos.X-a.Radius<640 && a.Pos.Y+a.Radius>-128 && a.Pos.Y-a.Radius<128)WallPenetration=true;
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
        if(e.Name=="c322_route")
        {
            Measuring=false;if(Body!=null)Body.Destroy();Followers.Clear();
            Setup();User.SetOrigin((400,0,0),false);User.Vel=(0,0,0);
            for(int i=0;i<4;i++)
            {
                User.SetPlayerPrisonerRescueState(i,CaelumConstants.PRISONER_STATE_CAPTIVE);
                let follower=CaelumAnchoredResident(Actor.Spawn(Kind(i),(250-i*50,0,0),NO_REPLACE));
                follower.ChangeTid(322+i);Followers.Push(follower);
            }
        }
        if(e.Name=="c322_routestart")
        {
            foreach(follower:Followers)follower.ReleaseEscortPrisoner(User);
            Body=Followers[0];Route=true;RouteAge=0;Waypoint=0;Overlap=false;WallPenetration=false;
        }
        if(e.Name=="c322_routecheck")
        {
            Route=false;Check(Waypoint==6,"leader completed both corners and reversal");
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
            Setup();Body=CaelumAnchoredResident(ActorIterator.Create(322).Next());
            Check(Body!=null && Body.EscortPrisonerId==0 && User.GetPrisonerRescueState(0)==CaelumConstants.PRISONER_STATE_FOLLOWING,"load retains original follower identity and rescue state");
            if(Body!=null)Check(Body.EscortControl!=null && Body.EscortControl.SchemaRevision==1,"existing escort initializes current controller idempotently");
        }
        if(e.Name=="c322_done") {Measuring=false;Check(Body!=null && Body.health>0,"released follower remains present");Console.Printf("CA282 DONE passes=%d failures=%d",Passed,Failed);}
    }
}
