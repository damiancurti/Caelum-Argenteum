// Fixture aislado: prepara inventario/estación, sin cambiar las reglas de interfaz.
class CA184Native : StaticEventHandler
{
    int Age,Failures;
    ui int UiFailures,Before,BeforeTime;
    ui double BeforeAngle,BeforePitch;
    ui Vector3 BeforePosition;
    void Check(bool ok,String label)
    {if(!ok)Failures++;Console.Printf("CA184 %s %s",ok?"PASS":"FAIL",label);}
    static void EndTalk(CaelumPlayer u)
    {if(u.player.ConversationNPC!=null)u.player.ConversationNPC.bInConversation=false;u.player.ConversationNPC=null;}
    static bool Station(CaelumPlayer u)
    {
        EndTalk(u);let it=ThinkerIterator.Create("CaelumCraftingStation");CaelumCraftingStation station;
        while((station=CaelumCraftingStation(it.Next()))!=null)
            if(station.CraftingRoomGroup==5 && station.GetCraftingStationType()==CaelumConstants.CRAFTING_STATION_WORKBENCH)
            {u.SetOrigin(station.Pos+(0,48,0),false);u.Vel=(0,0,0);station.CollectCraftingNetwork(u,u.BeginCraftingNetworkScan());u.OpenCraftingNetwork(station);return true;}
        return false;
    }
    override void WorldTick()
    {
        let u=CaelumPlayer(players[0].mo);if(u==null)return;Age++;
        let r=u.GetPersistentCharacterState(true);r.DemoNarrativeDelivered=2047;r.DemoNarrativePending=0;
        u.bInvulnerable=true;
        if(Age==40)
        {
            u.DebugAttributesAt100=true;u.ApplyCharacterProfile();u.GrantMagicBoxFromPalomo(false);CaelumTarotDeckRules.Grant(u);
            for(int i=0;i<CaelumConstants.CRAFTING_NETWORK_PLAYABLE_RECIPE_COUNT;i++)r.LearnCraftingRecipe(i);
            for(int i=0;i<CaelumConstants.MATERIAL_TYPE_COUNT;i++)
            {
                let material=u.CreateDetachedMaterialStack(i,1,20000);
                if(material!=null){material.AttachToOwner(u);material.InMagicBox=true;}
            }
            u.OnNativeInventoryChanged();Open(u,CVar.GetCVar("ca184_stage").GetInt());
            EventHandler.SendInterfaceEvent(0,"ca184_close_intro");
            Console.Printf("CA184 READY creation=%d",u.CharacterCreationComplete);
        }
    }
    void Open(CaelumPlayer u,int panel)
    {
        EndTalk(u);u.CloseCraftingStationSession();
        CaelumTimeSkipState.FinishSkip(u,"CA_SKIP_CANCELLED",true);
        let truco=CaelumTrucoMatch.Get(u);if(truco!=null)truco.Visible=false;
        let trucazo=CaelumTrucazoMatch.Get(u);if(trucazo!=null)trucazo.Visible=false;
        if(panel==0){Check(Station(u),"real workshop opens");u.CraftingSelectionRecipe=136;u.CraftingSelectionTier=1;u.RefreshCraftingPreview();CaelumCraftingBrowser.Get(u).Refresh(u);}
        else if(panel==1)CaelumTimeSkipState.OpenMenu(u);
        else
        {
            let it=ThinkerIterator.Create("CaelumArgento");let npc=CaelumArgento(it.Next());
            if(npc==null)return;u.player.ConversationNPC=npc;
            bool opened=panel==2?CaelumTrucoMatch.Open(u,npc):CaelumTrucazoMatch.Open(u,npc);
            Check(opened,panel==2?"Truco native match opens":"Trucazo native match opens");EndTalk(u);
        }
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayerAuthority.FromNetworkPlayer(e.Player);if(u==null)return;
        if(e.Name=="ca184_open")Open(u,e.Args[0]);
        if(e.Name=="ca184_recipe")
        {
            let browser=CaelumCraftingBrowser.Get(u);u.CraftingRecipeFilter=0;
            int recipe=0;
            if(e.Args[0]>0)for(int i=0;i<CaelumConstants.CRAFTING_NETWORK_PLAYABLE_RECIPE_COUNT;i++)
                if(CaelumCraftingRules.GetUnifiedRecipeKind(i)==(e.Args[0]==1?CaelumConstants.CRAFTING_RECIPE_KIND_PROCESSING:CaelumConstants.CRAFTING_RECIPE_KIND_COMPONENT)){recipe=i;break;}
            u.CraftingSelectionRecipe=recipe;u.CraftingSelectionTier=1;u.CraftingSelectionSize=1;u.RefreshCraftingPreview();browser.SetMode(u,0);
            Console.Printf("CA184 RECIPE %d kind=%d stock=%d/%d box=%d/%d ready=%d",recipe,u.CraftingSelectedRecipeKind,u.CraftingBasicOwned,u.CraftingBasicRequired,u.MagicBoxUsedSlots,u.MagicBoxMaximumSlots,u.CraftingDirectPlanAvailable);
        }
        if(e.Name=="ca184_complete")
        {
            Check(u.CraftingTaskActive,"clicked operation starts real native task");
            if(u.CraftingTaskActive){u.CraftingTaskRemainingSeconds=0;u.CompleteCraftingTask();}
        }
        if(e.Name=="ca184_damage")
        {
            for(Inventory item=u.Inv;item!=null;item=item.Inv)
            {
                let equipment=CaelumEquipmentItem(item);
                if(equipment!=null && equipment.EquipmentKind==CaelumConstants.EQUIPMENT_KIND_WEAPON && equipment.ItemType==CaelumConstants.WEAPON_TYPE_DAGGER)
                {equipment.Durability=Max(1,u.GetEquipmentTaskMaximumDurability(equipment)/2);CaelumCraftingBrowser.Get(u).SelectedWeaponId=equipment.ItemId;break;}
            }
            u.OnNativeInventoryChanged();CaelumCraftingBrowser.Get(u).SetMode(u,1);
        }
        if(e.Name=="ca184_expect")
        {
            if(e.Args[0]==0)Check(!u.CraftingTaskActive,"mouse cancellation stops native task");
            if(e.Args[0]==1)Check(u.CraftingTaskActive,"mouse confirmation starts native task");
            if(e.Args[0]==2)Check(CaelumTimeSkipState.IsOpen(u),"time skip opens independently and remains live");
            if(e.Args[0]==3)Check(!CaelumTimeSkipState.IsOpen(u),"time skip cancellation closes result");
        }
    }
    override void InterfaceProcess(ConsoleEvent e)
    {
        if(e.Name=="ca184_close_intro" && Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();
    }
    override void ConsoleProcess(ConsoleEvent e)
    {
        if(e.Name=="ca184_done"){Console.Printf("CA184 DONE failures=%d",Failures+UiFailures);return;}
        if(e.Name=="ca184_geometry"){Geometry();return;}
        if(e.Name=="ca184_lifecycle")
        {
            let u=CaelumPlayer(players[consoleplayer].mo);
            if(e.Args[0]==0){BeforeAngle=u.Angle;BeforePitch=u.Pitch;BeforePosition=u.Pos;}
            if(e.Args[0]==1)
            {
                CheckUI(Abs(u.Angle-BeforeAngle)<0.001 && Abs(u.Pitch-BeforePitch)<0.001,"held world turn input cannot rotate behind panel");
                CheckUI((u.Pos-BeforePosition).Length()<0.01 && !u.player.attackdown && !u.player.usedown,"held attack/use/movement do not act behind panel");
            }
            if(e.Args[0]==2)
            {
                let pointer=CaelumJournalInput.PointerFor(100);pointer.Add(999,0,0,10,10);pointer.Move((5,5));pointer.Press(1);
                CheckUI(pointer.Held,"reload test begins with armed pointer");
            }
            if(e.Args[0]==3)
            {
                CheckUI(CaelumJournalInput.SkipOpen(u),"save/load restores open time skip");
                CheckUI(!CaelumJournalInput.PointerFor(100).Held,"save/load discards held pointer");
                CheckUI(StaticEventHandler.Find("CaelumJournalInput").RequireMouse,"save/load restores native cursor request");
            }
            if(e.Args[0]==4)CheckUI(!StaticEventHandler.Find("CaelumJournalInput").RequireMouse,"closing all panels releases native cursor request");
            return;
        }
        if(e.Name=="ca184_craft"){CraftClick(e.Args[0]);return;}
        if(e.Name=="ca184_skip"){SkipClick(e.Args[0]);return;}
        if(e.Name=="ca184_cards"){Cards(e.Args[0],e.Args[1]);return;}
        if(e.Name!="ca184_report")return;
        let u=CaelumPlayer(players[consoleplayer].mo);if(u==null)return;
        let browser=u.CraftingBrowser;let skip=CaelumTimeSkipState(u.FindInventory("CaelumTimeSkipState"));
        Console.Printf("CA184 UI menu=%d time=%d angle=%.3f pitch=%.3f input=%d mouse=%d craft=%d task=%d recipe=%d mode=%d serial=%d skip=%d active=%d field=%d",menuactive,level.Time,u.Angle,u.Pitch,
            StaticEventHandler.Find("CaelumJournalInput").IsUiProcessor,StaticEventHandler.Find("CaelumJournalInput").RequireMouse,u.CraftingMenuOpen,u.CraftingTaskActive,u.CraftingSelectionRecipe,
            browser==null?-1:browser.Mode,browser==null?-1:browser.Serial,skip!=null && skip.Open,skip!=null && skip.Active,skip==null?-1:skip.Field);
    }
    ui void CheckUI(bool ok,String label)
    {if(!ok)UiFailures++;Console.Printf("CA184 %s %s",ok?"PASS":"FAIL",label);}
    ui Vector2 Center(CaelumMenuPointer pointer,int control)
    {
        for(int i=0;i<int(pointer.Ids.Size());i++)if(pointer.Ids[i]==control)
            return (pointer.Lefts[i]+pointer.Widths[i]/2,pointer.Tops[i]+pointer.Heights[i]/2);
        return (-100,-100);
    }
    ui void Geometry()
    {
        let pointer=new("CaelumMenuPointer");pointer.Add(1,10,20,30,40);pointer.Move((25,40));
        CheckUI(pointer.Release(1)==0,"orphan opening release ignored");
        pointer.Press(1);pointer.Press(1);CheckUI(pointer.Release(1)==1 && pointer.Release(1)==0,"one activation per press/release");
        pointer.Press(1);CheckUI(pointer.Release(2)==0,"stale revision rejects click");
        pointer.Press(1);pointer.Move((100,100));CheckUI(pointer.Release(1)==0,"dragging out cancels action");
        pointer.Clear();pointer.Add(2,10,20,30,40,false);pointer.Move((25,40));CheckUI(pointer.Hit()==0,"disabled controls excluded from hits");
        let u=CaelumPlayer(players[consoleplayer].mo);let view=CaelumJournalOverlay(EventHandler.Find("CaelumJournalOverlay"));
        CaelumCraftingUI.Layout(view,u,pointer,false);
        for(int i=0;i<int(pointer.Ids.Size());i++)
        {
            int id=pointer.Ids[i];Vector2 point=Center(pointer,id),origin,size;
            [origin,size]=Screen.VirtualToRealCoords(point,(1,1),(640,360),false,false);
            pointer.Move(CaelumMenuPointer.JournalPoint(origin.X,origin.Y));
            CheckUI(pointer.Hit()==id,String.Format("craft hit projection %d at %dx%d",id,Screen.GetWidth(),Screen.GetHeight()));
        }
        pointer=CaelumJournalInput.PointerFor(4);pointer.Move((0,0));pointer.Press(1);CaelumJournalInput.PointerFor(100);
        CheckUI(!pointer.Held && !pointer.Positioned,"switching panels discards held click and hover");
        CaelumJournalInput.PointerFor(4);
        CheckUI(menuactive==0,"crafting does not pause native world");
        BeforeTime=level.Time;
    }
    ui void CraftClick(int control)
    {
        let u=CaelumPlayer(players[consoleplayer].mo);let view=CaelumJournalOverlay(EventHandler.Find("CaelumJournalOverlay"));
        let pointer=CaelumJournalInput.PointerFor(4);CaelumCraftingUI.Layout(view,u,pointer,false);
        let point=Center(pointer,control);CheckUI(point.X>=0,String.Format("craft control %d enabled",control));
        CaelumCraftingUI.Mouse(view,u,UiEvent.Type_MouseMove,point);
        CaelumCraftingUI.Mouse(view,u,UiEvent.Type_LButtonDown,point);
        CaelumCraftingUI.Mouse(view,u,UiEvent.Type_LButtonUp,point);
        CaelumCraftingUI.Mouse(view,u,UiEvent.Type_LButtonUp,point);
        CheckUI(!pointer.Held,"craft click releases capture");
    }
    ui void SkipClick(int control)
    {
        let u=CaelumPlayer(players[consoleplayer].mo);let view=CaelumJournalOverlay(EventHandler.Find("CaelumJournalOverlay"));
        let skip=CaelumTimeSkipState(u.FindInventory("CaelumTimeSkipState"));
        let pointer=CaelumJournalInput.PointerFor(100);CaelumTimeSkipPanel.Layout(view,skip,pointer,false);
        let point=Center(pointer,control);CheckUI(point.X>=0,String.Format("time skip control %d enabled",control));
        CaelumTimeSkipPanel.PointerInput(view,u,UiEvent.Type_LButtonDown,point);
        CaelumTimeSkipPanel.PointerInput(view,u,UiEvent.Type_LButtonUp,point);
        CaelumTimeSkipPanel.PointerInput(view,u,UiEvent.Type_LButtonUp,point);
        CheckUI(menuactive==0 && level.Time>BeforeTime,"time skip input preserves live simulation");
    }
    ui void Cards(int test,int game)
    {
        let truco=CaelumTrucoMenu(Menu.GetCurrentMenu());let trucazo=CaelumTrucazoMenu(Menu.GetCurrentMenu());
        CheckUI(game==0?truco!=null:trucazo!=null,"expected native card menu owns input");
        if(truco==null && trucazo==null)return;
        let u=CaelumPlayer(players[consoleplayer].mo);
        let a=CaelumTrucoMatch(u.FindInventory("CaelumTrucoMatch"));let b=CaelumTrucazoMatch(u.FindInventory("CaelumTrucazoMatch"));
        if(truco!=null)truco.Choices();else trucazo.Choices();
        int target=-1;
        if(test==0)
        {
            BeforeTime=level.Time;
            if(truco!=null)truco.MouseEvent(Menu.MOUSE_Release,900,170);else trucazo.MouseEvent(Menu.MOUSE_Release,900,170);
            CheckUI(game==0?a.HandNumber==0:b.HandNumber==0,"card opening release cannot begin match");
            return;
        }
        if(test==1)target=game==0?CaelumTrucoRules.BEGIN:CaelumTrucazoRules.BEGIN;
        if(test==2)
        {
            CheckUI((game==0?a.HandNumber:b.HandNumber)>0,"card click begins match");
            CheckUI(level.Time==BeforeTime && menuactive==Menu.On,"card UI preserves native pause");
            target=game==0?CaelumTrucoRules.PLAY_CARD:CaelumTrucazoRules.PLAY_CARD;
        }
        if(test==3)target=-1;
        if(test==4)
        {
            CheckUI(game==0?truco.Details==1:trucazo.Details==1,"rules open with mouse");target=-1;
        }
        if(test==5)target=-3;
        if(test==6)
        {CheckUI(game==0?truco.ConfirmForfeit:trucazo.ConfirmForfeit,"forfeit requires confirmation");target=-4;}
        if(test==7)
        {CheckUI(game==0?!truco.ConfirmForfeit:!trucazo.ConfirmForfeit,"return cancels forfeit");return;}
        int row=-1;
        if(truco!=null){for(int i=0;i<int(truco.Operations.Size());i++)if(truco.Operations[i]==target)row=i;}
        else {for(int i=0;i<int(trucazo.Operations.Size());i++)if(trucazo.Operations[i]==target)row=i;}
        if(row<0 && test==2){CheckUI(true,"NPC call correctly hides play until response");return;}
        CheckUI(row>=0,String.Format("card operation %d present",target));if(row<0)return;
        int x=int(CaelumTrucoMenu.UILeft()+650*CaelumTrucoMenu.UIScale());
        int y=int(CaelumTrucoMenu.UITop()+(120+row*(game==0?24:27))*CaelumTrucoMenu.UIScale());
        if(truco!=null){truco.MouseEvent(Menu.MOUSE_Move,x,y);truco.MouseEvent(Menu.MOUSE_Click,x,y);truco.MouseEvent(Menu.MOUSE_Release,x,y);}
        else{trucazo.MouseEvent(Menu.MOUSE_Move,x,y);trucazo.MouseEvent(Menu.MOUSE_Click,x,y);trucazo.MouseEvent(Menu.MOUSE_Release,x,y);}
    }

}
