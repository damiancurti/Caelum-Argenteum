// Estados sintéticos de presentación: no afirman efectos raciales implementados.
class CA238HUDProbe : StaticEventHandler
{
    int Mode,Passed,Failed;
    CaelumPlayer TestUser;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA238 %s %s",ok?"PASS":"FAIL",label);}
    override void UiTick(){if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    override void WorldTick()
    {
        if(TestUser==null)return;
        if(Mode==2)TestUser.ClassPreparationTics=60;
        if(Mode==0)TestUser.CurrentAnima=0;
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let user=CaelumPlayer(players[e.Player].mo);if(user==null)return;
        if(e.Name=="c238_hud_setup")
        {
            TestUser=user;user.CharacterProfile.Race=CaelumConstants.RACE_HUMAN;
            user.CharacterProfile.FirstClass=CaelumConstants.CLASS_PRIEST;
            user.CharacterProfile.SecondClass=CaelumConstants.CLASS_MAGE;
            user.ApplyCharacterProfile();user.bInvulnerable=true;
            user.ClassSleepCooldownRemaining=0;user.ClassPreparationTics=0;
            double cost=CaelumSleepRules.Cost(user);
            user.CurrentAnima=cost-0.1;
            Check(!CaelumSleepRules.CanCast(user) && !CaelumSleepRules.Cast(user)
                && user.CurrentAnima==cost-0.1,"insufficient resource remains rejected without debit");
            user.CurrentAnima=cost;
            Check(CaelumSleepRules.CanCast(user),"exact existing Sleep cost remains eligible");
            user.CurrentAnima=user.DerivedStats.MaximumAnima;
            CaelumNotifications.Notify(user,"#238: presentación de estados; efectos raciales aún pendientes.");
        }
        if(e.Name=="c238_hud_state")
        {
            Mode=e.Args[0];user.ClassPreparationTics=Mode==2?60:0;
            user.ClassSleepCooldownRemaining=Mode==3?60:0;
            user.RacialAbilityActive=Mode==2;
            user.CurrentAnima=Mode==0?0:user.DerivedStats.MaximumAnima;
            user.CharacterProfile.FirstClass=Mode==4?CaelumConstants.CLASS_WARRIOR:CaelumConstants.CLASS_PRIEST;
            user.CharacterProfile.SecondClass=Mode==4?CaelumConstants.CLASS_WARRIOR:CaelumConstants.CLASS_MAGE;
            CaelumPlayerPresentation.SyncHUDActiveWeaponState(user);
        }
        if(e.Name=="c238_hud_check")
        {
            Check(user.HUDClassAbilityAvailable==(Mode==1 || Mode==2),"class availability agrees with current implemented effect");
            Check(user.RacialAbilityActive==(Mode==2),"racial display uses active/inactive state only");
            if(Mode==3)Check(user.ClassSleepCooldownRemaining>0 && user.ClassSleepCooldownRemaining<60,
                "class cooldown continues on simulation clock");
            Console.Printf("CA238 HUD mode=%d ready=%d preparation=%d cooldown=%.4f racial=%d",
                Mode,user.HUDClassAbilityAvailable,user.ClassPreparationTics,user.ClassSleepCooldownRemaining,user.RacialAbilityActive);
        }
        if(e.Name=="c238_hud_done")
        {
            user.RacialAbilityActive=false;user.ClassPreparationTics=0;
            Console.Printf("CA238 DONE failures=%d passes=%d HUD_ONLY",Failed,Passed);
        }
    }
}
