class CA164Optional : StaticEventHandler
{
    int Age,CompletedAt;
    bool Loaded;
    override void WorldLoaded(WorldEvent e){if(e.IsSaveGame){Loaded=true;Age=0;}}
    override void WorldTick()
    {
        if(!Loaded)return;Age++;
        let u=CaelumPlayer(players[0].mo);if(u==null)return;let r=u.GetPersistentCharacterState(true);
        if(CompletedAt==0 && Age>=30 && u.CombatTimeRemaining<=0)
        {
            CA164Route.Palomo(u);int first=r.MainM00StarterWeaponId;int stage=r.QuestStage[0];
            CA164Route.Check(CaelumMainM00Loadout.Choose(u,1,1),"optional armor still selectable after weapon-only victory");
            CA164Route.Check(CaelumMainM00Loadout.Choose(u,2,2),"optional Seal still selectable");
            CA164Route.Check(CaelumMainM00Loadout.Choose(u,3,0),"optional shield still selectable");
            CA164Route.Check(CaelumMainM00Necklace.Choose(u,0),"Palomo necklace choice and gift retained");
            int necklace=r.MainM00NecklaceItemId;CaelumMainM00Necklace.Choose(u,0);
            CA164Route.Check(necklace>0 && necklace==r.MainM00NecklaceItemId,"necklace gift idempotent");
            CA164Route.Check(r.QuestStage[0]==stage && r.MainM00StarterWeaponId==first && r.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_MAGIC_BOX_GRANTED),"optional selections reopen without regating progression");
            CA164Route.Talk(u,"CaelumCaella");CA164Route.Check(CaelumMainM00Necklace.Teach(u),"optional necklace recipe still learnable");
            let armor=new("CaelumMainM00StarterMaterials");armor.Efficiency=2;armor.AddArmor(r.MainM00ArmorType,r.MainM00ArmorSize,0);
            CA164Route.Craft(u,CaelumConstants.CRAFTING_NETWORK_PHYSICAL_RECIPE_COUNT+r.MainM00ArmorType*4,armor);
            CA164Route.Check(r.MainM00ArmorCrafted[0],"optional armor native output recorded");
            let shield=new("CaelumMainM00StarterMaterials");shield.Efficiency=2;shield.AddShield(0,r.MainM00StarterSize);
            CA164Route.Craft(u,CaelumConstants.CRAFTING_NETWORK_LEGACY_RECIPE_COUNT,shield);
            CA164Route.Check(r.MainM00ShieldCrafted,"optional shield native output recorded");
            let seal=new("CaelumMainM00StarterMaterials");seal.Efficiency=2;seal.AddSeal(2);
            int recipe=CaelumConstants.CRAFTING_NETWORK_PHYSICAL_RECIPE_COUNT+CaelumConstants.CRAFTING_NETWORK_ARMOR_RECIPE_COUNT+CaelumConstants.CRAFTING_NETWORK_ESSENCE_RECIPE_COUNT+CaelumConstants.CRAFTING_NETWORK_AMULET_RECIPE_COUNT+2;
            CA164Route.Craft(u,recipe,seal);CA164Route.Check(r.MainM00SealsPrepared[2],"optional Seal native output recorded");
            let necklacePlan=new("CaelumMainM00StarterMaterials");necklacePlan.Efficiency=2;necklacePlan.AddAmulet(0);
            CA164Route.Craft(u,CaelumMainM00Necklace.Recipe(0),necklacePlan);
            CA164Route.Check(r.MainM00NecklaceItemId==necklace && u.FindNativeEquipmentItemById(necklace)!=null,"optional necklace craft preserves gift identity");
            CA164Route.EndTalk(u);CompletedAt=Age;Console.Printf("CA164 OPTIONAL_DONE age=%d",Age);
        }
        if(CompletedAt>0 && Age==CompletedAt+50)
        {
            // Test the real departure transaction, including legacy class instances.
            let old=CA164Legacy.Item(u,"CA_LimboMagicImplement",CaelumConstants.EQUIPMENT_KIND_WEAPON,CaelumConstants.WEAPON_TYPE_STAFF);
            let seal=CA164Legacy.Item(u,"CA_LimboMagicSeal",CaelumConstants.EQUIPMENT_KIND_SEAL,0);seal.InMagicBox=true;
            let sword=CA164Legacy.Item(u,"CA_LimboRonnieSword",CaelumConstants.EQUIPMENT_KIND_WEAPON,CaelumConstants.WEAPON_TYPE_SWORD);
            r.MainM00LoadoutRevision=1;CaelumMainM00Loadout.EnsureMigration(u);
            let audit=CA164Audit(u.GiveInventoryType("CA164Audit"));audit.Capture(u,5);
            r.QuestStage[0]=CaelumConstants.MAIN_M00_STATE_FOOL_CAPTURED;
            r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_EXIT_READY);r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_THE_FOOL_CAPTURED);
            r.TarotOwned[CaelumConstants.TAROT_THE_FOOL]=true;
            let world=CaelumMainM00QuestController(EventHandler.Find("CaelumMainM00QuestController"));world.PresentReturnDoor(true);
            u.SetOrigin(world.ReturnDoor.Pos+(48,0,0),false);u.Vel=(0,0,0);u.Angle=180;
            u.player.ConversationNPC=world.ReturnDoor;world.ReturnDoor.bInConversation=true;
            CA164Route.Check(CaelumMainM00Return.Begin(u),"native departure confirmation");
            CaelumMainM00Return.Cancel(u);CA164Route.Check(!r.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_INVENTORY_SANITIZED),"cancelled departure keeps inventory");
            CA164Route.Check(CaelumMainM00Return.Begin(u),"departure reopens after cancellation");
            CA164Route.EndTalk(u);
            CA164Route.Check(CaelumMainM00Return.Commit(u),"real departure transaction succeeds");
            for(int i=0;i<audit.Count;i++)
            {
                let e=u.FindNativeEquipmentItemById(audit.Ids[i]);
                CA164Route.Check(e!=null && e.EquipmentSize==audit.Sizes[i] && e.Durability==audit.Wear[i] && e.InMagicBox==audit.Boxed[i],"departure retains exact owned or legacy tool");
            }
            CA164Route.Check(u.FindInventory("CaelumTarotDeck")==audit.Deck && CaelumMagicBox.EnsureOwned(u)==audit.Box,"departure retains exact deck and Box");
            Level.ChangeLevel("MAP02",0,CHANGELEVEL_NOINTERMISSION);
        }
        if(level.MapName=="MAP02" && Age>90)
        {
            let audit=CA164Audit(u.FindInventory("CA164Audit"));
            if(audit!=null)for(int i=0;i<audit.Count;i++)CA164Route.Check(u.FindNativeEquipmentItemById(audit.Ids[i])!=null,"MAP02 travel retains actual item ID");
            Console.Printf("CA164 EXIT_DONE");Loaded=false;
        }
    }
}
