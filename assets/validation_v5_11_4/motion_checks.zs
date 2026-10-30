// Native movement checks: real bodies, animation, collision and authored stairs.
class CA430MotionChecks : EventHandler
{
    Array<CaelumCombatActor> Bodies;
    Array<double> InitialX,InitialAir;
    Array<int> Frames;
    bool Active,Stairs,Descending,SawRun,SawWalk,Finished,Stuck;
    int Started,StepIndex,Failures,FinishAfter;
    CaelumPalomo Route;
    CaelumSlidingDoorLeaf DoorA,DoorB;
    void Check(bool ok,String label)
    {if(ok)Console.Printf("CA430 PASS %s",label);else{Failures++;Console.Printf("CA430 FAIL %s",label);}}
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=='ca430_near')
        {
            players[0].mo.SetOrigin(Bodies[1].Pos+(60,0,0),false);return;
        }
        if(e.Name=='ca430_doorprofile')
        {
            let leaf=CaelumSlidingDoorLeaf(Actor.Spawn('CaelumSlidingDoorLeaf',(-10000,-10000,0),NO_REPLACE));leaf.Peers();
            Check(CaelumPolyDoorEvents.Get().PeerRegistry.Rebuilds==1,"city door registry bootstraps once");
            Console.Printf("CA430 RESULT door profile");return;
        }
        if(e.Name=='ca430_doors')
        {
            let user=CaelumPlayer(players[0].mo);user.SetOrigin((300,0,0),false);
            let primer=CaelumSlidingDoorLeaf(Actor.Spawn('CaelumSlidingDoorLeaf',(-400,-400,0),NO_REPLACE));primer.Peers();
            DoorA=CaelumSlidingDoorLeaf(Actor.Spawn('CaelumSlidingDoorLeaf',(200,-32,0),NO_REPLACE));
            DoorB=CaelumSlidingDoorLeaf(Actor.Spawn('CaelumSlidingDoorLeaf',(200,32,0),NO_REPLACE));
            DoorA.args[0]=DoorB.args[0]=9999;DoorB.args[3]=200;
            DoorA.Peers();
            Check(DoorA.Peers()==DoorB.Peers(),"late assigned leaves share one cached group");
            Check(!DoorA.RequestDoorGroup(user),"peer lock rejects missing key");
            user.GiveInventoryType('CaelumSilverKey');
            Check(DoorA.RequestDoorGroup(user) && DoorB.DoorRequested,"key opens both cached leaves");
            DoorB.RuloArenaLocked=true;
            Check(!DoorA.RequestDoorGroup(user),"arena lock still denies group");DoorB.RuloArenaLocked=false;
            Console.Printf("CA430 RESULT cached door checks");return;
        }
        if(e.Name=='ca430_doors_reload')
        {
            let registry=CaelumPolyDoorEvents.Get().PeerRegistry;
            Check(registry!=null && registry.Rebuilds==1,"door registry rebuilt once only");
            Check(DoorA.Peers()==DoorB.Peers(),"door peers survive save reload");
            Check(CaelumPlayer(players[0].mo).FindInventory('CaelumSilverKey')!=null,"opening retains the key");
            Console.Printf("CA430 RESULT door reload checks");return;
        }
        if(e.Name=='ca430_prisoners')
        {
            let user=CaelumPlayer(players[0].mo);user.bInvulnerable=true;user.SetOrigin((300,0,0),false);user.Angle=0;
            for(int i=0;i<4;i++)
            {
                user.SetPlayerPrisonerRescueState(i,CaelumConstants.PRISONER_STATE_FOLLOWING);
                Name kind=i==0?'CaelumPrisonerUnitario':i==1?'CaelumPrisonerFederal':i==2?'CaelumPrisonerTarot':'CaelumPrisonerBestia';
                let body=CaelumCombatActor(Actor.Spawn(kind,(-400+i*64,0,0),NO_REPLACE));Bodies.Push(body);
            }
            return;
        }
        if(e.Name=='ca430_prisoners_follow')
        {
            let party=CaelumCompanionParty.Get(CaelumPlayer(players[0].mo),true);
            for(int i=0;i<Bodies.Size();i++)
            {
                let body=Bodies[i];Check(party.Recruit(body),String.Format("prisoner %d recruits after release",i));
                InitialX.Push(body.Pos.X);InitialAir.Push(body.CurrentCombatAir);Frames.Push(1<<body.frame);
            }
            party.Formation.SetShape(CaelumFormationData.COLUMN,true);
            Active=true;Started=level.time;FinishAfter=700;return;
        }
        if(e.Name=='ca430_diagnose')
        {
            let b=Bodies[0];let m=b.Companion.Motion;let u=CaelumPlayer(players[0].mo);
            Console.Printf("CA430 YIELD intent=%d dir=(%.3f,%.3f) giving=%d goal=(%.4f,%.4f) body=(%.4f,%.4f,%.4f) radius=%.3f floor=%.3f drop=%.3f step=%.3f cmd=%d",m.Walker.LeaderIntendsMove,m.Walker.LeaderDirection.X,m.Walker.LeaderDirection.Y,m.Walker.GivingWay,m.Walker.YieldPoint.X,m.Walker.YieldPoint.Y,b.Pos.X,b.Pos.Y,b.Pos.Z,b.Radius,b.FloorZ,b.MaxDropOffHeight,b.MaxStepHeight,u.player.cmd.forwardmove);
            for(int n=0;n<4;n++)
            {
                vector2 direction=n==0?(1,0):n==1?(-1,0):n==2?(0,1):(0,-1);
                vector3 p=(b.Pos.XY+direction*b.Radius/2,b.Pos.Z);FCheckPosition f;
                bool fit=b.CheckPosition(p.XY,false,f),clear=m.Walker.ClearSegment(b,p,0);
                Console.Printf("CA430 CANDIDATE %d fit=%d clear=%d floor=%.3f ceil=%.3f drop=%.3f blocker=%s",n,fit,clear,f.floorz,f.ceilingz,f.dropoffz,b.BlockingMobj!=null?b.BlockingMobj.GetClassName():'none');
            }
            Console.Printf("CA430 RESULT diagnosed yield");return;
        }
        if(e.Name=='ca430_continue'){Failures=0;Finished=false;Active=true;Started=level.time;FinishAfter=1700;return;}
        if(e.Name=='ca430_motion_snapshot'){Console.Printf("CA430 RESULT motion diagnostics captured");return;}
        if(e.Name!='ca430_motion' && e.Name!='ca430_stairs' && e.Name!='ca430_stuck' && e.Name!='ca430_descent')return;
        let user=CaelumPlayer(players[0].mo);user.bInvulnerable=true;
        user.SetOrigin((1100,0,0),false);user.Angle=0;
        let party=CaelumCompanionParty.Get(user,true);
        Stuck=e.Name=='ca430_stuck';Stairs=e.Name=='ca430_stairs' || e.Name=='ca430_descent';Started=level.time;Active=true;
        let world=CaelumMainM00QuestController(EventHandler.Find('CaelumMainM00QuestController'));
        world.EnsureResidentRegistry();
        for(int i=0;i<(Stuck?1:4);i++)
        {
            let body=world.StoryResidents[i];
            body.SetOrigin(e.Name=='ca430_descent'?(1000+i*80,0,264):Stuck?(1642.8,73.8,136):(200+i*80,0,0),false);body.Vel=(0,0,0);
            Check(party.Recruit(body),String.Format("recruits actual resident %d",i));
            Bodies.Push(body);InitialX.Push(body.Pos.X);InitialAir.Push(body.CurrentCombatAir);Frames.Push(1<<body.frame);
        }
        party.Formation.SetShape(CaelumFormationData.COLUMN,true);
        Route=CaelumPalomo(Actor.Spawn('CaelumPalomo',(0,0,-10000),NO_REPLACE));
        Route.bNoInteraction=true;Route.bSolid=false;Route.bShootable=false;
        StepIndex=1;FinishAfter=Stairs?3700:700;
        if(e.Name=='ca430_descent'){user.SetOrigin((1600,0,264),false);StepIndex=9;Descending=true;}
    }
    override void WorldTick()
    {
        if(!Active || Finished)return;
        let user=CaelumPlayer(players[0].mo);
        for(int i=0;i<Bodies.Size();i++)
        {
            let body=Bodies[i];Frames[i]|=1<<body.frame;
            if(body.Companion.Motion!=null)
            {if(body.Companion.Motion.Running)SawRun=true;else SawWalk=true;}
        }
        if(Stairs && StepIndex>=0 && StepIndex<=10)
        {
            vector3 point=StepIndex==0?(1100,0,0):Route.GetDepartureWaypoint(StepIndex);
            vector2 offset=point.XY-user.Pos.XY;
            if(offset.Length()<3 && Abs(user.Pos.Z-point.Z)<24)StepIndex+=Descending?-1:1;
            else
            {
                user.Vel.X=0;user.Vel.Y=0;user.Angle=VectorAngle(offset.X,offset.Y);user.player.cmd.forwardmove=1;
                if(offset.Length()>0){if(!user.TryMove(user.Pos.XY+offset.Unit()*Min(2.0,offset.Length()),0)){CaelumCompanionMotion.OpenBlockedDoor(user);if(level.time%175==0){let line=user.MovementBlockingLine!=null?user.MovementBlockingLine:user.BlockingLine;Console.Printf("CA430 BLOCK actor=%s line=%d special=%d id=%d",user.BlockingMobj!=null?user.BlockingMobj.GetClassName():'none',line!=null?line.Index():-1,line!=null?line.special:0,line!=null?line.args[0]:0);}}}
            }
        }
        if(Stairs && StepIndex<0){user.Vel=(0,0,0);user.player.cheats|=CF_TOTALLYFROZEN;}
        if(Stairs && StepIndex==11 && level.time-Started>1050)
        {Descending=true;StepIndex=10;}
        if((level.time-Started)%175==0)
        {
            Console.Printf("CA430 MOTION t=%d step=%d user=(%.1f,%.1f,%.1f)",level.time-Started,StepIndex,user.Pos.X,user.Pos.Y,user.Pos.Z);
            for(int i=0;i<Bodies.Size();i++){let b=Bodies[i];let m=b.Companion.Motion;Console.Printf("CA430 POSITION %d (%.1f,%.1f,%.1f) air=%.2f speed=%.3f motion=%d controlled=%d pose=%d direct=%d path=%d node=%d end=%d target=%s blocker=%s line=%d cursor=%d",i,b.Pos.X,b.Pos.Y,b.Pos.Z,b.CurrentCombatAir,m!=null?m.Walker.WalkingSpeed(b):0,m!=null,CaelumCompanions.Controlled(b),CaelumCompanionMotion.Pose(b),m!=null?m.Direct:false,m!=null&&m.Walker.Path!=null?m.Walker.Path.PointX.Size():-1,m!=null?m.MansionNode:-1,m!=null?m.MansionEnd:-1,b.target!=null?b.target.GetTag():"none",b.BlockingMobj!=null?b.BlockingMobj.GetClassName():'none',b.MovementBlockingLine!=null?b.MovementBlockingLine.Index():-1,m!=null&&m.Walker.Path!=null?m.Walker.Path.Cursor:-1);}
        }
        if((level.time-Started)%175==0 && Bodies.Size()>0)
        {
            let b=Bodies[0];let m=b.Companion.Motion;
            if(m!=null && m.Walker.Path!=null && m.Walker.Path.Cursor<m.Walker.Path.PointX.Size())
            {
                vector2 p=m.Walker.Path.Point(m.Walker.Path.Cursor),d=p-b.Pos.XY;
                bool fits=d.Length()>0 && b.CheckMove(b.Pos.XY+d.Unit()*Min(d.Length(),1),0);
                Console.Printf("CA430 ROUTE point=(%.1f,%.1f) fits=%d block=%s line=%d give=%d floor=%.1f",p.X,p.Y,fits,b.BlockingMobj!=null?b.BlockingMobj.GetClassName():'none',b.BlockingLine!=null?b.BlockingLine.Index():-1,m.Walker.GivingWay,b.FloorZ);
            }
        }
        if(level.time-Started<FinishAfter)return;
        Finished=true;
        for(int i=0;i<Bodies.Size();i++)
        {
            Check((Stuck || Stairs)?Bodies[i].Pos.Z<24:Bodies[i].Pos.X>InitialX[i]+32,String.Format("resident %d advances under its native Tick",i));
            Check((Frames[i]&(Frames[i]-1))!=0,String.Format("resident %d changes animation frame",i));
        }
        Check(SawRun,"distant followers enter running");Check(SawWalk,"near followers return to walking");
        if(Stairs)
        {
            Check(Descending && StepIndex==-1,"player traverses both authored stair flights and returns");
            for(int i=0;i<Bodies.Size();i++)Check(Bodies[i].Pos.Z<24 && Bodies[i].Pos.X>800,
                String.Format("resident %d returns downstairs without teleporting",i));
        }
        Console.Printf("CA430 RESULT native motion failures=%d",Failures);
    }
}
