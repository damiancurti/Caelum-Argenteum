// Ensayo de migración sobre copias; el puente solo se usa con 5.4.11.
class CA245Body : CaelumMandinga
{
    int Received,ProjectileHits,PeriodicHits;
    Default { Radius 16; Height 96; Mass 100; Health 100000; +SOLID +SHOOTABLE +NOGRAVITY +ISMONSTER }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA245Compat : StaticEventHandler
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
        if(e.Name=="c245_seed")
        {
            User.CreationWizardOpen=false;User.CharacterCreationComplete=true;
            User.CurrentAnima=500;User.bInvulnerable=true;
            User.DerivedStats.AnimaRegenerationPerSecond=0;
            Console.Printf("CA245 DONE failures=0 passed=1 neutral 5.4.11 seed");
        }
        if(e.Name=="c245_verify")
        {
            bool clean=User.FindInventory("CaelumMiracleEffect")==null && !User.ClassCastActive;
            let it=ThinkerIterator.Create("CaelumMiracleEffect");clean=clean && it.Next()==null;
            bool paid=Abs(User.CurrentAnima-Anima)<1e-6;
            Console.Printf("CA245 %s unsupported or absent effect stays inactive",clean?"PASS":"FAIL");
            Console.Printf("CA245 %s migration retains spent Anima",paid?"PASS":"FAIL");
            Console.Printf("CA245 DONE failures=%d passed=%d removed=%d was-preparing=%d",(clean?0:1)+(paid?0:1),(clean?1:0)+(paid?1:0),Cleared,WasPreparing);
        }
    }
}
