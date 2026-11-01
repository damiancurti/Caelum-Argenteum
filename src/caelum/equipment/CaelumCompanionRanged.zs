// #430: municion nativa finita y cadencia compartida; sin blancos nuevos ni
// recorridos del mapa. El cargador referencia la reserva, no duplica cartuchos.
class CaelumCompanionRanged : Object play
{
    CaelumCompanionLoadout Loadout;
    CaelumWeaponModel Weapon;
    CaelumEquipmentItem ReloadItem;
    int Magazine[4];
    double ReloadRemaining,ReloadTotal,Cooldown;
    vector3 PreviousPosition;
    bool PositionReady;
    int Shots,Reloads;

    int Slot(int type)
    {
        if(type==CaelumConstants.WEAPON_TYPE_SHOTGUN)return 1;
        if(type==CaelumConstants.WEAPON_TYPE_LONGBOW)return 2;
        if(type==CaelumConstants.WEAPON_TYPE_CROSSBOW)return 3;
        return 0;
    }

    Inventory Ammunition()
    {
        if(Loadout==null || Loadout.SelectedWeapon==null)return null;
        Name type=CaelumInventoryService.GetAmmunitionClassName(null,
            CaelumRangedRules.AmmoType(Loadout.SelectedWeapon.ItemType));
        for(Inventory item=Loadout.Body.Inv;item!=null;item=item.Inv)
            if(item.GetClassName()==type && item.Amount>0 && !CaelumContainerRules.Boxed(item))return item;
        return null;
    }

    void CancelReload()
    {ReloadRemaining=0;ReloadTotal=0;ReloadItem=null;}

    void Tick()
    {
        if(Loadout==null || Loadout.Body==null)return;
        let body=Loadout.Body;
        Cooldown=Max(0,Cooldown-1.0/TICRATE);
        if(body.health<=0 || body.ForcedSleepTics>0 || body.CombatLucidityPhysicalStunRemaining>0
            || CaelumBolas.Restrained(body) || CaelumTelekinesisRules.Held(body)
            || body.InStateSequence(body.CurState,body.FindState("Pain"))
            || ReloadItem!=Loadout.SelectedWeapon)CancelReload();
        if(ReloadRemaining>0)
        {
            bool moving=PositionReady && (body.Pos.XY-PreviousPosition.XY).Length()>0.01;
            double progress=moving ? CaelumConstants.RELOAD_MOVEMENT_AND_PROGRESS_MULTIPLIER : 1;
            CaelumThermalEffects.RecordReloadProgress(body,Min(ReloadRemaining,progress/TICRATE),ReloadTotal);
            ReloadRemaining=Max(0,ReloadRemaining-progress/TICRATE);
            if(ReloadRemaining<=0)
            {
                let ammo=Ammunition();int type=ReloadItem.ItemType;
                Magazine[Slot(type)]=Min(CaelumRangedRules.MagazineCapacity(type),ammo!=null ? ammo.Amount : 0);
                Reloads++;CancelReload();
            }
        }
        PreviousPosition=body.Pos;PositionReady=true;
    }

