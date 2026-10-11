// Baseline-compatible native creation and save observer.
class CA147Flow : StaticEventHandler
{
    ui int Step, Delay, Variant;
    ui bool Active;
    static void Check(bool ok,String label){Console.Printf("CA147 %s %s",ok?"PASS":"FAIL",label);}
    static ui void UCheck(bool ok,String label){Console.Printf("CA147 %s %s",ok?"PASS":"FAIL",label);}
    override void WorldLoaded(WorldEvent e)
    {
        if(e.IsSaveGame) Snapshot("LOAD");
    }
    static void Snapshot(String phase)
    {
        let u=CaelumPlayer(players[0].mo);if(u==null)return;
        let p=u.CharacterProfile;let r=u.GetPersistentCharacterState(false);
        Console.Printf("CA147 SNAP %s map=%s profile=%d,%d,%d,%d,%d health=%d air=%.9f anima=%.9f lucidity=%.9f hunger=%.9f thirst=%.9f sleep=%.9f stage=%d tarot=%d nextid=%d",phase,level.MapName,p.Race,p.FirstClass,p.SecondClass,p.Sex,p.HeightChoice,u.health,u.CurrentAir,u.CurrentAnima,u.CurrentLucidity,u.CurrentHunger,u.CurrentThirst,u.CurrentSleep,r.QuestStage[0],r.TarotOwned[22],r.NextEquipmentItemId);
        for(int i=0;i<4;i++)Console.Printf("CA147 LAYER %d=%d",i,u.CharacterAllocation.LayerBonus[i]);
        for(int i=0;i<12;i++)Console.Printf("CA147 ATTRIBUTE %d bonus=%d",i,u.CharacterAllocation.AttributeBonus[i]);
        Console.Printf("CA147 VALUES %.9f %.9f %.9f %.9f %.9f %.9f %.9f %.9f %.9f %.9f %.9f %.9f",u.Attributes.Strength,u.Attributes.Toughness,u.Attributes.Constitution,u.Attributes.Agility,u.Attributes.Dexterity,u.Attributes.Resilience,u.Attributes.Charisma,u.Attributes.Empathy,u.Attributes.Eloquence,u.Attributes.Intelligence,u.Attributes.Patience,u.Attributes.Insight);
        for(Inventory c=u.Inv;c!=null;c=c.Inv)
        {
            let item=CaelumEquipmentItem(c);if(item==null)continue;
            Console.Printf("CA147 ITEM %s id=%d kind=%d type=%d size=%d wear=%d boxed=%d",item.GetClassName(),item.ItemId,item.EquipmentKind,item.ItemType,item.EquipmentSize,item.Durability,item.InMagicBox);
        }
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayerAuthority.FromNetworkPlayer(e.Player);if(u==null)return;
        if(e.Name=="ca147_seed")
        {
            let r=u.GetPersistentCharacterState(true);
            r.DemoNarrativeDelivered=2047;r.DemoNarrativePending=0;
            r.QuestState[0]=CaelumConstants.QUEST_STATE_ACTIVE;
            r.QuestStage[0]=CaelumConstants.MAIN_M00_STATE_ARGENTO_ACTIVE;
            r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_PALOMO_MET);
            r.TarotOwned[22]=true;
            let item=CaelumEquipmentItem(Actor.Spawn("CA_LimboRonnieSword",u.Pos,NO_REPLACE));
            item.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;item.ItemType=CaelumConstants.WEAPON_TYPE_SWORD;
            item.Tier=1;item.ArmorSlot=-1;item.EquipmentSize=3;item.Durability=37;
            item.WeaponDurabilityRevision=CaelumAttackRules.DURABILITY_REVISION;
            item.UnitWeight=1;item.PickupDataInitialized=true;item.AcquisitionResolved=true;
            item.AttachToOwner(u);u.EnsureEquipmentItemId(item);
            CaelumTarotDeckRules.Grant(u,false);
            u.bInvulnerable=true;u.health=Max(2,u.health/2);u.player.health=u.health;
            u.CurrentAir=u.DerivedStats.MaximumAir/3;u.CurrentAnima=u.DerivedStats.MaximumAnima/3;
            u.PersistCharacterState();Snapshot("SEEDED");
        }
        if(e.Name=="ca147_snapshot")Snapshot("REQUEST");
        if(e.Name=="ca147_hub")level.ChangeLevel(e.Args[0]==0 ? "MAP03" : e.Args[0]==1 ? "MAP01" : "MAP02",0,CHANGELEVEL_NOINTERMISSION);
    }
    override void ConsoleProcess(ConsoleEvent e)
    {
        if(e.Name=="ca147_begin")
        {Variant=e.Args[0];Step=0;Delay=0;Active=true;Menu.SetMenu("CaelumNewCharacterMenu");}
    }
    override void UiTick()
    {
        if(!Active)return;Delay++;if(Delay<4)return;Delay=0;
        let m=CaelumCharacterCreationMenu(Menu.GetCurrentMenu());
        if(Step==10)
        {
            let intro=CaelumIntroductionMenu(Menu.GetCurrentMenu());
            if(intro!=null)return;
            if(level.MapName=="MAP01")
            {
                let u=CaelumPlayer(players[0].mo);let p=u.CharacterProfile;
                UCheck(p.Race==(Variant==0?2:0) && p.FirstClass==(Variant==0?2:0) && p.SecondClass==(Variant==0?2:1) && p.Sex==(Variant==0?1:0) && p.HeightChoice==(Variant==0?0:2),"confirmed profile matches all five creator choices");
                UCheck(u.CharacterAllocation.GetRemainingLayerPoints()==0 && u.CharacterAllocation.GetRemainingAttributePoints()==0,"exactly four family and thirty attribute points committed");
                UCheck(!CVar.GetCVar('ca_newchar_ready',players[0]).GetBool(),"draft bridge consumed once");
                Active=false;Console.Printf("CA147 FLOW COMPLETE variant=%d",Variant);
            }
            return;
        }
        if(m==null)return;
        if(Step==0)
        {
            m.ConfirmAndStart();UCheck(Menu.GetCurrentMenu()==m,"incomplete draft cannot start");
            while(m.Race!=(Variant==0?2:0))m.MenuEvent(Menu.MKEY_Right,false);
            Console.Printf("CA147 UI RACE %s",m.CurrentChoice());m.MenuEvent(Menu.MKEY_Enter,false);Step++;
        }
        else if(Step==1)
        {while(m.FirstClass!=(Variant==0?2:0))m.MenuEvent(Menu.MKEY_Right,false);m.MenuEvent(Menu.MKEY_Enter,false);Step++;}
        else if(Step==2)
        {
            while(m.SecondClass!=(Variant==0?2:1))m.MenuEvent(Menu.MKEY_Right,false);
            Console.Printf("CA147 UI PROFESSION %s",m.CurrentChoice());
            UCheck(m.CurrentChoice()!=m.ProfessionKey(m.SecondClass),"profession text localized");m.MenuEvent(Menu.MKEY_Enter,false);Step++;
        }
        else if(Step==3)
        {while(m.Sex!=(Variant==0?1:0))m.MenuEvent(Menu.MKEY_Right,false);m.MenuEvent(Menu.MKEY_Enter,false);Step++;}
        else if(Step==4)
        {while(m.HeightChoice!=(Variant==0?0:2))m.MenuEvent(Menu.MKEY_Right,false);m.MenuEvent(Menu.MKEY_Enter,false);Step++;}
        else if(Step==5)
        {
            for(int n=0;n<32 && m.RemainingLayerPoints()>0;n++){m.MenuEvent(Menu.MKEY_Right,false);m.MenuEvent(Menu.MKEY_Down,false);}
            UCheck(m.RemainingLayerPoints()==0,"native family allocation completes within cap");m.MenuEvent(Menu.MKEY_Enter,false);Step++;
        }
        else if(Step==6)
        {
            for(int n=0;n<60 && m.RemainingAttributePoints()>0;n++){m.MenuEvent(Menu.MKEY_Right,false);m.MenuEvent(Menu.MKEY_Down,false);}
            UCheck(m.RemainingAttributePoints()==0,"native individual allocation completes within cap");m.MenuEvent(Menu.MKEY_Enter,false);Step++;
        }
        else if(Step==7)
        {
            m.MenuEvent(Menu.MKEY_Back,false);m.MenuEvent(Menu.MKEY_Back,false);
            m.MenuEvent(Menu.MKEY_Enter,false);m.MenuEvent(Menu.MKEY_Enter,false);
            UCheck(m.RemainingLayerPoints()==0 && m.RemainingAttributePoints()==0,"back and forward preserve allocation");
            if(CVar.FindCVar('ca147_stage').GetInt()==0){m.ConfirmAndStart();Step=10;return;}
            m.Close();Step++;
        }
        else if(Step==9)
        {
            UCheck(m.Page==CaelumConstants.CREATION_PAGE_SUMMARY && m.Race==(Variant==0?2:0) && m.Sex==(Variant==0?1:0) && m.RemainingLayerPoints()==0 && m.RemainingAttributePoints()==0,"cancel and reopen recover the session draft");
            let u=CaelumPlayer(players[0].mo);
            UCheck(u.CharacterProfile.Race==2 && u.CharacterProfile.FirstClass==0 && u.CharacterProfile.SecondClass==3 && u.CharacterProfile.Sex==0,"draft editing leaves loaded character untouched");
            m.ConfirmAndStart();Step=10;
        }
    }
    override void RenderOverlay(RenderEvent e)
    {
        if(Active && Step==8 && Menu.GetCurrentMenu()==null){Menu.SetMenu("CaelumNewCharacterMenu");Step=9;}
    }
}
