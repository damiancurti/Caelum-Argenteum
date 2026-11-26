// La prueba usa Deploy real; el Tick automatico se suprime para aislar el alta
// y la politica de reservas, sin declarar un asedio completo.
class CA454FrontCity : CaelumPortSiege
{
    override void Tick() {}
}
class CA454FrontProbe : EventHandler
{
    int Failures;
    void Check(bool ok,String label)
    {if(!ok){Failures++;Console.Printf("CA454 FRONT FAIL %s",label);}}

    void Inspect(CaelumPortSiege port,bool resumed)
    {
        Check(port.Gates.Size()==4,"four unique gates");
        Check(port.Exits.Size()==6,"six lane exits");
        Check(port.Machines.Size()==12,"twelve hostile objectives");
        Check(port.Guns.Size()==42,"six attacking and36 defending guns");
        Check(port.Reinforcements.Enabled && port.Reinforcements.Successful<=100,"bounded first wave");
        Check(port.LivingHostilePopulation()<=CaelumReinforcementData.LIVING_CAP,"living cap");
        int active=0,large=0,queued=port.Reinforcements.InitialCrew.Size();
        for(int lane=0;lane<6;lane++)
        {
            let ram=CaelumBatteringRam(port.Machines[lane]);
            Check(ram!=null,String.Format("ram slot%d",lane));if(ram==null)continue;
            if(ram.Enabled)active++;if(ram.Large)large++;
            Check(ram.TargetGate==port.Gates[CaelumBarracasFrontData.GateForLane(lane)] || ram.TarotDestroyed,"shared front gate identity");
            Check(ram.CrewLayoutRevision==CaelumBarracasRamCrewData.REVISION,"crew layout revision");
            if(!ram.TarotDestroyed)Check(ram.Route.Size()==CaelumBarracasFrontData.RamPointCount(lane)+1 && ram.FollowRouteHeading,"full physical route");
        }
        Check(active==3 && large==1 && queued==74,"three active rams,one large,74 crew slots");
        int activeGuns=0;
        for(int i=6;i<42;i++)if(CaelumPortData.ActiveGun(i))activeGuns++;
        Check(activeGuns==12,"twelve active defensive posts");
        for(int i=0;i<4;i++)
        {
            let gate=port.Gates[i];
            Check((gate.Pos-CaelumBarracasFrontData.GatePoint(i)).Length()<0.01,"gate coordinates");
            Check(gate.args[1]==CaelumBarracasFrontData.GateMaterial(i),"gate material");
            CaelumAuthoredCartography.BindSubject(gate,CaelumPoiData.EXIT);
        }
        // Una consulta tipada de verificacion, solo al solicitar el informe.
        int bound=0;let it=ThinkerIterator.Create("CaelumPoiRegistration");CaelumPoiRegistration poi;
        while((poi=CaelumPoiRegistration(it.Next()))!=null)
            for(int i=0;i<4;i++)if(poi.Subject==port.Gates[i])
            {bound++;Check(poi.PoiId==String.Format("port-r4-gate-%d",i) && poi.NameKey==CaelumBarracasFrontData.GateName(i),"cardinal known-only label");}
        Check(bound==4,"four cartographic bindings");
        CaelumBarracasAssault.PrepareGates(port);Check(port.Gates.Size()==4 && port.Exits.Size()==6,"idempotent gate initialization");
        Check(port.RamReserveReleased[0]==resumed && !port.RamReserveReleased[1] && !port.RamReserveReleased[2],"saved reserve flags");
        Console.Printf("CA454 FRONT %s %s failures=%d gates=%d machines=%d active_rams=%d large=%d queued=%d living=%d",resumed?"RESUME":"DEPLOY",Failures==0?"PASS":"FAIL",Failures,port.Gates.Size(),port.Machines.Size(),active,large,queued,port.LivingHostilePopulation());
    }

    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="ca454_front_start" && e.Name!="ca454_front_resume")return;
        let user=players[0].mo;user.bInvulnerable=true;
        let port=CaelumPortSiege.Get();Check(port!=null && CaelumBarracasData.IsCurrent(),"revision4 controller");if(port==null)return;
        if(e.Name=="ca454_front_start")
        {
            Check(CaelumCityWorld.Prepare(),"city calendar");
            port.Deploy();Check(port.Attackers.Size()==0 && port.Machines.Size()==0,"peaceful deployment");
            port.Deploy(true);port.ActivateDeployment(true);Inspect(port,false);
            let first=CaelumBatteringRam(port.Machines[0]);let reserve=CaelumBatteringRam(port.Machines[1]);
            first.Sabotaged=true;CaelumBarracasAssault.UpdateReserves(port);
            Check(!reserve.Enabled && !port.RamReserveReleased[0],"temporary sabotage retains reserve");
            first.Sabotaged=false;Check(first.DestroyByTarot(),"native permanent destruction");
            CaelumBarracasAssault.UpdateReserves(port);CaelumBarracasAssault.UpdateReserves(port);
            Check(!first.Enabled && reserve.Enabled && port.RamReserveReleased[0],"reserve released once");
            Console.Printf("CA454 FRONT POLICY %s failures=%d",Failures==0?"PASS":"FAIL",Failures);
        }
        else
        {
            CaelumBarracasAssault.UpdateReserves(port);Inspect(port,true);
            Check(!CaelumBatteringRam(port.Machines[0]).Enabled && CaelumBatteringRam(port.Machines[1]).Enabled,"continued reserve activation");
            Console.Printf("CA454 FRONT CONTINUATION %s failures=%d",Failures==0?"PASS":"FAIL",Failures);
        }
    }
}
