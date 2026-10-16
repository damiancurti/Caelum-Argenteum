// Sólo para cargar una copia de 5.4.8 con el runtime de 5.4.7.
class CaelumSocializationEffect : CaelumRacialAbilityEffect { }
class CaelumSocialPage : Object { int Node,Offset; double Multiplier; }
class CaelumSocialSession : Object
{int Revision,Current;Actor Speaker;Array<CaelumSocialPage> Pages;}
class CA240Rollback : StaticEventHandler
{
    int Age;
    double Anima;
    bool WasActive;
    override void WorldLoaded(WorldEvent e)
    {
        let user=CaelumPlayer(players[0].mo);if(user==null)return;
        Anima=user.CurrentAnima;WasActive=user.RacialAbilityActive && user.RacialAbility is "CaelumSocializationEffect";
        CaelumRacialAbilityRules.Deactivate(user);
    }
    override void WorldTick()
    {
        if(++Age!=20)return;let user=CaelumPlayer(players[0].mo);
        bool ended=WasActive && !user.RacialAbilityActive && user.RacialAbility==null;
        bool retained=Abs(user.CurrentAnima-Anima)<1e-6;
        Console.Printf("CA240 %s rollback ends unsupported power",ended?"PASS":"FAIL");
        Console.Printf("CA240 %s rollback preserves spent Anima",retained?"PASS":"FAIL");
        Console.Printf("CA240 DONE failures=%d ROLLBACK_ONLY",(ended?0:1)+(retained?0:1));
    }
}
