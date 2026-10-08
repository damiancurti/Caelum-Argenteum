class CA140EnergyMarker : Actor
{
    CaelumCombatActor Body;
    double Pending,Shiver;
    Default { +NOINTERACTION }
    States { Spawn:TNT1 A -1;Stop; }
}
class CA140Upgrade : StaticEventHandler
{
    double ExpectedThirst,ExpectedHunger;
    bool HasTransition;
    override void WorldTick()
    {
        if(level.time!=64 || !CVar.GetCVar("ca140_queue_seed").GetBool())return;
        let marker=CA140Marker(ThinkerIterator.Create("CA140Marker").Next());if(marker==null)return;
        let energy=CA140EnergyMarker(Actor.Spawn("CA140EnergyMarker"));energy.Body=marker.Body;
        energy.Pending=97.125;energy.Shiver=54321.25;
        energy.Body.ThermalState.PendingFirearmJoules=energy.Pending;energy.Body.ThermalState.ShiveringJoules=energy.Shiver;
        Console.Printf("CA140 ENERGY_SEEDED pending=%.6f shiver=%.6f",energy.Pending,energy.Shiver);
    }
    override void WorldUnloaded(WorldEvent e)
    {
        let u=CaelumPlayer(players[0].mo);if(u==null)return;
        // Native travel executes one final source-map personal tic after this callback.
        double divisor=CaelumWorldClock.SecondsPerGameHour(level.MapName)*TICRATE;
        double factor=u.DerivedStats.HungerThirstLossMultiplier;
        ExpectedThirst=u.CurrentThirst-100.0/CaelumConstants.THIRST_EMPTY_GAME_HOURS/divisor*factor;
        ExpectedHunger=u.CurrentHunger-100.0/CaelumConstants.HUNGER_EMPTY_GAME_HOURS/divisor*factor;
        HasTransition=true;
    }
    override void WorldLoaded(WorldEvent e)
    {
        if(level.MapName!="CA140")return;
        let marker=CA140Marker(ThinkerIterator.Create("CA140Marker").Next());
        if(marker==null)return;
        let s=marker.Body.ThermalState;
        let energy=CA140EnergyMarker(ThinkerIterator.Create("CA140EnergyMarker").Next());
        if(energy!=null)
            Console.Printf("CA140 ENERGY_RELOAD pending=%.6f shiver=%.6f failures=%d",s.PendingFirearmJoules,s.ShiveringJoules,
                int(s.PendingFirearmJoules!=energy.Pending || s.ShiveringJoules!=energy.Shiver));
        bool discarded=s.Coefficients==null;
        let user=CaelumPlayer(players[0].mo);
        bool player=e.IsSaveGame ? CA140Seed.Preserved(marker) : HasTransition
            && Abs(user.CurrentThirst-ExpectedThirst)<1e-8 && Abs(user.CurrentHunger-ExpectedHunger)<1e-8;
        bool preserved=CA140Seed.Preserved(marker,false) && player;
        s.Initialize();s.Initialize();
        bool migrated=s.Revision==CaelumThermalData.REVISION && CA140Seed.Preserved(marker,false) && player;
        let c=CaelumThermalCoefficients.Get(s);c.Prepare(s);c.Prepare(s);
        bool cached=c.GeometryBuilds==1 && c.Hits==1;
        if(!preserved)
        {
            let u=CaelumPlayer(players[0].mo);
            Console.Printf("CA140 PRIMARY E=%.9f/%.9f A=%.9f/%.9f D=%.9f/%.9f W=%.9f/%.9f H=%.9f/%.9f S=%.9f/%.9f thirst=%.9f/%.9f hunger=%.9f/%.9f",
                s.Exposure,marker.Exposure,s.Acclimation,marker.Acclimation,s.DamageRemainder,marker.Damage,
                s.ActorWaterKg[0],marker.Water,s.Hydration,marker.Hydration,s.SweatKg,marker.Sweat,
                u.CurrentThirst,marker.Thirst,u.CurrentHunger,marker.Hunger);
        }
        Console.Printf("CA140 MIGRATION saved=%d primary=%d discarded=%d idempotent=%d rebuilt=%d failures=%d",
            e.IsSaveGame,preserved,discarded,migrated,cached,int(!(preserved && discarded && migrated && cached)));
    }
}
