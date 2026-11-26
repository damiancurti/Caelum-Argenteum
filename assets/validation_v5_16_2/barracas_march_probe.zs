// Marcha real a velocidad/cadencia normales. Solo se excluye el combate y se
// abren las puertas para medir la navegacion, no la resolucion del asedio.
class CA454MarchCity : CaelumPortSiege
{
    override void Tick(){ProcessNavigationQueue();}
}
class CA454MarchProbe : EventHandler
{
    Array<CaelumSiegeCombatant> Subjects;
    Array<bool> Finished;
    bool Running;
    int Elapsed,Passed,Failures;

    void OpenTestGates()
    {
        let port=CaelumPortSiege.Get();
        for(int i=0;i<port.Gates.Size();i++)
        {port.Gates[i].Opened=true;port.Gates[i].HoldTimer=60010;port.Gates[i].RefreshPassage();}
    }

    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca454_march_resume")
        {OpenTestGates();Console.Printf("CA454 MARCH RESUME %s elapsed=%d actors=%d",Running && Subjects.Size()==15?"PASS":"FAIL",Elapsed,Subjects.Size());return;}
        if(e.Name!="ca454_march_start")return;
        let user=players[0].mo;user.bNoTarget=true;user.bInvulnerable=true;
        let port=CaelumPortSiege.Get();CaelumBarracasAssault.PrepareGates(port);
        OpenTestGates();
        for(int lane=0;lane<6;lane++)
        {
            let ram=CaelumBatteringRam(Actor.Spawn("CaelumBatteringRam",CaelumBarracasFrontData.RamStart(lane),NO_REPLACE));
            ram.Angle=CaelumBarracasFrontData.RamStartAngle(lane);ram.Large=CaelumBarracasFrontData.RamLarge(lane);ram.InitializeRam();port.RegisterMachine(ram);
            let gun=CaelumCannon(Actor.Spawn("CaelumCannon",CaelumBarracasFrontData.GunPoint(lane),NO_REPLACE));
            gun.Angle=CaelumBarracasFrontData.GunAngle(lane);gun.InitializeCannon(false);port.RegisterMachine(gun);port.Guns.Push(gun);
        }
        for(int front=0;front<3;front++)
        {
            let entry=port.AddDemon(CaelumPortData.FormationPosition(front*CaelumReinforcementData.GROUP_SIZE/2),front*2);
            Subjects.Push(entry);Finished.Push(false);
        }
        for(int lane=0;lane<6;lane++)for(int crew=0;crew<CaelumCannonData.CREW;crew++)
        {
            let entry=port.AddDemon(CaelumBarracasMarchData.GunCrewStart(lane,crew),lane);
            entry.CrewOffset=CaelumPortData.OperatorOffset(lane,crew);port.Guns[lane].AssignOperator(entry.Body);
            CaelumBarracasMarch.Pending(entry);Subjects.Push(entry);Finished.Push(false);
        }
        port.SealRoster();port.ElectCommands();Running=true;
        Console.Printf("CA454 MARCH START actors=%d",Subjects.Size());
    }

    override void WorldTick()
    {
        if(!Running)return;Elapsed++;
        for(int i=0;i<Subjects.Size();i++)
        {
            if(Finished[i])continue;
            let entry=Subjects[i];let body=entry.Body;
            if(body==null || body.health<=0)
            {Failures++;Finished[i]=true;Console.Printf("CA454 MARCH FAIL missing actor=%d",i);continue;}
            vector3 destination=i<3?CaelumBarracasAssault.GateForLane(entry.Lane):entry.CrewPost();
            double distance=(body.Pos-destination).Length();
            if(entry.FrontMarchComplete && distance<=body.Radius)
            {Passed++;Finished[i]=true;Console.Printf("CA454 MARCH ARRIVED actor=%d lane=%d elapsed=%d distance=%.3f speed=%.3f",i,entry.Lane,Elapsed,distance,body.Speed);}
            else if(Elapsed%3500==0)
                Console.Printf("CA454 MARCH PROGRESS actor=%d lane=%d cursor=%d elapsed=%d position=(%.1f,%.1f) remaining=%.1f",i,entry.Lane,entry.FrontMarchCursor,Elapsed,body.Pos.X,body.Pos.Y,distance);
        }
        if(Passed+Failures==Subjects.Size())
        {Running=false;Console.Printf("CA454 MARCH COMPLETE passed=%d failures=%d elapsed=%d",Passed,Failures,Elapsed);}
        else if(Elapsed>=60000)
        {Running=false;Console.Printf("CA454 MARCH FAIL deadline passed=%d failures=%d",Passed,Failures);}
    }
}
