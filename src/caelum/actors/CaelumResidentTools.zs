// #195: inventario finito del residente y activación de las reglas compartidas.
// Los objetos del jugador y de los prisioneros no pasan por esta entrega.
class CaelumResidentTools : Object play
{
    const IDLE=0;
    const BOLAS_PREPARATION=1;
    const ICE_EMISSION=2;
    const CHARGE_PREPARATION=3;
    const MELEE_CYCLE=4;
    const RECOVERY=5;
    const PREPARED=6;
    CaelumAnchoredResident Owner;
    CaelumEquipmentItem Pickaxe,Staff,Bolas,Melee,ActiveItem;
    int Revision,Phase,PreparedTics,NextMeleeVariant;
    double ChargeRemaining,PreparedRemaining,CycleProgress,CycleDuration,RecoveryTics;
    bool Secondary,Charged,StrikeResolved;
    int MeleeUses,ChargedUses,IcePaidTics,BolasThrows,BolasRecoveries;
    int LastStrikeDamage,LastStrikeRawDamage,LastStrikeGrade;
    bool LastStrikeCritical;
    CaelumWeaponModel Sidearm;

    CaelumEquipmentItem Grant(int type,int size)
    {
        let item=CaelumEquipmentItem(Actor.Spawn("CaelumWeaponPickup",Owner.Pos,NO_REPLACE));
        if(item==null)return null;
        let model=new("CaelumWeaponModel");
        item.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;
        item.ItemType=type;item.Tier=1;item.EquipmentSize=size;item.Amount=1;
        item.Durability=model.GetMaximumDurabilityFor(type,1,size);
        item.WeaponDurabilityRevision=CaelumAttackRules.DURABILITY_REVISION;
        item.UnitWeight=model.GetWeightFor(type,1,size);
        item.PickupDataInitialized=item.AcquisitionResolved=true;
        item.SizePolicy=CaelumEquipmentRules.FIXED_SIZE;
        item.SizePolicyRevision=CaelumEquipmentRules.SIZE_POLICY_REVISION;
        item.AttachToOwner(Owner);
        return item;
    }

    void Initialize(CaelumAnchoredResident resident)
    {
        Owner=resident;
        if(Owner==null || Revision>=CaelumResidentData.REVISION)return;
        int size=Owner.CombatArmor!=null ? Owner.CombatArmor.Size[CaelumConstants.ARMOR_SLOT_BODY]
            : CaelumConstants.EQUIPMENT_SIZE_M;
        Pickaxe=Grant(CaelumConstants.WEAPON_TYPE_PICKAXE,size);
        Staff=Grant(CaelumConstants.WEAPON_TYPE_UTILITY_STAFF,size);
        Bolas=Grant(CaelumConstants.WEAPON_TYPE_BOLAS,size);
        Melee=Owner is "CaelumRulo" ? Grant(CaelumConstants.WEAPON_TYPE_WAR_AXE,size)
            : Owner is "CaelumRonnie" ? Grant(CaelumConstants.WEAPON_TYPE_SWORD,size) : Pickaxe;
        Revision=CaelumResidentData.REVISION;
    }

    bool Available(CaelumEquipmentItem item)
    {
        return Owner!=null && item!=null && !item.bDestroyed && item.Owner==Owner
            && !item.InMagicBox && item.Durability>0;
    }

    CaelumWeaponModel GetSidearm()
    {
        if(!Available(Melee))return null;
        if(Sidearm==null)Sidearm=new("CaelumWeaponModel");
        Sidearm.WeaponType=Melee.ItemType;Sidearm.Tier=Melee.Tier;Sidearm.Size=Melee.EquipmentSize;
        Sidearm.Durability=Melee.Durability;Sidearm.DurabilityRevision=CaelumAttackRules.DURABILITY_REVISION;
        Sidearm.Equipped=true;Sidearm.Initialized=true;return Sidearm;
    }

