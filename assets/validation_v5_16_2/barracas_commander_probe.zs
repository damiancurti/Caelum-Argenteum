// Huida por herida real del comandante, una identidad por caso y sin combate.
class CA454CommanderCity : CaelumPortSiege
{
    override void Tick(){ProcessNavigationQueue();}
}
class CA454CommanderProbe : EventHandler
{
    CaelumSiegeCombatant Subject;
    bool Running,PendingWound;
    int CaseIndex,Elapsed,CaseElapsed,Failures;

    void BeginCase()
    {
        let port=CaelumPortSiege.Get();
        for(int i=0;i<port.Gates.Size();i++)
        {port.Gates[i].Opened=true;port.Gates[i].HoldTimer=60010;port.Gates[i].RefreshPassage();}
        vector3 point=CaelumPortData.BossPosition();int lane=CaelumPortSiege.NearestLaneAt(point);
        if(CaseIndex>=1 && CaseIndex<=3)
        {
            lane=(CaseIndex-1)*2;int gate=CaelumBarracasFrontData.GateForLane(lane);
            double angle=CaelumBarracasFrontData.GateOutward(gate);
            point=CaelumBarracasFrontData.GatePoint(gate)-(Cos(angle),Sin(angle),0)*CaelumPortData.ROUTE_RADIUS*2;
        }
        else if(CaseIndex==4){point=CaelumBarracasData.HouseRoad(159);lane=4;}
        let body=CaelumPortCommander(Actor.Spawn('CaelumPortCommander',point,NO_REPLACE));
        Subject=port.RegisterAttacker(body);Subject.Lane=lane;Subject.ExitNode=port.Exits[lane];
        port.Boss=Subject;port.EnsureDefeatRevision();port.BossRetreated=false;
        CaseElapsed=0;PendingWound=true;
    }

    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca454_commander_resume")
        {Console.Printf("CA454 COMMANDER RESUME %s elapsed=%d case=%d",Running && Subject!=null?"PASS":"FAIL",Elapsed,CaseIndex);return;}
        if(e.Name!="ca454_commander_start")return;
        players[0].mo.bNoTarget=true;players[0].mo.bInvulnerable=true;
        CaelumBarracasAssault.PrepareGates(CaelumPortSiege.Get());
        BeginCase();Running=true;
    }

    override void WorldTick()
    {
        if(!Running)return;Elapsed++;CaseElapsed++;
        let port=CaelumPortSiege.Get();let body=CaelumPortCommander(Subject.Body);
        if(PendingWound && body!=null)
        {
            // Spawn difiere PostBeginPlay: esperar el perfil nativo antes de
            // aplicar la herida, sin sustituir atributos por valores del fixture.
            if(!body.CombatProfileInitialized || body.CombatMaximumHealth<=0)return;
            body.health=Max(1,int(Floor(body.CombatMaximumHealth*CaelumConstants.HEALTH_WOUNDED_THRESHOLD)));
            PendingWound=false;CaseElapsed=0;
            Console.Printf("CA454 COMMANDER CASE index=%d lane=%d health=%d maximum=%.3f radius=%.3f height=%.3f base_speed=%.3f",CaseIndex,Subject.Lane,body.health,body.CombatMaximumHealth,body.Radius,body.Height,body.CombatBaseSpeed);
        }
        if(Subject.Exited && port.BossRetreated && !Subject.ConfirmedDead)
        {
            Console.Printf("CA454 COMMANDER EXIT case=%d elapsed=%d case_elapsed=%d",CaseIndex,Elapsed,CaseElapsed);
            CaseIndex++;
            if(CaseIndex==5){Running=false;Console.Printf("CA454 COMMANDER COMPLETE passed=5 failures=0 elapsed=%d",Elapsed);}
            else BeginCase();
            return;
        }
        if(body==null || body.health<=0 || Subject.ConfirmedDead)
        {Running=false;Console.Printf("CA454 COMMANDER FAIL dead case=%d elapsed=%d",CaseIndex,Elapsed);return;}
        if(body.ThermalState!=null){body.ThermalState.Exposure=0;body.ThermalState.DamageRemainder=0;}
        if(CaseElapsed==TICRATE && (!body.SewerFleeing || Abs(body.Speed-body.CombatBaseSpeed*CaelumConstants.SEWER_ZUPAY_FLEE_SPEED_MULTIPLIER*CaelumSupportMagic.Factor(body))>0.001))
        {Running=false;Console.Printf("CA454 COMMANDER FAIL wound_trigger_or_speed case=%d",CaseIndex);return;}
        if(Elapsed%3500==0)
            Console.Printf("CA454 COMMANDER PROGRESS case=%d elapsed=%d position=(%.1f,%.1f,%.1f) health=%d speed=%.3f",CaseIndex,Elapsed,body.Pos.X,body.Pos.Y,body.Pos.Z,body.health,body.Speed);
        if(CaseElapsed>=60000)
        {Running=false;Console.Printf("CA454 COMMANDER FAIL deadline case=%d elapsed=%d",CaseIndex,Elapsed);}
    }
}
