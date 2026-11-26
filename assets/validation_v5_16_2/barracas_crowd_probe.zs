// Despliegue real desde los 600 registros de vivienda: no crear duplicados ni
// alterar velocidad, dimensiones o colision. El clima queda fuera del ensayo.
class CA454CrowdCity : CaelumPortSiege
{
    override void Tick(){ProcessNavigationQueue();RefreshDensity();}
}
class CA454CrowdProbe : EventHandler
{
    bool Running,SawHighDensity;
    int Elapsed,Stable,Failures;
    Array<bool> Reached;

    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca454_crowd_resume")
        {Reached.Resize(600);Console.Printf("CA454 CROWD RESUME %s elapsed=%d",Running?"PASS":"FAIL",Elapsed);return;}
        if(e.Name!="ca454_crowd_start")return;
        players[0].mo.bNoTarget=true;players[0].mo.bInvulnerable=true;
        let port=CaelumPortSiege.Get();
        if(port==null || !CaelumBarracasData.IsCurrent() || !CaelumCityWorld.Prepare())
        {Console.Printf("CA454 CROWD FAIL city setup");return;}
        port.Deploy();
        // Activar solo la emision y la IA de residentes; no iniciar atacantes,
        // disparos, bajas, transacciones ni la resolucion automatica del asedio.
        port.SiegeStarted=true;port.RosterSealed=true;
        CaelumHouseResidents.Get(true).BeginDeployment(port);Reached.Resize(600);Running=true;
        Console.Printf("CA454 CROWD START records=%d guns=%d",port.Defenders.Size(),port.Guns.Size()-6);
    }

    override void WorldTick()
    {
        if(!Running)return;Elapsed++;
        let port=CaelumPortSiege.Get();
        for(int i=0;i<port.Defenders.Size();i++)
        {
            let body=port.Defenders[i];
            if(body!=null && body.ThermalState!=null)
            {body.ThermalState.Exposure=0;body.ThermalState.DamageRemainder=0;}
        }
        int emitted=0,arrived=0,crew=0,dead=0,invalid=0;
        for(int i=0;i<port.Defenders.Size();i++)
        {
            let body=port.Defenders[i];if(body==null)continue;emitted++;
            if(body.health<=0){dead++;continue;}
            if(body.HomeIdentity!=i || body.Residence==null || body.Residence.Body!=body)invalid++;
            if(body.Gun!=null)crew++;
            // Registrar la primera llegada real. La guardia puede investigar
            // ruidos despues: exigir 600 puestos simultaneos cambiaria esa regla.
            // AdvanceDeployment confirma el ultimo punto a <=1 MU; CrewPost
            // confirma el puesto a un radio. No repetir esa prueba despues de
            // que otras acciones nativas del mismo tic hayan movido al guardia.
            if(!Reached[i] && body.DeploymentComplete && !body.FollowingCrewRoute)
            {
                Reached[i]=true;
                Console.Printf("CA454 CROWD ARRIVED id=%d elapsed=%d distance=%.3f speed=%.3f crew=%d",i,Elapsed,(body.Pos-body.Station).Length(),body.Speed,body.Gun!=null);
            }
            if(Reached[i])arrived++;
            else if(Elapsed%3500==0 && i%100==0)
                Console.Printf("CA454 CROWD BODY id=%d step=%d crew_step=%d complete=%d following=%d position=(%.1f,%.1f,%.1f) remaining=%.1f",i,body.DeploymentStep,body.CrewRouteStep,body.DeploymentComplete,body.FollowingCrewRoute,body.Pos.X,body.Pos.Y,body.Pos.Z,(body.Pos-body.Station).Length());
        }
        let population=CaelumPopulationState.Get();
        if(population!=null && population.HighDensity && port.HighDensity)SawHighDensity=true;
        if(Elapsed%3500==0)
            Console.Printf("CA454 CROWD PROGRESS elapsed=%d emitted=%d arrived=%d crew=%d queue=%d living=%d high=%d",Elapsed,emitted,arrived,crew,port.CityPathQueue.Size(),population!=null?population.LivingCombatants:-1,port.HighDensity);
        if(dead>0 || invalid>0)
        {Running=false;Failures++;Console.Printf("CA454 CROWD FAIL dead=%d invalid_identity=%d elapsed=%d",dead,invalid,Elapsed);return;}
        Stable=arrived==600 && emitted==600 && crew==72 && SawHighDensity?Stable+1:0;
        if(Stable>=2)
        {Running=false;Console.Printf("CA454 CROWD COMPLETE passed=600 failures=0 elapsed=%d crew=%d high=%d",Elapsed,crew,SawHighDensity);}
        else if(Elapsed>=90000)
        {
            Running=false;Console.Printf("CA454 CROWD FAIL deadline emitted=%d arrived=%d crew=%d high=%d",emitted,arrived,crew,SawHighDensity);
            for(int i=0;i<port.Defenders.Size();i++)
            {
                let body=port.Defenders[i];if(body==null){Console.Printf("CA454 CROWD MISSING id=%d",i);continue;}
                if(!Reached[i])
                    Console.Printf("CA454 CROWD PENDING id=%d step=%d crew_step=%d complete=%d following=%d position=(%.3f,%.3f,%.3f) remaining=%.3f",i,body.DeploymentStep,body.CrewRouteStep,body.DeploymentComplete,body.FollowingCrewRoute,body.Pos.X,body.Pos.Y,body.Pos.Z,(body.Pos-body.Station).Length());
            }
        }
    }
}
