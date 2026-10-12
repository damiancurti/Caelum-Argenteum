// Estado transitorio de puntero; las acciones siguen perteneciendo a cada menú.
class CaelumMenuPointer : Object ui
{
    Vector2 Position;
    bool Positioned, Held;
    int Armed, ArmedRevision;
    Array<int> Ids;
    Array<double> Lefts, Tops, Widths, Heights;

    void Reset()
    {
        Positioned=false; Held=false; Armed=0;
        Clear();
    }
    void Clear() { Ids.Clear(); Lefts.Clear(); Tops.Clear(); Widths.Clear(); Heights.Clear(); }
    void Move(Vector2 point) { Position=point; Positioned=true; }
    void Add(int id,double x,double y,double width,double height,bool enabled=true)
    {
        if(!enabled)return;
        Ids.Push(id); Lefts.Push(x); Tops.Push(y); Widths.Push(width); Heights.Push(height);
    }
    static bool Inside(Vector2 point,Vector2 origin,Vector2 size)
    { return point.X>=origin.X && point.Y>=origin.Y && point.X<origin.X+size.X && point.Y<origin.Y+size.Y; }
    int Hit()
    {
        if(Positioned)for(int i=int(Ids.Size())-1;i>=0;i--)
            if(Inside(Position,(Lefts[i],Tops[i]),(Widths[i],Heights[i])))return Ids[i];
        return 0;
    }
    void Press(int revision)
    {
        if(Held)return;
        Held=true; Armed=Hit(); ArmedRevision=revision;
    }
    int Release(int revision)
    {
        int result=Held && Armed!=0 && Armed==Hit() && ArmedRevision==revision?Armed:0;
        Held=false; Armed=0;
        return result;
    }
    static Vector2 JournalPoint(double x,double y)
    {
        Vector2 origin,size;
        [origin,size]=Screen.VirtualToRealCoords((0,0),(640,360),(640,360),false,false);
        return ((x-origin.X)*640/size.X,(y-origin.Y)*360/size.Y);
    }
    static int KeyScan(int key)
    {
        switch(key)
        {
            case UiEvent.Key_PgDn:return InputEvent.Key_PgDn;
            case UiEvent.Key_PgUp:return InputEvent.Key_PgUp;
            case UiEvent.Key_Left:return InputEvent.Key_LeftArrow;
            case UiEvent.Key_Right:return InputEvent.Key_RightArrow;
            case UiEvent.Key_Up:return InputEvent.Key_UpArrow;
            case UiEvent.Key_Down:return InputEvent.Key_DownArrow;
            case UiEvent.Key_Return:return InputEvent.Key_Enter;
            case UiEvent.Key_Home:return InputEvent.Key_Home;
            case UiEvent.Key_End:return InputEvent.Key_End;
            case UiEvent.Key_Del:return InputEvent.Key_Del;
            case UiEvent.Key_F1:return InputEvent.Key_F1;
            case UiEvent.Key_F2:return InputEvent.Key_F2;
            case UiEvent.Key_F3:return InputEvent.Key_F3;
            case UiEvent.Key_F4:return InputEvent.Key_F4;
            case UiEvent.Key_F5:return InputEvent.Key_F5;
            case UiEvent.Key_F6:return InputEvent.Key_F6;
            case UiEvent.Key_F7:return InputEvent.Key_F7;
            case UiEvent.Key_F8:return InputEvent.Key_F8;
            case UiEvent.Key_F9:return InputEvent.Key_F9;
            case UiEvent.Key_F10:return InputEvent.Key_F10;
            case UiEvent.Key_F11:return InputEvent.Key_F11;
            case UiEvent.Key_F12:return InputEvent.Key_F12;

            case 8:return InputEvent.Key_Backspace;
            case UiEvent.Key_Tab:return InputEvent.Key_Tab;
            case UiEvent.Key_Escape:return InputEvent.Key_Escape;
            case 96:case 126:return InputEvent.Key_Grave;
            case 32:return InputEvent.Key_Space;
        }
        if(key>=32 && key<127)
        {
            String name=String.Format("%c",key);
            for(int scan=1;scan<256;scan++)if(KeyBindings.NameKeys(scan,0)~==name)return scan;
        }
        return 0;
    }
    void Button(CaelumJournalOverlay view,int id,double x,double y,double width,String label,bool enabled=true,bool selected=false,bool draw=true)
    {
        Add(id,x,y,width,18,enabled);
        if(!draw)return;
        bool hover=enabled && Positioned && Inside(Position,(x,y),(width,18));
        Vector2 origin,size;
        [origin,size]=Screen.VirtualToRealCoords((x,y),(width,18),(640,360),false,false);
        Screen.Dim(hover?0x806632:0x101923,hover?0.85:0.75,int(origin.X),int(origin.Y),int(size.X),int(size.Y));
        view.DrawCenteredText(view.SmallFont,!enabled?Font.CR_DARKGRAY:hover || selected?Font.CR_GOLD:Font.CR_WHITE,
            x+width/2,y+3,CaelumCraftingUI.Fit(view.SmallFont,label,int(width)-8));
    }
}
