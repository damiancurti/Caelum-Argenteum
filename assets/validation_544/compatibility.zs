// Compatible con el runtime anterior: no contiene los campos nuevos de #238.
class CA238CompatibilityProbe : StaticEventHandler
{
    int Age;
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="c238_seed")return;
        let user=CaelumPlayer(players[e.Player].mo);if(user==null)return;
        user.CreationWizardOpen=false;user.CharacterCreationComplete=true;
        user.ApplyCharacterProfile();user.bInvulnerable=true;
    }
    override void UiTick(){if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    override void WorldTick()
    {
        Age++;
        if(Age==80)
        {
            let user=CaelumPlayer(players[0].mo);
            bool ok=user!=null && user.health>0 && user.player!=null && user.player.ReadyWeapon!=null;
            Console.Printf("CA238 %s compatible body and ready weapon",ok?"PASS":"FAIL");
            Console.Printf("CA238 DONE failures=%d COMPATIBILITY_ONLY",ok?0:1);
        }
    }
}

// Este observador sólo se incluye en la comprobación del runtime nuevo.
