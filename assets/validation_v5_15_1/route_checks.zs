// Geometría real; sólo se suprime el despliegue masivo del escenario de prueba.
class CA448RoutePort : CaelumPortSiege replaces CaelumPortSiege
{
    bool Released;
    override void Tick(){if(Released)Super.Tick();}
}

class CA448Checks : EventHandler
{
    CA448RoutePort Port;
    CaelumPortDefender Crew,Guard;
    CaelumCannon Gun;
    int Started,Failures;
    bool Active,CrewDone,GuardDone,Finished;
    vector3 PreviousCrew,PreviousGuard;
    double LargestCrewStep,LargestGuardStep;

    void Check(bool okay,String label)
    {if(!okay)Failures++;Console.Printf("CA448 %s %s",okay?"PASS":"FAIL",label);}

    void Seed()
    {
        Port=CA448RoutePort(CaelumPortSiege.Get());
        Check(Port!=null,"real city loads the isolated native port controller");if(Port==null)return;
        Gun=CaelumCannon(Actor.Spawn('CaelumCannon',CaelumPortData.GunPosition(6),NO_REPLACE));
        Gun.Angle=CaelumPortData.GunAngle(6);Gun.InitializeCannon(true);
        Crew=CaelumPortDefender(Actor.Spawn('CaelumPortDefender',Gun.Pos+CaelumPortData.OperatorOffset(6,0),NO_REPLACE));
        Guard=CaelumPortDefender(Actor.Spawn('CaelumPortDefender',CaelumCityData.HouseRoad(CaelumPropertyData.ResidentHouse(24)),NO_REPLACE));
        Crew.Port=Guard.Port=Port;Crew.Station=Crew.Pos;Guard.Station=Guard.Pos;
        Console.Printf("CA448 SEEDED");
    }

    CaelumMilitaryGroup Group(CaelumPortDefender body)
    {
        let group=new('CaelumMilitaryGroup');group.Port=Port;
        group.Formation=new('CaelumFormation');group.Formation.Initialize();
        group.Formation.Add(body,CaelumFormation.RoleFor(body),CaelumMilitaryData.MEMBER_PRIORITY);
        body.MilitaryGroup=group;group.Refresh();group.SetOrder(CaelumMilitaryData.WITHDRAW,body.Pos);
        Port.Military.Groups.Push(group);return group;
    }

    void Initial()
    {
        if(Port==null)return;
        let user=CaelumPlayer(players[0].mo);user.CharacterCreationComplete=true;user.CreationWizardOpen=false;
        let roster=CaelumHouseResidents.Get(true);roster.EnsureRecords();roster.Ready=true;roster.DeploymentPending=false;
        Port.SetupRevision=CaelumCityData.LAYOUT_REVISION;Port.SubcaptainCreated=true;
        Port.RentalAgentRevision=CaelumPortQuestData.REVISION;Port.SiegeStarted=true;Port.RosterSealed=true;
        Port.Reinforcements=new('CaelumSiegeReinforcements');Port.Reinforcements.Revision=CaelumReinforcementData.REVISION;
        Port.Reinforcements.Enabled=false;Port.Reinforcements.Stopped=true;
        Port.Guns.Resize(7);Port.Guns[6]=Gun;
        Port.Defenders.Push(Crew);Port.Defenders.Push(Guard);
        Crew.AssignHome(0);Guard.AssignHome(24);Crew.Gun=Gun;Gun.AssignOperator(Crew);
        Crew.DeploymentComplete=Guard.DeploymentComplete=true;
        Port.Military=new('CaelumMilitaryCommand');Port.Military.Port=Port;Port.Military.Revision=CaelumMilitaryData.REVISION;
        Group(Crew);Group(Guard);
        // Aísla las últimas piernas del acceso al cuartel; el operador recorre la escalera completa.
        Guard.MilitarySerial=Guard.MilitaryOrderSerial;Guard.MilitaryReturnStep=-1;Guard.MilitaryCrewStep=-1;
        PreviousCrew=Crew.Pos;PreviousGuard=Guard.Pos;Started=level.time;Active=true;Port.Released=true;
        Check(Crew.Pos.Z>0 && Crew.Gun!=null,"operator begins at the real elevated cannon post");
        Console.Printf("CA448 ROUTE START crew=%f,%f,%f guard=%f,%f,%f",Crew.Pos.X,Crew.Pos.Y,Crew.Pos.Z,Guard.Pos.X,Guard.Pos.Y,Guard.Pos.Z);
    }

    override void WorldTick()
    {
        if(!Active || Finished)return;
        LargestCrewStep=Max(LargestCrewStep,(Crew.Pos-PreviousCrew).Length());PreviousCrew=Crew.Pos;
        LargestGuardStep=Max(LargestGuardStep,(Guard.Pos-PreviousGuard).Length());PreviousGuard=Guard.Pos;
        if(!CrewDone && Crew.MilitarySerial==Crew.MilitaryOrderSerial && Crew.MilitaryCrewStep<0 && Crew.Pos.Z<=Crew.MaxStepHeight)
        {
            CrewDone=true;Crew.MilitaryGroup.SetOrder(CaelumMilitaryData.HOLD,Crew.Pos);
            Check(Crew.health>0 && !Crew.bDestroyed && Crew.bSolid,"operator descends the actual staircase as a living collidable body");
        }
        vector3 destination=CaelumCityData.DoorOutside(CaelumPropertyData.ResidentHouse(24));
        if(!GuardDone && Guard.MilitaryReturnStep<=-2 && (Guard.Pos.XY-destination.XY).Length()<=CaelumCityData.TRANSIT_WAYPOINT_REACH
            && Abs(Guard.Pos.Z-destination.Z)<=Guard.MaxStepHeight)
        {
            GuardDone=true;
            Check(Guard.health>0 && !Guard.bDestroyed && Guard.bSolid && !Guard.bInvisible,"barracks arrival remains visible, alive and collidable in the city");
        }
        if(level.time%TICRATE==0)Console.Printf("CA448 ROUTE tic=%d crew=%f,%f,%f step=%d return=%d guard=%f,%f return=%d",
            level.time-Started,Crew.Pos.X,Crew.Pos.Y,Crew.Pos.Z,Crew.MilitaryCrewStep,Crew.MilitaryReturnStep,Guard.Pos.X,Guard.Pos.Y,Guard.MilitaryReturnStep);
        if(CrewDone && GuardDone)
        {
            Finished=true;
            Check(LargestCrewStep<=Crew.Speed+Crew.MaxStepHeight && LargestGuardStep<=Guard.Speed+Guard.MaxStepHeight,"real routes contain no teleport-sized movement");
            Check(Port.LivingDefendingPopulation()>=3 && Port.Defenders[0]==Crew && Port.Defenders[1]==Guard,"both returned soldiers remain in the living side census");
            Console.Printf("CA448 ROUTES %s failures=%d",Failures==0?"PASS":"FAIL",Failures);
        }
    }

    override void NetworkProcess(ConsoleEvent e)
    {if(e.Name=="ca448_seed")Seed();else if(e.Name=="ca448_initial")Initial();}
}
