// Puente exclusivo de 5.4.8 para una copia del guardado de ensayo.
class CaelumHuntersInstinctEffect : CaelumRacialAbilityEffect { }
class CA239Body : CaelumCombatActor
{
    override void Tick() { }
    Default { +SOLID +SHOOTABLE +NOGRAVITY Radius 16; Height 96; Mass 100; Health 100000; }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA239Rollback : StaticEventHandler
{
    int Age;
    double Anima;
    bool WasActive;
    override void WorldLoaded(WorldEvent e)
    {
        let user=CaelumPlayer(players[0].mo);if(user==null)return;
        Anima=user.CurrentAnima;WasActive=user.RacialAbilityActive && user.RacialAbility is "CaelumHuntersInstinctEffect";
        CaelumRacialAbilityRules.Deactivate(user);
    }
    override void WorldTick()
    {
        if(++Age!=20)return;let user=CaelumPlayer(players[0].mo);
        bool ended=WasActive && !user.RacialAbilityActive && user.RacialAbility==null;
        bool retained=Abs(user.CurrentAnima-Anima)<1e-6;
        bool restored=Abs(user.EffectiveStealthPercent-20)<1e-6;
        Console.Printf("CA239 %s rollback ends unsupported power",ended?"PASS":"FAIL");
        Console.Printf("CA239 %s rollback preserves spent Anima",retained?"PASS":"FAIL");
        Console.Printf("CA239 %s rollback restores ordinary stealth",restored?"PASS":"FAIL");
        Console.Printf("CA239 DONE failures=%d ROLLBACK_ONLY",(ended?0:1)+(retained?0:1)+(restored?0:1));
    }
}
