// Contadores de causa: la muerte termica directa no informa DamageTypeReceived.
class CA304Deaths : StaticEventHandler
{
    int Deaths,ThermalDeaths;
    static void Record(CaelumCombatActor body,Name means)
    {
        if(!(body is "CaelumMandinga"))return;
        let audit=CA304Deaths(StaticEventHandler.Find("CA304Deaths"));
        audit.Deaths++;if(means=='CaelumThermal')audit.ThermalDeaths++;
        if(audit.Deaths<=8 || audit.Deaths%100==0)
            Console.Printf("CA304 DEATH tic=%d total=%d thermal=%d type=%s",level.time,audit.Deaths,audit.ThermalDeaths,means);
    }
    override void WorldTick()
    {
        if(level.time%350==0)Console.Printf("CA304 DEATH_TOTAL tic=%d total=%d thermal=%d",level.time,Deaths,ThermalDeaths);
    }
}
