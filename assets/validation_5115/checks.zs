// Isolated native service checks; all balance under test comes from production.
class CA162Passive : CaelumMandinga { override void Tick() {} }

class CA162Checks : EventHandler
{
    int Passed,Failed;
    bool ReloadChecked;
    void Check(String label,bool ok)
    {if(ok)Passed++;else Failed++;Console.Printf("CA162 %s %s",ok?"PASS":"FAIL",label);}
    CaelumCombatActor Body(Vector3 point)
    {
        let body=CaelumCombatActor(Actor.Spawn("CA162Passive",point,NO_REPLACE));
        CaelumFolkloreCombatActor(body).InitializeUniformFolkloreProfile(6);
        body.CaelumDiagnosticPassiveAI=true;body.health=100000;body.target=null;
        body.ElementalStatus=new("CaelumElementalStatus");
        CaelumThermalBody.Get(body,true);CaelumThermalRuntime.NPCStep(body,true);CaelumThermalBody.Refresh(body,body.ThermalState);
        return body;
    }
    CaelumEquipmentItem Item(CaelumPlayer u,int type)
    {
        let item=CaelumEquipmentItem(Actor.Spawn("CaelumWeaponPickup",u.Pos,NO_REPLACE));
        item.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;item.ItemType=type;
        item.Tier=1;item.EquipmentSize=2;item.Durability=u.WeaponModel.GetMaximumDurabilityFor(type,1,2);
        item.UnitWeight=u.WeaponModel.GetWeightFor(type,1,2);item.PickupDataInitialized=true;
        item.WeaponDurabilityRevision=CaelumAttackRules.DURABILITY_REVISION;item.Equipped=true;item.AttachToOwner(u);u.EnsureEquipmentItemId(item);return item;
    }
    override void WorldTick()
    {
        let u=CaelumPlayer(players[0].mo);
        if(level.time==1)u.InitializeDirectMapCharacter();
        if(CVar.FindCVar('ca162_stage').GetInt()==15 && !ReloadChecked)
        {
            ReloadChecked=true;Passed=0;Failed=0;
            let item=u.FindNativeEquipmentItemById(u.ActiveWeaponItemId);
            Check("save retains fractional contact wear and durability",item!=null && item.ItemType==21 && item.UtilityStaffContactTics==17 && item.Durability==9998);
            Check("saved stopped tool has no residual emitter",u.UtilityStaffStream==null);
            Console.Printf("CA162 RESULT passed=%d failed=%d",Passed,Failed);
        }
        if(level.time!=60)return;
        u.SetOrigin((2048,2048,0),false);u.Angle=0;u.Pitch=0;
        int type=CaelumConstants.WEAPON_TYPE_UTILITY_STAFF;
        int catalogue=CaelumConstants.CATALOGUE_WEAPON_UTILITY_STAFF;
        int pick=CaelumConstants.CATALOGUE_WEAPON_PICKAXE;
        Check("append-only weapon and recipe IDs",type==21 && catalogue==17 && CaelumConstants.CRAFTING_PICKAXE_RECIPE==131 && CaelumConstants.CRAFTING_UTILITY_STAFF_RECIPE==132);
        Check("family 1 and distinct from wand",u.GetWeaponFamilyForType(type)==1 && !u.WeaponModel.IsMagicalType(type) && type!=CaelumConstants.WEAPON_TYPE_STAFF);
        for(int tier=1;tier<=3;tier++)Check(String.Format("single tier from requested T%d",tier),CaelumWeaponModel.ResolveTierFor(type,tier)==1);
        for(int size=0;size<5;size++)
        {
            double mass=u.WeaponModel.GetWeightFor(type,1,size);
            Check(String.Format("size %d matches Pickaxe mass durability and components",size),
                mass==u.WeaponModel.GetWeightFor(CaelumConstants.WEAPON_TYPE_PICKAXE,1,size)
                && u.WeaponModel.GetMaximumDurabilityFor(type,1,size)==u.WeaponModel.GetMaximumDurabilityFor(CaelumConstants.WEAPON_TYPE_PICKAXE,1,size)
                && CaelumCraftingRules.GetRequiredTierMaterialUnits(catalogue,mass)==CaelumCraftingRules.GetRequiredTierMaterialUnits(pick,mass)
                && CaelumCraftingRules.GetRequiredBasicMaterialUnits(catalogue,mass)==CaelumCraftingRules.GetRequiredBasicMaterialUnits(pick,mass));
        }
        Check("M is 8kg 10000 durability 5600 handle 2400 head",u.WeaponModel.GetWeightFor(type,1,2)==8
            && u.WeaponModel.GetMaximumDurabilityFor(type,1,2)==10000
            && CaelumCraftingRules.GetRequiredBasicMaterialUnits(catalogue,8)==5600
            && CaelumCraftingRules.GetRequiredTierMaterialUnits(catalogue,8)==2400);
        Check("recipe uses Pickaxe component types and bronze T1",
            CaelumCraftingRules.GetBasicMaterial(catalogue)==CaelumCraftingRules.GetBasicMaterial(pick)
            && CaelumCraftingRules.GetTierMaterial(catalogue)==CaelumCraftingRules.GetTierMaterial(pick)
            && CaelumCraftingRules.GetComponentBaseMaterial(CaelumCraftingRules.GetTierMaterial(catalogue),1)==CaelumConstants.MATERIAL_BRONZE_INGOT);
        Check("no direct damage or physical Air charge",u.WeaponModel.GetDamageFor(type,1)==0 && u.WeaponModel.GetAirCostFor(type)==0);
        let record=u.GetPersistentCharacterState(true);
        record.RecipeBookVersion=5;record.KnownCraftingRecipe[131]=true;record.KnownCraftingRecipe[33]=true;
        record.EnsureRecipeBookInitialized();record.EnsureRecipeBookInitialized();
        Check("recipe revision 6 preserves old knowledge and locks new recipe",record.RecipeBookVersion==6 && record.KnownCraftingRecipe[131] && record.KnownCraftingRecipe[33] && !record.KnownCraftingRecipe[132]);
        Check("new recipe knowledge learns once",record.LearnCraftingRecipe(132) && !record.LearnCraftingRecipe(132));
        let item=Item(u,type);let other=Item(u,type);
        u.ActivateExactEquippedWeapon(item);u.EnsureWeaponFamilySelectors();
        Check("native utility selector exists",u.FindInventory("CaelumUtilityStaffSelectorWeapon")!=null);
        let source=CaelumUtilityStaffStream(Actor.Spawn("CaelumUtilityStaffStream",(2048,2048,32),NO_REPLACE));
        source.Emitter=u;source.SourceItem=item;source.Mode=1;source.SourceMap=level.MapName;
        source.Direction=(1,0,0);u.UtilityStaffStream=source;
        let near=Body((2120,2048,0));let far=Body((2560,2048,0));let side=Body((2048,2144,0));
        Check("contact reaches near body",CaelumElementalStream.Contact(source,u,source.Direction,near));
        Check("contact excludes far side and emitter",!CaelumElementalStream.Contact(source,u,source.Direction,far)
            && !CaelumElementalStream.Contact(source,u,source.Direction,side) && !CaelumElementalStream.Contact(source,u,source.Direction,u));
        int health=near.health;
        CaelumElementalStream.ApplyContact(u,near);
        Check("fire adds T1 burn without direct hit",near.health==health && near.ElementalStatus.BurnRemaining>0
            && near.ElementalStatus.BurnDamagePerSecond==Max(1,int(CaelumElementalStream.Damage(u)*CaelumConstants.ELEMENTAL_DOT_DAMAGE_RATIO*CaelumElementalStream.Power(u)+0.5)));
        for(int tic=0;tic<36;tic++){CaelumElementalStream.ApplyContact(u,near);near.ElementalStatus.Tick(near);}
        Check("refresh preserves burn pulse clock",near.health<health);
        health=near.health;CaelumElementalStream.ApplyContact(u,near,true);
        Check("ice applies real freeze without direct hit",near.health==health && near.ElementalStatus.FreezeRemaining>0 && near.ElementalStatus.GetMovementMultiplier()<1);
        double nearWatts=CaelumElementalStream.ReceivedWatts(source,source.Direction,near,near.ThermalState);
        double farWatts=CaelumElementalStream.ReceivedWatts(source,source.Direction,far,far.ThermalState);
        Check("radiation attenuates beyond contact without range cutoff",nearWatts>farWatts && farWatts>0);
        double energy=near.ThermalState.AbsorbedContinuousJoules,exposure=near.ThermalState.Exposure;
        CaelumElementalStream.Transfer(source,source.Direction,1);
        double fire=near.ThermalState.AbsorbedContinuousJoules-energy;
        Check("fire raises thermal exposure",fire>0 && near.ThermalState.Exposure>exposure);
        CaelumElementalStream.Transfer(source,source.Direction,1,true);
        Check("ice extracts same energy through shared thermal pipeline",Abs(near.ThermalState.AbsorbedContinuousJoules-energy)<0.000001
            && Abs(near.ThermalState.Exposure-exposure)<0.000001);
        source.SetOrigin((3920,2048,32),false);let blocked=Body((4064,2048,0));
        Check("wall occludes fire and ice contact",!CaelumElementalStream.Contact(source,u,source.Direction,blocked));
        Check("wall occludes thermal radiation",CaelumElementalStream.ReceivedWatts(source,source.Direction,blocked,blocked.ThermalState)==0);
        source.SetOrigin((2048,2048,32),false);
        double retention=CaelumThermalMagic.AreaRetention(near);
        energy=near.ThermalState.AbsorbedContinuousJoules;
        CaelumThermalMagic.Continuous(near,-1000,1);
        Check("ice respects authoritative armor retention once",Abs(near.ThermalState.AbsorbedContinuousJoules-energy+1000*retention)<0.000001);
        double originalCost=u.DerivedStats.StaffAnimaCost;
        u.DerivedStats.StaffAnimaCost=CaelumConstants.DEBUG_STAFF_ANIMA_COST;
        Check("base cost is ten per simulation second",CaelumUtilityStaff.CostPerSecond(u)==10);
        u.DerivedStats.StaffAnimaCost=originalCost;
        Check("cost reduction reused exactly once",Abs(CaelumUtilityStaff.CostPerSecond(u)-10*originalCost/CaelumConstants.DEBUG_STAFF_ANIMA_COST)<0.000001);
        double originalDamage=u.DerivedStats.DebugStaffDamage,originalOffense=u.EffectiveOffensiveDamageMultiplier;
        u.DerivedStats.DebugStaffDamage=1000;u.EffectiveOffensiveDamageMultiplier=1;u.ArmorDurabilityDamageMultiplier=1;
        int startDurability=item.Durability,otherDurability=other.Durability;
        for(int tic=0;tic<34;tic++)source.PaidTick();
        Check("contact below one second causes no wear",item.UtilityStaffContactTics==34 && item.Durability==startDurability);
        source.PaidTick();
        Check("one second uses wand wear on exact source item",item.UtilityStaffContactTics==0 && item.Durability==startDurability-1 && other.Durability==otherDurability);
        Console.Printf("CA162 WEAR before=%d now=%d tics=%d loss=%d",startDurability,item.Durability,item.UtilityStaffContactTics,u.LastWeaponDurabilityLoss);
        source.FlushHeat();for(int i=0;i<4;i++){if(source.Visuals[i]!=null)source.Visuals[i].Destroy();source.Visuals[i]=null;}
        source.Mode=2;for(int tic=0;tic<35;tic++)source.PaidTick();
        Check("ice contact uses same wear rule",item.Durability==startDurability-2);
        near.SetOrigin((2120,3000,0),false);
        for(int tic=0;tic<35;tic++)source.PaidTick();
        Check("empty emission does not wear item",item.Durability==startDurability-2 && item.UtilityStaffContactTics==0);
        u.DerivedStats.DebugStaffDamage=originalDamage;u.EffectiveOffensiveDamageMultiplier=originalOffense;
        source.PaidSeconds=0.2;source.Mode=1;energy=far.ThermalState.AbsorbedContinuousJoules;
        let oldVisual=source.Visuals[0];CaelumUtilityStaff.EndEmission(u);
        Check("stop settles paid residual and destroys owned visuals",u.UtilityStaffStream==null && (source==null || source.bDestroyed) && far.ThermalState.AbsorbedContinuousJoules>energy);
        Check("no lingering stream visual actors",oldVisual==null || oldVisual.bDestroyed);
        item.UtilityStaffContactTics=17;u.PersistCharacterState();
        Console.Printf("CA162 RESULT passed=%d failed=%d",Passed,Failed);
    }
}