    void Cancel()
    {
        if(Owner!=null){CaelumUtilityStaff.EndEmission(Owner);Owner.CombatActiveTool=null;}
        if(ActiveItem!=null)ActiveItem.Equipped=false;
        ActiveItem=null;Phase=IDLE;PreparedTics=0;ChargeRemaining=PreparedRemaining=0;
        CycleProgress=RecoveryTics=0;StrikeResolved=false;
    }

    bool Equip(CaelumEquipmentItem item)
    {
        if(!Available(item))return false;
        Cancel();ActiveItem=item;item.Equipped=true;Owner.CombatActiveTool=item;
        Owner.Vel.X=Owner.Vel.Y=0;Owner.A_FaceTarget();
        Owner.SetStateLabel("ResidentToolUse");return true;
    }

    void Aim()
    {
        if(Owner.target==null)return;
        Owner.A_FaceTarget();
        vector3 aim=Owner.target.Pos+(0,0,Owner.target.Height/2)
            -Owner.Pos-(0,0,Owner.Height/2);
        Owner.Pitch=-VectorAngle(aim.XY.Length(),aim.Z);
    }

    bool BeginBolas()
    {
        if(Owner.CurrentCombatAir<CaelumBolas.ThrowCost(Owner) || !Equip(Bolas))return false;
        Phase=BOLAS_PREPARATION;return true;
    }

    bool AimBolas()
    {
        if(Owner==null || Owner.target==null || !Owner.CheckSight(Owner.target))return false;
        Owner.UpdateActorOffensiveStatistics();Owner.A_FaceTarget();
        vector3 origin=Owner.Pos+(Cos(Owner.Angle)*32,Sin(Owner.Angle)*32,Owner.Height*0.65);
        vector3 delta=Owner.target.Pos+(0,0,Owner.target.Height/2)-origin;
        double distance=delta.XY.Length();
        double speed=CaelumConstants.PROJECTILE_SPEED_SLOW*Sqrt(Max(0.0,Owner.CombatPhysicalPushMultiplier));
        double gravity=Owner.GetGravity();
        double discriminant=speed**4-gravity*(gravity*distance*distance+2*delta.Z*speed*speed);
        if(discriminant<0 || distance<=0 || speed<=0)return false;
        Owner.Pitch=gravity>0 ? -ATan((speed*speed-Sqrt(discriminant))/(gravity*distance))
            : -VectorAngle(distance,delta.Z);
        return true;
    }

    bool TryStart()
    {
        if(CaelumBattleCry.Active(Owner))return false;
        if(Owner==null || !Owner.IsRuloPartyFighting() || Owner.target==null
            || CaelumBolas.Restrained(Owner) || CaelumBolas.Interrupted(Owner))return false;
        if(Phase!=IDLE)return true;
        RecoverBolas();
        let victim=CaelumCombatActor(Owner.target);
        bool bound=CaelumBolas.Restrained(victim);
        if(victim!=null && Available(Bolas) && !bound && Owner.Distance2D(victim)<=Owner.MaxTargetRange && AimBolas() && BeginBolas())return true;
        if(Available(Staff) && victim!=null && victim.ElementalStatus!=null && victim.ElementalStatus.FreezeRemaining<=0
            && Owner.Distance2D(victim)<=CaelumDemonBreathRules.Range()+victim.Radius && Owner.CheckSight(victim)
            && BeginIce())return true;
        bool secondary=(NextMeleeVariant&1)!=0;
        bool charged=(Owner is "CaelumRulo" || Owner is "CaelumRonnie") && (NextMeleeVariant&2)!=0;
        if(victim!=null && Owner.Distance2D(victim)<=MeleeRange(secondary)+victim.Radius && Owner.CheckSight(victim)
            && BeginMelee(secondary,charged))
        {NextMeleeVariant=(NextMeleeVariant+1)%4;return true;}
        // Sólo se persigue la pieza propia caída, nunca los regalos del jugador.
        if(Bolas!=null && !Bolas.bDestroyed && Bolas.Owner==null && Owner.CheckSight(Bolas))
        {
            vector2 delta=Bolas.Pos.XY-Owner.Pos.XY;
            if(delta.Length()>0)
            {
                vector2 velocity=delta.Unit()*Min(delta.Length(),Owner.Speed);
                Owner.Vel.X=velocity.X;Owner.Vel.Y=velocity.Y;
                CaelumThermalMotion.SetVelocity(Owner);return true;
            }
        }
        return false;
    }

