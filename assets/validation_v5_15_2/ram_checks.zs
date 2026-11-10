class CA449Port : CaelumPortSiege replaces CaelumPortSiege { override void Tick() {} }
class CA449Checks : EventHandler
{
    CaelumBatteringRam Ram;
    CaelumBreakableGate Gate;
    CaelumPortSiege Port;
    int Started,Stage,Failures;
    vector3 Start;
    void Check(bool okay,String label)
    {if(!okay)Failures++;Console.Printf("CA449 %s %s",okay?"PASS":"FAIL",label);}
    void Seed()
    {
        Port=CaelumPortSiege.Get();if(Port==null)Port=CaelumPortSiege(Actor.Spawn('CA449Port',(0,0,0)));
        Ram=CaelumBatteringRam(Actor.Spawn('CaelumBatteringRam',(-2048,0,0)));Ram.InitializeRam();Port.RegisterMachine(Ram);Port.SealRoster();
        let user=CaelumPlayer(players[0].mo);user.GetPersistentCharacterState(true).FactionMember[0]=true;
        Check(CaelumMachineOwnership.Capture(Ram,user,0),"original uncrewed ram transfers to the selected faction");
        double reach=(CaelumRamData.HEAD_X+CaelumRamData.EXTENDED_OFFSET+CaelumRamData.HEAD_RADIUS)*Ram.SizeFactor;
        Gate=CaelumBreakableGate(Actor.Spawn('CaelumBreakableGate',Ram.Pos+(reach+64,0,0)));Gate.Angle=90;Gate.InitializeGate();
        for(int i=0;i<CaelumRamData.SMALL_CREW;i++)
        {
            let guard=CaelumPortDefender(Actor.Spawn('CaelumPortDefender',Ram.Pos+(0,(i%2==0?-1:1)*90,0),NO_REPLACE));
            guard.Port=Port;Port.Defenders.Push(guard);guard.Station=guard.Pos;
            Check(CaelumMachineOwnership.Assign(Ram,guard),"allied ram operator receives a unique native bond");
            guard.SetOrigin(CaelumMachineOwnership.Post(guard),false);
        }
    }
    void Initial()
    {
        Check(Ram.FullCrewPresent(),"captured ram recognizes its complete allied crew");
        Start=Ram.Pos;Check(Ram.SetRoute(Gate,0),"captured ram accepts the original physical route mechanism");
        Ram.AddRoutePoint(Ram.Pos+(64,0,0));Check(Ram.ActivateRam(),"captured ram can be activated without restoring enemy operators");
        Started=level.time;Stage=1;
    }
    override void WorldTick()
    {
        if(Stage!=1 || level.time-Started<700)return;Stage=0;
        Check((Ram.Pos-Start).Length()>32 && !Ram.TarotDestroyed,"native frame movement preserves captured equipment");
        Check(Ram.ImpactCount>0 && Ram.LastDamage>0 && Gate.health<Gate.StructuralMaximum,"allied crew follows the moving frame and the native head damages the gate");
        Check(Ram.ControlledCrew.Size()==CaelumRamData.SMALL_CREW,"native motion creates no replacement operators");
        Console.Printf("CA449 RAM %s failures=%d pos=%f,%f staff=%d impacts=%d damage=%d",Failures==0?"PASS":"FAIL",Failures,Ram.Pos.X,Ram.Pos.Y,CaelumMachineOwnership.Staffing(Ram),Ram.ImpactCount,Ram.LastDamage);
    }
    override void NetworkProcess(ConsoleEvent e)
    {if(e.Name=="ca449_seed")Seed();else if(e.Name=="ca449_initial")Initial();}
}
