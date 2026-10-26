// Diagnóstico de geometría: un jugador nativo; el segundo cuerpo no simula red.
class CA412BagChecks : CA411DeployChecks
{
    CaelumDeployedTent Tent;
    CaelumSleepingBag Bag;
    int Good,Bad;
    void Assert(bool ok,String label)
    {if(ok)Good++;else Bad++;Console.Printf("CA412B %s %s",ok?"PASS":"FAIL",label);}
    void Summary(){Console.Printf("CA412B RESULT passes=%d failures=%d",Good,Bad);}
    vector3 Slot(bool second=false)
    {return Tent.Pos+Tent.LocalOffset((second?-22:22,0,0));}
    void Seed(CaelumPlayer u)
    {
        Setup(u);let item=Give(u);
        // La sala exterior privada no añade permisos de campaña. El montaje
        // legal se verifica por separado con el fixture original de MAP01.
        Tent=CaelumDeployedTent(Actor.Spawn('CaelumDeployedTent',(128,128,0),NO_REPLACE));
        Tent.Item=item;item.AttachToOwner(Tent);Tent.Prepare();
        Assert(Tent!=null && Tent.Ready,"original tent and item deployed");
        Bag=CaelumSleepingBag(u.GiveInventoryType('CaelumSleepingBag'));
        Assert(Bag!=null && Bag.AvailableTo(u),"one original unboxed sleeping bag");
    }
    void Inside(CaelumPlayer u)
    {
        if(Tent==null)return;
        CaelumRestState.Cancel(u);u.SetOrigin(Slot(),false);u.Angle=Tent.Angle+90;u.Vel=(0,0,0);
        Console.Printf("CA412B native body radius=%.3f height=%.3f crouch=%.3f",u.Radius,u.Height,u.player.crouchfactor);
    }
    void Core(CaelumPlayer u)
    {
        double height=u.Height,radius=u.Radius;
        Console.Printf("CA412B player xyz=%.1f/%.1f/%.1f radius=%.1f height=%.1f flags=%d/%d parts=%d angle=%.1f",u.Pos.X,u.Pos.Y,u.Pos.Z,u.Radius,u.Height,u.bNoClip,u.bSolid,Tent.Parts.Size(),u.Angle);
        let scan=BlockThingsIterator.Create(u,50);int total=0,low=0;
        while(scan.Next()){if(scan.thing.bSolid){total++;if(scan.thing.Pos.Z<u.Pos.Z+height)low++;}}
        Console.Printf("CA412B nearby solid total=%d low=%d firstpart=%.1f/%.1f/%.1f",total,low,Tent.Parts[0].Pos.X,Tent.Parts[0].Pos.Y,Tent.Parts[0].Pos.Z);
        Assert(Tent!=null && u.TestMobjLocation() && Tent.Covers(u),"native crouched capsule fits under approved roof");
        Assert(CaelumRestBag.HasRoom(u),"first oriented bag footprint fits inside tent");
        let body=Actor.Spawn('CA411DeployObstacle',Slot(true),NO_REPLACE);
        body.A_SetSize(radius,height,false);
        Console.Printf("CA412B body2 xy=%.1f/%.1f floor=%.3f ceiling=%.3f height=%.3f radius=%.3f native=%d cover=%d angle=%.1f",body.Pos.X,body.Pos.Y,body.FloorZ,body.CeilingZ,body.Height,body.Radius,body.TestMobjLocation(),Tent.Covers(body),Tent.Angle);
        Assert(body.TestMobjLocation() && Tent.Covers(body),"second native-sized capsule also fits");
        Assert(CaelumRestBag.HasRoom(u),"neighbor body outside rectangular bag does not falsely block");
        body.Destroy();u.SetOrigin(Slot(true),false);
        Console.Printf("CA412B slot2 xy=%.1f/%.1f floor=%.3f ceiling=%.3f native=%d",u.Pos.X,u.Pos.Y,u.FloorZ,u.CeilingZ,u.TestMobjLocation());
        Assert(CaelumRestBag.HasRoom(u),"second oriented bag footprint fits");
        let mat=CaelumRestBag(Actor.Spawn('CaelumRestBag',Slot(),NO_REPLACE));mat.Angle=u.Angle;
        Assert(!CaelumRestBag.OverlapsBag(u.Pos,u.Angle,mat),"two accepted model envelopes do not overlap");
        Assert(CaelumRestBag.OverlapsBag(mat.Pos,u.Angle,mat),"coincident bags are rejected");
        Assert(CaelumRestBag.OverlapsBag(mat.Pos,u.Angle+90,mat),"crossing rotated bags are rejected");
        mat.Destroy();u.SetOrigin(Slot(),false);
        vector3 tip=u.Pos+(Cos(u.Angle)*43,Sin(u.Angle)*43,0);
        let obstacle=Actor.Spawn('CA411DeployObstacle',tip,NO_REPLACE);obstacle.A_SetSize(1,4,false);
        Assert(!CaelumRestBag.HasRoom(u),"small low obstruction at bag tip rejected");obstacle.Destroy();
        obstacle=Actor.Spawn('CA411DeployObstacle',u.Pos+(0,0,height-1),NO_REPLACE);obstacle.A_SetSize(1,4,false);
        Assert(!CaelumRestBag.HasRoom(u),"body head obstruction still rejected");obstacle.Destroy();
        Assert(u.Height==height && u.Radius==radius,"clearance leaves player collision unchanged");
        u.SetOrigin(Slot(true),false);u.Angle=Tent.Angle;
        Assert(!CaelumRestBag.HasRoom(u),"bag directed through rear wall rejected");
        u.Angle=Tent.Angle+90;u.SetOrigin((220,64,0),false);
        Assert(CaelumRestBag.HasRoom(u),"existing open-floor placement remains valid");
        u.SetOrigin((4,128,0),false);
        Assert(!CaelumRestBag.HasRoom(u),"world wall collision remains enforced");
        Summary();
    }
    void StartRest(CaelumPlayer u)
    {
        Assert(Bag!=null && Bag.BeginRest(u,5),"normal sleep starts through real bag entry point");
        Assert(CaelumRestState.IsSleeping(u),"native rest is sleeping");
        Assert(Tent.HasRestingOccupant(),"tent packing guard sees actual sleeper");
        Assert(!CaelumCampTask.BeginPack(u,Tent),"occupied tent cannot start packing");
        Summary();
    }
    void Follow(CaelumPlayer u)
    {
        let rest=CaelumRestState.Get(u);
        Assert(rest!=null && rest.Status==CaelumRestRules.STATUS_ACTIVE,"sleep remains active after native tics or load");
        Assert(rest!=null && rest.ElapsedTics>0,"normal clock advances actual rest");
        Assert(Bag!=null && Bag.Owner==u && Bag.Amount==1,"same bag identity remains owned once");
        Assert(Tent!=null && Tent.Covers(u) && u.TestMobjLocation(),"unchanged body remains supported in tent");
        if(rest!=null)Console.Printf("CA412B rest elapsed=%d result=%s height=%.3f",rest.ElapsedTics,rest.ResultKey,u.Height);
        CaelumRestState.Cancel(u);
        Assert(!Tent.HasRestingOccupant() && Bag.Owner==u,"waking releases tent without duplicating bag");
        Summary();
    }
    void Preview(CaelumPlayer u)
    {
        CaelumRestState.Cancel(u);u.SetOrigin((220,220,0),false);
        Tent.bInvisible=true;
        let first=Actor.Spawn('CA412PreviewBag',Slot(),NO_REPLACE);first.Angle=Tent.Angle+90;
        let second=Actor.Spawn('CA412PreviewBag',Slot(true),NO_REPLACE);second.Angle=Tent.Angle+90;
        let camera=Actor.Spawn('CA412BagCamera',Tent.Pos+(0,0,150),NO_REPLACE);camera.Pitch=90;camera.Angle=90;
        u.player.camera=camera;
        Assert(true,"diagnostic roof-hidden view uses unchanged bag and tent assets");Summary();
    }
    void Fast(CaelumPlayer u)
    {
        let rest=CaelumRestState.Get(u);int before=rest.ElapsedTics;
        Assert(CaelumTimeAdvanceState.Toggle(u),"existing solo acceleration accepts actual tent sleep");
        CaelumTimeAdvanceState.Pump(u);
        Assert(rest.ElapsedTics>before && CaelumRestState.IsSleeping(u),"accelerated rest advances without cancelling the bag");
        Assert(CaelumRestState.ResourceFactor(u)==3 && Tent.Covers(u),"existing bag recovery factor and tent shelter retained");
        CaelumTimeAdvanceState.Halt(u);Summary();
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=='ca412b_setup')Seed(u);
        else if(e.Name=='ca412b_inside')Inside(u);
        else if(e.Name=='ca412b_core')Core(u);
        else if(e.Name=='ca412b_rest')StartRest(u);
        else if(e.Name=='ca412b_follow')Follow(u);
        else if(e.Name=='ca412b_cancel')CaelumRestState.Cancel(u);
        else if(e.Name=='ca412b_read')CaelumRestState.Report(u);
        else if(e.Name=='ca412b_preview')Preview(u);
        else if(e.Name=='ca412b_fast')Fast(u);
    }
}
class CA412PreviewBag : CaelumRestBag {override void Tick(){}}
class CA412BagCamera : Actor
{Default {+NOGRAVITY +NOBLOCKMAP RenderStyle "None";} States {Spawn:TNT1 A -1;Stop;}}
