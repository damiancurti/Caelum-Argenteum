// Observación de la IA normal, sin modificar actores ni relojes de combate.
class CA128Battle : StaticEventHandler
{
    int DamageEvents, Deaths, Projectiles;
    override void WorldThingDamaged(WorldEvent e)
    {
        if(e.Thing is "CaelumCombatActor" && e.DamageSource!=null && e.DamageSource!=e.Thing && e.Damage>0)DamageEvents++;
    }
    override void WorldThingDied(WorldEvent e)
    {
        if(e.Thing is "CaelumCombatActor")Deaths++;
    }
    override void WorldThingSpawned(WorldEvent e)
    {
        if(e.Thing is "CaelumActorProjectile" || e.Thing is "CaelumCannonProjectile")Projectiles++;
    }
    override void WorldTick()
    {
        if(level.time%35!=0)return;
        let port=CaelumPortSiege.Get();let population=CaelumPopulationState.Get();
        if(port==null || population==null)return;
        int reduced=0,incomplete=0,shots=0;
        for(int i=0;i<port.Attackers.Size();i++)
        {
            let b=port.Attackers[i].Body;if(b==null || b.health<=0)continue;
            if(b.CaelumMassAIScheduleActive || b.CaelumDiagnosticPassiveAI)reduced++;
            if(b.AnatomyProfile==null || b.CombatArmor==null || b.ElementalStatus==null)incomplete++;
        }
        for(int i=0;i<port.Guns.Size();i++)if(port.Guns[i]!=null)shots+=port.Guns[i].Shots;
        Console.Printf("CA128 BATTLE tic=%d living=%d active=%d revision=%d groups=%d reduced=%d incomplete=%d damage=%d deaths=%d projectiles=%d cannonShots=%d",level.time,population.LivingCombatants,port.HighDensity,port.TargetingRevision,port.Groups,reduced,incomplete,DamageEvents,Deaths,Projectiles,shots);
    }
}
