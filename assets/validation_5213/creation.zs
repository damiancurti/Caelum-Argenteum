class CA148Creation : StaticEventHandler
{
    ui int Step,Delay,Failures;
    ui bool Active;
    ui CaelumCharacterProfile Original;
    ui void Check(bool ok,String label)
    {if(!ok)Failures++;Console.Printf("CA148 %s %s",ok?"PASS":"FAIL",label);}
    override void ConsoleProcess(ConsoleEvent e)
    {
        if(e.Name!="ca148_new")return;
        Active=true;Step=0;
        Original=CaelumCharacterIdentity.Profile(CaelumPlayer(players[0].mo));
        Menu.SetMenu("CaelumNewCharacterMenu");
    }
    override void UiTick()
    {
        if(!Active || ++Delay<5)return;Delay=0;
        let menu=CaelumCharacterCreationMenu(Menu.GetCurrentMenu());
        if(Step==0 && menu!=null)
        {
            menu.Race=2;menu.Sex=1;menu.HeightChoice=2;menu.Page=4;
            menu.MenuEvent(Menu.MKEY_Enter,false);
            Check(menu.Page==CaelumAppearance.PAGE,"height advances to appearance page");
            menu.MenuEvent(Menu.MKEY_Right,false);
            menu.MenuEvent(Menu.MKEY_Down,false);
            menu.MenuEvent(Menu.MKEY_Right,false);
            menu.MenuEvent(Menu.MKEY_Down,false);
            menu.MenuEvent(Menu.MKEY_Right,false);
            menu.MenuEvent(Menu.MKEY_Right,false);
            menu.MenuEvent(Menu.MKEY_Down,false);
            for(int n=0;n<3;n++)menu.MenuEvent(Menu.MKEY_Right,false);
            Check(menu.SkinTone==1 && menu.Face==1 && menu.HairStyle==2 && menu.HairColor==3,"keyboard events select tone, face, hairstyle and hair color");
            menu.MenuEvent(Menu.MKEY_PageDown,false);menu.MenuEvent(Menu.MKEY_Clear,false);
            Check(menu.Preview.Rotation==1 && menu.Preview.Walking,"native keyboard events rotate and animate preview");
            menu.Page=CaelumConstants.CREATION_PAGE_LAYERS;
            for(int n=0;n<32 && menu.RemainingLayerPoints()>0;n++)
            {menu.MenuEvent(Menu.MKEY_Right,false);menu.MenuEvent(Menu.MKEY_Down,false);}
            menu.Page=CaelumConstants.CREATION_PAGE_ATTRIBUTES;
            for(int n=0;n<60 && menu.RemainingAttributePoints()>0;n++)
            {menu.MenuEvent(Menu.MKEY_Right,false);menu.MenuEvent(Menu.MKEY_Down,false);}
            Check(menu.RemainingLayerPoints()==0 && menu.RemainingAttributePoints()==0,"normal allocation remains valid");
            menu.ConfirmAndStart();Step=1;
        }
        else if(Step==1)
        {
            let intro=CaelumIntroductionMenu(Menu.GetCurrentMenu());
            if(intro==null)Step=2;
        }
        else if(Step==2 && gamestate==GS_LEVEL && level.time>5)
        {
            let user=CaelumPlayer(players[0].mo);let p=CaelumCharacterIdentity.Profile(user);
            if(p==Original)return;
            Check(user.CharacterCreationComplete && p.Race==2 && p.Sex==1 && p.HeightChoice==2
                && p.SkinTone==1 && p.Face==1 && p.HairStyle==2 && p.HairColor==3,"new game consumes selected appearance with structural identity");
            Check(!CVar.GetCVar('ca_newchar_ready',players[0]).GetBool(),"new-game appearance bridge consumed once");
            Check(Original.SkinTone==0 && Original.BeastForm==0,"second character does not mutate previous profile");
            Console.Printf("CA148 DONE failures=%d",Failures);Active=false;
        }
    }
}
