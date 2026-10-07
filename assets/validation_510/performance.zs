// Same read-only observer in baseline and current packages; no actor throttling.
class CA130Performance : StaticEventHandler
{
    override void WorldTick()
    {
        if(level.time%35!=0)return;
        let siege=CaelumPortSiege.Get();let population=CaelumPopulationState.Get();
        if(siege==null || population==null)return;
        int thermalCount=0,harmful=0;
        double exposureSum=0;
        // THERMAL_OBSERVATION
        Console.Printf("CA130 PERF tic=%d ms=%.6f living=%d attackers=%d defenders=%d dense=%d thermal=%d harmful=%d exposureSum=%.6f",
            level.time,MSTimeF(),population.LivingCombatants,siege.Attackers.Size(),siege.Defenders.Size(),
            population.HighDensity,thermalCount,harmful,exposureSum);
        if(level.time==700)Console.Printf("CA130 PERFORMANCE COMPLETE");
    }
}
