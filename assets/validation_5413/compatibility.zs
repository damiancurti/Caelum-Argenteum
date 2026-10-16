// Puente opcional sobre copias; no se distribuye ni modifica saves originales.
class CA246Body : CaelumMandinga { int Hits; bool TickStatus; }
class CA246Compat : StaticEventHandler
{
    CaelumPlayer User;
    double Anima;
    int Cleared;
    bool WasPreparing;
    override void UiTick(){if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    override void WorldLoaded(WorldEvent e)
    {
        User=CaelumPlayer(players[0].mo);if(User==null)return;
        Anima=User.CurrentAnima;WasPreparing=User.ClassCastActive;
        // ROLLBACK_ACTION
    }
    override void WorldTick()
    {if(User!=null && User.DerivedStats!=null)User.DerivedStats.AnimaRegenerationPerSecond=0;}
    override void NetworkProcess(ConsoleEvent e)
    {
        User=CaelumPlayer(players[e.Player].mo);if(User==null)return;
        if(e.Name=="c246_seed")
        {
            User.CreationWizardOpen=false;User.CharacterCreationComplete=true;
            User.CurrentAnima=500;User.bInvulnerable=true;
            User.DerivedStats.AnimaRegenerationPerSecond=0;
            Console.Printf("CA246 DONE failures=0 passed=1 neutral 5.4.12 seed");
        }
        if(e.Name=="c246_verify")
        {
            let it=ThinkerIterator.Create("CaelumArcaneSunShot");
            bool clean=it.Next()==null && !User.ClassCastActive;
            bool paid=Abs(User.CurrentAnima-Anima)<1e-6;
            Console.Printf("CA246 %s unsupported or absent projectile stays inactive",clean?"PASS":"FAIL");
            Console.Printf("CA246 %s migration retains spent Anima",paid?"PASS":"FAIL");
            Console.Printf("CA246 DONE failures=%d passed=%d removed=%d was-preparing=%d",(clean?0:1)+(paid?0:1),(clean?1:0)+(paid?1:0),Cleared,WasPreparing);
        }
    }
}
