// Prueba privada de selección, oclusión y lectura; sin datos de balance.
class CA481Enemy : CaelumCombatActor
{
    override void Tick() { Vel=(0,0,0); }
    Default { Radius 16; Height 64; Scale 0.15; Health 1000; +SOLID +SHOOTABLE +NOGRAVITY Tag "Target attribute fixture"; }
    States { Spawn: RUID A -1; Stop; }
}
class CA481Invisible : Actor
{
    Default { Radius 16; Height 64; +INVISIBLE +NOGRAVITY }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA481Fixture : StaticEventHandler
{
    Actor Objects[7];
    int Selected,Passed,Failed;
    bool Ready;
    void Check(bool ok,String name)
    {if(ok)Passed++;else Failed++;Console.Printf("CA481 %s %s",ok?"PASS":"FAIL",name);}
    void Focus(CaelumPlayer u,int index)
    {
        Selected=Clamp(index,0,6);let object=Objects[Selected];
        u.SetOrigin(object.Pos-(64,0,0),false);u.Angle=0;
        u.Pitch=VectorAngle(64,u.ViewHeight-object.Height/2);
        if(u.TargetInfo==null)u.TargetInfo=new("CaelumTargetInfo");
        u.TargetInfo.Refresh(u);
    }
    void Setup(CaelumPlayer u)
    {
        if(Ready)return;
        u.bInvulnerable=true;u.CreationWizardOpen=false;u.CharacterCreationComplete=true;
        u.CurrentHunger=100;u.CurrentThirst=100;u.CurrentSleep=100;
        u.Attributes.Insight=2;
        Objects[0]=Actor.Spawn("CA481Enemy",(0,0,0),NO_REPLACE);
        Objects[1]=Actor.Spawn("CaelumStashChest",(256,0,0),NO_REPLACE);
        Objects[2]=Actor.Spawn("CaelumSlidingDoorLeaf",(512,0,0),NO_REPLACE);
        Objects[3]=Actor.Spawn("CaelumRestChair",(768,0,0),NO_REPLACE);
        Objects[4]=Actor.Spawn("CaelumHousePortal",(0,384,0),NO_REPLACE);
        Objects[5]=Actor.Spawn("CaelumAlchemyStation",(256,384,0),NO_REPLACE);
        Objects[6]=Actor.Spawn("CaelumRestBed",(512,384,0),NO_REPLACE);
        let enemy=CaelumCombatActor(Objects[0]);
        enemy.CombatStrength=1;enemy.CombatToughness=2;enemy.CombatConstitution=3;
        enemy.CombatMaximumHealth=1000;enemy.health=750;
        enemy.MaximumCombatAnima=1000;enemy.CurrentCombatAnima=500;
        enemy.MaximumCombatAir=1000;enemy.CurrentCombatAir=250;
        enemy.MaximumCombatAdrenaline=1000;enemy.CurrentCombatAdrenaline=125;
        Ready=true;Focus(u,0);
        Console.Printf("CA481 RESULT manual fixture ready; F1 target, F2 Insight");
    }
    void Checks(CaelumPlayer u)
    {
        let subject=CaelumCombatActor(Objects[0]);subject.CombatMaximumHealth=1000;subject.health=750;
        Check(CaelumTargetInfo.VisibleAttribute(1,2)=="1.0","attribute below Insight");
        Check(CaelumTargetInfo.VisibleAttribute(2,2)=="¿?","equal attribute hidden");
        Check(CaelumTargetInfo.VisibleAttribute(3,2)=="¿?","greater attribute hidden");
        Check(CaelumTargetInfo.Attribute(Objects[0],2)==3,"authoritative constitution");
        for(int i=0;i<7;i++)
        {
            Focus(u,i);Check(u.TargetInfo.Subject==Objects[i],String.Format("aim target %d",i));
            Check(u.TargetInfo.Title!="",String.Format("target name %d",i));
            if(i>0)Check(u.TargetInfo.Actions!="",String.Format("target actions %d",i));
        }
        Check(!CaelumStashChest(Objects[1]).ChestOpen,"inspection does not open chest");
        Check(!CaelumSlidingDoorLeaf(Objects[2]).DoorRequested,"inspection does not open door");
        Check(CaelumRestFurniture(Objects[3]).Occupant==null,"inspection does not sit");
        Focus(u,0);u.Angle=180;u.TargetInfo.Refresh(u);
        Check(u.TargetInfo.Subject==null && u.TargetInfo.Title=="","empty aim clears panel");
        let hidden=Actor.Spawn("CA481Enemy",(1350,768,0),NO_REPLACE);
        u.SetOrigin((1100,768,0),false);u.Angle=0;u.Pitch=0;u.TargetInfo.Refresh(u);
        Check(u.TargetInfo.Subject!=hidden,"wall occludes target");
        let helper=Actor.Spawn("CA481Invisible",(1130,768,0),NO_REPLACE);u.TargetInfo.Refresh(u);
        Check(u.TargetInfo.Subject!=hidden,"invisible helper never bypasses wall");
        helper.Destroy();hidden.Destroy();
        u.SetOrigin((900,-640,0),false);u.Angle=0;u.Pitch=0;u.TargetInfo.Refresh(u);
        Check(u.TargetInfo.TargetLine!=null && u.TargetInfo.TargetLine.special==74,"crossable map transition selected");
        Check(u.TargetInfo.Actions==CaelumTargetInfo.L("CA_TARGET_CROSS"),"crossable transition action");
        Check(Abs(u.TargetInfo.Distance-60)<0.01,"transition uses candidate distance");
        let occluder=Actor.Spawn("CA481Enemy",(930,-640,0),NO_REPLACE);u.TargetInfo.Refresh(u);
        Check(u.TargetInfo.Subject==occluder && u.TargetInfo.TargetLine==null,"actor occludes crossable transition");
        occluder.Destroy();
        u.SetOrigin((900,-448,0),false);u.TargetInfo.Refresh(u);
        Check(u.TargetInfo.TargetLine!=null && u.TargetInfo.TargetLine.special==10,"native line door selected");
        Check(u.TargetInfo.Actions==CaelumTargetInfo.L("CA_TARGET_OPEN"),"native line door action");
        Console.Printf("CA481 RESULT checks passed=%d failed=%d",Passed,Failed);Focus(u,0);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(level.MapName!="CTGT481")return;
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=="ca481_setup")Setup(u);
        if(e.Name=="ca481_reloaded")
        {
            Check(u.TargetInfo!=null && u.TargetInfo.Subject is 'CaelumStashChest',"target reconstructed after load");
            Check(u.TargetInfo!=null && u.TargetInfo.Actions!="","interaction restored after load");
            Console.Printf("CA481 RESULT load passed=%d failed=%d",Passed,Failed);
        }
        if(!Ready)return;
        if(e.Name=="ca481_checks")Checks(u);
        if(e.Name=="ca481_next")Focus(u,(Selected+1)%7);
        if(e.Name=="ca481_select")Focus(u,e.Args[0]);
        if(e.Name=="ca481_insight")u.Attributes.Insight=u.Attributes.Insight<100?100:2;
    }
}

