class CA192Creator : StaticEventHandler
{
    ui int Failures,Passes;
    ui void Check(bool ok,String text)
    {if(ok)Passes++;else Failures++;Console.Printf("CA192 %s %s",ok?"PASS":"FAIL",text);}
    ui void Click(CaelumCharacterCreationMenu menu,int id)
    {
        menu.PointerLayout(false);Vector2 point=(-1,-1);
        for(int i=0;i<int(menu.Pointer.Ids.Size());i++)if(menu.Pointer.Ids[i]==id)
            point=(menu.Pointer.Lefts[i]+menu.Pointer.Widths[i]/2,menu.Pointer.Tops[i]+menu.Pointer.Heights[i]/2);
        Check(point.X>=0,"creator native control exists");point*=Screen.GetHeight()/600.0;
        menu.MouseEvent(Menu.MOUSE_Click,int(point.X),int(point.Y));
        menu.MouseEvent(Menu.MOUSE_Release,int(point.X),int(point.Y));
    }
    override void ConsoleProcess(ConsoleEvent e)
    {
        if(e.Name!="ca192_creator")return;
        int mode=e.Args[0];
        if(mode==9){Menu.SetMenu("CaelumNewCharacterMenu");return;}
        if(mode==0)
        {
            if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();
            let settings=CaelumCharacterSettings(StaticEventHandler.Find("CaelumCharacterSettings"));settings.Draft=null;
            Menu.SetMenu("CaelumNewCharacterMenu");return;
        }
        let menu=CaelumCharacterCreationMenu(Menu.GetCurrentMenu());
        Check(menu!=null,"native creator owns cursor");if(menu==null)return;
        if(mode==1)
        {
            menu.Page=CaelumConstants.CREATION_PAGE_ATTRIBUTES;Click(menu,4);
            Check(menu.Page==CaelumPersonalityRules.FIRST_PAGE,"attributes continue to personality");
            for(int layer=0;layer<4;layer++)
            {
                Check(menu.Page==8+layer,"four independent personality pages in order");
                for(int choice=0;choice<3;choice++)
                {
                    Click(menu,100+choice);Check(menu.Personality[layer]==choice,"mouse selects personality option");
                    Check(menu.ContextText()!="" && menu.ContextText().IndexOf("CA_PERSONALITY")<0,"localized mechanical description resolves");
                }
                Click(menu,4);
            }
            Check(menu.Page==CaelumConstants.CREATION_PAGE_SUMMARY,"four pages lead to summary");
            Click(menu,1);Check(menu.Page==11,"summary back reaches ideology");
            menu.MenuEvent(Menu.MKEY_Left,false);Check(menu.Personality[3]==1,"keyboard changes ideology");
            menu.MenuEvent(Menu.MKEY_Right,false);Check(menu.Personality[3]==2,"keyboard restores ideology");
            Click(menu,100);menu.Close();return;
        }
        if(mode==2)
        {
            Check(menu.Page==11 && menu.Personality[0]==2 && menu.Personality[1]==2 && menu.Personality[2]==2 && menu.Personality[3]==0,
                "draft restores page and all four choices");
            menu.Page=8;return;
        }
        if(mode>=3 && mode<=6){menu.Page=mode+5;return;}
        if(mode==7){menu.Page=CaelumConstants.CREATION_PAGE_SUMMARY;return;}
        if(mode==8)
        {
            Click(menu,4);
            Check(CVar.GetCVar("ca_newchar_personality",players[consoleplayer]).GetInt()==26,"confirmed bridge stores all four choices");
            if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();
            Console.Printf("CA192 DONE failures=%d passes=%d",Failures,Passes);
        }
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="ca192_consume")return;
        let u=CaelumPlayerAuthority.FromNetworkPlayer(e.Player);let r=u.GetPersistentCharacterState(true);
        u.CharacterCreationComplete=false;r.ProfileCommitted=false;
        bool ok=u.ConsumeNewCharacterDraft() && CaelumPersonalityRules.Pack(u.CharacterProfile)==26;
        Console.Printf("CA192 %s authoritative creator bridge consumes validated personality",ok?"PASS":"FAIL");
        u.PersistCharacterState();
        Console.Printf("CA192 %s traveler owns same personality profile",r.IdentityProfile==u.CharacterProfile && CaelumPersonalityRules.Pack(r.IdentityProfile)==26?"PASS":"FAIL");
    }
}