    bool BeginIce()
    {
        if(Owner.CurrentCombatAnima<CaelumUtilityStaff.ActorCostPerSecond(Owner)/TICRATE || !Equip(Staff))return false;
        Phase=ICE_EMISSION;return true;
    }

    double AttackDuration(CaelumEquipmentItem item)
    {
        if(!Available(item))return -1;
        double factor=100.0/Owner.CalculateActorType4Percent(Owner.CombatDexterity
            +Owner.GetCombatArmorAttributeBonus(CaelumConstants.ATTRIBUTE_DEXTERITY));
        double gloves=Owner.CombatArmor!=null ? Owner.CombatArmor.GetWeight(CaelumConstants.ARMOR_SLOT_HANDS) : 0;
        double capacity=Owner.Mass*Owner.CalculateActorType4Percent(Owner.CombatStrength)/100.0;
        return CaelumAttackRules.Duration(factor,item.UnitWeight,gloves,capacity)/CaelumThermalEffects.Speed(Owner);
    }

    double AttackCost(bool secondary,bool charged)
    {
        if(Melee==null)return 0;
        int catalogue=CaelumCraftingRules.GetCatalogueWeaponForPlayableType(Melee.ItemType);
        double cost=secondary ? CaelumWeaponCatalogue.GetSecondaryAirCost(catalogue)
            : CaelumWeaponCatalogue.GetPrimaryAirCost(catalogue);
        return Owner.GetEffectiveAttackAir(cost)*CaelumThermalEffects.HeatCost(Owner)*CaelumAltitudeService.Effort(Owner)
            *(charged ? CaelumConstants.WEAPON_CHARGED_COST_MULTIPLIER : 1);
    }

    bool BeginMelee(bool useSecondary,bool useCharged)
    {
        if(AttackDuration(Melee)<=0 || Owner.CurrentCombatAir<AttackCost(useSecondary,useCharged) || !Equip(Melee))return false;
        Secondary=useSecondary;Charged=useCharged;
        if(useCharged)
        {
            Phase=CHARGE_PREPARATION;
            ChargeRemaining=CaelumConstants.WEAPON_CHARGE_BASE_SECONDS
                *100.0/Owner.CalculateActorType4Percent(Owner.CombatDexterity
                    +Owner.GetCombatArmorAttributeBonus(CaelumConstants.ATTRIBUTE_DEXTERITY));
        }
        else BeginMeleeCycle();
        return true;
    }

    bool BeginMeleeCycle()
    {
        double cost=AttackCost(Secondary,Charged);
        CycleDuration=AttackDuration(ActiveItem);
        if(CycleDuration<=0 || Owner.CurrentCombatAir<cost)return false;
        Phase=MELEE_CYCLE;CycleProgress=0;StrikeResolved=false;PreparedRemaining=0;
        MeleeUses++;if(Charged)ChargedUses++;return true;
    }

    double MeleeRange(bool secondary)
    {
        if(Melee==null)return 0;
        int catalogue=CaelumCraftingRules.GetCatalogueWeaponForPlayableType(Melee.ItemType);
        return secondary ? CaelumWeaponCatalogue.GetSecondaryRange(catalogue) : CaelumWeaponCatalogue.GetPrimaryRange(catalogue);
    }

