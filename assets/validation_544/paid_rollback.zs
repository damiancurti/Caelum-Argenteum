// Isolated schema round trip; production gameplay is never replaced by this probe.
class CA238RollbackBody : CaelumCombatActor
{
    Default { Radius 16; Height 56; Mass 80; Health 100000; +SHOOTABLE; +NOGRAVITY; }
    States { Spawn: TNT1 A -1; Stop; RestLying: TNT1 B -1; Stop; }
}

class CA238PaidRollback : StaticEventHandler
{
    CaelumPlayer User;
    int Passed,Failed,InitialTics;
    double InitialPaid,InitialAnima,InitialCooldown;
    bool Loaded;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA238 %s %s",ok?"PASS":"FAIL",label);}
    override void UiTick(){if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    override void WorldTick()
    {
        User=CaelumPlayer(players[0].mo);
        if(User!=null && User.DerivedStats!=null)User.DerivedStats.AnimaRegenerationPerSecond=0;
    }
    override void WorldLoaded(WorldEvent e)
    {
        if(!e.IsSaveGame)return;
        User=CaelumPlayer(players[0].mo);Loaded=true;
        InitialTics=User.ClassPreparationTics;InitialPaid=User.ClassCastPaid;
        InitialAnima=User.CurrentAnima;InitialCooldown=User.ClassSleepCooldownRemaining;
        Check(User.ClassCastRevision==1 && User.ClassPreparationRevision==1,"class schema revisions retained");
        Check(User.RacialAbilityRevision==1 && (InitialTics==0 ? !User.RacialAbilityActive && User.RacialAbility==null : User.RacialAbilityActive
            && User.RacialAbility!=null && User.RacialAbility.Revision==1
            && User.RacialAbility.Race==User.CharacterProfile.Race),"racial object and active identity retained");
        Check(Abs(User.CurrentAnima+User.ClassCastPaid-1000)<1e-6,"paid resource is not refunded or duplicated on load");
        Check(User.ClassCastCost==1000 && User.ClassCastProfession==CaelumConstants.PROFESSION_ARCANIST,
            "fixed cost and profession retained");
        let it=ThinkerIterator.Create("CA238RollbackBody");let body=CA238RollbackBody(it.Next());
        Check(body!=null && body.SpellSleep!=null && body.SpellSleep.Revision==1
            && body.SpellSleep.HitsRemaining==2 && body.SpellSleep.DamageMultiplier==6
            && body.ForcedSleepTics>0 && body.SpellSleep.SavedState!=null
            && body.SpellSleep.LyingState!=null,"Sleep counter potency timer and state pointers retained");
        Check(User.player.ReadyWeapon!=null,"native ready weapon restored");
        Console.Printf("CA238 SNAPSHOT remaining=%d paid=%.12f anima=%.12f cooldown=%.12f sleep=%d",
            InitialTics,InitialPaid,InitialAnima,InitialCooldown,body==null?-1:body.ForcedSleepTics);
    }
    virtual void CurrentEvent(ConsoleEvent e) {}
    override void NetworkProcess(ConsoleEvent e)
    {
        User=CaelumPlayer(players[e.Player].mo);if(User==null)return;
        CurrentEvent(e);
        if(e.Name=="c238_bridge_check")
        {
            Check(Loaded,"bridge loaded a saved session");
            Check(User.ClassPreparationTics==InitialTics && User.ClassCastPaid==InitialPaid,
                "old gameplay keeps new preparation and paid ledger inert");
            Check(Abs(User.CurrentAnima-InitialAnima)<1e-6,"bridge does not spend or refund Anima");
            Check(InitialCooldown==0?User.ClassSleepCooldownRemaining==0:
                User.ClassSleepCooldownRemaining>0 && User.ClassSleepCooldownRemaining<InitialCooldown,
                "existing cooldown follows old gameplay without refresh");
            Check(InitialTics==0 ? User.RacialAbility==null && !User.RacialAbilityActive :
                User.RacialAbility!=null && User.RacialAbilityActive,"racial state survives bridge ticks");
            let it=ThinkerIterator.Create("CA238RollbackBody");let body=CA238RollbackBody(it.Next());
            Check(body!=null && body.SpellSleep!=null && body.SpellSleep.HitsRemaining==2
                && body.SpellSleep.DamageMultiplier==6,"old gameplay preserves new Sleep metadata");
        }
        if(e.Name=="c238_rollback_done")
            Console.Printf("CA238 DONE failures=%d passes=%d PAID_ROLLBACK",Failed,Passed);
    }
}
