// #382: fixtures aisladas; no cambian las existencias de campaña.
class CA382Checkpoint : Inventory
{
    CaelumStashChest Chest;
    CaelumLockItem Key;
    CaelumCombatActor Witness;
    Default { Inventory.MaxAmount 1; Inventory.InterHubAmount 1; +INVENTORY.UNDROPPABLE }
}
class CA382Checks : StaticEventHandler
{
    int Passed,Failed;
    vector3 AttackChestOrigin;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA382 %s %s",ok?"PASS":"FAIL",label);}
    void Prepare(CaelumPlayer u)
    {
        u.bInvulnerable=true;u.DebugAttributesAt100=true;u.ApplyCharacterProfile();
        u.CancelCraftingTask();u.CloseCraftingStationSession();u.ClosePalomoMerchant();
        u.CreationWizardOpen=false;u.EquipmentMenuOpen=false;u.CombatTimeRemaining=0;
    }
    CaelumStashChest Chest(CaelumPlayer u,int tier=1)
    {
        let chest=CaelumStashChest(Actor.Spawn("CaelumStashChest",u.Pos+(64,0,0),NO_REPLACE));
        chest.EnsureStorage();chest.StorageTier=tier;chest.ApplyStorageSize();return chest;
    }
    CaelumLockItem Pair(CaelumPlayer u,int tier)
    {
        let identity=new("CaelumLockIdentity");
        let padlock=CaelumLockRules.Create(tier,u.Pos,identity);
        let key=CaelumLockRules.Create(tier+3,u.Pos,identity);
        padlock.AttachToOwner(u);key.AttachToOwner(u);return padlock;
    }
    CaelumCombatActor Witness(CaelumPlayer u,vector3 offset)
    {
        let npc=CaelumCombatActor(Actor.Spawn("CaelumRonnie",u.Pos+offset,NO_REPLACE));
        npc.bFriendly=true;npc.Speed=0;return npc;
    }
    void Suite(CaelumPlayer u)
    {
        Prepare(u);
        let chest=Chest(u);
        Check(chest.LawfulRevision==1 && chest.LawfulOwner==null,"legacy remains unclassified");
        CaelumContainerSession.Open(u,chest);
        let session=CaelumContainerSession.Get(u);
        let lockItem=Pair(u,1);let key=CaelumLockItem(u.Inv);
        Check(!chest.TogglePadlock(u) && lockItem.Owner==u,"possession does not privatize public chest");
        chest.GrantLawfulTitle(u);let title=chest.LawfulOwner;
        Check(chest.TogglePadlock(u) && chest.InstalledPadlock==lockItem && lockItem.Owner==chest,"owner installs exact tier");
        Check(chest.StorageSlots()==0 && Abs(chest.TotalStorageWeight(u)-103)<0.00001,"installed lock contributes once outside contents");
        Check(chest.IsChestLocked() && session.Chest==null,"installation closes and locks");
        key.InMagicBox=true;
        CaelumContainerSession.Open(u,chest);
        Check(session.Chest==null && chest.TheftOpenings==0,"boxed key cannot open or report theft");
        let wrong=CaelumLockRules.Create(4,u.Pos,new("CaelumLockIdentity"));wrong.AttachToOwner(u);
        CaelumContainerSession.Open(u,chest);
        Check(session.Chest==null,"same tier different pair cannot open");
        key.InMagicBox=false;
        CaelumContainerSession.Open(u,chest);
        Check(session.Chest==chest && chest.TheftOpenings==0,"owner matching key opens without theft");
        session.Close();chest.LawfulOwner=new("CaelumLawfulIdentity");
        let near=Witness(u,(0,96,0));
        let far=Witness(u,(CaelumLockRules.WITNESS_METERS*CaelumPhysicsUnits.MAP_UNITS_PER_METER+1,0,0));
        Check(near.CheckSight(u),"near witness fixture sees player");
        CaelumContainerSession.Open(u,chest);
        Check(chest.TheftOpenings==1 && near.TheftTarget==u && !near.bFriendly,"foreign opening alerts witness and records once");
        Check(far.TheftTarget==null && far.bFriendly,"outside radius unaffected");
        CaelumContainerSession.Open(u,chest);
        Check(chest.TheftOpenings==1,"repeated open request does not report twice");
        Check(!chest.TogglePadlock(u) && chest.InstalledPadlock==lockItem,"intruder cannot remove lock");
        session.Close();key.InMagicBox=true;wrong.InMagicBox=true;
        let picks=CaelumLockRules.Create(CaelumLockRules.PICKS,u.Pos);picks.AttachToOwner(u);
        CaelumContainerSession.Open(u,chest);
        Check(chest.TheftOpenings==2 && picks.Owner==u && picks.Amount==1,"reusable picks open once");
        session.Close();picks.InMagicBox=true;
        let master=CaelumLockRules.Create(CaelumLockRules.MASTER,u.Pos);master.AttachToOwner(u);
        CaelumContainerSession.Open(u,chest);
        Check(chest.TheftOpenings==3 && master.Owner==u,"reusable master key opens once");
        session.Close();
        chest.DamageMobj(u,u,10,'CaelumMeleeTest',0,0);
        Check(chest.InstalledPadlock==lockItem && chest.TheftOpenings==3,"nonblunt damage preserves lock and alert count");
        u.ThermalBluntDelivery=true;chest.DamageMobj(u,u,1,'CaelumMeleeTest',0,0);u.ThermalBluntDelivery=false;
        Check(chest.InstalledPadlock==null && chest.ChestOpen && chest.TheftOpenings==4,"one blunt hit opens and alerts");
        u.ThermalBluntDelivery=true;chest.DamageMobj(u,u,1,'CaelumMeleeTest',0,0);u.ThermalBluntDelivery=false;
        Check(chest.TheftOpenings==4,"second hit cannot repeat theft");
        let mission=CaelumStashChest(Actor.Spawn("CaelumLockedStashChest",u.Pos+(0,64,0),NO_REPLACE));
        CaelumContainerSession.Open(u,mission);
        Check(session.Chest==null && mission.IsChestLocked(),"master key cannot bypass native mission lock");
        mission.Destroy();near.Destroy();far.Destroy();
        chest.LawfulOwner=title;
        Check(chest.IsLawfulOwner(u),"lawful identity independent of lock possession");
        chest.Destroy();wrong.Destroy();key.Destroy();picks.Destroy();master.Destroy();
        Craft(u);
        Console.Printf("CA382 RESULT %d PASS %d FAIL",Passed,Failed);
    }
    void Craft(CaelumPlayer u)
    {
        u.GrantMagicBoxFromPalomo(false);u.DebugSetAllCraftingRecipesKnown(true);
        Array<Name> names;
        names.Push('CaelumWorkbenchStation');names.Push('CaelumForgeStation');
        names.Push('CaelumAnvilStation');names.Push('CaelumMasterBenchStation');
        CaelumCraftingStation bench;
        for(int i=0;i<names.Size();i++)
        {let station=CaelumCraftingStation(Actor.Spawn(names[i],u.Pos+(0,48,0),NO_REPLACE));if(i==0)bench=station;}
        bench.CollectCraftingNetwork(u,u.BeginCraftingNetworkScan());u.OpenCraftingNetwork(bench);
        for(int recipe=CaelumLockRules.FIRST_RECIPE;recipe<CaelumLockRules.FIRST_RECIPE+CaelumLockRules.RECIPE_COUNT;recipe++)
        {
            u.CraftingSelectionRecipe=recipe;u.CraftingSelectionTier=CaelumLockRules.RecipeTier(recipe);
            u.CraftingEfficiencyIndex=2;u.ResetCraftingLayerChoices();u.RefreshCraftingPreview();
            int grams=int(CaelumLockRules.RecipeWeight(recipe)*1000+0.5);
            Check(u.CraftingBasicRequired==grams && u.CraftingTierRequired==0
                && u.CraftingSilverRequired==0 && u.CraftingGoldRequired==0,String.Format("recipe %d is approved pure steel",recipe));
            let material=u.FindNativeSpecialItem(CaelumConstants.EQUIPMENT_KIND_MATERIAL,CaelumConstants.MATERIAL_STEEL_INGOT,1);
            if(material==null){material=u.CreateDetachedMaterialStack(CaelumConstants.MATERIAL_STEEL_INGOT,1,grams+10);material.AttachToOwner(u);}
            material.Amount=grams+10;material.InMagicBox=true;
            u.OnNativeInventoryChanged();u.RefreshCraftingPreview();
            u.BeginSelectedCraftingTask();
            Check(u.CraftingTaskActive,String.Format("recipe %d starts native reserved task",recipe));
            u.CraftingTaskRemainingSeconds=0;u.CompleteCraftingTask();
            int count=0;CaelumLockItem result=null;
            for(Inventory item=u.Inv;item!=null;item=item.Inv)
            {let tool=CaelumLockItem(item);if(tool!=null && tool.LockItemType==CaelumLockRules.RecipeItem(recipe)){count++;result=tool;}}
            Check(count==1 && material.Amount==10,String.Format("recipe %d commits one product and exact input",recipe));
            Check(u.GetPersistentCharacterState(true).RecipePractice[CaelumRecipeLearning.Slot(recipe,CaelumLockRules.RecipeTier(recipe))]==1,
                "successful equipment practice recorded");
            if(result!=null && result.LockItemType<3)
                Check(CaelumLockRules.HasAccess(u,result),"paired crafted key matches lock");
            u.CompleteCraftingTask();Check(material.Amount==10,"duplicate completion cannot pay twice");
        }
        u.CloseCraftingStationSession();
    }
    void Save(CaelumPlayer u)
    {
        Prepare(u);let mark=CA382Checkpoint(Actor.Spawn("CA382Checkpoint",u.Pos,NO_REPLACE));mark.AttachToOwner(u);
        mark.Chest=Chest(u,0);mark.Chest.GrantLawfulTitle(u);
        Pair(u,0);mark.Key=CaelumLockItem(u.Inv);
        CaelumContainerSession.Open(u,mark.Chest);mark.Chest.TogglePadlock(u);
        Check(CaelumInventoryService.CarryStorageChest(u,mark.Chest),"carry owned locked chest");
        mark.Witness=Witness(u,(0,96,0));mark.Witness.TheftTarget=u;mark.Witness.bFriendly=false;
        Verify(u);
    }
    void Verify(CaelumPlayer u)
    {
        let mark=CA382Checkpoint(u.FindInventory("CA382Checkpoint"));
        Check(mark!=null && mark.Chest!=null && mark.Key!=null,"saved native references present");
        if(mark==null || mark.Chest==null || mark.Key==null)return;
        Check(mark.Chest.IsLawfulOwner(u) && mark.Chest.Cargo!=null && mark.Chest.Cargo.Owner==u,"saved title and carrier distinct");
        Check(mark.Chest.InstalledPadlock!=null && mark.Chest.InstalledPadlock.Owner==mark.Chest
            && CaelumLockRules.SamePair(mark.Chest.InstalledPadlock.PairIdentity,mark.Key.PairIdentity),"saved paired key and installed native owner");
        Check(mark.Chest.IsChestLocked() && mark.Chest.TheftOpenings==0,"saved lock state and exact count");
        if(mark.Witness!=null)Check(mark.Witness.TheftTarget==u,"saved witness target");
        Console.Printf("CA382 RESULT %d PASS %d FAIL",Passed,Failed);
    }
    void Hub(CaelumPlayer u,bool verify)
    {
        if(!verify)
        {
            Prepare(u);let chest=Chest(u,0);chest.ChangeTid(38201);chest.GrantLawfulTitle(u);
            Pair(u,0);CaelumContainerSession.Open(u,chest);chest.TogglePadlock(u);
            Check(chest.InstalledPadlock!=null,"hub setup installs paired lock");
        }
        else
        {
            let iterator=ActorIterator.Create(38201);
            let chest=CaelumStashChest(iterator.Next());
            Check(chest!=null && chest.InstalledPadlock!=null,"hub retains stationary locked chest");
            if(chest!=null && chest.InstalledPadlock!=null)
            {
                Check(chest.IsLawfulOwner(u),"hub stationary owner matches traveling character");
                Check(CaelumLockRules.HasAccess(u,chest.InstalledPadlock),"hub stationary padlock matches traveling key");
            }
        }
        Console.Printf("CA382 RESULT %d PASS %d FAIL",Passed,Failed);
    }
    void Visibility(CaelumPlayer u)
    {
        Prepare(u);
        let near=Witness(u,(96,160,0));let hidden=Witness(u,(512,0,0));
        let edge=Witness(u,(-1024,0,0));let outside=Witness(u,(-1025,128,0));
        let asleep=Witness(u,(0,-96,0));asleep.ForcedSleepTics=100;
        let stunned=Witness(u,(0,-192,0));stunned.CombatLucidityPhysicalStunRemaining=10;
        let corpse=Witness(u,(-96,0,0));corpse.health=0;
        let dormant=Witness(u,(-96,-96,0));dormant.bDormant=true;
        State sleepState=asleep.CurState,stunState=stunned.CurState;
        Check(level.MapName=="LOCKTEST" && near.CheckSight(u) && !hidden.CheckSight(u),"two-room LOS fixture valid");
        CaelumTheftWitnesses.Alert(u);
        Check(near.TheftTarget==u && edge.TheftTarget==u,"visible witnesses including exact 32m boundary react");
        Check(hidden.TheftTarget==null && outside.TheftTarget==null,"wall and range exclude witnesses independently");
        Check(corpse.TheftTarget==null && dormant.TheftTarget==null,"dead and dormant actors unaffected");
        Check(asleep.TheftTarget==u && asleep.CurState==sleepState && asleep.ForcedSleepTics==100,"sleep stores hostility without waking");
        Check(stunned.TheftTarget==u && stunned.CurState==stunState,"stun stores hostility without restarting action");
        Check(CaelumTheftWitnesses.Pursue(asleep) && !asleep.LastCombatAttackAttempted,"sleep blocks pursuit attack");
        Check(CaelumTheftWitnesses.Pursue(stunned) && !stunned.LastCombatAttackAttempted,"stun blocks pursuit attack");
        near.bInConversation=true;State conversation=near.CurState;
        CaelumTheftWitnesses.Alert(u);
        Check(near.CurState==conversation && CaelumTheftWitnesses.Pursue(near)
            && !near.LastCombatAttackAttempted,"conversation pauses hostile pursuit");
        near.bInConversation=false;
        let effect=CaelumRedemptionEffect(Actor.Spawn("CaelumRedemptionEffect",u.Pos,NO_REPLACE));
        effect.Revision=CaelumRedemption.REVISION;effect.RemainingTics=100;effect.AttachToOwner(u);
        let bond=CaelumRedemptionBody(Actor.Spawn("CaelumRedemptionBody",near.Pos,NO_REPLACE));
        bond.AttachToOwner(near);bond.Remember();bond.Convert(effect);
        Check(!CaelumTheftWitnesses.HasTarget(near) && !CaelumTheftWitnesses.Pursue(near)
            && near.target==null && near.bFriendly,"active redemption overrides saved theft target");
        CaelumTheftWitnesses.Alert(u);
        Check(near.bFriendly && near.target==null,"new theft alert preserves active conversion");
        effect.RemainingTics=0;
        Check(CaelumTheftWitnesses.HasTarget(near),"expired conversion releases saved hostility");
        effect.Destroy();
        near.Destroy();hidden.Destroy();edge.Destroy();outside.Destroy();asleep.Destroy();stunned.Destroy();corpse.Destroy();dormant.Destroy();
        bool oldBox=u.MagicBoxOwned;u.MagicBoxOwned=false;
        let existing=CaelumLockRules.Create(3,u.Pos,new("CaelumLockIdentity"));existing.AttachToOwner(u);
        let incoming=CaelumLockRules.Create(3,u.Pos,new("CaelumLockIdentity"));
        let burden=u.CreateDetachedMaterialStack(CaelumConstants.MATERIAL_IRON_INGOT,1,500000000);burden.AttachToOwner(u);
        Check(!CaelumInventoryService.PrepareNativeSpecialPickup(u,incoming) && incoming.Owner==null,
            "second same-tier key cannot bypass capacity preflight");
        burden.Destroy();existing.Destroy();incoming.Destroy();u.MagicBoxOwned=oldBox;u.OnNativeInventoryChanged();
        Console.Printf("CA382 RESULT %d PASS %d FAIL",Passed,Failed);
    }
    void PushControls(CaelumPlayer u)
    {
        Prepare(u);
        let chest=Chest(u,0);let npc=Witness(u,(0,96,0));
        let rock=Actor.Spawn("CaelumRockGraniteHalf",u.Pos+(0,-128,0),NO_REPLACE);
        Check(chest!=null && chest.bDONTTHRUST && rock!=null && !rock.bDONTTHRUST,
            "push controls use fixed chest and native movable rock");
        if(chest==null || rock==null)return;
        u.ApplyAttackPushToTarget(npc,0,1);
        Check(npc.Vel.Length()>0 && u.LastAttackPushForce>0,"player still pushes ordinary combatants");
        npc.Vel=(0,0,0);u.ApplyAttackPushToTarget(chest,0,1);
        Check(chest.Vel.Length()==0 && u.LastAttackPushForce==0,"player fixed-target rejection clears previous impulse");
        u.ApplyAttackPushToTarget(rock,0,1);
        Check(rock.Vel.Length()>0 && u.LastAttackPushForce>0,"player still pushes movable rocks");
        rock.Vel=(0,0,0);npc.ApplyActorAttackPush(rock,0,1);
        Check(rock.Vel.Length()>0 && npc.LastCombatPushForce>0,"NPC still pushes movable rocks");
        npc.ApplyActorAttackPush(chest,0,1);
        Check(chest.Vel.Length()==0 && npc.LastCombatPushForce==0,"NPC fixed-target rejection clears previous impulse");
        npc.ApplyActorAttackPush(u,0,1);
        Check(u.Vel.Length()>0 && npc.LastCombatPushForce>0,"NPC still pushes ordinary player");
        u.Vel=(0,0,0);rock.Destroy();npc.Destroy();chest.Destroy();
        Console.Printf("CA382 RESULT %d PASS %d FAIL",Passed,Failed);
    }
    void House(CaelumPlayer u,bool returning)
    {
        Prepare(u);int house=CaelumHouseHubData.HouseForMap(level.MapName);
        let nearby=BlockThingsIterator.Create(u,1024);
        CaelumStashChest chest=null;int count=0;
        while(nearby.Next())
        {
            let candidate=CaelumStashChest(nearby.thing);
            if(candidate!=null && candidate.LawfulOwner!=null && candidate.LawfulOwner.Token=="house:"..level.MapName)
            {chest=candidate;count++;}
        }
        Check(house>=0 && count==1,"one native household chest");if(chest==null)return;
        let coins=chest.FindInventory("CaelumGoldCoin");
        Check(chest.StorageTier==0 && chest.IsChestLocked() && chest.InstalledPadlock!=null,"small household chest starts locked");
        Check(coins!=null && coins.Amount==(returning ? 9 : 10),"finite household gold survives revisit");
        if(!returning && coins!=null)coins.Amount--;
        let roster=CaelumHouseResidents.Get();
        Check(roster!=null && roster.HouseChestIssued[house],"source entitlement committed");
        if(roster!=null && roster.Residents[house].Body!=null)
        {
            bool paired=false;
            for(Inventory item=roster.Residents[house].Body.Inv;item!=null;item=item.Inv)
            {let key=CaelumLockItem(item);if(key!=null && CaelumLockRules.SamePair(key.PairIdentity,chest.InstalledPadlock.PairIdentity))paired=true;}
            Check(paired,"resident retains matching native key");
        }
        Check(chest.TestMobjLocation(),"household placement is unobstructed");
        Console.Printf("CA382 RESULT %d PASS %d FAIL",Passed,Failed);
    }
    void HouseMigration(CaelumPlayer u)
    {
        Prepare(u);int house=CaelumHouseHubData.HouseForMap(level.MapName);
        let roster=CaelumHouseResidents.Get();if(house<0 || roster==null)return;
        vector3 point=CaelumCityData.ChestPosition(house);
        let nearby=BlockThingsIterator.Create(u,1024);CaelumStashChest chest=null;
        while(nearby.Next())
        {let candidate=CaelumStashChest(nearby.thing);if(candidate!=null)chest=candidate;}
        Check(chest!=null && roster.Ready,"house migration fixture initialized");if(chest==null)return;
        // Destruir el contenido del fixture antes del cofre evita que su caída ocupe el punto.
        while(chest.Inv!=null)chest.Inv.Destroy();chest.InstalledPadlock=null;chest.Destroy();
        roster.HouseChestIssued[house]=false;
        let block=Actor.Spawn("CaelumSummoningProbe",point,NO_REPLACE);block.A_SetSize(32,64);block.bSolid=true;
        Check(!CaelumHouseChestRules.Prepare() && !roster.HouseChestIssued[house],"occupied placement leaves source uncommitted");
        block.Destroy();
        if(roster.Residents[house].Body!=null)roster.Residents[house].Body.Destroy();
        Check(CaelumHouseChestRules.Prepare() && roster.HouseChestIssued[house],"destroyed first resident does not block household chest");
        nearby=BlockThingsIterator.Create(u,1024);chest=null;
        while(nearby.Next())
        {let candidate=CaelumStashChest(nearby.thing);if(candidate!=null)chest=candidate;}
        bool paired=false;
        let second=roster.Residents[house+CaelumCityData.HOUSE_COUNT].Body;
        if(second!=null && chest!=null)
            for(Inventory item=second.Inv;item!=null;item=item.Inv)
            {let key=CaelumLockItem(item);if(key!=null && CaelumLockRules.SamePair(key.PairIdentity,chest.InstalledPadlock.PairIdentity))paired=true;}
        Check(paired,"surviving household resident receives paired key");
        if(chest!=null){while(chest.Inv!=null)chest.Inv.Destroy();chest.InstalledPadlock=null;chest.Destroy();}
        for(int i=house;i<roster.Residents.Size();i+=CaelumCityData.HOUSE_COUNT)
            if(roster.Residents[i].Body!=null)roster.Residents[i].Body.Destroy();
        roster.HouseChestIssued[house]=false;
        Check(CaelumHouseChestRules.Prepare() && roster.HouseChestIssued[house],"empty household receives chest without respawning residents");
        Check(CaelumHouseChestRules.Prepare(),"house issuance remains idempotent");
        Console.Printf("CA382 RESULT %d PASS %d FAIL",Passed,Failed);
    }
    void Upgrade(CaelumPlayer u)
    {
        let mark=CA382LegacyCheckpoint(u.FindInventory("CA382LegacyCheckpoint"));
        Check(mark!=null && mark.Chest!=null,"old checkpoint restored");
        if(mark!=null && mark.Chest!=null)
        {
            mark.Chest.EnsureStorage();mark.Chest.EnsureStorage();
            Check(mark.Chest.LawfulRevision==1 && mark.Chest.LawfulOwner==null
                && mark.Chest.InstalledPadlock==null && mark.Chest.TheftOpenings==0,"idempotent unclassified chest migration");
        }
        let record=u.GetPersistentCharacterState(true);record.EnsureTierRecipeBook();
        Check(record.KnowsCraftingRecipe(CaelumConstants.CRAFTING_LARGE_CANTEEN_RECIPE)
            && !record.KnowsCraftingRecipe(CaelumLockRules.FIRST_RECIPE),"old known recipe survives appended locked recipes");
        Console.Printf("CA382 RESULT %d PASS %d FAIL",Passed,Failed);
    }
    void Author(CaelumPlayer u,bool uiOnly=false)
    {
        Prepare(u);u.GrantMagicBoxFromPalomo(false);
        let own=Chest(u,0);own.SetOrigin(u.Pos+(96,-128,0),false);own.GrantLawfulTitle(u);
        Pair(u,0);u.SetOrigin(own.Pos+(-48,0,0),false);
        CaelumContainerSession.Open(u,own);own.TogglePadlock(u);
        if(uiOnly)
        {CaelumContainerSession.Open(u,own);return;}
        CaelumContainerSession.Get(u).Close();
        let foreign=Chest(u,0);foreign.SetOrigin((96,0,0),false);
        foreign.ChangeTid(38202);
        foreign.LawfulOwner=new("CaelumLawfulIdentity");foreign.LawfulOwner.Token="fixture:neighbor";
        let padlock=CaelumLockRules.Create(0,foreign.Pos,new("CaelumLockIdentity"));
        padlock.AttachToOwner(foreign);foreign.InstalledPadlock=padlock;foreign.bShootable=true;foreign.RefreshChestVisual();
        let coins=Inventory(Actor.Spawn("CaelumGoldCoin",foreign.Pos,NO_REPLACE));coins.Amount=10;coins.AttachToOwner(foreign);
        let publicChest=Chest(u,0);publicChest.SetOrigin((96,128,0),false);
        own.Angle=270;foreign.Angle=270;publicChest.Angle=270;
        let picks=CaelumLockRules.Create(CaelumLockRules.PICKS,u.Pos);picks.AttachToOwner(u);
        let master=CaelumLockRules.Create(CaelumLockRules.MASTER,u.Pos);master.AttachToOwner(u);
        let weapon=CaelumEquipmentItem(Actor.Spawn("CaelumWeaponPickup",u.Pos,NO_REPLACE));
        weapon.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;weapon.ItemType=CaelumConstants.WEAPON_TYPE_FLAIL;
        weapon.Tier=1;weapon.EquipmentSize=CaelumEquipmentRules.GetDefaultSizeForCharacterTier(u.CharacterProfile.GetSizeTier());
        weapon.PickupDataInitialized=true;weapon.bDropped=false;
        weapon.Durability=weapon.PreviewMaximumDurability(u);weapon.UnitWeight=weapon.PreviewUnitWeight(u);
        weapon.AcquisitionResolved=true;
        weapon.AttachToOwner(u);u.EnsureEquipmentItemId(weapon);u.ApplyFormalInventorySelection(weapon);u.EquipSelectedNativeEquipment();
        u.SetOrigin((0,0,0),false);u.Angle=0;u.Pitch=0;u.OnNativeInventoryChanged();
        let witness=Witness(u,(160,-96,0));witness.Speed=witness.CombatBaseSpeed;
        u.DebugSetAllCraftingRecipesKnown(true);
        let steel=u.CreateDetachedMaterialStack(CaelumConstants.MATERIAL_STEEL_INGOT,1,50000);
        steel.InMagicBox=true;steel.AttachToOwner(u);
        Actor.Spawn("CaelumWorkbenchStation",(-192,0,0),NO_REPLACE);
        Actor.Spawn("CaelumForgeStation",(-192,96,0),NO_REPLACE);
        Actor.Spawn("CaelumAnvilStation",(-192,-96,0),NO_REPLACE);
        Actor.Spawn("CaelumMasterBenchStation",(-288,0,0),NO_REPLACE);
        u.OnNativeInventoryChanged();
        Console.Printf("CA382 FLAIL equipped=%d weight=%g id=%d active=%d action=%d size=%d compatible=%d",
            weapon.Equipped,weapon.UnitWeight,weapon.ItemId,u.ActiveWeaponItemId,u.LastEquipmentAction,
            weapon.EquipmentSize,u.EquipmentSelectionSizeCompatible);
        Check(weapon.Equipped && weapon.UnitWeight>0 && u.ActiveWeaponItemId==weapon.ItemId,"author receives equipped usable flail");
        Check(own.IsLawfulOwner(u) && own.InstalledPadlock!=null && foreign.IsChestLocked()
            && picks.Owner==u && master.Owner==u,"author scene supplied: own/foreign/public chests and tools");
        Console.Printf("CA382 AUTHOR Right/south: owned. Center: foreign with gold. Left/north: public. Behind: crafting stations, known recipes and 50kg steel in Box. Use opens; L installs/removes owned locks. Flail breaks a locked padlock. Player invulnerable.");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Player<0 || e.Player>=MAXPLAYERS)return;
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=="ca382_suite")Suite(u);
        if(e.Name=="ca382_save")Save(u);
        if(e.Name=="ca382_verify")Verify(u);
        if(e.Name=="ca382_hub_setup")Hub(u,false);
        if(e.Name=="ca382_hub_verify")Hub(u,true);
        if(e.Name=="ca382_visibility")Visibility(u);
        if(e.Name=="ca382_push_controls")PushControls(u);
        if(e.Name=="ca382_house")House(u,false);
        if(e.Name=="ca382_house_return")House(u,true);
        if(e.Name=="ca382_house_migration")HouseMigration(u);
        if(e.Name=="ca382_upgrade")Upgrade(u);
        if(e.Name=="ca382_baseline_upgrade")
        {
            let mark=CA382BaselineCheckpoint(u.FindInventory("CA382BaselineCheckpoint"));
            if(mark!=null && mark.Chest!=null)
            {
                mark.Chest.EnsureStorage();mark.Chest.EnsureStorage();
                Check(mark.Chest.StorageTier==1 && mark.Chest.LawfulRevision==1
                    && mark.Chest.LawfulOwner==null && mark.Chest.InstalledPadlock==null
                    && mark.Chest.TheftOpenings==0,"5.5.8a migration preserves medium/public chest without crime");
            }
        }
        if(e.Name=="ca382_author")Author(u);
        if(e.Name=="ca382_ui")Author(u,true);
        if(e.Name=="ca382_attack_setup")
        {
            Author(u);u.SetOrigin((48,0,0),false);u.Pitch=45;
            let iterator=ActorIterator.Create(38202);let chest=CaelumStashChest(iterator.Next());
            if(chest!=null)AttackChestOrigin=chest.Pos;
        }
        if(e.Name=="ca382_attack_capture")
        {
            let iterator=ActorIterator.Create(38202);let chest=CaelumStashChest(iterator.Next());
            if(chest!=null)AttackChestOrigin=chest.Pos;
        }
        if(e.Name=="ca382_attack_verify")
        {
            let iterator=ActorIterator.Create(38202);let chest=CaelumStashChest(iterator.Next());
            Check(chest!=null && chest.InstalledPadlock==null && chest.ChestOpen
                && chest.TheftOpenings==1,"real flail attack breaks lock and commits theft once");
            Check(chest!=null && chest.FindInventory("CaelumGoldCoin")!=null
                && chest.FindInventory("CaelumGoldCoin").Amount==10,"real blunt break preserves contents");
            Check(chest!=null && (chest.Pos-AttackChestOrigin).Length()<0.001
                && chest.Vel.Length()<0.001,"real blunt break leaves chest position and velocity unchanged");
            Console.Printf("CA382 RESULT %d PASS %d FAIL",Passed,Failed);
        }
    }
}
