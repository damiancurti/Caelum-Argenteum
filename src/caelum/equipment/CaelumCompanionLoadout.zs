// #430: los modelos de combate existentes se vinculan a piezas nativas una vez.
// El modelo conserva autoridad durante el uso; las transferencias sincronizan
// desgaste y contaminacion antes de separar la pieza. No se genera botin nuevo.
class CaelumCompanionLoadout : Object play
{
    CaelumCombatActor Body;
    int Revision;
    CaelumEquipmentItem Armor[4];
    CaelumEquipmentItem Clothing[4];
    bool ClothingManaged[4];
    CaelumEquipmentItem Amulet,Seal;
    int AppliedAmuletBonus[4];
    CaelumEquipmentItem ShieldItem,SidearmItem;
    CaelumShieldModel Shield;
    CaelumWeaponModel Sidearm;
    CaelumResidentTools Tools;
    CaelumEquipmentItem SelectedWeapon;
    bool ManualWeapon;
    CaelumCompanionRanged Ranged;
    CaelumCompanionMagic Magic;

    CaelumEquipmentItem MakeArmor(int slot)
    {
        let model=Body.CombatArmor;
        if(model==null || model.ArmorType[slot]==CaelumConstants.ARMOR_TYPE_BASE_CLOTHING)return null;
        if(model.ContaminationState[slot]==null)model.ContaminationState[slot]=new("CaelumContaminationState");
        let item=CaelumEquipmentItem(Actor.Spawn("CaelumArmorPickup",Body.Pos,NO_REPLACE));
        if(item==null)return null;
        item.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_ARMOR;
        item.ArmorSlot=slot;item.ItemType=model.ArmorType[slot];item.Tier=model.Tier[slot];
        item.EquipmentSize=model.Size[slot];item.Durability=model.Durability[slot];
        item.UnitWeight=model.GetWeight(slot);item.ContaminationState=model.ContaminationState[slot];
        item.Amount=1;item.Equipped=true;item.AcquisitionResolved=item.PickupDataInitialized=true;
        item.SizePolicy=CaelumEquipmentRules.FIXED_SIZE;item.SizePolicyRevision=CaelumEquipmentRules.SIZE_POLICY_REVISION;
        item.AttachToOwner(Body);return item;
    }

    void Initialize(CaelumCombatActor ownerBody)
    {
        Body=ownerBody;if(Revision>=1)return;
        for(int slot=0;slot<CaelumConstants.ARMOR_SLOT_COUNT;slot++)Armor[slot]=MakeArmor(slot);
        let resident=CaelumAnchoredResident(Body);
        if(resident!=null){resident.EnsureResidentTools();Tools=resident.ResidentTools;}
        if(Tools==null){Tools=new("CaelumResidentTools");Tools.Owner=Body;}
        let defender=CaelumPortDefender(Body);
        if(defender!=null)
        {
            Shield=defender.Shield;
            if(Shield!=null)
            {
                if(Shield.ContaminationState==null)Shield.ContaminationState=new("CaelumContaminationState");
                ShieldItem=MakeItem("CaelumShieldPickup",CaelumConstants.EQUIPMENT_KIND_SHIELD,
                    Shield.ShieldType,Shield.Tier,Shield.Size,Shield.Durability,Shield.GetWeight(),Shield.ContaminationState);
                if(ShieldItem!=null)ShieldItem.Equipped=Shield.Equipped;
            }
            Sidearm=defender.Sword;
            if(Sidearm!=null)
            {
                if(Sidearm.ContaminationState==null)Sidearm.ContaminationState=new("CaelumContaminationState");
                SidearmItem=MakeItem("CaelumWeaponPickup",CaelumConstants.EQUIPMENT_KIND_WEAPON,
                    Sidearm.WeaponType,Sidearm.Tier,Sidearm.Size,Sidearm.Durability,
                    Sidearm.GetWeightFor(Sidearm.WeaponType,Sidearm.Tier,Sidearm.Size),Sidearm.ContaminationState);
                if(SidearmItem!=null){SidearmItem.EssenceType=Sidearm.EssenceType;SidearmItem.Equipped=Sidearm.Equipped;}
            }
        }
        Revision=1;CaelumActorMaintenance.InventoryChanged(Body);
    }

