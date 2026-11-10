class CaelumMachineUI : Object ui
{
    static bool Key(int type,int scan,String keyString)
    {
        if(type!=InputEvent.Type_KeyDown || scan==InputEvent.Key_Grave)return false;
        int choice=-1;
        if(scan==InputEvent.Key_Tab || keyString~=="q")choice=0;
        else if(keyString=="1")choice=1;
        else if(keyString=="2")choice=2;
        else if(keyString=="3")choice=3;
        else if(keyString=="4")choice=4;
        else if(keyString=="5")choice=5;
        else if(keyString=="6")choice=6;
        else if(keyString=="7")choice=7;
        else if(scan==InputEvent.Key_LeftArrow)choice=8;
        else if(scan==InputEvent.Key_RightArrow)choice=9;
        if(choice>=0)EventHandler.SendNetworkEvent("ca_machine_action",choice);
        return true;
    }
    static void Draw(CaelumJournalOverlay view,CaelumPlayer user)
    {
        let session=CaelumMachineSession(user.FindInventory('CaelumMachineSession'));
        if(session==null || !session.Open)return;
        let machine=CaelumHostileMachine(session.Target);let barrier=CaelumBarricade(session.Target);
        int kind=session.Building?session.Recipe-CaelumMachineData.FIRST_RECIPE:barrier!=null?CaelumMachineData.BARRICADE:
            machine is 'CaelumBatteringRam'?(CaelumBatteringRam(machine).Large?CaelumMachineData.LARGE_RAM:CaelumMachineData.SMALL_RAM):CaelumMachineData.CANNON;
        CaelumPresentation.MenuBackground(0x05070A,0.94);view.DrawPanel(16,12,608,336);
        view.DrawCenteredText(view.TitleFont,Font.CR_GOLD,320,25,StringTable.Localize(CaelumMachineData.NameKey(kind),false));
        String faction=session.Faction<0?StringTable.Localize("CA_MACHINE_NO_FACTION",false):StringTable.Localize(CaelumFactionRules.GetNameKey(session.Faction),false);
        view.DrawTextLine(view.SmallFont,Font.CR_WHITE,36,58,String.Format(StringTable.Localize("CA_MACHINE_SELECTED_FACTION",false),faction));
        if(session.Building)
        {
            view.DrawParagraph(view.SmallFont,Font.CR_WHITE,36,86,560,StringTable.Localize("CA_MACHINE_BUILD_HELP",false));
            view.DrawTextLine(view.SmallFont,Font.CR_WHITE,36,129,String.Format(StringTable.Localize("CA_MACHINE_BUILD_COST",false),
                user.CraftingBasicRequired/1000.0,user.CraftingTierRequired/1000.0,user.CraftingPreviewSeconds/3600.0));
        }
        else
        {
            CaelumBreakableGate hull=machine!=null?CaelumBreakableGate(machine.Structure):CaelumBreakableGate(barrier);
            int owner=machine!=null?machine.OwnerFaction:barrier!=null?barrier.OwnerFaction:-1;
            String name=owner<0?StringTable.Localize("CA_MACHINE_ENEMY",false):StringTable.Localize(CaelumFactionRules.GetNameKey(owner),false);
            if(hull!=null)view.DrawTextLine(view.SmallFont,Font.CR_WHITE,36,88,String.Format(StringTable.Localize("CA_MACHINE_STATE",false),name,hull.health,hull.StructuralMaximum));
            if(machine!=null && machine.Sabotaged)view.DrawTextLine(view.SmallFont,Font.CR_GOLD,36,112,StringTable.Localize("CA_MACHINE_DISABLED",false));
            if(hull!=null && hull.StructuralMaximum>0)
            {
                double fraction=double(hull.StructuralMaximum-hull.health)/hull.StructuralMaximum
                    +(machine!=null && machine.Sabotaged?CaelumMachineData.SABOTAGE_REPAIR_FRACTION:0);
                view.DrawTextLine(view.SmallFont,Font.CR_WHITE,36,127,String.Format(StringTable.Localize("CA_MACHINE_BUILD_COST",false),
                    CaelumMachineData.Grams(kind,0,fraction)/1000.0,CaelumMachineData.Grams(kind,1,fraction)/1000.0,CaelumMachineData.Seconds(kind)*fraction/3600.0));
            }
            let work=CaelumMachineWork(user.FindInventory('CaelumMachineWork'));
            if(user.CraftingTaskActive && user.CraftingTaskKind==CaelumConstants.CRAFTING_TASK_MACHINE && work!=null)
                view.DrawTextLine(view.SmallFont,Font.CR_WHITE,36,151,String.Format(StringTable.Localize("CA_MACHINE_PROGRESS",false),
                    user.CraftingTaskRemainingSeconds,StringTable.Localize(work.WorkKind>=CaelumMachineWork.SABOTAGE?"CA_MACHINE_REAL_SECONDS":"CA_MACHINE_WORLD_SECONDS",false)));
        }
        let task=CaelumMachineWork(user.FindInventory('CaelumMachineWork'));
        String status=task!=null && task.Paused?task.Status:session.Status;
        if(status=="" && !session.Building)status="CA_MACHINE_HELP";
        if(status!="")view.DrawParagraph(view.SmallFont,Font.CR_GOLD,36,173,560,StringTable.Localize(status,false));
    }
}
