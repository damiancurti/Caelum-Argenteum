class CA597MenuProbe : StaticEventHandler
{
    ui int Age;
    ui void Check(bool result,String label)
    {Console.Printf("CA597 %s %s",result?"PASS":"FAIL",label);}
    override void UiTick()
    {
        Age++;
        if(Age==10)
        {
            let main=ListMenuDescriptor(MenuDescriptor.GetDescriptor('MainMenu'));
            bool found=false;
            for(int i=0;i<main.mItems.Size();i++)
                if(main.mItems[i].GetAction()=='CaelumStandaloneMenu')found=true;
            Check(found,"main menu exposes localized Multiplayer entry");
            CVar.GetCVar('ca_standalone_bridge').SetBool(false);
            Menu.SetMenu('CaelumStandaloneMenu');
            let menu=CaelumStandaloneMenu(Menu.GetCurrentMenu());
            Check(menu!=null,"native Multiplayer menu opens on title");
            if(menu!=null)
            {
                for(int i=0;i<menu.mDesc.mItems.Size();i++)if(menu.mDesc.mItems[i] is 'OptionMenuItemCommand')
                    Check(menu.mDesc.mItems[i].IsGrayed(),"direct engine launch cannot request an unavailable bridge");
                menu.Close();
            }
            CVar.GetCVar('ca_standalone_bridge').SetBool(true);
            Menu.SetMenu('CaelumStandaloneMenu');
        }
        if(Age==30)
        {
            let menu=CaelumStandaloneMenu(Menu.GetCurrentMenu());
            if(menu==null){Check(false,"menu remains active");return;}
            menu.mDesc.mSelectedItem=2;menu.MenuEvent(Menu.MKEY_Right,false);
            menu.mDesc.mSelectedItem=3;menu.MenuEvent(Menu.MKEY_Right,false);
            Check(CVar.GetCVar('ca_match_mode').GetInt()==1,"native mode selector changes the request");
            Check(CVar.GetCVar('ca_match_preset').GetInt()==1,"native resident selector changes the request");
        }
        if(Age==90)
        {
            let menu=CaelumStandaloneMenu(Menu.GetCurrentMenu());
            if(menu==null)return;
            for(int i=0;i<menu.mDesc.mItems.Size();i++)if(menu.mDesc.mItems[i] is 'OptionMenuItemCommand')
            {
                Check(!menu.mDesc.mItems[i].IsGrayed(),"bridge enables explicit fresh-match launch");
                Console.Printf("CA597 RESULT menu");
                // La pulsación final debe llegar por la entrada nativa de Windows.
                menu.mDesc.mSelectedItem=i;return;
            }
        }
    }
}
