// Compatibilidad de copias neutrales: no modifica partidas de campaña.
class CA251Compat : StaticEventHandler
{
    CaelumPlayer User;
    double Anima;
    int Passed,Failed;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA251 %s %s",ok?"PASS":"FAIL",label);}
    override void UiTick(){if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    override void WorldLoaded(WorldEvent e)
    {User=CaelumPlayer(players[0].mo);if(User!=null)Anima=User.CurrentAnima;}
    override void WorldTick()
    {if(User!=null && User.DerivedStats!=null)User.DerivedStats.AnimaRegenerationPerSecond=0;}
    override void NetworkProcess(ConsoleEvent e)
    {
        User=CaelumPlayer(players[0].mo);if(User==null)return;
        if(e.Name=="c251_seed")
        {
            User.CreationWizardOpen=false;User.CharacterCreationComplete=true;
            User.CharacterProfile.FirstClass=CaelumConstants.CLASS_EXPLORER;
            User.CharacterProfile.SecondClass=CaelumConstants.CLASS_MAGE;
            User.ApplyCharacterProfile();User.bInvulnerable=true;User.CurrentAnima=500;
            User.DerivedStats.AnimaRegenerationPerSecond=0;
            Check(User.health>0,"accepted 5.4.19 neutral Investigator seed is alive");
        }
        else if(e.Name=="c251_verify")
        {
            Check(User.CharacterProfile.GetProfession()==CaelumConstants.PROFESSION_INVESTIGATOR,"copied save retains Investigator identity");
            Check(abs(User.CurrentAnima-Anima)<0.000001,"upgrade or neutral rollback does not charge or refund Anima");
            Check(!User.ClassCastActive && User.ClassSleepCooldownRemaining==0,"neutral save keeps shared ability inactive");
            Check(User.health>0 && User.player.playerstate==PST_LIVE,"player remains alive and controlled");
        }
        else if(e.Name=="c251_done")Console.Printf("CA251 DONE failures=%d passed=%d",Failed,Passed);
    }
}
