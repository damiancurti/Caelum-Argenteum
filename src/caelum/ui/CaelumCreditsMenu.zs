// Avisos originales en una vista de lectura; sólo conserva estado transitorio UI.
class CaelumCreditsMenu : ListMenu
{
    CaelumMenuPointer Pointer;
    Array<String> Lines;
    int Document, First, Revision, Selected;
    const ROWS=12;
    const LINE_WIDTH=552;

    override void Init(Menu parent,ListMenuDescriptor desc)
    {
        Super.Init(parent,desc); DontDim=true; DontBlur=true;
        Pointer=new("CaelumMenuPointer"); LoadDocument(0);
    }
    void LoadDocument(int index)
    {
        Document=Clamp(index,0,CaelumCreditsData.COUNT-1); First=0;
        Lines.Clear(); Pointer.Reset(); Revision++;
        int lump=Wads.CheckNumForFullName(CaelumCreditsData.Path(Document));
        String text=lump<0?StringTable.Localize("CA_CREDITS_UNAVAILABLE",false):Wads.ReadLump(lump);
        let broken=Font.GetFont("CaelumText").BreakLines(text,LINE_WIDTH);
        for(int i=0;i<broken.Count();i++)Lines.Push(broken.StringAt(i));
        broken.Destroy();
    }
    void Scroll(int amount)
    {First=Clamp(First+amount,0,Max(0,int(Lines.Size())-ROWS));Pointer.Reset();Revision++;}
    void Activate(int id)
    {
        if(id==1)LoadDocument(Document-1);
        else if(id==2)Scroll(-ROWS);
        else if(id==3)Scroll(ROWS);
        else if(id==4)LoadDocument(Document+1);
        else if(id==5)Close();
    }
    override bool MenuEvent(int key,bool fromcontroller)
    {
        if(key==MKEY_Back){Close();return true;}
        if(key==MKEY_Up)Scroll(-1);
        else if(key==MKEY_Down)Scroll(1);
        else if(key==MKEY_PageUp)Scroll(-ROWS);
        else if(key==MKEY_PageDown)Scroll(ROWS);
        else if(key==MKEY_Left){Selected=(Selected+4)%5;Pointer.Reset();}
        else if(key==MKEY_Right){Selected=(Selected+1)%5;Pointer.Reset();}
        else if(key==MKEY_Enter)Activate(Selected+1);
        return true;
    }
    override bool OnUIEvent(UIEvent e)
    {
        if(e.Type==UIEvent.Type_WheelUp || e.Type==UIEvent.Type_WheelDown)
        {Scroll(e.Type==UIEvent.Type_WheelUp?-1:1);return true;}
        return Super.OnUIEvent(e);
    }
    void Buttons(bool draw)
    {
        Pointer.Clear();
        for(int i=0;i<5;i++)
        {
            double x=36+i*114;
            bool enabled=i==0?Document>0:i==1?First>0:i==2?First+ROWS<Lines.Size():i==3?Document+1<CaelumCreditsData.COUNT:true;
            Pointer.Add(i+1,x,304,110,18,enabled);
            if(draw)
            {
                String key=i==0?"CA_CREDITS_PREVIOUS":i==1?"CA_CREDITS_UP":i==2?"CA_CREDITS_DOWN":i==3?"CA_CREDITS_NEXT":"CA_UI_BACK";
                int color=!enabled?Font.CR_DARKGRAY:Selected==i || Pointer.Hit()==i+1?Font.CR_GOLD:Font.CR_WHITE;
                CaelumMapNoteMenu.Literal(Font.GetFont("CaelumText"),color,x,304,StringTable.Localize(key,false));
            }
        }
    }
    override bool MouseEvent(int type,int x,int y)
    {
        Buttons(false);Pointer.Move(CaelumMenuPointer.JournalPoint(x,y));
        if(type==MOUSE_Click)Pointer.Press(Revision);
        else if(type==MOUSE_Release)Activate(Pointer.Release(Revision));
        return true;
    }
    override void Drawer()
    {
        CaelumNarrativeArtwork.DrawBackground();
        Screen.Dim(0x05070A,0.92,0,0,Screen.GetWidth(),Screen.GetHeight());
        CaelumPresentation.BeginMenu();
        let font=Font.GetFont("CaelumText");
        CaelumMapNoteMenu.Literal(Font.GetFont("CaelumDisplay"),Font.CR_GOLD,36,18,StringTable.Localize("CA_CREDITS_TITLE",false));
        CaelumMapNoteMenu.Literal(font,Font.CR_GRAY,36,47,String.Format("%d / %d",Document+1,CaelumCreditsData.COUNT));
        for(int i=0;i<ROWS && First+i<Lines.Size();i++)
            CaelumMapNoteMenu.Literal(font,Font.CR_WHITE,44,74+i*(font.GetHeight()+2),Lines[First+i]);
        Buttons(true);
        CaelumMapNoteMenu.Literal(font,Font.CR_GRAY,36,332,StringTable.Localize("CA_CREDITS_HELP",false));
        CaelumPresentation.End();
    }
}
