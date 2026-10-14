// Historial del personaje: fuente de mensajes nativa, sin recortar las entradas.
class CaelumNotificationMenu : ListMenu
{
    CaelumPlayer Subject;
    CaelumMenuPointer Pointer;
    Array<String> Lines;
    int Offset, VisibleLines;
    double LastWidth, LastScale;
    String LastLanguage, OriginMap;

    static String Link()
    {
        int scan=CaelumMenuPointer.KeyScan(108);
        bool available=!CaelumInputHints.Matches(scan,"ca_journal_toggle") && !CaelumInputHints.Matches(scan,"ca_time_skip")
            && !CaelumExplorationNavigation.IsShortcut(Bindings.GetBinding(scan));
        return CaelumInputHints.Label(StringTable.Localize("CA_MESSAGES_LINK",false),available?"L":StringTable.Localize("CA_HINT_MOUSE",false));
    }

    override void Init(Menu parent,ListMenuDescriptor desc)
    {
        Super.Init(parent,desc);DontDim=true;DontBlur=true;
        Subject=consoleplayer>=0?CaelumPlayer(players[consoleplayer].mo):null;
        OriginMap=level.MapName;Pointer=new("CaelumMenuPointer");
        menuactive=Menu.OnNoPause;
    }
    override void Ticker()
    {
        if(GetCurrentMenu()!=self)return;
        if(consoleplayer<0 || players[consoleplayer].mo!=Subject || OriginMap!=level.MapName || Subject==null || Subject.health<=0)
        {Close();return;}
        menuactive=Menu.OnNoPause;
    }
    void Layout(bool draw)
    {
        let view=CaelumLiveMenu.Journal();Pointer.Clear();
        Pointer.Button(view,1,32,326,180,CaelumInputHints.Fixed(StringTable.Localize("CA_UI_UP",false),InputEvent.Key_PgUp),Offset>0,false,draw);
        Pointer.Button(view,2,228,326,180,CaelumInputHints.Fixed(StringTable.Localize("CA_UI_DOWN",false),InputEvent.Key_PgDn),Offset+VisibleLines<Lines.Size(),false,draw);
        Pointer.Button(view,3,424,326,180,CaelumInputHints.Fixed(StringTable.Localize("CA_UI_BACK",false),InputEvent.Key_Escape),true,false,draw);
    }
    void Scroll(int amount)
    {Offset=Clamp(Offset+amount,0,Max(0,int(Lines.Size())-VisibleLines));Pointer.Reset();}
    override bool MenuEvent(int key,bool fromcontroller)
    {
        if(key==MKEY_Up)Scroll(-1);
        else if(key==MKEY_Down)Scroll(1);
        else if(key==MKEY_PageUp)Scroll(-VisibleLines);
        else if(key==MKEY_PageDown)Scroll(VisibleLines);
        else if(key==MKEY_Back)Close();
        return true;
    }
    override bool OnUIEvent(UIEvent e)
    {
        if(e.Type==UIEvent.Type_WheelUp || e.Type==UIEvent.Type_WheelDown)
        {Scroll(e.Type==UIEvent.Type_WheelUp?-1:1);return true;}
        return Super.OnUIEvent(e);
    }
    override bool MouseEvent(int type,int x,int y)
    {
        Layout(false);Pointer.Move(CaelumMenuPointer.JournalPoint(x,y));
        if(type==MOUSE_Click)Pointer.Press(0);
        else if(type==MOUSE_Release)
        {int id=Pointer.Release(0);if(id==1)Scroll(-VisibleLines);else if(id==2)Scroll(VisibleLines);else if(id==3)Close();}
        return true;
    }
    virtual String TitleKey(){return "CA_MESSAGES_TITLE";}
    virtual String HelpKey(){return "CA_MESSAGES_HELP";}
    virtual void CollectText(Array<String> text)
    {
        let inbox=CaelumNotificationInbox(Subject.FindInventory("CaelumNotificationInbox"));
        if(inbox!=null)for(int i=inbox.HistoryCount-1;i>=0;i--)text.Push(inbox.HistoryText[i]);
        if(text.Size()==0)text.Push(StringTable.Localize("CA_MESSAGES_EMPTY",false));
    }
    override void Drawer()
    {
        if(Subject==null)return;
        Vector2 origin,size;[origin,size]=CaelumPresentation.MenuRect((36,58),(568,246));
        Vector2 scale=CaelumPresentation.MessageScale();
        let font=Font.GetFont("CaelumText");
        double lineHeight=(font.GetHeight()+2)*scale.Y;
        VisibleLines=Max(1,int(size.Y/lineHeight));
        String language=CVar.GetCVar("language").GetString();
        if(size.X!=LastWidth || scale.X!=LastScale || language!=LastLanguage)
        {Offset=0;Pointer.Reset();LastWidth=size.X;LastScale=scale.X;LastLanguage=language;}
        Lines.Clear();
        Array<String> text;CollectText(text);
        for(int i=0;i<text.Size();i++)
        {
            let wrapped=font.BreakLines(CaelumInputHints.Resolve(text[i]),Max(1,int(size.X/scale.X)));
            for(int line=0;line<wrapped.Count();line++)Lines.Push(wrapped.StringAt(line));
            wrapped.Destroy();Lines.Push("");
        }
        if(Lines.Size()==0)Lines.Push(StringTable.Localize("CA_MESSAGES_EMPTY",false));
        Offset=Clamp(Offset,0,Max(0,int(Lines.Size())-VisibleLines));
        Screen.Dim(0x05070A,0.92,0,0,Screen.GetWidth(),Screen.GetHeight());
        CaelumPresentation.BeginMenu();
        let view=CaelumLiveMenu.Journal();view.DrawPanel(16,12,608,336);
        view.DrawCenteredText(view.TitleFont,Font.CR_GOLD,320,16,StringTable.Localize(TitleKey(),false));
        CaelumInputHints.Draw(view.SmallFont,Font.CR_GRAY,320,42,StringTable.Localize(HelpKey(),false),560);
        Layout(true);CaelumPresentation.End();
        for(int i=0;i<VisibleLines && Offset+i<Lines.Size();i++)
            Screen.DrawText(font,Font.CR_WHITE,origin.X,origin.Y+i*lineHeight,Lines[Offset+i],
                DTA_SCALEX,scale.X,DTA_SCALEY,scale.Y,DTA_SHADOW,true);
    }
}