    void Strike()
    {
        if(CaelumBattleCry.Active(Owner))return;
        LastStrikeDamage=LastStrikeRawDamage=0;LastStrikeCritical=false;
        if(!Available(ActiveItem))return;
        double cost=AttackCost(Secondary,Charged);
        if(Owner.CurrentCombatAir<cost)return;
        Owner.CurrentCombatAir-=cost;Owner.MarkActorCombatActivity();
        CaelumThermalEffects.RecordWeaponAction(Owner,ActiveItem.ItemType,Secondary,Charged,false);
        Owner.EnsureCombatPersonality();Owner.UpdateCombatHealthEffects();Owner.UpdateActorOffensiveStatistics();
        int catalogue=CaelumCraftingRules.GetCatalogueWeaponForPlayableType(ActiveItem.ItemType);
        double accuracy=Max(1.0,Owner.CombatPhysicalAccuracyPercent
            *(Owner.ElementalStatus!=null ? Owner.ElementalStatus.GetAccuracyMultiplier() : 1));
        double low=CaelumWeaponCatalogue.GetMinimumSpread(catalogue,ActiveItem.Tier,Owner.CurrentCombatLucidity)*100/accuracy;
        double high=CaelumWeaponCatalogue.GetMaximumSpread(catalogue,ActiveItem.Tier,Owner.CurrentCombatLucidity)*100/accuracy;
        int yawRoll=Random[CaelumSwordAccuracyYaw](-100000,100000);
        int pitchRoll=Random[CaelumSwordAccuracyPitch](-100000,100000);
        double yaw=Owner.Angle+(yawRoll<0 ? -1 : 1)*(low+(high-low)*Abs(yawRoll)/100000.0);
        double pitch=Owner.Pitch+(pitchRoll<0 ? -1 : 1)*(low+(high-low)*Abs(pitchRoll)/100000.0);
        FLineTraceData hit;
        vector3 origin=Owner.Pos+(0,0,Owner.Height/2);
        if(!Owner.LineTrace(yaw,MeleeRange(Secondary),pitch,TRF_ABSPOSITION,
            origin.Z,origin.X,origin.Y,hit) || hit.HitActor==null)return;
        let victim=CaelumCombatActor(hit.HitActor);
        if(victim==null || victim==Owner || victim.IsFriend(Owner))return;
        double chance=Clamp((CaelumWeaponCatalogue.GetCriticalChancePercent(catalogue)
            +CaelumGrowthRules.Bonus(Owner.CombatEffectiveDexterity))*CaelumPersonalityRules.Critical(Owner),0.0,100.0);
        LastStrikeCritical=Random[CaelumPhysicalCritical](0,999999)/10000.0<chance;
        LastStrikeGrade=victim.RegisterDirectionalAnatomyImpact(Owner,
            (hit.HitLocation.Z-victim.Pos.Z)/Max(0.0001,victim.Height));
        victim.RegisterPendingCriticalHit(LastStrikeCritical);
        double anatomy=victim.GetActorVulnerabilityMultiplier(LastStrikeGrade);
        if(LastStrikeCritical)anatomy*=anatomy+1;
        let model=new("CaelumWeaponModel");
        double raw=CaelumWeaponUseRules.PhysicalDamage(Secondary ? CaelumWeaponCatalogue.GetSecondaryDamage(catalogue)
            : CaelumWeaponCatalogue.GetPrimaryDamage(catalogue),model.GetTierDamageMultiplierFor(ActiveItem.Tier),
            Owner.CombatPhysicalPushMultiplier*Owner.CombatHealthPerformanceMultiplier,Charged);
        LastStrikeRawDamage=int(raw+0.5);
        Owner.ThermalBluntDelivery=(Secondary ? CaelumWeaponCatalogue.GetSecondaryDamageType(catalogue)
            : CaelumWeaponCatalogue.GetPrimaryDamageType(catalogue))==CaelumConstants.CATALOGUE_DAMAGE_BLUNT;
        LastStrikeDamage=victim.DamageMobj(Owner,Owner,Max(1,int(raw*anatomy+0.5)),'Melee',DMG_THRUSTLESS,yaw);
        Owner.ThermalBluntDelivery=false;
        if(LastStrikeDamage>0)
        {
            Owner.AddActorCombatAdrenaline(CaelumConstants.ADRENALINE_GAIN_ON_MELEE_DAMAGE);
            Owner.ApplyActorAttackPush(victim,yaw,Owner.CombatPhysicalPushMultiplier);
            CaelumWeaponUseRules.Wear(ActiveItem,LastStrikeDamage);
            Owner.A_StartSound("weapons/swordhit",CHAN_WEAPON);
        }
    }

