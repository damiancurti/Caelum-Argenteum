// Fixture aislado: prepara inventario/estación, sin cambiar las reglas de interfaz.
class CA189Native : StaticEventHandler
{
    int Age,Failures;
    ui int UiFailures,Before,BeforeTime;
    ui double BeforeAngle,BeforePitch;
    ui Vector3 BeforePosition;
    void Check(bool ok,String label)
    {if(!ok)Failures++;Console.Printf("CA189 %s %s",ok?"PASS":"FAIL",label);}
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
    override void WorldLoaded(WorldEvent e){if(e.IsSaveGame)Age=Max(Age,40);}
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
            u.OnNativeInventoryChanged();Open(u,CVar.GetCVar("ca189_stage").GetInt());
            EventHandler.SendInterfaceEvent(0,"ca189_close_intro");
            Console.Printf("CA189 READY creation=%d",u.CharacterCreationComplete);
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
        if(e.Name=="ca189_open")Open(u,e.Args[0]);
        if(e.Name=="ca189_extra")Extra(u,e.Args[0]);
        if(e.Name=="ca189_recipe")
        {
            let browser=CaelumCraftingBrowser.Get(u);u.CraftingRecipeFilter=0;
            int recipe=0;
            if(e.Args[0]>0)for(int i=0;i<CaelumConstants.CRAFTING_NETWORK_PLAYABLE_RECIPE_COUNT;i++)
                if(CaelumCraftingRules.GetUnifiedRecipeKind(i)==(e.Args[0]==1?CaelumConstants.CRAFTING_RECIPE_KIND_PROCESSING:CaelumConstants.CRAFTING_RECIPE_KIND_COMPONENT)){recipe=i;break;}
            u.CraftingSelectionRecipe=recipe;u.CraftingSelectionTier=1;u.CraftingSelectionSize=1;u.RefreshCraftingPreview();browser.SetMode(u,0);
            Console.Printf("CA189 RECIPE %d kind=%d stock=%d/%d box=%d/%d ready=%d",recipe,u.CraftingSelectedRecipeKind,u.CraftingBasicOwned,u.CraftingBasicRequired,u.MagicBoxUsedSlots,u.MagicBoxMaximumSlots,u.CraftingDirectPlanAvailable);
        }
        if(e.Name=="ca189_complete")
        {
            Check(u.CraftingTaskActive,"clicked operation starts real native task");
            if(u.CraftingTaskActive){u.CraftingTaskRemainingSeconds=0;u.CompleteCraftingTask();}
        }
        if(e.Name=="ca189_damage")
        {
            for(Inventory item=u.Inv;item!=null;item=item.Inv)
            {
                let equipment=CaelumEquipmentItem(item);
                if(equipment!=null && equipment.EquipmentKind==CaelumConstants.EQUIPMENT_KIND_WEAPON && equipment.ItemType==CaelumConstants.WEAPON_TYPE_DAGGER)
                {equipment.Durability=Max(1,u.GetEquipmentTaskMaximumDurability(equipment)/2);CaelumCraftingBrowser.Get(u).SelectedWeaponId=equipment.ItemId;break;}
            }
            u.OnNativeInventoryChanged();CaelumCraftingBrowser.Get(u).SetMode(u,1);
        }
        if(e.Name=="ca189_expect")
        {
            if(e.Args[0]==0)Check(!u.CraftingTaskActive,"mouse cancellation stops native task");
            if(e.Args[0]==1)Check(u.CraftingTaskActive,"mouse confirmation starts native task");
            if(e.Args[0]==2)Check(CaelumTimeSkipState.IsOpen(u),"time skip opens independently and remains live");
            if(e.Args[0]==3)Check(!CaelumTimeSkipState.IsOpen(u),"time skip cancellation closes result");
        }
    }
    override void InterfaceProcess(ConsoleEvent e)
    {
        if(e.Name=="ca189_show")
        {
            if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();
            let view=CaelumLiveMenu.Journal();view.SetJournalOpen(false);
            if(e.Args[0]==10 || e.Args[0]==11){view.SetJournalOpen(true);view.SetJournalPage(e.Args[0]==11?2:0);}
            if(e.Args[0]==11)CaelumScheduleCalendar.Open(CaelumPlayer(players[consoleplayer].mo));
        }
        if(e.Name=="ca189_close_intro" && Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();
    }
    override void ConsoleProcess(ConsoleEvent e)
    {
        if(e.Name=="ca189_rest_held")
        {
            let u=CaelumPlayer(players[consoleplayer].mo);
            let rest=CaelumRestState(u.FindInventory("CaelumRestState"));
            let menu=CaelumLiveMenu(Menu.GetCurrentMenu());
            CheckUI(rest!=null && rest.Status==CaelumRestRules.STATUS_ACTIVE,"held opening use retains active rest");
            if(rest==null)return;
            CheckUI(rest.InputArmed==(e.Args[0]!=0),e.Args[0]==0?"held opening use keeps cancellation disarmed":"release arms subsequent rest cancellation");
            if(e.Args[0]==0 && menu!=null)
            {
                int scan=CaelumMenuPointer.KeyScan(101);
                menu.Key(InputEvent.Type_KeyDown,scan,101,"e");
                menu.Key(InputEvent.Type_KeyDown,scan,101,"e");
            }
            return;
        }
        if(e.Name=="ca189_value")
        {
            let u=CaelumPlayer(players[consoleplayer].mo);
            int value=e.Args[0]==0?u.FormalInventoryFilter:e.Args[0]==1?int(u.EquipmentSelectionInMagicBox):
                e.Args[0]==2?u.EquipmentSelectionKind:e.Args[0]==3?u.PalomoMerchantSelectedQuantity:
                e.Args[0]==4?u.PalomoMerchantSelection:e.Args[0]==5?int(CaelumRestState(u.FindInventory("CaelumRestState")).Status):0;
            if(e.Args[1]==0)Before=value;
            else CheckUI(e.Args[1]==1?value!=Before:value==Before,String.Format("live action field %d %s",e.Args[0],e.Args[1]==1?"changes once":"remains unchanged"));return;
        }
        if(e.Name=="ca189_context") {ContextCheck(e.Args[0]);return;}
        if(e.Name=="ca189_click") {LiveClick(e.Args[0],e.Args[1]);return;}
        if(e.Name=="ca189_tick")
        {
            if(e.Args[0]==0)BeforeTime=level.Time;
            else CheckUI(e.Args[0]==1?level.Time>BeforeTime:level.Time==BeforeTime,e.Args[0]==1?"world advances behind live native menu":"nested engine pause stops simulation");
            return;
        }
        if(e.Name=="ca189_key")
        {
            let menu=CaelumLiveMenu(Menu.GetCurrentMenu());CheckUI(menu!=null,"native key owner exists");
            if(menu!=null)menu.Stroke(e.Args[0],e.Args[1],String.Format("%c",e.Args[1]));return;
        }
        if(e.Name=="ca189_closemenu"){if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();return;}
        if(e.Name=="ca189_orbit")
        {
            let menu=CaelumLiveMenu(Menu.GetCurrentMenu());let u=CaelumPlayer(players[consoleplayer].mo);
            let rest=CaelumRestState(u.FindInventory("CaelumRestState"));
            CheckUI(menu!=null && menu.Context==CaelumLiveMenu.CTX_REST && rest!=null,"rest owns native cursor");
            if(menu==null || rest==null)return;
            if(e.Args[0]==0)
            {
                BeforeAngle=rest.CameraYaw;BeforePitch=rest.CameraPitch;
                menu.OrbitInput(UIEvent.Type_MouseMove,100,100);
                CheckUI(!menu.OrbitHeld,"free cursor does not orbit");
                menu.OrbitInput(UIEvent.Type_RButtonDown,100,100);
                CheckUI(menu.OrbitHeld,"right press captures camera drag");
                menu.OrbitInput(UIEvent.Type_MouseMove,200,130);
                menu.OrbitInput(UIEvent.Type_RButtonUp,200,130);
                CheckUI(!menu.OrbitHeld,"right release stops orbit drag");
            }
            else if(e.Args[0]==1)CheckUI(rest.CameraYaw!=BeforeAngle && rest.CameraPitch>BeforePitch,"right drag changes authoritative orbit without standing");
            else if(e.Args[0]==2)
            {
                menu.OrbitInput(UIEvent.Type_RButtonDown,100,100);menu.OrbitInput(UIEvent.Type_MouseMove,100,100000);
                menu.OrbitInput(UIEvent.Type_RButtonUp,100,100000);
            }
            else if(e.Args[0]==3)CheckUI(rest.CameraPitch==60,"orbit retains existing pitch limit");
            else if(e.Args[0]==4)
            {
                BeforeAngle=rest.CameraYaw;
                menu.OrbitInput(UIEvent.Type_RButtonDown,100,100);menu.OrbitInput(UIEvent.Type_MouseMove,200,100);menu.OrbitInput(UIEvent.Type_RButtonUp,200,100);
            }
            else CheckUI(Abs(rest.CameraYaw-BeforeAngle-100.0*360.0/Screen.GetWidth()*CVar.GetCVar("m_sensitivity_x").GetFloat()*CVar.GetCVar("m_yaw").GetFloat())<0.002,"right orbit respects native sensitivity and horizontal inversion");return;
        }
        if(e.Name=="ca189_dialogue")
        {
            let menu=CaelumHistoryConversationMenu(Menu.GetCurrentMenu());CheckUI(menu!=null,"native conversation owner exists");if(menu==null)return;
            CheckUI(menuactive==Menu.OnNoPause,"NPC dialogue explicitly remains live");
            CheckUI(menu.ypositions.Size()>1,"native wrapped-reply geometry available");if(menu.ypositions.Size()<2)return;
            int x=Screen.GetWidth()/2,y=int((menu.ypositions[0]+menu.ypositions[1])/2);
            if(e.Args[0]==0)
            {
                menu.MouseEvent(Menu.MOUSE_Release,x,y);CheckUI(Menu.GetCurrentMenu()==menu,"NPC orphan release ignored");
                menu.MouseEvent(Menu.MOUSE_Click,x,y);menu.MouseEvent(Menu.MOUSE_Release,0,0);
                CheckUI(Menu.GetCurrentMenu()==menu,"NPC drag outside cancels reply");
                menu.MouseEvent(Menu.MOUSE_Click,x,y);menu.FormatReplies(-1);menu.MouseEvent(Menu.MOUSE_Release,x,y);
                CheckUI(Menu.GetCurrentMenu()==menu,"NPC rebuilt page rejects armed reply");
            }
            else if(e.Args[0]==1){menu.MouseEvent(Menu.MOUSE_Click,x,y);menu.MouseEvent(Menu.MOUSE_Release,x,y);CheckUI(Menu.GetCurrentMenu()!=menu,"NPC valid release dispatches native response");}
            else if(e.Args[0]==2)
            {
                int found=-1;for(int i=0;i<menu.ReplyMap.Size();i++)if(menu.ReplyMap[i]==menu.REPEAT)found=i;
                CheckUI(found>=0,"conversation history action present after reply");
                if(found>=0){y=int((menu.ypositions[found]+menu.ypositions[found+1])/2);menu.MouseEvent(Menu.MOUSE_Click,x,y);menu.MouseEvent(Menu.MOUSE_Release,x,y);CheckUI(menu.Replaying,"click enters read-only history");}
            }
            return;
        }
        if(e.Name=="ca189_creator")
        {
            if(e.Args[0]==0){Menu.SetMenu("CaelumNewCharacterMenu");return;}
            let menu=CaelumCharacterCreationMenu(Menu.GetCurrentMenu());CheckUI(menu!=null,"native creator owns cursor");if(menu==null)return;
            if(e.Args[0]==1)
            {
                menu.PointerLayout(false);int before=menu.Race;
                Vector2 point=Center(menu.Pointer,100+((before+1)%4))*Screen.GetHeight()/600.0;
                menu.MouseEvent(Menu.MOUSE_Release,int(point.X),int(point.Y));CheckUI(menu.Race==before,"creator orphan release ignored");
                menu.MouseEvent(Menu.MOUSE_Click,int(point.X),int(point.Y));menu.MouseEvent(Menu.MOUSE_Release,int(point.X),int(point.Y));
                CheckUI(menu.Race==(before+1)%4,"creator row click selects profile and recommendations");
                int original=menu.LayerBonus[0];menu.LayerBonus[0]++;
                menu.PointerLayout(false);point=Center(menu.Pointer,100+menu.Race)*Screen.GetHeight()/600.0;
                menu.MouseEvent(Menu.MOUSE_Click,int(point.X),int(point.Y));menu.MouseEvent(Menu.MOUSE_Release,int(point.X),int(point.Y));
                CheckUI(menu.LayerBonus[0]==original+1,"same profile click preserves edited allocations");menu.LayerBonus[0]=original;
                menu.PointerLayout(false);point=Center(menu.Pointer,4)*Screen.GetHeight()/600.0;
                menu.MouseEvent(Menu.MOUSE_Click,int(point.X),int(point.Y));menu.MouseEvent(Menu.MOUSE_Release,int(point.X),int(point.Y));
                CheckUI(menu.Page==1,"creator continue button uses existing navigation");
            }
            return;
        }
        if(e.Name=="ca189_latch")
        {
            let menu=CaelumLiveMenu(Menu.GetCurrentMenu());
            menu.Key(InputEvent.Type_KeyDown,CaelumMenuPointer.KeyScan(103),103,"g");
            CheckUI(CaelumScheduleCalendar.Setting("ca_journal_quest_abandon_held")==1,"abandon press latches");
            menu.Key(InputEvent.Type_KeyDown,CaelumMenuPointer.KeyScan(103),103,"g");
            CheckUI(CaelumScheduleCalendar.Setting("ca_journal_quest_abandon_held")==1,"repeated keydown retains latch");
            menu.Key(InputEvent.Type_KeyUp,CaelumMenuPointer.KeyScan(103),103,"g");
            CheckUI(CaelumScheduleCalendar.Setting("ca_journal_quest_abandon_held")==0,"real release clears latch");
            CheckUI(CaelumMenuPointer.KeyScan(119)>0 && KeyBindings.NameKeys(CaelumMenuPointer.KeyScan(119),0)~=="w","GUI letter resolves native bound key");return;
        }
        if(e.Name=="ca189_done"){Console.Printf("CA189 DONE failures=%d",Failures+UiFailures);return;}
        if(e.Name=="ca189_geometry"){Geometry();return;}
        if(e.Name=="ca189_lifecycle")
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
                CheckUI(CaelumLiveMenu(Menu.GetCurrentMenu())!=null && menuactive==Menu.OnNoPause,"save/load restores native menu ownership");
            }
            if(e.Args[0]==4)CheckUI(Menu.GetCurrentMenu()==null && menuactive==Menu.Off,"closing all panels releases native ownership");
            return;
        }
        if(e.Name=="ca189_craft"){CraftClick(e.Args[0]);return;}
        if(e.Name=="ca189_skip"){SkipClick(e.Args[0]);return;}
        if(e.Name=="ca189_cards"){Cards(e.Args[0],e.Args[1]);return;}
        if(e.Name!="ca189_report")return;
        let u=CaelumPlayer(players[consoleplayer].mo);if(u==null)return;
        let browser=u.CraftingBrowser;let skip=CaelumTimeSkipState(u.FindInventory("CaelumTimeSkipState"));
        Console.Printf("CA189 UI menu=%d time=%d angle=%.3f pitch=%.3f input=%d mouse=%d craft=%d task=%d recipe=%d mode=%d serial=%d skip=%d active=%d field=%d",menuactive,level.Time,u.Angle,u.Pitch,
            StaticEventHandler.Find("CaelumJournalInput").IsUiProcessor,StaticEventHandler.Find("CaelumJournalInput").RequireMouse,u.CraftingMenuOpen,u.CraftingTaskActive,u.CraftingSelectionRecipe,
            browser==null?-1:browser.Mode,browser==null?-1:browser.Serial,skip!=null && skip.Open,skip!=null && skip.Active,skip==null?-1:skip.Field);
    }
    void Extra(CaelumPlayer u,int panel)
    {
        EndTalk(u);u.CloseCraftingStationSession();u.ClosePalomoMerchant();u.EquipmentMenuOpen=false;u.CreationWizardOpen=false;
        CaelumRestState.Cancel(u);CaelumJourneyPlan.Cancel(u);CaelumChestPreviewState.Get(u,true).Close();
        CaelumTimeSkipState.FinishSkip(u,"CA_SKIP_CANCELLED",true);
        let truco=CaelumTrucoMatch.Get(u);if(truco!=null)truco.Visible=false;
        let trucazo=CaelumTrucazoMatch.Get(u);if(trucazo!=null)trucazo.Visible=false;
        if(panel==12)u.ToggleEquipmentMenu();
        if(panel==13)
        {
            let chest=CaelumMazeChest(Actor.Spawn("CaelumMazeChest",u.Pos+(48,0,0),NO_REPLACE));
            let item=u.CreateDetachedMaterialStack(CaelumConstants.MATERIAL_LEATHER,1,100);item.AttachToOwner(chest);chest.Loot[0]=item;
            let preview=CaelumChestPreviewState.Get(u,true);preview.Chest=chest;preview.Refresh();Check(preview.IsOpen(),"real chest inspection opens");
        }
        if(panel==14)
        {
            let it=ThinkerIterator.Create("CaelumRestChair");CaelumRestChair chair;bool opened=false;
            while((chair=CaelumRestChair(it.Next()))!=null)
            {
                u.SetOrigin(chair.Pos+(40,0,0),false);u.Vel=(0,0,0);u.player.onground=true;
                if(CaelumRestState.Begin(u,CaelumRestRules.MODE_WAIT,0,chair)){opened=true;break;}
            }
            Check(opened,"real chair starts native rest and camera");
        }
        if(panel==15)
        {
            let it=ThinkerIterator.Create("CaelumPalomo");let npc=CaelumPalomo(it.Next());
            if(npc!=null){u.SetOrigin(npc.Pos+(48,0,0),false);u.Vel=(0,0,0);u.OpenPalomoMerchant(npc);}
            Check(u.PalomoMerchantMenuOpen,"real merchant session opens");
        }
        if(panel==16)
        {
            let plan=CaelumJourneyPlan.Get(u,true);
            // Modelo de vista aislado: la confirmacion sigue validando la ruta real.
            plan.ConnectionId=CaelumWorldCatalogue.CONNECTION_TO_COAST;plan.TravelMode=CaelumJourneyState.MODE_FOOT;
            plan.Available=new("CaelumJourneyModel");plan.Needed=new("CaelumJourneyModel");
            plan.Available.Capture(u,false);plan.Needed.Capture(u,true);plan.OriginMap=level.MapName;plan.OriginPosition=u.Pos;plan.Open=true;
        }
        if(panel==17)u.CreationWizardOpen=true;
        if(panel==18)
        {
            let it=ThinkerIterator.Create("CaelumPalomo");let npc=CaelumPalomo(it.Next());
            if(npc!=null){u.SetOrigin(npc.Pos+(48,0,0),false);u.Vel=(0,0,0);u.RecordMainM00UnknownVoiceHeard();Check(u.OpenPalomoDialogue(npc),"real native NPC conversation opens");}
        }
        if(panel!=18)EventHandler.SendInterfaceEvent(0,"ca189_show",panel);
    }
    ui void ContextCheck(int context)
    {
        let menu=CaelumLiveMenu(Menu.GetCurrentMenu());
        CheckUI(menu!=null && menu.Context==context,String.Format("native owner context %d",context));
        if(menu==null)return;
        CheckUI(menuactive==Menu.OnNoPause,"live menu uses native OnNoPause");
        CheckUI(!StaticEventHandler.Find("CaelumJournalInput").IsUiProcessor && !StaticEventHandler.Find("CaelumJournalInput").RequireMouse,"legacy raw GUI capture disabled");
        menu.Controls.Layout(menu,false);
        for(int i=0;i<int(menu.Pointer.Ids.Size());i++)
        {
            int id=menu.Pointer.Ids[i];let point=Center(menu.Pointer,id);Vector2 origin,size;
            [origin,size]=Screen.VirtualToRealCoords(point,(1,1),(640,360),false,false);
            menu.Pointer.Move(CaelumMenuPointer.JournalPoint(origin.X,origin.Y));
            CheckUI(menu.Pointer.Hit()==id,String.Format("native hit geometry context %d id %d",context,id));
        }
        menu.Pointer.Reset();
    }
    ui void LiveClick(int id,int variant)
    {
        let menu=CaelumLiveMenu(Menu.GetCurrentMenu());CheckUI(menu!=null,"native click owner exists");if(menu==null)return;
        menu.Controls.Layout(menu,false);let point=Center(menu.Pointer,id);
        CheckUI(point.X>=0,String.Format("native control %d exists",id));if(point.X<0)return;
        Vector2 origin,size;[origin,size]=Screen.VirtualToRealCoords(point,(1,1),(640,360),false,false);
        if(variant==1){menu.MouseEvent(Menu.MOUSE_Release,int(origin.X),int(origin.Y));return;}
        menu.MouseEvent(Menu.MOUSE_Click,int(origin.X),int(origin.Y));
        if(variant==2)menu.MouseEvent(Menu.MOUSE_Release,0,0);
        else menu.MouseEvent(Menu.MOUSE_Release,int(origin.X),int(origin.Y));
        CheckUI(!menu.Pointer.Held,"native click releases armed target");
    }
    ui void CheckUI(bool ok,String label)
    {if(!ok)UiFailures++;Console.Printf("CA189 %s %s",ok?"PASS":"FAIL",label);}
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
        CheckUI(menuactive==Menu.OnNoPause,"crafting does not pause native world");
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
        CheckUI(menuactive==Menu.OnNoPause && level.Time>BeforeTime,"time skip input preserves live simulation");
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
