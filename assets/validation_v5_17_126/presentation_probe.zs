// Prueba aislada: usa las mismas entradas del menú, sin modificar la partida.
class CA465Probe : StaticEventHandler
{
    ui int Passed,Failed;
    ui void Check(bool okay,String label)
    {if(okay)Passed++;else Failed++;Console.Printf("CA465 %s %s",okay?"PASS":"FAIL",label);}
    override void ConsoleProcess(ConsoleEvent e)
    {
        if(e.Name=='ca465_open')
        {
            while(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();
            Menu.SetMenu('CaelumCreditsMenu');
        }
        if(e.Name=='ca465_test')
        {
            let menu=CaelumCreditsMenu(Menu.GetCurrentMenu());
            Check(menu!=null,"credits opens from native descriptor");if(menu==null)return;
            Check(StringTable.Localize("CA_CREDITS_TITLE",false)==(e.Args[0]==1?"Créditos":"Credits"),"ES/EN interface");
            Check(Screen.GetWidth()==e.Args[1] && Screen.GetHeight()==e.Args[2],"actual client resolution matches case");
            Console.Printf("CA465 SCREEN %dx%d",Screen.GetWidth(),Screen.GetHeight());
            let font=Font.GetFont("CaelumText");
            Check(font.CanPrint("ABCabc áéíóúüñ ¿¡ ĩ — – ‘ ’ “ ”",false),"retained letters and extension print");
            Check(font.StringWidth("Caelum Argenteum",false)>40,"font retains original glyph metrics");
            Check(StringTable.Localize("CA_PHYSICS_DAMAGE",false)==(e.Args[0]==1?"Daño":"Damage"),"physics ES/EN label");
            Check(CA465LocaleProbe.Check(e.Args[0]==1)==0,"all 79 affected locale entries resolve correctly");
            Console.Printf("CA465 LOCALE note=%s camp=%s exhaustion=%s hunt=%s",StringTable.Localize("CA_NOTE_NEED_MAP",false),StringTable.Localize("CA_CAMP_PACK_ACTION",false),StringTable.Localize("CA_EXHAUSTION_TITLE",false),StringTable.Localize("CA_HUNT_FRAGILE",false));
            for(int i=0;i<CaelumCreditsData.COUNT;i++)
            {
                menu.LoadDocument(i);Check(menu.Lines.Size()>0,"notice available");
                bool bounded=true;
                for(int j=0;j<menu.Lines.Size();j++)
                    if(font.StringWidth(menu.Lines[j])>CaelumCreditsMenu.LINE_WIDTH)
                    {bounded=false;Console.Printf("CA465 OVERFLOW notice=%d line=%d width=%d",i,j,font.StringWidth(menu.Lines[j]));}
                Check(bounded,"all notice lines fit");
            }
            menu.LoadDocument(0);
            menu.MenuEvent(Menu.MKEY_Down,false);Check(menu.First==1,"keyboard scroll");
            menu.MenuEvent(Menu.MKEY_PageDown,false);Check(menu.First>1,"keyboard page");
            menu.MenuEvent(Menu.MKEY_Up,true);Check(menu.First>=0,"controller navigation path");
            menu.Scroll(-100000);Check(menu.First==0,"upper bound");
            menu.Scroll(100000);Check(menu.First==Max(0,int(menu.Lines.Size())-menu.ROWS),"lower bound");
            menu.Selected=2;menu.MenuEvent(Menu.MKEY_Right,true);menu.MenuEvent(Menu.MKEY_Enter,true);
            Check(menu.Document==1,"controller selects next notice");
            menu.LoadDocument(0);
            Vector2 origin,size;[origin,size]=CaelumPresentation.MenuRect((378,304),(110,18));
            menu.MouseEvent(Menu.MOUSE_Click,int(origin.X+size.X/2),int(origin.Y+size.Y/2));
            menu.MouseEvent(Menu.MOUSE_Release,int(origin.X+size.X/2),int(origin.Y+size.Y/2));
            Check(menu.Document==1,"scaled mouse hit opens next notice");
            menu.LoadDocument(0);
            menu.MouseEvent(Menu.MOUSE_Click,int(origin.X+size.X/2),int(origin.Y+size.Y/2));
            menu.Scroll(1);
            menu.MouseEvent(Menu.MOUSE_Release,int(origin.X+size.X/2),int(origin.Y+size.Y/2));
            Check(menu.Document==0,"stale mouse gesture rejected");
            menu.MenuEvent(Menu.MKEY_Back,true);Check(Menu.GetCurrentMenu()==null,"native controller back closes credits");
            Menu.SetMenu('CaelumCreditsMenu');
        }
        if(e.Name=='ca465_done')Console.Printf("CA465 RESULT passed=%d failed=%d",Passed,Failed);
        if(e.Name=='ca465_main')
        {
            while(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();
            Menu.SetMenu('MainMenu');
        }
    }
}
