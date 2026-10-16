// Puente exclusivo de 5.4.6: quitar la nueva sujeción sin restaurar recursos.
class CaelumTelekinesisEffect : CaelumRacialAbilityEffect { }
class CA241Body : CaelumCombatActor
{
    int Actions;
    void Act(){Actions++;}
    Default { +SOLID +SHOOTABLE +NOBLOOD Mass 66; Radius 16; Height 96; Health 10000; }
    States { Spawn: TNT1 A 1 {Act();} Loop; }
}
class CA241Rollback : StaticEventHandler
{
    int Age,InitialActions;
    bool WasActive;
    double Anima;
    override void WorldLoaded(WorldEvent e)
    {
        let user=CaelumPlayer(players[0].mo);if(user==null)return;
        WasActive=user.RacialAbilityActive && user.RacialAbility is "CaelumTelekinesisEffect";
        Anima=user.CurrentAnima;
        let body=CA241Body(ActorIterator.Create(241).Next());
        if(body!=null)InitialActions=body.Actions;
        CaelumRacialAbilityRules.Deactivate(user);
    }
    override void UiTick(){if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    override void WorldTick()
    {
        Age++;if(Age!=20)return;
        let user=CaelumPlayer(players[0].mo);
        let body=CA241Body(ActorIterator.Create(241).Next());
        bool ended=user!=null && WasActive && !user.RacialAbilityActive && user.RacialAbility==null;
        bool resources=user!=null && Abs(user.CurrentAnima-Anima)<1e-6;
        bool mobile=body!=null && body.tics>=0 && body.Actions>InitialActions;
        Console.Printf("CA241 %s rollback deactivates unsupported power",ended?"PASS":"FAIL");
        Console.Printf("CA241 %s rollback preserves Anima",resources?"PASS":"FAIL");
        Console.Printf("CA241 %s rollback restores target actions",mobile?"PASS":"FAIL");
        Console.Printf("CA241 DONE failures=%d ROLLBACK_ONLY",(ended?0:1)+(resources?0:1)+(mobile?0:1));
    }
}