    bool TryAttack()
    {
        let body=Loadout.Body;let item=Loadout.SelectedWeapon;
        if(body==null || body.health<=0 || CaelumBolas.Interrupted(body) || CaelumBolas.Restrained(body)
            || item==null || item.Owner!=body || item.Durability<=0 || body.target==null
            || !CaelumVisualPerception.Identify(body,body.target) || CaelumBattleCry.Active(body))return false;
        if(Weapon==null){Weapon=new("CaelumWeaponModel");Weapon.InitializeDefaults();}
        Weapon.SourceItem=item;Weapon.WeaponType=item.ItemType;Weapon.Tier=item.Tier;Weapon.Size=item.EquipmentSize;
        Weapon.Durability=item.Durability;Weapon.ContaminationState=item.ContaminationState;
        if(body.Distance3D(body.target)>Weapon.GetRangedRangeFor(item.ItemType) || !body.CheckSight(body.target))return false;
        let ammo=Ammunition();if(ammo==null)return false;
        int slot=Slot(item.ItemType);Magazine[slot]=Min(Magazine[slot],ammo.Amount);
        body.Vel.X=0;body.Vel.Y=0;
        if(ReloadRemaining>0 || Cooldown>0)return true;
        if(Magazine[slot]<=0)
        {
            int dexterity=body.CombatDexterity+body.GetCombatArmorAttributeBonus(CaelumConstants.ATTRIBUTE_DEXTERITY);
            ReloadTotal=CaelumRangedRules.BaseReloadSeconds(item.ItemType)*100/Max(1.0,body.CalculateActorType4Percent(dexterity));
            ReloadRemaining=ReloadTotal;ReloadItem=item;
            if(CaelumRangedRules.IsFirearm(item.ItemType))CaelumThermalEffects.BeginFirearmReload(body);
            return true;
        }
        body.UpdateCombatHealthEffects();body.UpdateActorOffensiveStatistics();
        int catalogue=CaelumCraftingRules.GetCatalogueWeaponForPlayableType(item.ItemType);
        double air=body.GetEffectiveAttackAir(CaelumWeaponCatalogue.GetPrimaryAirCost(catalogue));
        if(body.CurrentCombatAir<air*CaelumThermalEffects.HeatCost(body)*CaelumAltitudeService.Effort(body))return false;
        double duration=Loadout.Tools.AttackDuration(item);if(duration<=0)return false;
        double accuracy=CaelumCombatAim.Accuracy(body,false);
        double minimum=CaelumWeaponCatalogue.GetMinimumSpread(catalogue,item.Tier,body.CurrentCombatLucidity)*100/accuracy;
        double maximum=CaelumWeaponCatalogue.GetMaximumSpread(catalogue,item.Tier,body.CurrentCombatLucidity)*100/accuracy;
        double chance=Clamp(CaelumWeaponCatalogue.GetCriticalChancePercent(catalogue)*CaelumRangedRules.TierCriticalMultiplier(item.Tier)
            +Max(0,body.CombatPhysicalCriticalChancePercent-CaelumConstants.BASE_CRITICAL_CHANCE_PERCENT),0,100);
        double roll=Random[CaelumCarbineCritical](0,999999)/10000.0;bool critical=roll<chance;
        body.A_CaelumFacePerceivedTarget();
        vector3 aim=body.target.Pos+(0,0,body.target.Height/2)-body.Pos-(0,0,CaelumRangedRules.LaunchHeight(body,item.ItemType));
        body.Pitch=-VectorAngle(aim.XY.Length(),aim.Z);
        double damage=Weapon.GetDamage()*body.CombatHealthPerformanceMultiplier;
        if(item.ItemType==CaelumConstants.WEAPON_TYPE_SHOTGUN)
        {
            if(!CaelumShotgunRules.Fire(body,Weapon,damage,critical,body.CombatPhysicalPushMultiplier,minimum,maximum,chance,roll))return false;
        }
        else
        {
            double spread=minimum+(maximum-minimum)*Random[CaelumCarbineSpread](0,100000)/100000.0;
            double yaw=body.Angle+Random[CaelumCarbineYaw](-100000,100000)/100000.0*spread;
            double pitch=body.Pitch+Random[CaelumCarbinePitch](-100000,100000)/100000.0*spread;
            if(CaelumRangedRules.Fire(body,Weapon,damage,critical,body.CombatPhysicalPushMultiplier,yaw,pitch,chance,roll)==null)return false;
        }
        body.TrySpendCombatAir(air);ammo.Amount--;Magazine[slot]--;Shots++;
        if(ammo.Amount<=0)ammo.Destroy();
        CaelumActorMaintenance.InventoryChanged(body);Cooldown=duration/TICRATE;body.MarkActorCombatActivity();
        if(CaelumRangedRules.IsFirearm(item.ItemType))
        {CaelumThermalEffects.RecordFirearmShot(body);body.A_StartSound("caelum/weapons/carabine_fire",CHAN_WEAPON);}
        else CaelumThermalEffects.RecordWeaponAction(body,item.ItemType);
        CaelumNoise.Emit(body,CaelumRangedRules.IsFirearm(item.ItemType) ? CaelumNoiseData.FIREARM : CaelumNoiseData.SWING);
        return true;
    }
}
