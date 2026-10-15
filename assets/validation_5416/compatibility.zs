// Copied-save bridge. The old runtime cancels unsupported effects without refund.
class CA247Player : CaelumPlayer { }
class CA247Body : CaelumCombatActor { }
class CA247Compat : StaticEventHandler
{
    CaelumPlayer User;
    double Anima;
    int Cleared,Passed,Failed;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA247 %s %s",ok?"PASS":"FAIL",label);}
    override void UiTick(){if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    override void WorldLoaded(WorldEvent e)
    {
        User=CaelumPlayer(players[0].mo);if(User==null)return;
        Anima=User.CurrentAnima;
        // ROLLBACK_ACTION
    }
    override void WorldTick()
    {if(User!=null && User.DerivedStats!=null)User.DerivedStats.AnimaRegenerationPerSecond=0;}
    override void NetworkProcess(ConsoleEvent e)
    {
        User=CaelumPlayer(players[0].mo);if(User==null)return;
        if(e.Name=="c247_seed")
        {
            User.CreationWizardOpen=false;User.CharacterCreationComplete=true;
            User.CurrentAnima=500;User.bInvulnerable=true;
            User.DerivedStats.AnimaRegenerationPerSecond=0;
            User.CharacterProfile.FirstClass=CaelumConstants.CLASS_WARRIOR;
            User.CharacterProfile.SecondClass=CaelumConstants.CLASS_EXPLORER;
            Check(User.health>0,"neutral 5.4.15 save seed is alive");
        }
        if(e.Name=="c247_verify")
        {
            Check(User.CharacterProfile.GetProfession()==CaelumConstants.PROFESSION_MERCENARY,"migration retains saved profession");
            Check(Abs(User.CurrentAnima-Anima)<1e-6,"migration retains spent Anima without refund or duplicate debit");
            Check(User.FindInventory("CaelumFormationBreakerEffect")==null && !User.ClassCastActive,"unsupported or absent effect remains inactive");
            let it=ThinkerIterator.Create("CaelumFormationAfterimage");
            Check(it.Next()==null,"no orphaned afterimages survive rollback or re-upgrade");
        }
        if(e.Name=="c247_done")Console.Printf("CA247 DONE failures=%d passes=%d removed=%d",Failed,Passed,Cleared);
    }
}
