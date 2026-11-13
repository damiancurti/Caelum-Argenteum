// Retirada nativa: seis salidas finales y descenso de las 36 rutas elevadas.
class CA454RetreatCity : CaelumPortSiege
{
    override void Tick(){ProcessNavigationQueue();}
}
class CA454RetreatProbe : EventHandler
{
    Array<CaelumSiegeCombatant> Subjects;
    Array<bool> Finished;
    bool Running;
    bool FullRoute;
    int Elapsed,Passed,Failures;

    override void WorldThingDamaged(WorldEvent e)
    {
        if(!Running || e.Damage<=0)return;
        for(int i=0;i<Subjects.Size();i++)if(Subjects[i].Body==e.Thing)
        {
            Console.Printf("CA454 RETREAT DAMAGE actor=%d elapsed=%d damage=%d type=%s source=%s",i,Elapsed,e.Damage,e.DamageType,e.DamageSource!=null?e.DamageSource.GetClassName():'none');
            return;
        }
    }

    void Add(CaelumPortSiege port,vector3 point,int lane)
    {
        let entry=port.AddDemon(point,lane);
        entry.Withdrawing=true;entry.Body.SetStateLabel('SiegeWithdrawal');
        Subjects.Push(entry);Finished.Push(false);
    }

    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca454_retreat_resume")
        {Console.Printf("CA454 RETREAT RESUME %s elapsed=%d actors=%d",Running && Subjects.Size()==(FullRoute?6:42)?"PASS":"FAIL",Elapsed,Subjects.Size());return;}
        if(e.Name!="ca454_retreat_start" && e.Name!="ca454_retreat_full_start")return;
        FullRoute=e.Name=="ca454_retreat_full_start";
        players[0].mo.bNoTarget=true;players[0].mo.bInvulnerable=true;
        let port=CaelumPortSiege.Get();CaelumBarracasAssault.PrepareGates(port);
        for(int i=0;i<4;i++){port.Gates[i].Opened=true;port.Gates[i].RefreshPassage();}
        if(FullRoute)
        {
            for(int front=0;front<3;front++)
            {
                int gate=CaelumBarracasFrontData.GateForLane(front*2);
                double angle=CaelumBarracasFrontData.GateOutward(gate);
                Add(port,CaelumBarracasFrontData.GatePoint(gate)-(Cos(angle),Sin(angle),0)*CaelumPortData.ROUTE_RADIUS*2,front*2);
            }
            Add(port,CaelumBarracasData.HouseRoad(0),0);
            Add(port,CaelumBarracasData.HouseRoad(69),2);
            Add(port,CaelumBarracasData.HouseRoad(159),4);
        }
        else
        {
            for(int lane=0;lane<6;lane++)
                Add(port,port.Exits[lane].Pos+(lane%2==0?-128:128,512,0),lane);
            for(int gun=0;CaelumBarracasSiegeData.CrewRouteCount(gun)>0;gun++)
            {
                vector3 point=CaelumBarracasSiegeData.CrewRoutePoint(gun,CaelumBarracasSiegeData.CrewRouteCount(gun)-1);
                Add(port,point,CaelumPortSiege.NearestLaneAt(point));
            }
        }
        port.Victory=true;Running=true;
        Console.Printf("CA454 RETREAT START actors=%d",Subjects.Size());
    }

    override void WorldTick()
    {
        if(!Running)return;Elapsed++;
        for(int i=0;i<Subjects.Size();i++)
        {
            if(Finished[i])continue;
            let entry=Subjects[i];let body=entry.Body;
            // Aislamiento de navegacion: no evaluar supervivencia climatica.
            // No cambiar vida, velocidad, dimensiones ni la colision del cuerpo.
            if(body!=null && body.ThermalState!=null)
            {body.ThermalState.Exposure=0;body.ThermalState.DamageRemainder=0;}
            if(i<6 && entry.Exited && !entry.ConfirmedDead)
            {Passed++;Finished[i]=true;Console.Printf("CA454 RETREAT EXIT actor=%d lane=%d elapsed=%d",i,entry.Lane,Elapsed);continue;}
            if(body==null || body.health<=0 || entry.ConfirmedDead)
            {
                Failures++;Finished[i]=true;
                Console.Printf("CA454 RETREAT FAIL actor=%d elapsed=%d missing=%d confirmed=%d exited=%d",i,Elapsed,body==null,entry.ConfirmedDead,entry.Exited);
                if(body!=null)Console.Printf("CA454 RETREAT BODY health=%d position=(%.1f,%.1f,%.1f) floor=%.1f impact=%.3f kind=%d",body.health,body.Pos.X,body.Pos.Y,body.Pos.Z,body.FloorZ,body.LastImpactFinalDamage,body.LastImpactKind);
                if(body!=null && body.ThermalState!=null)
                {
                    let thermal=body.ThermalState;
                    Console.Printf("CA454 RETREAT THERMAL exposure=%.3f severity=%.3f damage=%.3f wet=%.3f air=%.3f",thermal.Exposure,thermal.Severity,thermal.AppliedDamageHP,thermal.WetnessPercent,thermal.AirC);
                }
                continue;
            }
            if(i>=6 && Elapsed>1 && body.Pos.Z==0 && body.FloorZ==0)
            {
                Passed++;Finished[i]=true;
                Console.Printf("CA454 RETREAT DESCENDED actor=%d gun=%d elapsed=%d speed=%.3f",i,entry.RetreatGun,Elapsed,body.Speed);
                // La prueba termina aqui para estos36: no afirma la salida final.
                body.Destroy();continue;
            }
            if(Elapsed%3500==0)
                Console.Printf("CA454 RETREAT PROGRESS actor=%d gun=%d step=%d elapsed=%d position=(%.1f,%.1f,%.1f)",i,entry.RetreatGun,entry.RetreatStep,Elapsed,body.Pos.X,body.Pos.Y,body.Pos.Z);
        }
        if(Passed+Failures==Subjects.Size())
        {Running=false;Console.Printf("CA454 RETREAT COMPLETE passed=%d failures=%d elapsed=%d",Passed,Failures,Elapsed);}
        else if(Elapsed>=(FullRoute?90000:14000))
        {Running=false;Console.Printf("CA454 RETREAT FAIL deadline passed=%d failures=%d",Passed,Failures);}
    }
}
