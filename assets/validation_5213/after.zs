class CA148After : StaticEventHandler
{
    override void ConsoleProcess(ConsoleEvent e)
    {
        if(e.Name=="ca148_edit")Menu.SetMenu("CaelumAppearanceMenu");
        if(e.Name=="ca148_turn")
        {
            let menu=CaelumCharacterCreationMenu(Menu.GetCurrentMenu());
            if(menu!=null)
            {menu.MenuEvent(Menu.MKEY_PageDown,false);menu.MenuEvent(Menu.MKEY_Clear,false);}
        }
        if(e.Name=="ca148_setup")EventHandler.SendNetworkEvent("ca148_setup",e.Args[0],e.Args[1],e.Args[2]);
        if(e.Name=="ca148_after")
        {
            Menu.SetMenu("CaelumNewCharacterMenu");
            let menu=CaelumCharacterCreationMenu(Menu.GetCurrentMenu());
            if(menu!=null)
            {menu.Page=e.Args[0];menu.Race=e.Args[1];menu.Sex=e.Args[2];menu.SkinTone=2;menu.BeastForm=3;}
        }
        if(e.Name=="ca148_done")Console.Printf("CA148 DONE failures=0");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="ca148_setup")return;
        let user=CaelumPlayer(players[e.Player].mo);
        let profile=CaelumCharacterIdentity.Profile(user);
        profile.Race=e.Args[0];profile.Sex=e.Args[1];profile.SkinTone=e.Args[2];profile.BeastForm=3;
        user.CharacterCreationComplete=true;
        user.ApplyCharacterProfile();user.UpdateWorldCarbineVisual();
    }
}