    CaelumEquipmentItem MakeItem(class<CaelumEquipmentItem> type,int kind,int itemType,int tier,int size,
        int durability,double weight,CaelumContaminationState contamination)
    {
        let item=CaelumEquipmentItem(Actor.Spawn(type,Body.Pos,NO_REPLACE));if(item==null)return null;
        item.EquipmentKind=kind;item.ItemType=itemType;item.Tier=tier;item.EquipmentSize=size;
        item.Durability=durability;item.UnitWeight=weight;item.ContaminationState=contamination;
        item.Amount=1;item.AcquisitionResolved=item.PickupDataInitialized=true;
        item.WeaponDurabilityRevision=CaelumAttackRules.DURABILITY_REVISION;
        item.SizePolicy=CaelumEquipmentRules.FIXED_SIZE;item.SizePolicyRevision=CaelumEquipmentRules.SIZE_POLICY_REVISION;
        item.AttachToOwner(Body);return item;
    }

    void Sync()
    {
        if(Body==null || Body.CombatArmor==null)return;
        if(ShieldItem!=null && ShieldItem.Owner==Body && Shield!=null)
        {ShieldItem.Durability=Shield.Durability;ShieldItem.ContaminationState=Shield.ContaminationState;}
        if(SidearmItem!=null && SidearmItem.Owner==Body && Sidearm!=null)
        {SidearmItem.Durability=Sidearm.Durability;SidearmItem.ContaminationState=Sidearm.ContaminationState;}
        for(int slot=0;slot<CaelumConstants.ARMOR_SLOT_COUNT;slot++)
        {
            let item=Armor[slot];if(item==null || item.Owner!=Body)continue;
            item.Durability=Body.CombatArmor.Durability[slot];
            item.ContaminationState=Body.CombatArmor.ContaminationState[slot];
        }
    }

    double MaterializedArmorWeight()
    {
        double weight=0;
        for(int slot=0;slot<CaelumConstants.ARMOR_SLOT_COUNT;slot++)
            if(Armor[slot]!=null && Armor[slot].Owner==Body)weight+=Body.CombatArmor.GetWeight(slot);
        return weight;
    }

    bool CanChange()
    {
        if(Body==null || Body.health<=0 || Body.Companion==null || !Body.Companion.Enlisted)return false;
        if(Body.MeleeState!=null && Body.InStateSequence(Body.CurState,Body.MeleeState))return false;
        if(Body.MissileState!=null && Body.InStateSequence(Body.CurState,Body.MissileState))return false;
        return Body.CombatActiveTool==null;
    }

    void ApplyAmulet()
    {
        int delta[4];bool changed=false;int oldAgility=Body.CombatAgility;
        for(int family=0;family<4;family++)
        {
            int bonus=Amulet!=null && Amulet.Equipped && Amulet.Owner==Body
                ? CaelumEquipmentRules.AmuletFamilyBonus(Amulet.ItemType,family,Amulet.Tier) : 0;
            delta[family]=bonus-AppliedAmuletBonus[family];
            AppliedAmuletBonus[family]=bonus;changed|=delta[family]!=0;
        }
        if(!changed)return;
        // Guardar el aporte aplicado permite retirarlo sin acumularlo al cargar.
        Body.CombatStrength+=delta[0];Body.CombatToughness+=delta[0];Body.CombatConstitution+=delta[0];
        Body.CombatAgility+=delta[1];Body.CombatDexterity+=delta[1];Body.CombatResilience+=delta[1];
        Body.CombatCharisma+=delta[2];Body.CombatEmpathy+=delta[2];Body.CombatEloquence+=delta[2];
        Body.CombatIntelligence+=delta[3];Body.CombatPatience+=delta[3];Body.CombatInsight+=delta[3];
        Body.CombatBaseSpeed*=CaelumGrowthRules.Multiplier(Body.CombatAgility,2)
            /CaelumGrowthRules.Multiplier(oldAgility,2);
        Body.CombatMaximumHealth=Max(1,int(CaelumConstants.HEALTH_ANIMA_DAMAGE_SCALE
            *Body.CalculateActorType1Percent(Body.CombatConstitution)*Max(0.01,Body.Mass/100.0)));
        if(Body.health>Body.CombatMaximumHealth)Body.health=Body.CombatMaximumHealth;
        let cache=Body.GetActorMaintenance();if(cache!=null)cache.Invalidate();
        Body.RecalculateCombatStatistics();
    }