class CA481UICheck : EventHandler
{
    ui Array<double> Intervals;
    ui double PreviousFrame,StartedAt;
    ui int StartedTic;
    ui bool Capturing;
    override void RenderOverlay(RenderEvent e)
    {
        if(!Capturing)return;
        double stamp=MSTimeF();
        if(PreviousFrame>0)Intervals.Push(stamp-PreviousFrame);
        PreviousFrame=stamp;
    }
    override void ConsoleProcess(ConsoleEvent e)
    {
        if(e.Name=="ca481_perf_start")
        {Intervals.Clear();PreviousFrame=0;StartedAt=MSTimeF();StartedTic=level.time;Capturing=true;return;}
        if(e.Name=="ca481_perf_stop")
        {
            Capturing=false;
            Console.Printf("CA481 PERF start_ms=%.6f end_ms=%.6f tics=%d",StartedAt,MSTimeF(),level.time-StartedTic);
            for(int i=0;i<Intervals.Size();i++)Console.Printf("CA481 FRAME %.6f",Intervals[i]);
            Console.Printf("CA481 RESULT frame samples=%d",Intervals.Size());return;
        }
        if(e.Name!="ca481_ui_check")return;
        let u=CaelumPlayer(players[consoleplayer].mo);
        String actions=CaelumInputHints.Resolve(u.TargetInfo.Actions);
        bool ok=CaelumInputHints.Keys("+use").IndexOf("R")>=0 || CaelumInputHints.Keys("+use").IndexOf("r")>=0;
        Console.Printf("CA481 %s remapped key in live UI: %s",ok?"PASS":"FAIL",actions);
    }
}
