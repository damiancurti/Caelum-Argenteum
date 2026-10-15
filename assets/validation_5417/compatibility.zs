// Copied-save bridge; it never edits the original campaign save.
class CA248Body : CaelumMandinga { override void Tick() { } }
class CA248Compat : StaticEventHandler
{
    CaelumPlayer User;
    double Anima;
    int Cleared,Passed,Failed;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA248 %s %s",ok?"PASS":"FAIL",label);}
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
        if(e.Name=="c248_seed")
        {
            User.CreationWizardOpen=false;User.CharacterCreationComplete=true;
            User.CurrentAnima=500;User.bInvulnerable=true;
            User.DerivedStats.AnimaRegenerationPerSecond=0;
            User.CharacterProfile.FirstClass=CaelumConstants.CLASS_WARRIOR;
            User.CharacterProfile.SecondClass=CaelumConstants.CLASS_PRIEST;
            Check(User.health>0,"neutral 5.4.16 seed is alive");
        }
        if(e.Name=="c248_verify")
        {
            Check(User.CharacterProfile.GetProfession()==CaelumConstants.PROFESSION_CLERIC,"migration preserves saved Cleric identity");
            Check(Abs(User.CurrentAnima-Anima)<1e-6,"migration preserves spent Anima without refund or duplicate debit");
            Check(User.FindInventory("CaelumRallyEffect")==null && !User.ClassCastActive,"unsupported or absent Rally remains inactive");
            // CURRENT_CONTEXT_CHECK
        }
        if(e.Name=="c248_done")Console.Printf("CA248 DONE failures=%d passed=%d removed=%d",Failed,Passed,Cleared);
    }
}
