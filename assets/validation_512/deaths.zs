// Sonda de solo lectura: identifica bajas naturales sin alterar supervivencia.
class CA132DeathAudit : StaticEventHandler
{
    int Deaths, ThermalDeaths;
    static void Record(CaelumCombatActor body,Name means)
    {
        if(body==null || !(body is "CaelumMandinga"))return;
        let audit=CA132DeathAudit(StaticEventHandler.Find("CA132DeathAudit"));
        audit.Deaths++;
        if(means=='CaelumThermal')audit.ThermalDeaths++;
        if(audit.Deaths<=8 || audit.Deaths%500==0)
        {
            let t=body.ThermalState;
            Console.Printf("CA132 DEATH tic=%d count=%d thermal=%d type=%s exposure=%.3f air=%.3f comfort=%.3f thermalHP=%.3f",level.time,audit.Deaths,audit.ThermalDeaths,means,t!=null?t.Exposure:0,t!=null?t.AirC:0,t!=null?t.ComfortC:0,t!=null?t.AppliedDamageHP:0);
        }
    }
    override void WorldTick()
    {
        if(level.time==5355)Console.Printf("CA132 DEATH COMPLETE deaths=%d thermal=%d",Deaths,ThermalDeaths);
    }
}
