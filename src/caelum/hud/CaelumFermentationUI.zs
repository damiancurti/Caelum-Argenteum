// Proyección local; todos los botones vuelven a validar el actor y el lote en play.
class CaelumFermentationUI : Object
{
    static String L(String key){return StringTable.Localize(key,false);}
    static ui void Send(CaelumJournalOverlay view,CaelumPlayer user,int command,int amount=0)
    {
        let barrel=CaelumFermentationStation(user.ActiveCraftingStationActor);
        if(barrel!=null && barrel.Batch!=null)
            view.SendNetworkEvent("ca_fermentation_action",command,amount,barrel.Batch.Generation);
    }
    static ui void Layout(CaelumJournalOverlay view,CaelumPlayer user,CaelumMenuPointer pointer,bool draw)
    {
        let barrel=CaelumFermentationStation(user.ActiveCraftingStationActor);
        let batch=barrel.Batch;let menu=user.FermentationMenu;
        pointer.Clear();
        pointer.Button(view,11,376,237,106,CaelumInputHints.Context(L("CA_FERMENT_MIN"),InputEvent.Key_Home),true,false,draw);
        pointer.Button(view,12,486,237,106,CaelumInputHints.Context(L("CA_FERMENT_MAX"),InputEvent.Key_End),true,false,draw);
        pointer.Button(view,1,48,263,78,CaelumInputHints.Context("-1",InputEvent.Key_LeftArrow),true,false,draw);
        pointer.Button(view,2,130,263,78,CaelumInputHints.Context("+1",InputEvent.Key_RightArrow),true,false,draw);
        pointer.Button(view,3,212,263,78,CaelumInputHints.Context("-10",InputEvent.Key_DownArrow),true,false,draw);
        pointer.Button(view,4,294,263,78,CaelumInputHints.Context("+10",InputEvent.Key_UpArrow),true,false,draw);
        pointer.Button(view,5,376,263,96,CaelumInputHints.Context("-100",0,98),true,false,draw);
        pointer.Button(view,6,476,263,116,CaelumInputHints.Context("+100",0,118),true,false,draw);
        pointer.Button(view,7,48,318,160,CaelumInputHints.Context(L(batch.Occupied?"CA_FERMENT_COLLECT":"CA_FERMENT_BEGIN"),InputEvent.Key_Enter),
            !batch.Occupied || batch.Ready(menu.Now),false,draw);
        pointer.Button(view,8,212,318,144,CaelumInputHints.Context(L("CA_FERMENT_DISCARD"),0,99),batch.Occupied,false,draw);
        pointer.Button(view,9,360,318,116,CaelumInputHints.Bound(L("CA_UI_TIME_SKIP"),"ca_time_skip"),true,false,draw);
        pointer.Button(view,10,480,318,112,CaelumInputHints.BoundOrFallback(L("CA_UI_BACK"),"ca_journal_toggle",InputEvent.Key_Tab),true,false,draw);
    }
    static ui void Draw(CaelumJournalOverlay view,CaelumPlayer user)
    {
        let barrel=CaelumFermentationStation(user.ActiveCraftingStationActor);
        let batch=barrel.Batch;let menu=user.FermentationMenu;
        if(batch==null || menu==null)return;
        view.DrawTextLine(view.TextFont,Font.CR_GOLD,48,134,L("CA_CHEMISTRY_FERMENTATION"));
        String details;
        if(batch.Occupied)
        {
            view.DrawTextLine(view.SmallFont,batch.Ready(menu.Now)?Font.CR_GREEN:Font.CR_CYAN,48,160,
                String.Format(L("CA_FERMENT_PROGRESS"),batch.WorkingLiters,batch.RemainingUnits,batch.SecondsLeft(menu.Now)/3600));
            details=L(batch.Ready(menu.Now)?"CA_FERMENT_READY":"CA_FERMENT_WAITING")
                .."\n"..String.Format(L("CA_FERMENT_WITHDRAW_UNITS"),menu.Units);
        }
        else
        {
            int recipe=CaelumChemistryData.FIRST_RECIPE;
            view.DrawTextLine(view.SmallFont,Font.CR_CYAN,48,160,
                String.Format(L("CA_FERMENT_LOAD"),menu.Liters,CaelumFermentationData.WORKING_CAPACITY_LITERS));
            details=String.Format(L("CA_FERMENT_INPUTS"),CaelumChemistryData.InputUnits(recipe,0)*menu.Liters,
                CaelumChemistryData.InputUnits(recipe,1)*menu.Liters,CaelumChemistryData.WaterLiters(recipe)*menu.Liters)
                .."\n"..String.Format(L("CA_FERMENT_OUTPUT"),CaelumChemistryData.OutputUnits(recipe)*menu.Liters,CaelumChemistryData.Seconds(recipe)/3600)
                .."\n"..L("CA_FERMENT_REQUIREMENTS");
        }
        CaelumCraftingUI.Paragraph(view,details,48,181,544,5,"ca_journal_craft_scroll");
        String status=menu.ConfirmDiscard && menu.DiscardGeneration==batch.Generation
            ? "CA_FERMENT_CONFIRM_DISCARD" : menu.Status;
        if(status!="")CaelumCraftingUI.Paragraph(view,L(status),48,292,544,2,"ca_journal_craft_scroll");
        Layout(view,user,CaelumJournalInput.PointerFor(4),true);
    }
    static ui bool Key(CaelumJournalOverlay view,CaelumPlayer user,int scan,int character)
    {
        if(scan==InputEvent.Key_LeftArrow || scan==InputEvent.Key_Pad_DPad_Left)Send(view,user,0,-1);
        else if(scan==InputEvent.Key_RightArrow || scan==InputEvent.Key_Pad_DPad_Right)Send(view,user,0,1);
        else if(scan==InputEvent.Key_DownArrow || scan==InputEvent.Key_Pad_DPad_Down)Send(view,user,0,-10);
        else if(scan==InputEvent.Key_UpArrow || scan==InputEvent.Key_Pad_DPad_Up)Send(view,user,0,10);
        else if(character==98 || character==66)Send(view,user,0,-100);
        else if(character==118 || character==86)Send(view,user,0,100);
        else if(scan==InputEvent.Key_Home)Send(view,user,3,-1);
        else if(scan==InputEvent.Key_End)Send(view,user,3,1);
        else if(scan==InputEvent.Key_Enter || scan==InputEvent.Key_Pad_A || character==101 || character==69)Send(view,user,1);
        else if(character==99 || character==67)Send(view,user,2);
        else return false;
        return true;
    }
    static ui bool Mouse(CaelumJournalOverlay view,CaelumPlayer user,int type,Vector2 point)
    {
        let barrel=CaelumFermentationStation(user.ActiveCraftingStationActor);
        let pointer=CaelumJournalInput.PointerFor(4);
        pointer.Move(point);Layout(view,user,pointer,false);
        if(type==UiEvent.Type_LButtonDown)pointer.Press(barrel.Batch.Generation);
        else if(type==UiEvent.Type_LButtonUp)
        {
            int id=pointer.Release(barrel.Batch.Generation);
            if(id>=1 && id<=6)Send(view,user,0,id==1?-1:id==2?1:id==3?-10:id==4?10:id==5?-100:100);
            else if(id==7)Send(view,user,1);
            else if(id==8)Send(view,user,2);
            else if(id==9)view.SendNetworkEvent("ca_skip_open");
            else if(id==10)view.JournalKey(InputEvent.Type_KeyDown,InputEvent.Key_Tab,0,"",user);
            else if(id==11 || id==12)Send(view,user,3,id==11?-1:1);
        }
        return true;
    }
}