    bool RecoverBolas()
    {
        if(Bolas==null || Bolas.bDestroyed || Bolas.Owner!=null || Owner==null
            || Owner.Distance2D(Bolas)>Owner.Radius+Bolas.Radius || !Owner.CheckSight(Bolas)
            || Bolas.Pos.Z>Owner.Pos.Z+Owner.Height || Bolas.Pos.Z+Bolas.Height<Owner.Pos.Z)return false;
        Bolas.AttachToOwner(Owner);Bolas.Equipped=false;BolasRecoveries++;return true;
    }

    void Finish()
    {
        Cancel();if(Owner!=null && Owner.health>0)Owner.SetState(Owner.SeeState);
    }

    void Tick()
    {
        if(Owner==null)return;
        if(CaelumBattleCry.Active(Owner) || !Owner.IsRuloPartyFighting() || CaelumBolas.Restrained(Owner) || CaelumBolas.Interrupted(Owner))
        {
            if(Phase!=IDLE)
            {
                Cancel();
                if(Owner.InStateSequence(Owner.CurState,Owner.FindState("ResidentToolUse")))Owner.SetState(Owner.SeeState);
            }
            return;
        }
        RecoverBolas();
        if(Phase==IDLE)return;
        if(Phase!=RECOVERY && !Available(ActiveItem)){Finish();return;}
        Owner.Vel.X=Owner.Vel.Y=0;Aim();
        if(Phase==BOLAS_PREPARATION)
        {
            PreparedTics=Min(CaelumBolasRules.PREPARE_TICS,PreparedTics+1);
            if(PreparedTics>=CaelumBolasRules.PREPARE_TICS)
            {
                if(AimBolas() && CaelumBolas.ThrowItem(Owner,ActiveItem,PreparedTics)!=null)BolasThrows++;
                Phase=RECOVERY;RecoveryTics=CaelumAttackRules.BASE_TICS;
            }
        }
        else if(Phase==ICE_EMISSION)
        {
            let victim=CaelumCombatActor(Owner.target);
            if(victim==null || victim.health<=0 || Owner.Distance2D(victim)>CaelumDemonBreathRules.Range()+victim.Radius
                || !Owner.CheckSight(victim)){Finish();return;}
            if(!CaelumUtilityStaff.Emit(Owner,ActiveItem,CaelumUtilityStaffRules.ICE)){Finish();return;}
            IcePaidTics++;
            if(victim==null || victim.ElementalStatus==null || victim.ElementalStatus.FreezeRemaining>0)Finish();
        }
        else if(Phase==CHARGE_PREPARATION)
        {
            ChargeRemaining=Max(0.0,ChargeRemaining-1.0/TICRATE);
            if(ChargeRemaining<=0)
            {
                PreparedRemaining=CaelumConstants.WEAPON_CHARGED_STATE_SECONDS;
                Phase=PREPARED;
                if(Owner.target!=null && Owner.Distance2D(Owner.target)<=MeleeRange(Secondary)+Owner.target.Radius
                    && Owner.CheckSight(Owner.target) && !BeginMeleeCycle())Finish();
            }
        }
        else if(Phase==PREPARED)
        {
            PreparedRemaining-=1.0/TICRATE;
            if(PreparedRemaining<=0){Finish();return;}
            if(Owner.target!=null && Owner.Distance2D(Owner.target)<=MeleeRange(Secondary)+Owner.target.Radius
                && Owner.CheckSight(Owner.target) && !BeginMeleeCycle())Finish();
        }
        else if(Phase==MELEE_CYCLE)
        {
            CycleProgress+=1.0/Max(1.0,CycleDuration);
            double impact=CaelumAttackRules.IsThrust(ActiveItem.ItemType,Secondary)
                ? CaelumAttackRules.THRUST_IMPACT : CaelumAttackRules.SWING_IMPACT;
            if(!StrikeResolved && CycleProgress>=impact){StrikeResolved=true;Strike();}
            if(CycleProgress>=1)Finish();
        }
        else if(Phase==RECOVERY && --RecoveryTics<=0)Finish();
    }
}
