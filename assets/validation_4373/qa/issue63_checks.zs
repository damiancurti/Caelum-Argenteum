class Issue63Route : CaelumSocialDebugAction
{
    override bool Use(bool pickup)
    {
        let u=CaelumPlayer(Owner);Issue63Legacy.Setup(u);
        let r=u.GetPersistentCharacterState(true);r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_PALOMO_MET);
        u.GiveInventoryType("Issue63RouteWatch");return true;
    }
}
class Issue63RouteWatch : Inventory
{
    int Age;int LastWaypoint;
    override void Tick()
    {
        Super.Tick();let u=CaelumPlayer(Owner);if(u==null)return;
        let p=Issue63Legacy.Palomo();if(p==null)return;Age++;
        if(Age%70==0)Console.Printf("QA63 ROUTE t=%d waypoint=%d pos=(%.1f,%.1f,%.1f)",Age,p.DepartureWaypoint,p.Pos.X,p.Pos.Y,p.Pos.Z);
        if(p.DepartureWaypoint!=LastWaypoint || Age==1)
        {LastWaypoint=p.DepartureWaypoint;u.SetOrigin(p.Pos+(0,-100,0),false);u.Angle=90;u.Pitch=0;u.Vel=(0,0,0);}
        if(p.DepartureDone)
        {
            Issue63Legacy.Check(p.bSolid&&!p.bInvisible,"Palomo physical entrance route completed visibly");
            u.SetOrigin((500,20,264),false);u.Vel=(0,0,0);u.Angle=90;
            Issue63Legacy.Check(u.OpenPalomoDialogue(p),"catch up and open loadout dialogue");
            Console.Printf("QA63 ROUTE_DONE t=%d",Age);Destroy();
        }
        else if(Age>=2100){Issue63Legacy.Check(false,"Palomo route timeout");Destroy();}
    }
    Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE }
    States { Spawn: TNT1 A -1; Stop; }
}
class Issue63UI : CaelumSocialDebugAction
{
    override bool Use(bool pickup)
    {
        let u=CaelumPlayer(Owner);Issue63Legacy.Setup(u);let p=Issue63Legacy.Palomo();
        u.GetPersistentCharacterState(true).SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_PALOMO_MET);
        p.SetOrigin((500,120,264),false);p.DepartureStarted=true;p.DepartureDone=true;p.NarrativeRevealRequired=true;
        u.SetOrigin((500,20,264),false);u.Angle=90;u.Pitch=0;u.Vel=(0,0,0);
        Issue63Legacy.Check(u.OpenPalomoDialogue(p),"open native equipment menu");return true;
    }
}
class Issue63Migration : CaelumSocialDebugAction
{
    override bool Use(bool pickup)
    {
        let u=CaelumPlayer(Owner);let r=u.GetPersistentCharacterState(true);
        int stage=r.QuestStage[0];int recipes=r.MainM00StarterOption;
        CaelumMainM00Loadout.EnsureMigration(u);CaelumMainM00Loadout.EnsureMigration(u);
        Issue63Legacy.Check(r.MainM00LoadoutRevision==1,"migration revision applied idempotently");
        Issue63Legacy.Check(stage==r.QuestStage[0]&&recipes==r.MainM00StarterOption,"migration preserves quest and choice");
        if(r.MainM00StarterChosen)
        {
            Issue63Legacy.Check(r.MainM00StarterOption==4&&r.MainM00ArmorType==1&&r.MainM00SealChoice==3,"legacy confirmed choices preserved");
            Issue63Legacy.Check(r.MainM00SupplyIssued[CaelumConstants.MATERIAL_WOOD]==111&&r.MainM00SupplyIssued[CaelumConstants.MATERIAL_LEATHER]==222,"issued allowances not replenished");
        }
        for(Inventory c=u.Inv;c!=null;c=c.Inv)
        {
            let e=CaelumEquipmentItem(c);if(e==null)continue;
            Issue63Legacy.Check(CaelumMainM00Loadout.IsBorrowed(e)||!e.IsLimboTemporary(),"own equipment reclassified; loans remain distinct");
        }
        Issue63Legacy.Dump(u,"migrated");Console.Printf("QA63 MIGRATION_DONE");return true;
    }
}

