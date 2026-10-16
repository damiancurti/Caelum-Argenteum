// Puente opcional sólo para volver al runtime 5.4.4; no cargar junto a 5.4.6.
// Conserva el tipo serializado y apaga la racial que el runtime anterior no ejecuta.
class CaelumSupernaturalBreathingEffect : CaelumRacialAbilityEffect
{
}
class CA242Rollback : StaticEventHandler
{
    int Age;
    bool WasActive;
    override void WorldLoaded(WorldEvent e)
    {
        let user=CaelumPlayer(players[0].mo);if(user==null)return;
        WasActive=user.RacialAbilityActive && user.RacialAbility is "CaelumSupernaturalBreathingEffect";
        CaelumRacialAbilityRules.Deactivate(user);
    }
    override void UiTick(){if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    override void WorldTick()
    {
        Age++;if(Age!=20)return;
        let user=CaelumPlayer(players[0].mo);
        bool ended=user!=null && WasActive && !user.RacialAbilityActive && user.RacialAbility==null;
        bool resources=user!=null && Abs(user.CurrentAnima-777)<1e-6 && Abs(user.CurrentAir-333)<1e-6;
        Console.Printf("CA242 %s rollback deactivates unsupported power",ended?"PASS":"FAIL");
        Console.Printf("CA242 %s rollback preserves both reserves",resources?"PASS":"FAIL");
        Console.Printf("CA242 DONE failures=%d ROLLBACK_ONLY",(ended?0:1)+(resources?0:1));
    }
}
