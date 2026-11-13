// Controlador completo: 600 defensores y refuerzos con limite nativo de 1000.
// Solo aislar la exposicion termica; no acelerar tics, poblacion ni movimiento.
class CA454RefillCity : CaelumPortSiege {}
class CA454RefillProbe : EventHandler
{
    bool Running;
    int Elapsed,Stage,BeforeSuccessful,AfterOpportunity,PeakLiving;
    Array<CaelumSiegeCombatant> Removed;
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca454_refill_resume")
        {Console.Printf("CA454 REFILL RESUME %s elapsed=%d stage=%d",Running?"PASS":"FAIL",Elapsed,Stage);return;}
        if(e.Name!="ca454_refill_start")return;
        let port=CaelumPortSiege.Get();players[0].mo.bNoTarget=true;players[0].mo.bInvulnerable=true;
        if(port.SetupRevision==0){CaelumCityWorld.Prepare();port.Deploy();}
        if(!port.SiegeStarted)port.Deploy(true);
        Running=true;Console.Printf("CA454 REFILL START defenders=%d",port.Defenders.Size());
    }
    void NeutralizeExposure(CaelumCombatActor body)
    {if(body!=null && body.ThermalState!=null){body.ThermalState.Exposure=0;body.ThermalState.DamageRemainder=0;}}
    void Fail(String reason)
    {Running=false;Console.Printf("CA454 REFILL FAIL %s elapsed=%d",reason,Elapsed);}
    override void WorldTick()
    {
        if(!Running)return;Elapsed++;let port=CaelumPortSiege.Get();let pool=port.Reinforcements;
        for(int i=0;i<port.Attackers.Size();i++)NeutralizeExposure(port.Attackers[i].Body);
        for(int i=0;i<port.Defenders.Size();i++)NeutralizeExposure(port.Defenders[i]);
        if(Elapsed%TICRATE!=0)return;
        int living=port.LivingHostilePopulation();PeakLiving=Max(PeakLiving,living);
        if(living>CaelumReinforcementData.LIVING_CAP){Fail("living cap exceeded");return;}
        if(pool.Successful+pool.Remaining+pool.Withheld!=CaelumReinforcementData.TOTAL)
        {Fail("finite reserve accounting");return;}
        if(Stage==0 && (living==CaelumReinforcementData.LIVING_CAP || pool.Successful>=CaelumReinforcementData.LIVING_CAP))
        {
            BeforeSuccessful=pool.Successful;
            // Cinco bajas reales de fixture: Die registra cadáver y baja; no
            // borrar referencias, liberar plazas a mano ni reiniciar las tandas.
            for(int i=port.Attackers.Size()-1;i>=0 && Removed.Size()<5;i--)
            {
                let entry=port.Attackers[i];let body=entry.Body;
                if(entry==port.Boss || entry.CrewMachine!=null || entry.Exited || entry.ConfirmedDead || body==null || body.health<=0)continue;
                Removed.Push(entry);body.health=0;body.Die(null,null,0,'None');
            }
            if(Removed.Size()!=5){Fail("five eligible fixture casualties");return;}
            Stage=1;Console.Printf("CA454 REFILL CASUALTIES successful=%d living_before=%d peak=%d",BeforeSuccessful,living,PeakLiving);
        }
        if(Stage==1 && pool.Successful>=BeforeSuccessful+5)
        {Stage=2;AfterOpportunity=pool.Opportunities;Console.Printf("CA454 REFILL REPLACED successful=%d remaining=%d living=%d",pool.Successful,pool.Remaining,living);}
        if(Stage==2 && pool.Opportunities>=AfterOpportunity+2)
        {
            for(int i=0;i<Removed.Size();i++)if(!Removed[i].ConfirmedDead || Removed[i].Exited)
            {Fail("casualty identity lost");return;}
            Running=false;Console.Printf("CA454 REFILL COMPLETE passed=1 failures=0 elapsed=%d successful=%d remaining=%d living=%d peak=%d opportunities=%d defenders=%d",Elapsed,pool.Successful,pool.Remaining,living,PeakLiving,pool.Opportunities,port.Defenders.Size());return;
        }
        if(Elapsed%350==0)Console.Printf("CA454 REFILL PROGRESS elapsed=%d successful=%d living=%d remaining=%d pending=%d opportunities=%d",Elapsed,pool.Successful,living,pool.Remaining,pool.Pending,pool.Opportunities);
        if(Elapsed>=14000)Fail("deadline");
    }
}
