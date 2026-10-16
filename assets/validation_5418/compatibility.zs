// Copied-save checks; original campaign saves are never changed.
class CA249Target : CaelumMandinga { override void Tick(){} }
class CA249Checkpoint : Inventory
{
    Actor Body; int Health,Remaining; double Anima,Air;
    Default {Inventory.MaxAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA249Compat : StaticEventHandler
{
    CaelumPlayer User; double Anima; int Passed,Failed,Cleared;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA249 %s %s",ok?"PASS":"FAIL",label);}
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
        if(e.Name=="c249_seed")
        {
            User.CreationWizardOpen=false;User.CharacterCreationComplete=true;
            User.CurrentAnima=500;User.bInvulnerable=true;
            User.DerivedStats.AnimaRegenerationPerSecond=0;
            User.CharacterProfile.FirstClass=CaelumConstants.CLASS_WARRIOR;
            User.CharacterProfile.SecondClass=CaelumConstants.CLASS_MAGE;
            Check(User.health>0,"neutral 5.4.17 seed is alive");
        }
        if(e.Name=="c249_verify")
        {
            Check(User.CharacterProfile.GetProfession()==CaelumConstants.PROFESSION_BATTLE_MAGE,"migration preserves saved Battle Mage identity");
            Check(Abs(User.CurrentAnima-Anima)<1e-6,"migration does not refund or charge Anima");
            Check(User.FindInventory("CaelumSummoningEffect")==null && !User.ClassCastActive,"absent or unsupported summoning stays inactive");
            Check(ThinkerIterator.Create("CaelumSummonedZupay").Next()==null,"no orphaned summoned body after migration");
        }
        if(e.Name=="c249_done")Console.Printf("CA249 DONE failures=%d passed=%d removed=%d",Failed,Passed,Cleared);
    }
}
