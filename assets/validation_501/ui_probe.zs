// Observador de teclas y movimiento; no altera el estado de juego.
class CA117UIProbe : EventHandler
{
    int LastTic;
    override void ConsoleProcess(ConsoleEvent e)
    {
        if(e.Name=="ca117_open_creator")
        {
            Menu.SetMenu("CaelumNewCharacterMenu");
            Console.Printf("CA117 MENU opened");
        }
        if(e.Name=="ca117_creator_next")
        {
            let creator=CaelumCharacterCreationMenu(Menu.GetCurrentMenu());
            if(creator==null) { Console.Printf("CA117 FAIL creator not open"); return; }
            creator.MenuEvent(Menu.MKEY_Enter,false);
            Console.Printf("CA117 MENU page=%d layers=%d attributes=%d",creator.Page,creator.RemainingLayerPoints(),creator.RemainingAttributePoints());
        }
        if(e.Name=="ca117_creator_allocate")
        {
            let creator=CaelumCharacterCreationMenu(Menu.GetCurrentMenu());
            if(creator==null) { Console.Printf("CA117 FAIL allocation creator not open"); return; }
            for(int pass=0;pass<10;pass++)
            for(int i=0;i<(creator.Page==CaelumConstants.CREATION_PAGE_LAYERS?4:12);i++)
            {
                creator.SelectedLayer=i%4; creator.SelectedAttribute=i;
                creator.MenuEvent(Menu.MKEY_Right,false);
            }
            Console.Printf("CA117 MENU allocated layers=%d attributes=%d",creator.RemainingLayerPoints(),creator.RemainingAttributePoints());
        }
        if(e.Name=="ca117_intro_next")
        {
            let intro=CaelumIntroductionMenu(Menu.GetCurrentMenu());
            if(intro==null) { Console.Printf("CA117 FAIL introduction not open"); return; }
            intro.MenuEvent(Menu.MKEY_Enter,false);
            Console.Printf("CA117 INTRO advanced");
        }
    }
    override void WorldTick()
    {
        if(level.time<LastTic+35)return;
        LastTic=level.time;
        let u=CaelumPlayer(players[0].mo); if(u==null)return;
        Console.Printf("CA117 UI tic=%d x=%.3f y=%.3f z=%.3f air=%.6f active=%d ready=%d creation=%d",
            level.time,u.Pos.X,u.Pos.Y,u.Pos.Z,u.CurrentAir,u.ActiveWeaponItemId,
            u.player.ReadyWeapon!=null,u.CharacterCreationComplete);
    }
    override bool InputProcess(InputEvent e)
    {
        if(e.Type==InputEvent.Type_KeyDown || e.Type==InputEvent.Type_KeyUp)
            Console.Printf("CA117 KEY type=%d scan=%d",e.Type,e.KeyScan);
        return false;
    }
}
