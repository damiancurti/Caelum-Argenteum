// Lista y borrador UI; sólo Guardar/Borrar envían una transacción autoritativa.
class CaelumMapNoteMenu : ListMenu
{
    CaelumPlayer Subject;
    CaelumMenuPointer Pointer;
    TextEnterMenu Entry;
    String OriginMap,Draft,Feedback;
    Vector3 Center;
    bool CanPlace,Pending;
    int Mode,Selected,First,SelectedAction,LayoutRevision,SeenSerial,Expected,EditingId,Category,TextOffset,PendingReply;
    Array<int> Rows;
    const PAGE_ROWS=6;

    CaelumPersistentCharacterState Record()
    {return Subject==null?null:CaelumPersistentCharacterState(Subject.FindInventory("CaelumPersistentCharacterState"));}
    bool ValidOwner()
    {return consoleplayer>=0 && Subject!=null && players[consoleplayer].mo==Subject
        && level.MapName==OriginMap && CaelumMapNotes.Available(Subject);}
    override void Init(Menu parent,ListMenuDescriptor desc)
    {
        Super.Init(parent,desc);DontDim=true;DontBlur=true;Pointer=new("CaelumMenuPointer");
        Subject=consoleplayer>=0?CaelumPlayer(players[consoleplayer].mo):null;
        OriginMap=level.MapName;SeenSerial=-1;
        CanPlace=gamestate==GS_LEVEL && automapactive && ValidOwner();
        if(CanPlace){Vector2 point=level.GetAutomapPosition();Center=(point.X,point.Y,Subject.Pos.Z);}
        Refresh();
        if(ValidOwner())menuactive=Menu.OnNoPause;
    }
    void Refresh()
    {
        let record=Record();if(record==null)return;
        if(Pending && record.ManualNoteReplySerial!=PendingReply && !record.ManualNoteReplySuccess)
        {Pending=false;Feedback="CA_NOTE_STALE";Pointer.Reset();LayoutRevision++;}
        if(record.ManualNotesSerial==SeenSerial)return;
        SeenSerial=record.ManualNotesSerial;Rows.Clear();
        for(int i=0;i<record.ManualNotes.Size();i++)
        {let note=record.ManualNotes[i];if(note!=null && note.MapId==OriginMap)Rows.Push(note.Id);}
        bool retained=false;for(int i=0;i<Rows.Size();i++)if(Rows[i]==Selected)retained=true;
        if(!retained)Selected=Rows.Size()>0?Rows[0]:0;
        First=Clamp(First,0,Max(0,int(Rows.Size())-PAGE_ROWS));
        if(Pending){Pending=false;Mode=0;Feedback="CA_NOTE_SAVED";SelectedAction=Rows.Size()>0?1:0;}
        Pointer.Reset();LayoutRevision++;
    }
    override void Ticker()
    {
        Refresh();
        if(Subject!=null && !ValidOwner()){Close();return;}
        if(ValidOwner())menuactive=Menu.OnNoPause;
    }
    CaelumMapNote Selection() {return CaelumMapNotes.Find(Record(),OriginMap,Selected);}
    void SelectRow(int direction)
    {
        if(Rows.Size()==0)return;
        int index=0;for(int i=0;i<Rows.Size();i++)if(Rows[i]==Selected)index=i;
        index=Clamp(index+direction,0,int(Rows.Size())-1);Selected=Rows[index];
        if(index<First)First=index;else if(index>=First+PAGE_ROWS)First=index-PAGE_ROWS+1;
        TextOffset=0;Pointer.Reset();LayoutRevision++;
    }
    void BeginEdit(bool create)
    {
        let record=Record();let note=Selection();
        if(record==null || !ValidOwner() || (create?!CanPlace:note==null))return;
        Mode=1;Expected=record.ManualNotesSerial;EditingId=create?0:note.Id;
        Draft=create?"":note.Text;Category=create?0:note.Category;Feedback="";
        SelectedAction=0;TextOffset=0;Pointer.Reset();LayoutRevision++;
    }
    void BeginText(bool controller)
    {
        if(Pending || Mode!=1 || !ValidOwner())return;
        Entry=TextEnterMenu.OpenTextEnter(self,Font.GetFont("CaelumText"),Draft,-1,controller,false);
        Entry.ActivateMenu();menuactive=Menu.OnNoPause;Pointer.Reset();
    }
    void CancelEdit()
    {Mode=0;Entry=null;Draft="";Feedback="";TextOffset=0;SelectedAction=Rows.Size()>0?1:0;Pointer.Reset();LayoutRevision++;}
    void Send(int operation)
    {
        if(Pending || !ValidOwner())return;
        let record=Record();if(record==null)return;
        if(record.ManualNotesSerial!=Expected){Feedback="CA_NOTE_STALE";return;}
        if(operation!=CaelumMapNoteData.REMOVE && Draft.Length()==0){Feedback="CA_NOTE_EMPTY_TEXT";return;}
        if(!CaelumMapNoteData.FitsRequest(OriginMap,Draft)){Feedback="CA_NOTE_TOO_LONG";return;}
        let buffer=new("NetworkBuffer");buffer.AddInt(operation);buffer.AddInt(Expected);
        buffer.AddInt(EditingId);buffer.AddInt(Category);buffer.AddString(OriginMap);
        buffer.AddVector3(Center);buffer.AddString(Draft);
        PendingReply=record.ManualNoteReplySerial;
        Pending=EventHandler.SendNetworkBuffer('ca_note_apply',buffer);
        buffer.Destroy();Feedback=Pending?"CA_NOTE_SAVING":"CA_NOTE_STALE";
        Pointer.Reset();LayoutRevision++;
    }
    void Activate(int id,bool controller=false)
    {
        if(Pending)return;
        if(Mode==0)
        {
            if(id==1)BeginEdit(true);
            else if(id==2)BeginEdit(false);
            else if(id==3 && Selection()!=null)
            {
                Mode=2;EditingId=Selected;Expected=Record().ManualNotesSerial;
                Draft=Selection().Text;Category=Selection().Category;SelectedAction=1;
                Pointer.Reset();LayoutRevision++;
            }
            else if(id==4)Close();
            else if(id>=1000 && id-1000<Rows.Size())
            {Selected=Rows[id-1000];TextOffset=0;SelectedAction=1;Pointer.Reset();LayoutRevision++;}
        }
        else if(Mode==1)
        {
            if(id==1)BeginText(controller);
            else if(id==2){Category=(Category+1)%(CaelumPoiData.TRANSPORT+1);Pointer.Reset();LayoutRevision++;}
            else if(id==3)Send(EditingId==0?CaelumMapNoteData.CREATE:CaelumMapNoteData.EDIT);
            else if(id==4)CancelEdit();
        }
        else if(Mode==2)
        {if(id==1)Send(CaelumMapNoteData.REMOVE);else if(id==2)CancelEdit();}
    }
    override bool MenuEvent(int key,bool fromcontroller)
    {
        if(key==MKEY_Input && Entry!=null){Draft=Entry.GetText();Entry=null;TextOffset=0;Pointer.Reset();return true;}
        if(key==MKEY_Abort){Entry=null;Pointer.Reset();return true;}
        if(key==MKEY_Back){if(!Pending){if(Mode==0)Close();else CancelEdit();}return true;}
        if(Pending)return true;
        if(key==MKEY_Left || key==MKEY_Right)
        {int count=Mode==2?2:4;SelectedAction=(SelectedAction+(key==MKEY_Left?count-1:1))%count;Pointer.Reset();}
        else if(key==MKEY_Up || key==MKEY_Down)
        {if(Mode==0)SelectRow(key==MKEY_Up?-1:1);else TextOffset=Max(0,TextOffset+(key==MKEY_Up?-1:1));}
        else if(key==MKEY_PageUp || key==MKEY_PageDown)
        {if(Mode==0)SelectRow(key==MKEY_PageUp?-PAGE_ROWS:PAGE_ROWS);else TextOffset=Max(0,TextOffset+(key==MKEY_PageUp?-PAGE_ROWS:PAGE_ROWS));}
        else if(key==MKEY_Enter)Activate(SelectedAction+1,fromcontroller);
        return true;
    }
    override bool OnUIEvent(UIEvent e)
    {
        if(e.Type==UIEvent.Type_WheelUp || e.Type==UIEvent.Type_WheelDown)
        {if(Mode==0)SelectRow(e.Type==UIEvent.Type_WheelUp?-1:1);else TextOffset=Max(0,TextOffset+(e.Type==UIEvent.Type_WheelUp?-1:1));return true;}
        return Super.OnUIEvent(e);
    }
    override bool MouseEvent(int type,int x,int y)
    {
        Refresh();Layout(false);Pointer.Move(CaelumMenuPointer.JournalPoint(x,y));
        if(type==MOUSE_Click)Pointer.Press(LayoutRevision);
        else if(type==MOUSE_Release)Activate(Pointer.Release(LayoutRevision));
        return true;
    }
    static String Local(String key) {return StringTable.Localize(key,false);}
    static String ShortText(Font font,String text,double width)
    {
        if(font.StringWidth(text)<=width)return text;
        // Acotar primero por la primera línea evita recortar carácter a
        // carácter toda una nota larga en cada fotograma de lista/automapa.
        let wrapped=font.BreakLines(text,Max(1,int(width)));
        text=wrapped.Count()>0?wrapped.StringAt(0):"";wrapped.Destroy();
        while(text.Length()>0 && font.StringWidth(text.."...")>width)text.DeleteLastCharacter();
        return text.."...";
    }
    static String CenterLabel(CaelumPlayer user,double width)
    {
        let record=user==null?null:CaelumPersistentCharacterState(user.FindInventory("CaelumPersistentCharacterState"));
        if(record==null)return "";
        Vector2 center=level.GetAutomapPosition();CaelumMapNote nearest;double best=0;
        for(int i=0;i<record.ManualNotes.Size();i++)
        {
            let note=record.ManualNotes[i];if(note==null || note.MapId!=level.MapName)continue;
            double distance=(note.Position.XY-center).LengthSquared();
            if(nearest==null || distance<best){nearest=note;best=distance;}
        }
        if(nearest==null)return "";
        String text=String.Format(Local("CA_NOTE_NEAREST"),
            Local(CaelumMapNoteData.CategoryKey(nearest.Category))..": "..nearest.Text);
        return ShortText(Font.GetFont("CaelumText"),text,width-8);
    }
    static void Literal(Font font,int color,double x,double y,String text)
    {
        // No interpretar el texto del jugador como plantillas de controles.
        Screen.DrawText(font,color,x,y,text,DTA_VIRTUALWIDTHF,640.0,
            DTA_VIRTUALHEIGHTF,360.0,DTA_KEEPRATIO,true,DTA_SHADOW,true);
    }
    void Paragraph(String text,double y,int lines,bool tail=false)
    {
        let font=Font.GetFont("CaelumText");let wrapped=font.BreakLines(text,552);
        int first=tail?Max(0,wrapped.Count()-lines):Clamp(TextOffset,0,Max(0,wrapped.Count()-lines));
        for(int i=0;i<lines && first+i<wrapped.Count();i++)
            Literal(font,Font.CR_WHITE,44,y+i*(font.GetHeight()+2),wrapped.StringAt(first+i));
        wrapped.Destroy();
    }
    void Layout(bool draw)
    {
        let view=CaelumLiveMenu.Journal();Pointer.Clear();
        if(view==null)
        {
            Pointer.Add(4,36,304,568,18);
            if(draw)Literal(Font.GetFont("CaelumText"),Font.CR_GOLD,44,304,Local("CA_UI_BACK"));
            return;
        }
        bool valid=ValidOwner() && !Pending;
        if(Mode==0)
        {
            for(int i=First;i<Rows.Size() && i<First+PAGE_ROWS;i++)
            {
                let note=CaelumMapNotes.Find(Record(),OriginMap,Rows[i]);if(note==null)continue;
                double y=74+(i-First)*22;
                Pointer.Button(view,1000+i,36,y,568,"",valid,Selected==note.Id,draw);
                if(draw)Literal(view.SmallFont,Selected==note.Id?Font.CR_GOLD:Font.CR_WHITE,44,y+3,
                    ShortText(view.SmallFont,Local(CaelumMapNoteData.CategoryKey(note.Category))..": "..note.Text,550));
            }
            Pointer.Button(view,1,36,304,136,Local("CA_NOTE_NEW"),valid && CanPlace,SelectedAction==0,draw);
            Pointer.Button(view,2,180,304,136,Local("CA_NOTE_EDIT"),valid && Selection()!=null,SelectedAction==1,draw);
            Pointer.Button(view,3,324,304,136,Local("CA_NOTE_DELETE"),valid && Selection()!=null,SelectedAction==2,draw);
            Pointer.Button(view,4,468,304,136,Local("CA_UI_BACK"),!Pending,SelectedAction==3,draw);
        }
        else if(Mode==1)
        {
            Pointer.Button(view,1,36,304,136,Local("CA_NOTE_TEXT"),valid,SelectedAction==0,draw);
            Pointer.Button(view,2,180,304,136,Local(CaelumMapNoteData.CategoryKey(Category)),valid,SelectedAction==1,draw);
            Pointer.Button(view,3,324,304,136,Local("CA_NOTE_SAVE"),valid,SelectedAction==2,draw);
            Pointer.Button(view,4,468,304,136,Local("CA_NOTE_CANCEL"),!Pending,SelectedAction==3,draw);
        }
        else
        {
            Pointer.Button(view,1,108,304,196,Local("CA_NOTE_DELETE"),valid,SelectedAction==0,draw);
            Pointer.Button(view,2,336,304,196,Local("CA_NOTE_CANCEL"),!Pending,SelectedAction==1,draw);
        }
    }
    override void Drawer()
    {
        Refresh();let view=CaelumLiveMenu.Journal();
        Screen.Dim(0x05070A,0.92,0,0,Screen.GetWidth(),Screen.GetHeight());
        CaelumPresentation.BeginMenu();
        if(view==null)
        {Paragraph(Local("CA_NOTE_UNAVAILABLE"),80,6);Layout(true);CaelumPresentation.End();return;}
        view.DrawPanel(16,12,608,336);
        view.DrawCenteredText(view.TitleFont,Font.CR_GOLD,320,18,Local("CA_NOTE_TITLE"));
        view.DrawCenteredText(view.SmallFont,Font.CR_GRAY,320,43,Local("CA_NOTE_MANUAL"));
        if(!ValidOwner())Paragraph(Local("CA_NOTE_UNAVAILABLE"),80,6);
        else if(Mode==0)
        {
            if(Rows.Size()==0)Paragraph(Local("CA_NOTE_NONE"),80,4);
            let note=Selection();if(note!=null)Paragraph(note.Text,218,3);
            view.DrawCenteredText(view.SmallFont,Font.CR_GRAY,320,65,
                Local(CanPlace?"CA_NOTE_CENTER_READY":"CA_NOTE_NEED_MAP"));
        }
        else
        {
            Paragraph(Local(Mode==2?"CA_NOTE_DELETE_CONFIRM":"CA_NOTE_EDIT_HELP"),64,2);
            String text=Entry==null?Draft:Entry.GetText()..Font.GetFont("CaelumText").GetCursor();
            Paragraph(text,100,Entry==null?8:5,Entry!=null);
        }
        if(Feedback.Length()>0)view.DrawCenteredText(view.SmallFont,Font.CR_GOLD,320,278,Local(Feedback));
        Layout(true);
        view.DrawCenteredText(view.SmallFont,Font.CR_GRAY,320,328,Local("CA_NOTE_NAVIGATION"));
        CaelumPresentation.End();
    }
}