    bool Fits(CaelumEquipmentItem item)
    {
        if(item.EquipmentKind==CaelumConstants.EQUIPMENT_KIND_AMULET
            || item.EquipmentKind==CaelumConstants.EQUIPMENT_KIND_SEAL)return true;
        // Invertir las siete alturas existentes, sin otra tabla de talles.
        let dimensions=new("CaelumDerivedStats");int tier=1;double best=double.MAX;
        for(int i=1;i<=7;i++)
        {
            double distance=Abs(Body.GetPhysiologicalHeight()-dimensions.GetActorHeightForTier(i));
            if(distance<best){best=distance;tier=i;}
        }
        return CaelumEquipmentRules.IsSizeCompatible(item.EquipmentSize,tier);
    }

    int ThermalMaterial(int slot)
    {
        if(Armor[slot]!=null)return CaelumThermalData.MaterialForArmor(Armor[slot].ItemType);
        if(Clothing[slot]!=null)return CaelumClothingData.THERMAL_FIRST+Clothing[slot].ItemType;
        // La ropa implicita anterior no se convierte en botin inventado.
        return ClothingManaged[slot] ? -1 : CaelumThermalData.LIGHT_CLOTH;
    }
    double Water(CaelumThermalState thermal,int slot)
    {
        return thermal.ActorWaterKg[slot]+(Clothing[slot]!=null?Clothing[slot].ThermalWaterKg:0)
            +(Armor[slot]!=null?Armor[slot].ThermalWaterKg:0);
    }
    void SetWater(CaelumThermalState thermal,int slot,double kg)
    {
        let garment=Clothing[slot];let armor=Armor[slot];
        double total=CaelumThermalData.WaterCapacityKgPerArea(ThermalMaterial(slot));
        double inner=garment==null && ClothingManaged[slot] ? 0 : armor==null ? total
            : Min(total,CaelumThermalData.WaterCapacityKgPerArea(CaelumThermalData.LIGHT_CLOTH));
        double fraction=total>0 ? inner/total : 0;
        if(garment!=null)garment.ThermalWaterKg=kg*fraction;
        if(armor!=null)armor.ThermalWaterKg=kg*(1-fraction);
        thermal.ActorWaterKg[slot]=garment==null ? (armor==null ? kg : kg*fraction) : 0;
        CaelumActorMaintenance.InventoryChanged(Body);
    }
    void ReconcileWater()
    {
        let thermal=CaelumThermalBody.Get(Body,false);if(thermal==null || thermal.SurfaceArea<=0)return;
        for(int slot=0;slot<4;slot++)
        {
            double before=Water(thermal,slot);
            double capacity=thermal.SurfaceArea*thermal.Coverage[slot]
                *CaelumThermalData.WaterCapacityKgPerArea(ThermalMaterial(slot));
            double after=Min(before,capacity);thermal.ClothingRunoffKg+=before-after;
            SetWater(thermal,slot,after);
        }
    }