class Issue63Rules : Object play
{
    static int EquipmentCount(CaelumPlayer u)
    { int n=0;for(Inventory c=u.Inv;c!=null;c=c.Inv)if(c is "CaelumEquipmentItem")n++;return n; }
    static int RecipeCount(CaelumPersistentCharacterState r)
    { int n=0;for(int i=0;i<CaelumConstants.CRAFTING_NETWORK_PLAYABLE_RECIPE_COUNT;i++)if(r.KnowsCraftingRecipe(i))n++;return n; }
    static void ResetChoices(CaelumPersistentCharacterState r)
    {r.MainM00StarterChosen=false;r.MainM00ArmorChosen=false;r.MainM00SealChoice=0;r.MainM00ShieldChoice=0;}
    static void AtPalomo(CaelumPlayer u)
    {
        let p=Issue63Legacy.Palomo();p.SetOrigin((500,120,264),false);p.DepartureDone=true;p.DepartureStarted=true;p.NarrativeRevealRequired=true;
        u.SetOrigin((500,20,264),false);u.Vel=(0,0,0);u.Angle=90;u.Pitch=0;
        if(u.player.ConversationNPC!=null)u.player.ConversationNPC.bInConversation=false;
        u.player.ConversationNPC=null;u.OpenPalomoDialogue(p);
    }
    static void AtRonnie(CaelumPlayer u)
    {
        if(u.player.ConversationNPC!=null)u.player.ConversationNPC.bInConversation=false;
        u.player.ConversationNPC=Issue63Legacy.Ronnie();
    }
    static void Plan(CaelumPlayer u,int shield)
    {
        AtPalomo(u);
        Issue63Legacy.Check(CaelumMainM00Loadout.Choose(u,0,4),"confirm sword with Palomo");
        Issue63Legacy.Check(CaelumMainM00Loadout.Choose(u,1,1),"confirm light armor with Palomo");
        Issue63Legacy.Check(CaelumMainM00Loadout.Choose(u,2,2),"confirm Earth Seal with Palomo");
        Issue63Legacy.Check(CaelumMainM00Loadout.Choose(u,3,shield),"confirm shield with Palomo");
    }
    static CaelumCraftingStation Station(CaelumPlayer u)
    {
        let it=ThinkerIterator.Create("CaelumCraftingStation");CaelumCraftingStation station;
        while((station=CaelumCraftingStation(it.Next()))!=null)
        {
            if(station.CraftingRoomGroup!=5||station.GetCraftingStationType()!=CaelumConstants.CRAFTING_STATION_WORKBENCH)continue;
            u.SetOrigin(station.Pos+(0,48,0),false);u.Vel=(0,0,0);
            station.CollectCraftingNetwork(u,u.BeginCraftingNetworkScan());u.OpenCraftingNetwork(station);return station;
        }
        return null;
    }
    static void Materials(CaelumPlayer u,CaelumMainM00StarterMaterials needs)
    {
        for(int material=0;material<CaelumConstants.MATERIAL_TYPE_COUNT;material++)
        {
            if(needs.Units[material]<=0)continue;
            let item=u.FindNativeSpecialItem(CaelumConstants.EQUIPMENT_KIND_MATERIAL,material,1);
            if(item==null){item=u.CreateDetachedMaterialStack(material,1,needs.Units[material]);item.InMagicBox=false;item.AttachToOwner(u);}
            else item.Amount+=needs.Units[material];
        }
        u.OnNativeInventoryChanged();
    }
    static void Craft(CaelumPlayer u,int recipe,int size,CaelumMainM00StarterMaterials needs)
    {
        if(u.player.ConversationNPC!=null)u.player.ConversationNPC.bInConversation=false;
        u.player.ConversationNPC=null;
        Issue63Legacy.Check(Station(u)!=null,"actual upstairs station network found");
        u.CraftingSelectionRecipe=recipe;u.CraftingSelectionTier=1;u.CraftingSelectionSize=size;
        u.CraftingEfficiencyIndex=2;u.ResetCraftingLayerChoices();Materials(u,needs);
        u.RefreshCraftingPreview();u.BeginSelectedCraftingTask();
        Issue63Legacy.Check(u.CraftingTaskActive,"native task starts without Magic Box");
        if(!u.CraftingTaskActive){Console.Printf("QA63 CRAFT_FAIL recipe=%d action=%d known=%d infrastructure=%d",recipe,u.LastCraftingAction,u.CraftingSelectedRecipeKnown,u.CraftingSelectedInfrastructureAvailable);return;}
        int before=EquipmentCount(u);int raw=0;
        for(int m=0;m<CaelumConstants.MATERIAL_TYPE_COUNT;m++)raw+=u.CountRawCraftingMaterial(m,1);
        u.CancelCraftingTask();
        int after=0;for(int m=0;m<CaelumConstants.MATERIAL_TYPE_COUNT;m++)after+=u.CountRawCraftingMaterial(m,1);
        Issue63Legacy.Check(before==EquipmentCount(u)&&raw==after&&!u.CraftingTaskActive,"cancel releases reservations without output or material loss");
        u.BeginSelectedCraftingTask();Issue63Legacy.Check(u.CraftingTaskActive,"cancelled recipe can resume as a new task");
        // Accelerate only elapsed work; use the complete native payment/output transaction.
        u.CraftingTaskRemainingSeconds=0;u.CompleteCraftingTask();
        Issue63Legacy.Check(u.LastCraftingAction==CaelumConstants.CRAFTING_ACTION_CREATED,"native crafting transaction completes");
        u.CloseCraftingStationSession();
    }
}
class Issue63Matrix : CaelumSocialDebugAction
{
    override bool Use(bool pickup)
    {
        let u=CaelumPlayer(Owner);Issue63Legacy.Setup(u);let r=u.GetPersistentCharacterState(true);
        r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_PALOMO_MET);Issue63Rules.AtPalomo(u);
        int items=Issue63Rules.EquipmentCount(u);int recipes=Issue63Rules.RecipeCount(r);int stage=r.QuestStage[0];
        for(int kind=0;kind<4;kind++)
        {
            int count=kind==0?36:kind==2?5:4;
            for(int option=0;option<count;option++)
            {
                Issue63Rules.ResetChoices(r);
                Issue63Legacy.Check(CaelumMainM00Loadout.Choose(u,kind,option),String.Format("choice kind=%d option=%d",kind,option));
                Issue63Legacy.Check(CaelumMainM00Loadout.Choose(u,kind,option),"same choice retry succeeds without reward");
                Issue63Legacy.Check(!CaelumMainM00Loadout.Choose(u,kind,(option+1)%count),"confirmed choice cannot be replaced");
                Issue63Legacy.Check(Issue63Rules.EquipmentCount(u)==items&&Issue63Rules.RecipeCount(r)==recipes&&r.QuestStage[0]==stage&&!CaelumMainM00RonnieTrial.IsStarted(u),"planning grants no items or recipes and does not skip trials");
            }
        }
        Issue63Rules.ResetChoices(r);Issue63Rules.AtRonnie(u);
        Issue63Legacy.Check(!CaelumMainM00RonnieTrial.Choose(u,0),"Ronnie cannot reopen the choice authority");
        Issue63Legacy.Check(!CaelumMainM00RonnieTrial.Start(u),"incomplete plan cannot begin crafting");
        Issue63Rules.Plan(u,0);Issue63Rules.AtRonnie(u);
        Issue63Legacy.Check(!CaelumMainM00RonnieTrial.Start(u),"Caella still gates Ronnie crafting");
        r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_CAELLA_COMPLETE);r.QuestStage[0]=CaelumConstants.MAIN_M00_STATE_CAELLA_COMPLETE;
        Issue63Legacy.Check(CaelumMainM00RonnieTrial.Start(u),"Ronnie consumes complete Palomo plan");
        int before=Issue63Rules.EquipmentCount(u);int known=Issue63Rules.RecipeCount(r);
        r.MainM00SupplyIssued[CaelumConstants.MATERIAL_LEATHER]=123;
        Issue63Legacy.Check(CaelumMainM00RonnieTrial.Start(u)&&before==Issue63Rules.EquipmentCount(u)&&known==Issue63Rules.RecipeCount(r)&&r.MainM00SupplyIssued[CaelumConstants.MATERIAL_LEATHER]==123,"reopening Ronnie duplicates neither loan recipes nor material allowance");
        Issue63Legacy.Check(r.KnowsCraftingRecipe(CaelumConstants.CRAFTING_NETWORK_LEGACY_RECIPE_COUNT),"shield recipe taught");
        let withShield=new("CaelumMainM00StarterMaterials");withShield.Efficiency=2;withShield.AddShield(0,r.MainM00StarterSize);
        Issue63Legacy.Check(withShield.Units[CaelumConstants.MATERIAL_RAW_COPPER]>0&&withShield.Units[CaelumConstants.MATERIAL_RAW_TIN]>0&&withShield.Units[CaelumConstants.MATERIAL_LEATHER]>0,"shield expands to authored available copper tin and leather");
        Issue63Legacy.Dump(u,"chosen");Console.Printf("QA63 MATRIX_DONE choices=49");return true;
    }
}
class Issue63Craft : CaelumSocialDebugAction
{
    override bool Use(bool pickup)
    {
        let u=CaelumPlayer(Owner);let r=u.GetPersistentCharacterState(true);
        Issue63Legacy.Check(!u.MagicBoxOwned,"tutorial crafting before receiving Box");
        for(int shield=0;shield<4;shield++)
        {
            if(shield>0){r.MainM00ShieldChoice=0;Issue63Rules.AtPalomo(u);Issue63Legacy.Check(CaelumMainM00Loadout.Choose(u,3,shield),"legacy-style missing shield addition keeps started plan");}
            let needs=new("CaelumMainM00StarterMaterials");needs.Efficiency=2;needs.AddShield(shield,r.MainM00StarterSize);
            int count=Issue63Rules.EquipmentCount(u);
            Issue63Rules.Craft(u,CaelumConstants.CRAFTING_NETWORK_LEGACY_RECIPE_COUNT+shield,r.MainM00StarterSize,needs);
            let item=u.FindNativeEquipmentItem(CaelumConstants.EQUIPMENT_KIND_SHIELD,shield,-1,1,r.MainM00StarterSize);
            Issue63Legacy.Check(item!=null&&!item.InMagicBox&&!item.IsLimboTemporary()&&r.MainM00ShieldCrafted&&Issue63Rules.EquipmentCount(u)==count+1,"chosen shield crafted once into personal inventory");
        }
        let needs=new("CaelumMainM00StarterMaterials");needs.Build(r.MainM00StarterOption,r.MainM00StarterSize,2);
        Issue63Rules.Craft(u,CaelumMainM00StarterRules.GetRecipe(r.MainM00StarterOption),r.MainM00StarterSize,needs);
        Issue63Legacy.Check(r.MainM00StarterWeaponId>0,"first weapon remains a real crafting task");
        for(int slot=0;slot<4;slot++)
        {
            let armor=new("CaelumMainM00StarterMaterials");armor.Efficiency=2;armor.AddArmor(r.MainM00ArmorType,r.MainM00ArmorSize,slot);
            Issue63Rules.Craft(u,CaelumConstants.CRAFTING_NETWORK_PHYSICAL_RECIPE_COUNT+r.MainM00ArmorType*4+slot,r.MainM00ArmorSize,armor);
            Issue63Legacy.Check(r.MainM00ArmorCrafted[slot],"chosen armor part recorded");
        }
        let seal=new("CaelumMainM00StarterMaterials");seal.Efficiency=2;seal.AddSeal(r.MainM00SealChoice-1);
        Issue63Rules.Craft(u,CaelumConstants.CRAFTING_NETWORK_PHYSICAL_RECIPE_COUNT+CaelumConstants.CRAFTING_NETWORK_ARMOR_RECIPE_COUNT+CaelumConstants.CRAFTING_NETWORK_ESSENCE_RECIPE_COUNT+CaelumConstants.CRAFTING_NETWORK_AMULET_RECIPE_COUNT+r.MainM00SealChoice-1,r.MainM00StarterSize,seal);
        Issue63Legacy.Check(r.MainM00SealsPrepared[r.MainM00SealChoice-1],"Palomo Seal reaches Ronnie's crafting plan");
        Issue63Rules.AtRonnie(u);Issue63Legacy.Check(CaelumMainM00RonnieTrial.Finish(u),"finish Ronnie and return gathering loan");
        Issue63Legacy.Check(CaelumMainM00RonnieTrial.FindLoan(u)==null,"borrowed sword returned");
        Issue63Legacy.Dump(u,"crafted");Console.Printf("QA63 CRAFT_DONE");return true;
    }
}

