// La sesión sólo selecciona objetos poseídos; las transacciones vuelven a validarlos.
class CaelumMateSession : Inventory
{
    CaelumMateItem Mate;
    Array<CaelumWaterContainer> Sources;
    int Selection;
    bool Open,ConfirmDiscard;
    String Status;
    static clearscope CaelumMateSession Find(CaelumPlayer user)
    {return user==null?null:CaelumMateSession(user.FindInventory('CaelumMateSession'));}
    static clearscope CaelumMateItem Selected(CaelumPlayer user)
    {
        if(user==null || user.EquipmentSelectionKind!=CaelumConstants.EQUIPMENT_KIND_CONSUMABLE
            || !CaelumMateData.IsConsumable(user.EquipmentSelectionConsumableType))return null;
        return CaelumMateItem(user.FindInventory(CaelumMateData.ItemClass(user.EquipmentSelectionConsumableType-CaelumMateData.FIRST_CONSUMABLE)));
    }
    static clearscope bool Active(CaelumPlayer user)
    {
        let session=Find(user);
        return session!=null && session.Open && session.Mate!=null && session.Mate.Owner==user
            && !session.Mate.InMagicBox && session.Mate.Amount==1;
    }
    clearscope CaelumWaterContainer Source()
    {return Selection>=0 && Selection<Sources.Size()?Sources[Selection]:null;}
    void Refresh(CaelumPlayer user)
    {
        let previous=Source();Sources.Clear();
        // Sólo seis clases de recipientes existentes, al abrir o accionar el panel.
        for(int kind=5;kind<=10;kind++)
        {
            let water=CaelumWaterContainer(user.FindInventory(user.GetConsumableClassName(kind)));
            if(water==null || water.InMagicBox || water.Amount!=1 || water.WaterLiters<=0
                || !water.IsPotable() || CaelumWaterBoiling.Locked(water))continue;
            water.AdvanceTemperature(user,0);Sources.Push(water);
        }
        int index=Sources.Find(previous);Selection=index<Sources.Size()?index:Clamp(Selection,0,Max(0,Sources.Size()-1));
        if(Mate!=null)Mate.SyncTemperature(user);
    }
    static void OpenSelected(CaelumPlayer user)
    {
        let mate=Selected(user);if(mate==null || !mate.Accessible(user))return;
        let session=Find(user);if(session==null)session=CaelumMateSession(user.GiveInventoryType('CaelumMateSession'));
        if(session==null)return;
        session.Mate=mate;session.Open=true;session.Selection=0;session.ConfirmDiscard=false;session.Status="";session.Refresh(user);
    }
    static void Act(CaelumPlayer user,int command)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || !Active(user))return;
        let session=Find(user);if(!session.Mate.Accessible(user))return;
        if(command==0){session.Open=false;session.ConfirmDiscard=false;user.RefreshFormalInventorySnapshot();return;}
        let selectedSource=session.Source();
        session.Refresh(user);
        if(command==6 || command==7)
        {
            if(session.Sources.Size()>0)session.Selection=(session.Selection+session.Sources.Size()+(command==6?-1:1))%session.Sources.Size();
            session.ConfirmDiscard=false;return;
        }
        if(command==2 && !session.ConfirmDiscard)
        {session.ConfirmDiscard=true;session.Status="CA_MATE_CONFIRM_DISCARD";return;}
        bool ok=command==1?session.Mate.LoadYerba(user):command==2?session.Mate.DiscardYerba(user)
            :command==3?session.Mate.Pour(user,selectedSource):command==4?session.Mate.EmptyWater(user)
            :command==5?session.Mate.Drink(user):false;
        session.ConfirmDiscard=false;session.Status=ok?"CA_MATE_DONE":"CA_MATE_REJECTED";
        session.Refresh(user);
    }
    Default {Inventory.Amount 1;Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn: TNT1 A -1;Stop;}
}

class CaelumMateUI : Object ui
{
    static String L(String key){return StringTable.Localize(key,false);}
    static String Contents(CaelumMateItem mate)
    {
        return String.Format(L("CA_MATE_CONTENT"),mate.WaterLiters*1000,CaelumMateData.WaterCapacity(mate.Variant())*1000,
            mate.TemperatureC,mate.YerbaLoaded?CaelumMateData.YerbaGrams(mate.Variant()):0,mate.UsesRemaining,CaelumMateData.HOT_USES);
    }
    static void Draw(CaelumJournalOverlay view,CaelumPlayer user)
    {
        let session=CaelumMateSession.Find(user);if(session==null || session.Mate==null)return;
        let mate=session.Mate;CaelumPresentation.MenuBackground(0x05070A,0.92);
        view.DrawPanel(16,12,608,336);view.DrawCenteredText(view.TitleFont,Font.CR_GOLD,320,28,mate.GetTag());
        if(mate.Icon.IsValid())Screen.DrawTexture(mate.Icon,false,48,62,DTA_DESTWIDTH,96,DTA_DESTHEIGHT,96,
            DTA_VIRTUALWIDTH,640,DTA_VIRTUALHEIGHT,360,DTA_KEEPRATIO,true,DTA_LEFTOFFSET,0,DTA_TOPOFFSET,0);
        CaelumCraftingUI.Paragraph(view,Contents(mate),160,74,422,3,"ca_journal_craft_scroll");
        if(!mate.YerbaLoaded || mate.UsesRemaining==0)view.DrawTextLine(view.TextFont,Font.CR_GOLD,160,119,
            L(mate.YerbaLoaded?"CA_MATE_WASHED":"CA_MATE_NO_YERBA"));
        CaelumCraftingUI.Paragraph(view,String.Format(L("CA_MATE_NEEDS_YERBA"),CaelumMateData.YerbaGrams(mate.Variant())),48,160,544,2,"ca_journal_craft_scroll");
        let source=session.Source();String selected=L("CA_MATE_NO_SOURCE");
        if(source!=null && source.Owner==user)selected=String.Format(L("CA_MATE_SOURCE"),source.GetTag(),source.WaterLiters*1000,source.WaterTemperatureC);
        CaelumCraftingUI.Paragraph(view,selected,48,191,544,2,"ca_journal_craft_scroll");
        CaelumCraftingUI.Paragraph(view,L("CA_MATE_RULES"),48,218,544,2,"ca_journal_craft_scroll");
        if(session.Status!="")CaelumCraftingUI.Paragraph(view,L(session.Status),48,300,544,2,"ca_journal_craft_scroll");
    }
    static bool Key(CaelumLiveMenu host,int type,int scan,int character,String key)
    {
        if(type==InputEvent.Type_KeyUp && host.MateDiscardHeld && scan==host.MateDiscardScan)
        {host.MateDiscardHeld=false;return true;}
        if(type!=InputEvent.Type_KeyDown)return true;
        int command=-1;
        if(scan==InputEvent.Key_Tab || scan==InputEvent.Key_Pad_B || key~=="q")command=0;
        else if(key~=="r")command=1;
        else if(key~=="c")
        {if(host.MateDiscardHeld)return true;host.MateDiscardHeld=true;host.MateDiscardScan=scan;command=2;}
        else if(key~=="f")command=3;
        else if(key~=="v")command=4;
        else if(scan==InputEvent.Key_Enter || scan==InputEvent.Key_Pad_A)command=5;
        else if(scan==InputEvent.Key_LeftArrow)command=6;
        else if(scan==InputEvent.Key_RightArrow)command=7;
        if(command>=0)EventHandler.SendNetworkEvent("ca_mate_action",command);
        return true;
    }
}