    bool Unequip(CaelumEquipmentItem item)
    {
        if(item==null || item.Owner!=Body || !CanChange())return false;
        Sync();
        if(item==Amulet){Amulet=null;item.Equipped=false;ApplyAmulet();return true;}
        if(item==Seal){Seal=null;item.Equipped=false;return true;}
        for(int slot=0;slot<4;slot++)if(Clothing[slot]==item)
        {Clothing[slot]=null;item.Equipped=false;ReconcileWater();CaelumActorMaintenance.InventoryChanged(Body);return true;}
        if(SelectedWeapon==item)
        {SelectedWeapon=null;Tools.Cancel();if(Ranged!=null)Ranged.CancelReload();item.Equipped=false;ManualWeapon=true;return true;}
        if(item==ShieldItem)
        {
            ShieldItem=null;item.Equipped=false;Shield.Equipped=false;
            let defender=CaelumPortDefender(Body);if(defender!=null)defender.Shield=null;
            Shield=null;CaelumActorMaintenance.InventoryChanged(Body);return true;
        }
        if(item==SidearmItem)
        {
            SidearmItem=null;item.Equipped=false;Sidearm.Equipped=false;
            let defender=CaelumPortDefender(Body);if(defender!=null)defender.Sword=null;
            Sidearm=null;CaelumActorMaintenance.InventoryChanged(Body);return true;
        }
        for(int slot=0;slot<CaelumConstants.ARMOR_SLOT_COUNT;slot++)
        {
            if(Armor[slot]!=item)continue;
            Armor[slot]=null;item.Equipped=false;
            Body.CombatArmor.ArmorType[slot]=CaelumConstants.ARMOR_TYPE_BASE_CLOTHING;
            Body.CombatArmor.Tier[slot]=1;Body.CombatArmor.Durability[slot]=0;
            Body.CombatArmor.ContaminationState[slot]=null;
            ReconcileWater();Body.RecalculateCombatStatistics();CaelumActorMaintenance.InventoryChanged(Body);return true;
        }
        return !item.Equipped;
    }

    bool Toggle(CaelumEquipmentItem item)
    {
        if(item==null || item.Owner!=Body || item.InMagicBox || !CanChange())return false;
        if(item.Equipped)return Unequip(item);
        if(!Fits(item))return false;
        if(item.EquipmentKind==CaelumConstants.EQUIPMENT_KIND_AMULET)
        {
            if(Amulet!=null && !Unequip(Amulet))return false;
            Amulet=item;item.Equipped=true;ApplyAmulet();return true;
        }
        if(item.EquipmentKind==CaelumConstants.EQUIPMENT_KIND_SEAL)
        {
            if(Seal!=null && !Unequip(Seal))return false;
            Seal=item;item.Equipped=true;return true;
        }
        if(item.EquipmentKind==CaelumConstants.EQUIPMENT_KIND_CLOTHING)
        {
            int region=item.ArmorSlot;if(region<0 || region>=4)return false;
            if(Clothing[region]!=null && !Unequip(Clothing[region]))return false;
            Clothing[region]=item;ClothingManaged[region]=true;item.Equipped=true;
            ReconcileWater();CaelumActorMaintenance.InventoryChanged(Body);return true;
        }
        if(item.EquipmentKind==CaelumConstants.EQUIPMENT_KIND_WEAPON)
        {
            if(SidearmItem!=null && !Unequip(SidearmItem))return false;
            if(SelectedWeapon!=null && !Unequip(SelectedWeapon))return false;
            let defender=CaelumPortDefender(Body);
            if(defender!=null && defender.Carbine!=null)defender.Carbine.Select(false);
            Tools.Cancel();SelectedWeapon=item;ManualWeapon=true;item.Equipped=true;
            Tools.Melee=item;CaelumActorMaintenance.InventoryChanged(Body);return true;
        }
        if(item.EquipmentKind==CaelumConstants.EQUIPMENT_KIND_SHIELD)
        {
            if(ShieldItem!=null && !Unequip(ShieldItem))return false;
            Shield=new("CaelumShieldModel");Shield.InitializeDefaults();
            Shield.ShieldType=item.ItemType;Shield.Tier=item.Tier;Shield.Size=item.EquipmentSize;
            Shield.Durability=item.Durability;Shield.ContaminationState=item.ContaminationState;Shield.Equipped=true;
            ShieldItem=item;item.Equipped=true;
            let defender=CaelumPortDefender(Body);if(defender!=null)defender.Shield=Shield;
            CaelumActorMaintenance.InventoryChanged(Body);return true;
        }
        if(item.EquipmentKind!=CaelumConstants.EQUIPMENT_KIND_ARMOR)return false;
        int slot=item.ArmorSlot;
        if(slot<0 || slot>=CaelumConstants.ARMOR_SLOT_COUNT)return false;
        if(Armor[slot]!=null && !Unequip(Armor[slot]))return false;
        Armor[slot]=item;item.Equipped=true;
        Body.CombatArmor.ArmorType[slot]=item.ItemType;Body.CombatArmor.Tier[slot]=item.Tier;
        Body.CombatArmor.Size[slot]=item.EquipmentSize;Body.CombatArmor.Durability[slot]=item.Durability;
        Body.CombatArmor.ContaminationState[slot]=item.ContaminationState;
        ReconcileWater();Body.RecalculateCombatStatistics();CaelumActorMaintenance.InventoryChanged(Body);return true;
    }

