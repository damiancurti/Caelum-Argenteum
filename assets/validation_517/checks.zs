class CA136Target : Actor
{
    int Hits;
    override int DamageMobj(Actor inflictor,Actor source,int damage,Name mod,int flags,double angle)
    {Hits++;return Super.DamageMobj(inflictor,source,damage,mod,flags,angle);}
    Default { Radius 64; Height 128; Health 1000000; +SHOOTABLE +SOLID }
    States { Spawn: DOID A -1; Stop; }
}
class CA136Soldier : CaelumPortDefender { override void Tick() {} }
class CA136Checks : EventHandler
{
    int Checks,Failures;
    CA136Target Target;
    CaelumEquipmentItem Gun;
    CaelumShotgunAmmo Shells;
    void Check(bool ok,String label)
    {Checks++;if(!ok)Failures++;Console.Printf("CA136 %s %s",ok ? "PASS" : "FAIL",label);}
    CaelumEquipmentItem Equip(CaelumPlayer user,int kind,int tier=1)
    {
        let vendor=CaelumCityMerchant(Actor.Spawn("CaelumCityMerchant",(1000,1000,0)));
        vendor.SeedEquipment(user,CaelumConstants.EQUIPMENT_KIND_WEAPON,kind,0,CaelumConstants.EQUIPMENT_SIZE_M,0);
        let item=CaelumEquipmentItem(vendor.Inv);vendor.RemoveInventory(item);item.AttachToOwner(user);
        item.AcquisitionResolved=true;item.Tier=tier;user.EnsureEquipmentItemId(item);
        user.EquipmentSelectionItemId=item.ItemId;user.EquipmentSelectionKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;
        user.EquipmentSelectionWeaponType=kind;user.EquipmentSelectionTier=tier;user.EquipmentSelectionSize=CaelumConstants.EQUIPMENT_SIZE_M;
        user.RefreshEquipmentSelectionPreview();user.EquipSelectedNativeEquipment();return item;
    }
    void Catalogue(CaelumPlayer user)
    {
        Console.Printf("CA136 CATALOGUE %s",CaelumMainM00StarterRules.GetName(12));
        Check(CaelumWeaponCatalogue.GetCriticalChancePercent(CaelumConstants.CATALOGUE_WEAPON_HATCHET)==10
            && CaelumWeaponCatalogue.GetCriticalChancePercent(CaelumConstants.CATALOGUE_WEAPON_MACHETE)==10
            && CaelumWeaponCatalogue.GetCriticalChancePercent(CaelumConstants.CATALOGUE_WEAPON_GREATSWORD)==10
            && CaelumWeaponCatalogue.GetPrimaryAirCost(CaelumConstants.CATALOGUE_WEAPON_HATCHET)==3
            && CaelumWeaponCatalogue.GetPrimaryAirCost(CaelumConstants.CATALOGUE_WEAPON_MACHETE)==3,"former grouped melee catalogue cases retain accepted critical chance and Air cost");
        let model=new("CaelumWeaponModel");model.InitializeDefaults();
        for(int tier=1;tier<=3;tier++)
        {
            int s=CaelumConstants.WEAPON_TYPE_SHOTGUN,c=CaelumConstants.WEAPON_TYPE_CARBINE;
            Check(Abs(model.GetDamageFor(s,tier)-1.2*model.GetDamageFor(c,tier))<0.0001,String.Format("T%d total damage is 1.2 carbine",tier));
            Check(model.GetMaximumDurabilityFor(s,tier,2)==model.GetMaximumDurabilityFor(c,tier,2)
                && model.GetWeightFor(s,tier,2)==model.GetWeightFor(c,tier,2),String.Format("T%d mass and durability match carbine",tier));
            Check(model.GetRangedRangeFor(s)==model.GetRangedRangeFor(c)*0.5,String.Format("T%d range is half carbine",tier));
        }
        Check(CaelumWeaponCatalogue.GetMaximumSpread(12)==130 && CaelumWeaponCatalogue.GetMinimumSpread(12)==13,"shotgun uses existing Maximum dispersion category");
        Check(CaelumWeaponCatalogue.GetPrimaryAirCost(12)==CaelumWeaponCatalogue.GetPrimaryAirCost(13)
            && CaelumWeaponCatalogue.GetCriticalChancePercent(12)==CaelumWeaponCatalogue.GetCriticalChancePercent(13),"Air and critical chance match carbine");
        Check(user.GetRangedEffectiveReloadSeconds(14)==user.GetRangedEffectiveReloadSeconds(2),"effective reload uses same Dexterity pipeline");
        Check(CaelumCraftingRules.GetPrimaryMaterial(12)==CaelumCraftingRules.GetPrimaryMaterial(13)
            && CaelumCraftingRules.GetSecondaryMaterial(12)==CaelumCraftingRules.GetSecondaryMaterial(13)
            && CaelumCraftingRules.GetPhysicalWeaponComplexityTics(12)==CaelumCraftingRules.GetPhysicalWeaponComplexityTics(13),"crafting components and complexity match carbine");
        Check(CaelumRangedRules.MagazineCapacity(15)==50 && CaelumRangedRules.MagazineCapacity(16)==20
            && model.GetDamageFor(15,1)==1800 && model.GetRangedRangeFor(15)==2240,"longbow and crossbow retain accepted magazines and longbow balance");
        Check(CaelumEconomyRules.GetAmmunitionUnitBaseValue(6)==CaelumEconomyRules.GetAmmunitionUnitBaseValue(0)
            && user.GetAmmunitionUnitWeight(6)==user.GetAmmunitionUnitWeight(0),"shell price and mass match carbine ammo");
        Check(user.GetSpriteIndex("SHF1")>=0 && user.GetSpriteIndex("SHHD")>=0 && user.GetSpriteIndex("SHGW")>=0
            && user.GetSpriteIndex("CSGN")>=0 && user.GetSpriteIndex("CSAM")>=0,"all dynamic shotgun sprite families registered");
    }
    void Armor(CaelumPlayer user)
    {
        let npc=CaelumPortDefender(Actor.Spawn("CA136Soldier",(4000,4000,0)));
        npc.InitializeCombatArmor(CaelumConstants.ARMOR_TYPE_HEAVY,3);npc.CombatToughness=18;
        int slot=CaelumConstants.ARMOR_SLOT_BODY;
        user.ArmorModel.ArmorType[slot]=CaelumConstants.ARMOR_TYPE_HEAVY;user.ArmorModel.Tier[slot]=3;
        user.ArmorModel.Durability[slot]=user.ArmorModel.GetMaximumDurability(slot);
        user.PrepareRealArmorDamage(10000,false,slot,false);
        double pre=user.LastArmorPreDefenseDamage;
        double innate=CaelumArmorRules.InnateDefense(user.CharacterProfile.Race,false);
        let shot=CaelumCarbineProjectile(Actor.Spawn("CaelumCarbineProjectile",(1000,2000,100)));
        for(int kind=0;kind<2;kind++)for(int tier=1;tier<=3;tier++)
        {
            int type=kind==0 ? 2 : 14;
            double bypass=(kind==0 ? 0.6 : 0.5)+tier*0.1;
            shot.StoreCaelumWeaponWearIdentity(type,tier,2);
            user.PrepareRealArmorDamage(10000,false,slot,false,shot);
            Check(Abs(user.LastArmorPreDefenseDamage-pre)<0.0001
                && Abs(user.LastArmorAbsorbedDamage-pre*(innate+70*(1-bypass))/100)<0.0001,
                String.Format("player weapon%d T%d bypasses equipment only after unchanged Toughness",type,tier));
            npc.PendingLocalizedImpact=true;npc.LastAnatomyLocation=CaelumConstants.HIT_LOCATION_TORSO;
            npc.ResolveActorArmorImpact(10000,false,shot);
            Check(Abs(npc.LastCombatArmorDefenseExactPercent-(npc.GetInnateArmorDefense()+70*(1-bypass)))<0.0001,
                String.Format("NPC weapon%d T%d uses same equipment bypass",type,tier));
        }
        shot.StoreCaelumWeaponWearIdentity(15,3,2);
        user.PrepareRealArmorDamage(10000,false,slot,false,shot);
        Check(Abs(user.LastArmorAbsorbedDamage-pre*(innate+70)/100)<0.0001,"longbow arrow metadata does not gain firearm penetration");
        let cannon=Actor.Spawn("CaelumCannonProjectile",(1000,2000,500));
        user.PrepareRealArmorDamage(10000,false,slot,false,cannon);
        Check(Abs(user.LastArmorAbsorbedDamage-pre*innate/100)<0.0001 && user.LastArmorDurabilityLoss==0,"cannon removes equipped defense and wear but preserves racial defense");
        npc.PendingLocalizedImpact=true;npc.LastAnatomyLocation=CaelumConstants.HIT_LOCATION_TORSO;
        npc.ResolveActorArmorImpact(10000,false,cannon);
        Check(npc.LastCombatArmorDefenseExactPercent==npc.GetInnateArmorDefense() && npc.LastCombatArmorDurabilityLoss==0,"NPC cannon defense preserves innate armor and bypasses equipment");
        shot.Destroy();cannon.Destroy();npc.Destroy();
    }
    void Integration(CaelumPlayer user)
    {
        let vendor=CaelumCityMerchant(Actor.Spawn("CaelumCityMerchant",(1000,1000,0)));
        vendor.Category=2;vendor.EnsureStock(user);
        let ammo=Inventory(vendor.FindInventory("CaelumShotgunAmmo"));
        Check(ammo!=null && ammo.Amount==100 && vendor.Accepts(ammo),"armory stocks and accepts 100 independent cartridges");
        ammo.Amount=83;vendor.EnsureStock(user);
        Check(ammo.Amount==83,"reopening armory does not replenish cartridges");
        ammo.Destroy();vendor.Revision=1;vendor.EnsureStock(user);
        Check(vendor.FindInventory("CaelumShotgunAmmo").Amount==100 && vendor.Revision==2,"old armory stock gains its one-time cartridge allocation");
        let legacy=CaelumEquipmentItem(Actor.Spawn("CaelumWeaponPickup"));
        legacy.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;legacy.ItemType=14;
        legacy.Tier=1;legacy.EquipmentSize=2;legacy.ItemId=54321;legacy.AcquisitionResolved=true;legacy.PickupDataInitialized=true;
        legacy.Durability=500;legacy.UnitWeight=6;legacy.ShotgunRevision=0;legacy.InMagicBox=true;
        legacy.MigrateShotgun();
        Check(legacy.Durability==600 && legacy.UnitWeight==12 && legacy.InMagicBox && legacy.ItemId==54321,"legacy shortbow preserves identity storage and proportional condition");
        legacy.MigrateShotgun();Check(legacy.Durability==600,"shortbow migration is idempotent");legacy.Destroy();
        let record=CaelumPersistentCharacterState(Actor.Spawn("CaelumPersistentCharacterState"));
        record.ShotgunRevision=0;record.WeaponType=14;record.WeaponDurability=500;
        record.KnownCraftingRecipe[12]=true;record.KnownCraftingRecipe[129]=true;
        record.MigrateShotgun();record.MigrateShotgun();
        Check(record.WeaponDurability==600 && record.KnownCraftingRecipe[12] && record.KnownCraftingRecipe[129],"legacy recipe identity and arrow knowledge persist without duplication");record.Destroy();
    }
    override void WorldTick()
    {
        if(level.MapName!="CA136")return;
        let user=CaelumPlayer(players[0].mo);
        if(level.time==1){user.InitializeDirectMapCharacter();user.PersistCharacterState();user.bNOTARGET=true;}
        if(level.time==50)
        {
            Catalogue(user);Armor(user);Integration(user);
            Gun=Equip(user,14);
            Shells=CaelumShotgunAmmo(Actor.Spawn("CaelumShotgunAmmo",user.Pos));Shells.Amount=5;Shells.AttachToOwner(user);
            let arrows=Inventory(Actor.Spawn("CaelumArrowAmmo",user.Pos));arrows.Amount=7;arrows.AttachToOwner(user);
            let bullets=Inventory(Actor.Spawn("CaelumCarbineAmmo",user.Pos));bullets.Amount=9;bullets.AttachToOwner(user);
            user.OnNativeInventoryChanged();user.SetRangedMagazineCount(14,2);
            Target=CA136Target(Actor.Spawn("CA136Target",user.Pos+(256,0,0)));
        }
        if(level.time==60)
        {
            user.CurrentAir=user.DerivedStats.MaximumAir;user.Angle=0;user.Pitch=0;
            user.DerivedStats.PhysicalAccuracyPercent=100000;user.PerformCarbineAttack();
            Check(user.LastCarbineFired && Shells.Amount==4 && user.ShotgunLoadedMask==1 && user.ShotgunLastBarrel==1,"first shot spends one shell and fires right barrel");
            Check(user.FindNativeAmmunition(1).Amount==7 && user.FindNativeAmmunition(0).Amount==9,"shotgun never consumes arrows or carbine cartridges");
            let it=ThinkerIterator.Create("CaelumShotgunPellet");CaelumShotgunPellet pellet;int count=0,sum=0;
            while((pellet=CaelumShotgunPellet(it.Next()))!=null){count++;sum+=pellet.CaelumPreparedDamage;}
            Check(count==12 && sum==int(user.LastCarbineDamage+0.5),"actual launch creates twelve pellets with conserved total budget");
        }
        if(level.time==70)
        {
            Console.Printf("CA136 IMPACT hits=%d loss=%d nominal=%.6f target=(%.2f,%.2f,%.2f) player=(%.2f,%.2f,%.2f)",Target.Hits,1000000-Target.health,user.LastCarbineDamage,Target.Pos.X,Target.Pos.Y,Target.Pos.Z,user.Pos.X,user.Pos.Y,user.Pos.Z);
            Check(Target.Hits==12 && 1000000-Target.health==int(user.LastCarbineDamage+0.5),"all twelve actual projectile impacts deliver exactly one shot budget");
            user.EquippedWeaponCooldownRemaining=0;user.CurrentAir=user.DerivedStats.MaximumAir;
            user.DerivedStats.PhysicalAccuracyPercent=100000;user.PerformCarbineAttack();
            Check(user.LastCarbineFired && Shells.Amount==3 && user.ShotgunLoadedMask==0 && user.ShotgunLastBarrel==0,"second shot fires left barrel and empties both chambers");
            user.RequestRangedReload(14);
            Check(user.RangedReloadActive && user.RangedReloadTotalSeconds==user.GetRangedEffectiveReloadSeconds(2),"empty reload matches real carbine duration");
            user.CancelRangedReload();Check(user.ShotgunLoadedMask==0 && Shells.Amount==3,"interrupted reload adds no cartridge");
            user.SetRangedMagazineCount(14,1);Shells.Amount=2;user.RequestRangedReload(14);
            user.RangedReloadRemainingSeconds=0.001;user.UpdateRangedReload();
            Check(user.ShotgunLoadedMask==3 && Shells.Amount==2,"partial reload fills only missing chamber without consuming inventory twice");
        }
        if(level.time==90)
        {
            let pickup=CaelumShotgunAmmo(Actor.Spawn("CaelumShotgunAmmo",user.Pos+(64,0,0)));
            pickup.Amount=20;Actor toucher=user;
            bool picked=pickup.CallTryPickup(toucher);
            Check(picked && Shells.Amount==22 && user.FindNativeAmmunition(0).Amount==9,"native shell pickup stacks with shells without merging into carbine ammo");
            let bulletPickup=CaelumCarbineAmmo(Actor.Spawn("CaelumCarbineAmmo",user.Pos+(64,0,0)));bulletPickup.Amount=20;
            Check(bulletPickup.CallTryPickup(toucher) && user.FindNativeAmmunition(0).Amount==29 && Shells.Amount==22,"native carbine pickup never merges into shotgun cartridges");
            int sum=0;
            for(int i=0;i<12;i++)sum+=CaelumShotgunRules.PelletDamage(120.6,i);
            Check(sum==121,"non-divisible nominal shot preserves nearest-integer aggregate");
            Console.Printf("CA136 COMPLETE checks=%d failures=%d",Checks,Failures);
        }
    }
}