class Issue63Audit : Inventory
{
    int AuditAge;
    override void Tick()
    {
        Super.Tick();let u=CaelumPlayer(Owner);
        if(u==null||level.MapName!="MAP02")return;
        AuditAge++;if(AuditAge%100==0)Verify(u);
    }
    int Count;int Ids[64];int Kinds[64];int Types[64];int Sizes[64];int Conditions[64];int Essence[64];double Weights[64];bool Equipped[64];bool Boxed[64];
    void Capture(CaelumPlayer u)
    {
        Count=0;u.SyncActiveModelsToNativeInventory();
        for(Inventory c=u.Inv;c!=null;c=c.Inv)
        {
            let e=CaelumEquipmentItem(c);if(e==null||CaelumMainM00Loadout.IsBorrowed(e))continue;
            Ids[Count]=e.ItemId;Kinds[Count]=e.EquipmentKind;Types[Count]=e.ItemType;Sizes[Count]=e.EquipmentSize;
            Conditions[Count]=e.Durability;Essence[Count]=e.EssenceType;Weights[Count]=e.UnitWeight;Equipped[Count]=e.Equipped;Boxed[Count]=e.InMagicBox;Count++;
        }
        Console.Printf("QA63 AUDIT_CAPTURE count=%d",Count);
    }
    void Verify(CaelumPlayer u)
    {
        Issue63Legacy.Check(level.MapName=="MAP02","narrative crossing reaches MAP02");
        Issue63Legacy.Check(u.MagicBoxOwned&&CaelumMagicBox.EnsureOwned(u)!=null,"owned Magic Box persists");
        Issue63Legacy.Check(Issue63Rules.EquipmentCount(u)==Count,"all owned equipment survives without duplication; loans returned");
        for(int i=0;i<Count;i++)
        {
            let e=u.FindNativeEquipmentItemById(Ids[i]);
            if(e!=null&&i==0)Console.Printf("QA63 AUDIT_DETAIL id=%d size=%d/%d durability=%d/%d essence=%d/%d weight=%.4f/%.4f equipped=%d/%d box=%d/%d",Ids[i],e.EquipmentSize,Sizes[i],e.Durability,Conditions[i],e.EssenceType,Essence[i],e.UnitWeight,Weights[i],e.Equipped,Equipped[i],e.InMagicBox,Boxed[i]);
            Issue63Legacy.Check(e!=null&&e.EquipmentKind==Kinds[i]&&e.ItemType==Types[i]&&e.EquipmentSize==Sizes[i]&&e.Durability==Conditions[i]&&e.EssenceType==Essence[i]&&Abs(e.UnitWeight-Weights[i])<0.00001&&e.Equipped==Equipped[i]&&e.InMagicBox==Boxed[i],String.Format("identity condition sizing and location retained id=%d",Ids[i]));
        }
        int supplies=0;for(Inventory c=u.Inv;c!=null;c=c.Inv)if(c is "CaelumSpecialInventoryItem"||c is "CaelumConsumableItem"||c is "Ammo"||c is "Key")supplies+=c.Amount;
        Issue63Legacy.Check(supplies==0,"ammunition materials coins and consumables removed");
        Issue63Legacy.Check(!CaelumMainM00Return.Commit(u),"repeated exit cannot duplicate equipment");
        Console.Printf("QA63 EXIT_DONE count=%d",Count);
    }
    Default { Inventory.MaxAmount 1; Inventory.InterHubAmount 1; +INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE }
    States { Spawn: TNT1 A -1; Stop; }
}
class Issue63Exit : CaelumSocialDebugAction
{
    override bool Use(bool pickup)
    {
        let u=CaelumPlayer(Owner);let r=u.GetPersistentCharacterState(true);
        if(u.player.ConversationNPC!=null)u.player.ConversationNPC.bInConversation=false;u.player.ConversationNPC=null;
        u.GrantMagicBoxFromPalomo(false);
        let amulet=Issue63Legacy.Item(u,"CaelumAmuletPickup",CaelumConstants.EQUIPMENT_KIND_AMULET,0,-1,false,false);
        let extra=Issue63Legacy.Item(u,"CaelumWeaponPickup",CaelumConstants.EQUIPMENT_KIND_WEAPON,CaelumConstants.WEAPON_TYPE_STAFF,-1,true,false);extra.EssenceType=3;extra.EquipmentSize=CaelumConstants.EQUIPMENT_SIZE_XL;
        for(Inventory c=u.Inv;c!=null;c=c.Inv)
        {
            let e=CaelumEquipmentItem(c);if(e==null||CaelumMainM00Loadout.IsBorrowed(e))continue;
            if(e==extra)continue;
            if(e.EquipmentKind==CaelumConstants.EQUIPMENT_KIND_SHIELD&&e.ItemType!=0){e.InMagicBox=true;continue;}
            u.EquipmentSelectionItemId=e.ItemId;u.EquipmentSelectionKind=e.EquipmentKind;u.RefreshEquipmentSelectionPreview();u.EquipSelectedNativeEquipment();
        }
        let borrowed=Issue63Legacy.Item(u,"CA_LimboMagicImplement",CaelumConstants.EQUIPMENT_KIND_WEAPON,CaelumConstants.WEAPON_TYPE_STAFF,-1,false,true);
        let loan=Issue63Legacy.Item(u,"CA_LimboRonnieSword",CaelumConstants.EQUIPMENT_KIND_WEAPON,CaelumConstants.WEAPON_TYPE_SWORD,-1,false,true);r.MainM00RonnieSwordId=loan.ItemId;
        u.GiveInventoryType("CaelumArrowAmmo");u.GiveInventoryType("CaelumCopperCoin");u.GiveInventoryType("CaelumFoodRation");
        let material=u.CreateDetachedMaterialStack(CaelumConstants.MATERIAL_WOOD,1,123);material.InMagicBox=true;material.AttachToOwner(u);
        r.QuestState[0]=CaelumConstants.QUEST_STATE_ACTIVE;r.QuestStage[0]=CaelumConstants.MAIN_M00_STATE_FOOL_CAPTURED;
        r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_EXIT_READY);r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_THE_FOOL_CAPTURED);
        r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RULO_COMPLETE);r.TarotOwned[CaelumConstants.TAROT_THE_FOOL]=true;
        let controller=CaelumMainM00QuestController(EventHandler.Find("CaelumMainM00QuestController"));controller.PresentReturnDoor(true);
        u.SetOrigin(controller.ReturnDoor.Pos+(48,0,0),false);u.Vel=(0,0,0);u.Angle=180;
        let audit=Issue63Audit(u.GiveInventoryType("Issue63Audit"));audit.Capture(u);
        u.player.ConversationNPC=controller.ReturnDoor;controller.ReturnDoor.bInConversation=true;
        Issue63Legacy.Check(CaelumMainM00Return.Begin(u),"native return begins after requirements");
        CaelumMainM00Return.Cancel(u);Issue63Legacy.Check(!r.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_INVENTORY_SANITIZED),"cancelled departure does not clean inventory");
        Issue63Legacy.Check(CaelumMainM00Return.Begin(u),"departure can be confirmed again");
        controller.ReturnDoor.bInConversation=false;u.player.ConversationNPC=null;
        u.PersistCharacterState();return true;
    }
}
class Issue63TaskAudit : Inventory
{
    int Before;int Recipe;int Size;int Raw;
    Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE }
    States { Spawn: TNT1 A -1; Stop; }
}
class Issue63TaskStart : CaelumSocialDebugAction
{
    override bool Use(bool pickup)
    {
        let u=CaelumPlayer(Owner);let r=u.GetPersistentCharacterState(false);
        if(u.player.ConversationNPC!=null)u.player.ConversationNPC.bInConversation=false;u.player.ConversationNPC=null;
        Issue63Rules.Station(u);u.CraftingSelectionRecipe=CaelumConstants.CRAFTING_NETWORK_LEGACY_RECIPE_COUNT;
        u.CraftingSelectionTier=1;u.CraftingSelectionSize=r.MainM00StarterSize;u.CraftingEfficiencyIndex=2;u.ResetCraftingLayerChoices();
        let needs=new("CaelumMainM00StarterMaterials");needs.Efficiency=2;needs.AddShield(0,r.MainM00StarterSize);Issue63Rules.Materials(u,needs);
        u.RefreshCraftingPreview();u.BeginSelectedCraftingTask();
        Issue63Legacy.Check(u.CraftingTaskActive,"pending shield task starts before save");
        u.CraftingTaskRemainingSeconds=3600;
        let audit=Issue63TaskAudit(u.GiveInventoryType("Issue63TaskAudit"));audit.Before=Issue63Rules.EquipmentCount(u);
        audit.Recipe=u.CraftingTaskRecipeIndex;audit.Size=u.CraftingTaskSize;
        for(int m=0;m<CaelumConstants.MATERIAL_TYPE_COUNT;m++)audit.Raw+=u.CountRawCraftingMaterial(m,1);
        u.PersistCharacterState();return true;
    }
}
class Issue63TaskResume : CaelumSocialDebugAction
{
    override bool Use(bool pickup)
    {
        let u=CaelumPlayer(Owner);let audit=Issue63TaskAudit(u.FindInventory("Issue63TaskAudit"));
        Issue63Legacy.Check(audit!=null&&u.CraftingTaskActive&&u.CraftingTaskRecipeIndex==audit.Recipe&&u.CraftingTaskSize==audit.Size,"reload retains active task recipe and size");
        if(audit==null)return false;
        int raw=0;for(int m=0;m<CaelumConstants.MATERIAL_TYPE_COUNT;m++)raw+=u.CountRawCraftingMaterial(m,1);
        Issue63Legacy.Check(audit.Before==Issue63Rules.EquipmentCount(u)&&raw==audit.Raw,"reload neither spends reserved material nor creates output");
        u.CraftingTaskRemainingSeconds=0;u.CompleteCraftingTask();
        Issue63Legacy.Check(u.LastCraftingAction==CaelumConstants.CRAFTING_ACTION_CREATED&&Issue63Rules.EquipmentCount(u)==audit.Before+1,"reloaded task creates one shield");
        u.CompleteCraftingTask();Issue63Legacy.Check(Issue63Rules.EquipmentCount(u)==audit.Before+1,"repeated task completion creates no duplicate");
        Console.Printf("QA63 TASK_DONE");return true;
    }
}
class Issue63PlanReload : CaelumSocialDebugAction
{
    override bool Use(bool pickup)
    {
        let u=CaelumPlayer(Owner);let r=u.GetPersistentCharacterState(false);
        Issue63Legacy.Check(r.MainM00StarterOption==17&&r.MainM00ArmorType==3&&r.MainM00SealChoice==2&&r.MainM00ShieldChoice==4,"native menu confirmed plan persists on reload");
        Issue63Legacy.Check(Issue63Rules.EquipmentCount(u)==0&&!CaelumMainM00RonnieTrial.IsStarted(u),"reloading confirmed choices grants no equipment and does not start Ronnie");
        int recipes=Issue63Rules.RecipeCount(r);Issue63Rules.AtPalomo(u);Issue63Rules.AtPalomo(u);
        Issue63Legacy.Check(CaelumMainM00Loadout.IsComplete(r)&&Issue63Rules.RecipeCount(r)==recipes&&Issue63Rules.EquipmentCount(u)==0,"closing and reopening conversation retains plan without rewards");
        Console.Printf("QA63 PLAN_DONE");return true;
    }
}
class Issue63LostFirst : CaelumSocialDebugAction
{
    override bool Use(bool pickup)
    {
        let u=CaelumPlayer(Owner);let r=u.GetPersistentCharacterState(false);
        let first=u.FindNativeEquipmentItemById(r.MainM00StarterWeaponId);if(first!=null)first.Destroy();
        u.ActiveWeaponItemId=0;u.WeaponModel.Equipped=false;
        Issue63Legacy.Check(CaelumMainM00Return.ResolveStarter(u)==null,"destroyed first weapon is not reconstructed from a choice");return true;
    }
}
class Issue63UIRonnie : CaelumSocialDebugAction
{
    override bool Use(bool pickup)
    {
        let u=CaelumPlayer(Owner);let r=u.GetPersistentCharacterState(false);
        if(u.player.ConversationNPC!=null)u.player.ConversationNPC.bInConversation=false;u.player.ConversationNPC=null;
        r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_CAELLA_COMPLETE);r.QuestStage[0]=CaelumConstants.MAIN_M00_STATE_CAELLA_COMPLETE;
        r.MainM00SocialResult[1]=CaelumConstants.MAIN_M00_SOCIAL_SUCCESS;
        r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_ARGENTO_STARTED);
        r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RONNIE_CONVINCED);
        let ronnie=Issue63Legacy.Ronnie();u.SetOrigin(ronnie.Pos+(0,-80,0),false);u.Vel=(0,0,0);u.Angle=90;
        Issue63Legacy.Check(CaelumMainM00SocialDialogue.Open(u,ronnie),"open actual Ronnie conversation after native Palomo confirmations");
        return true;
    }
}
class Issue63VerifyRonnie : CaelumSocialDebugAction
{
    override bool Use(bool pickup)
    {
        let u=CaelumPlayer(Owner);let r=u.GetPersistentCharacterState(false);
        Issue63Legacy.Check(CaelumMainM00RonnieTrial.IsStarted(u)&&r.QuestStage[0]==CaelumConstants.MAIN_M00_STATE_RONNIE_ACTIVE,"native Ronnie reply begins existing crafting stage");
        Issue63Legacy.Check(r.KnowsCraftingRecipe(CaelumMainM00StarterRules.GetRecipe(17))&&r.KnowsCraftingRecipe(CaelumConstants.CRAFTING_NETWORK_LEGACY_RECIPE_COUNT+3),"native reply teaches stored water staff and magic shield plan");
        Console.Printf("QA63 RONNIE_UI_DONE");return true;
    }
}
class Issue63VerifyExit : CaelumSocialDebugAction
{
    override bool Use(bool pickup)
    {
        let u=CaelumPlayer(Owner);let audit=Issue63Audit(u.FindInventory("Issue63Audit"));
        Issue63Legacy.Check(audit!=null,"exit audit travels with character");if(audit!=null)audit.Verify(u);return true;
    }
}