    void Step()
    {
        if(Ranged!=null)Ranged.Tick();
        if(Magic!=null)Magic.Tick();
        let resident=CaelumAnchoredResident(Body);
        if(Tools!=null && (resident==null || resident.ResidentTools!=Tools))Tools.Tick();
    }

    bool TryAttack()
    {
        if(SelectedWeapon!=null)
        {
            if(CaelumSupportImplementData.IsSupport(SelectedWeapon.ItemType)
                || CaelumSupportImplementData.IsOffensiveMagic(SelectedWeapon.ItemType))
            {
                if(Magic==null){Magic=new("CaelumCompanionMagic");Magic.Loadout=self;}
                return Magic.TryAttack();
            }
            if(CaelumRangedRules.MagazineCapacity(SelectedWeapon.ItemType)>0)
            {
                if(Ranged==null){Ranged=new("CaelumCompanionRanged");Ranged.Loadout=self;}
                return Ranged.TryAttack();
            }
        }
        return Tools.TryStart();
    }
}

// Bloqueo compartido: misma defensa, desgaste y efectos del guardia original.
class CaelumActorShield : Object play
{
    static double Resolve(CaelumCombatActor holder,CaelumShieldModel shield,bool ranged,Actor inflictor,Actor source,double damage,Name mod,int flags)
    {
        Actor attacker=source!=null ? source : inflictor;
        bool blocking=holder.health>0 && !holder.bInvulnerable && shield!=null && shield.Durability>0 && !ranged
            && attacker!=null && attacker!=holder && damage>0
            && mod!='CaelumImpact' && mod!='Crush' && mod!='CaelumWeight'
            && !(mod=='Electric' && inflictor is "CaelumChannelEffect")
            && !holder.InStateSequence(holder.CurState,holder.MeleeState)
            && Abs(holder.DeltaAngle(holder.Angle,holder.AngleTo(attacker)))<=shield.GetCoverageDegrees()/2.0;
        if(blocking)
        {
            if(CaelumContaminationCombat.Physical(holder,inflictor,source,mod,flags))
                holder.ContaminationBlocker=CaelumContaminationCombat.ShieldPoint(shield);
            bool magic=CaelumArmorRules.IsMagical(inflictor,mod);
            int kind=magic ? CaelumConstants.SHIELD_DAMAGE_MAGICAL : CaelumConstants.SHIELD_DAMAGE_PHYSICAL;
            double absorption=shield.GetDefense(kind)/100.0*CaelumPersonalityRules.Absorption(holder,magic)
                *(1-CaelumPersonalityRules.AttackPenetration(inflictor,source));
            double absorbed=damage*Clamp(absorption,0,1);
            damage=Max(0,damage-absorbed);
            let mixed=CaelumMixedMeleeDamage.ForHit(holder,inflictor,source,mod);
            if(mixed!=null)absorbed+=mixed.BlockFire(holder,shield.GetDefense(CaelumConstants.SHIELD_DAMAGE_MAGICAL),inflictor,source);
            double wear=holder.EquipmentCanWear()?absorbed:0;
            int loss=int(wear/CaelumConstants.ARMOR_ABSORBED_DAMAGE_PER_GUARANTEED_DURABILITY);
            double remainder=wear-loss*CaelumConstants.ARMOR_ABSORBED_DAMAGE_PER_GUARANTEED_DURABILITY;
            if(Random[CaelumShieldDurability](0,999999)/10000.0
                < remainder/CaelumConstants.ARMOR_DAMAGE_PER_DURABILITY_CHANCE_PERCENT)loss++;
            shield.Durability=Max(0,shield.Durability-loss);
            if(absorbed>0)holder.AddActorCombatAdrenaline(CaelumConstants.ADRENALINE_GAIN_ON_SHIELD_BLOCK
                *CaelumConstants.SHIELD_KITE_BLOCK_ADRENALINE_MULTIPLIER);
        }
        return damage;
    }

}
