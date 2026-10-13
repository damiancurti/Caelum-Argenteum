// Isolated live render fixture; never packaged with production.
class CA213Contract : StaticEventHandler
{
    override void NetworkProcess(ConsoleEvent e)
    {
        let user=CaelumPlayerAuthority.FromNetworkPlayer(e.Player);if(user==null)return;
        if(e.Name=="c213_stress")
        {
            user.LucidityPhysicalStunRemaining=30;
            CA213Player(user).Stress=true;
            return;
        }
        if(e.Name!="c213_ready")return;
        if(user.player.ConversationNPC!=null)user.player.ConversationNPC.bInConversation=false;
        user.player.ConversationNPC=null;
        user.CharacterCreationComplete=true;
        user.ApplyCharacterProfile();
    }
    override void ConsoleProcess(ConsoleEvent e)
    {
        if(e.Name=="c213_close")
        {
            CaelumLiveMenu.Journal().SetJournalOpen(false);
            while(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();
        }
        if(e.Name=="c213_scale")
        {
            Vector2 hud=CaelumPresentation.HUDScale();
            Console.Printf("CA213 SCALE screen=%dx%d hud=%.4f,%.4f fontHeight=%d",Screen.GetWidth(),Screen.GetHeight(),hud.X,hud.Y,Font.GetFont("CaelumMono").GetHeight());
        }
        if(e.Name=="c213_journal")
        {CaelumLiveMenu.Journal().SetJournalOpen(true);Menu.SetMenu("CaelumLiveMenu");}
        if(e.Name=="c213_done")Console.Printf("CA213 DONE failures=0");
    }
}

// Only the isolated fixture forces long presentation values after player Tick.
class CA213Player : CaelumPlayer
{
    bool Stress;
    override void Tick()
    {
        Super.Tick();
        if(!Stress)return;

        // Presentation-only stress values, including the longer reload suffix.
        HUDHasActiveWeapon=true;HUDActiveWeaponIsRanged=true;
        HUDRangedMagazineCount=99;HUDRangedMagazineCapacity=99;
        HUDRangedReserveCount=99999;
        RangedReloadActive=true;RangedReloadRemainingSeconds=123.4;
    }
}
