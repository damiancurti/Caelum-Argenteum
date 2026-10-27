// La interfaz sólo propone una acción sobre la generación observada.
class CaelumProofingUI : Object
{
    static clearscope bool Active(CaelumPlayer user)
    {return user!=null && user.CraftingMenuOpen && user.ActiveCraftingStationActor is 'CaelumKitchenCounterStation';}
    static String L(String key){return StringTable.Localize(key,false);}
    static ui void Send(CaelumJournalOverlay view,CaelumPlayer user)
    {
        let counter=CaelumKitchenCounterStation(user.ActiveCraftingStationActor);
        if(counter!=null && counter.Batch!=null)view.SendNetworkEvent("ca_kitchen_proof",counter.Batch.Generation);
    }
    static ui void Layout(CaelumJournalOverlay view,CaelumPlayer user,CaelumMenuPointer pointer,bool draw)
    {
        let counter=CaelumKitchenCounterStation(user.ActiveCraftingStationActor);let batch=counter.Batch;
        pointer.Clear();
        pointer.Button(view,1,48,318,220,CaelumInputHints.Context(L(batch.Occupied?"CA_PROOF_COLLECT":"CA_PROOF_BEGIN"),InputEvent.Key_Enter),
            !user.CraftingTaskActive && (!batch.Occupied || batch.Ready(counter.MenuNow)),false,draw);
        pointer.Button(view,2,276,318,156,CaelumInputHints.Bound(L("CA_UI_TIME_SKIP"),"ca_time_skip"),true,false,draw);
        pointer.Button(view,3,440,318,152,CaelumInputHints.BoundOrFallback(L("CA_UI_BACK"),"ca_journal_toggle",InputEvent.Key_Tab),true,false,draw);
    }
    static ui void Draw(CaelumJournalOverlay view,CaelumPlayer user)
    {
        let counter=CaelumKitchenCounterStation(user.ActiveCraftingStationActor);let batch=counter.Batch;
        if(batch==null)return;
        view.DrawTextLine(view.TextFont,Font.CR_GOLD,48,134,L("CA_PROOF_TITLE"));
        String details=L("CA_PROOF_INPUTS");
        if(batch.Occupied)details=String.Format(L("CA_PROOF_PROGRESS"),batch.SecondsLeft(counter.MenuNow)/60,
            batch.Lots!=null?batch.Lots.OldestContamination():0);
        CaelumCraftingUI.Paragraph(view,details,48,176,544,8,"ca_journal_craft_scroll");
        if(user.LastCraftingAction!=CaelumConstants.CRAFTING_ACTION_NONE)
            CaelumCraftingUI.Paragraph(view,L(view.GetCraftingActionKey(user.LastCraftingAction)),48,290,544,2,"ca_journal_craft_scroll");
        Layout(view,user,CaelumJournalInput.PointerFor(4),true);
    }
    static ui bool Key(CaelumJournalOverlay view,CaelumPlayer user,int scan,int character)
    {
        if(scan!=InputEvent.Key_Enter && scan!=InputEvent.Key_Pad_A && character!=101 && character!=69)return false;
        Send(view,user);return true;
    }
    static ui bool Mouse(CaelumJournalOverlay view,CaelumPlayer user,int type,Vector2 point)
    {
        let counter=CaelumKitchenCounterStation(user.ActiveCraftingStationActor);
        if(counter.Batch==null)return true;
        let pointer=CaelumJournalInput.PointerFor(4);pointer.Move(point);Layout(view,user,pointer,false);
        if(type==UiEvent.Type_LButtonDown)pointer.Press(counter.Batch.Generation);
        else if(type==UiEvent.Type_LButtonUp)
        {
            int id=pointer.Release(counter.Batch.Generation);
            if(id==1)Send(view,user);
            else if(id==2)view.SendNetworkEvent("ca_skip_open");
            else if(id==3)view.JournalKey(InputEvent.Type_KeyDown,InputEvent.Key_Tab,0,"",user);
        }
        return true;
    }
}
