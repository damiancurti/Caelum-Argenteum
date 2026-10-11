// #163: datos confirmados; la integridad es binaria y nunca se desgasta.
class CaelumBolasRules : Object
{
    const REVISION=2;
    const MASS_KG=1.018;
    const BRONZE_KG=0.800;
    const LENGTH_METERS=1.09;
    const PREPARE_TICS=TICRATE;
    const RESTRAINT_TICS=5*TICRATE;
    const CUT_BASE_TICS=2*TICRATE;
    const AIR_COST=6.0;
    // Registro de las capas originales; no modifica colisión ni alcance.
    const ARMS_HEIGHT=0.46;
    const LEGS_HEIGHT=0.16;
    const WRAP_WIDTH_FACTOR=2.1;
    const WRAP_HEIGHT_LIMIT=0.63;
    const SPRITE_SIZE=128.0;
    const SPIN_HZ=3.0;
    const READY_LIFT=65.0;
    const WRAP_DEPTH=0.25;

    static double Spread(int prepared)
    {
        double hi=CaelumWeaponCatalogue.GetMaximumSpread(CaelumConstants.CATALOGUE_WEAPON_JAVELIN);
        double lo=CaelumWeaponCatalogue.GetMinimumSpread(CaelumConstants.CATALOGUE_WEAPON_JAVELIN);
        return hi+(lo-hi)*Clamp(prepared/double(PREPARE_TICS),0.0,1.0);
    }

    static bool Breaks(int strength,int roll)
    {return roll<Clamp(strength,0,100)*10000;}

    static bool Cuts(int weaponType)
    {
        int id=CaelumCraftingRules.GetCatalogueWeaponForPlayableType(weaponType);
        return id>=0 && ((CaelumWeaponCatalogue.GetPrimaryDamage(id)>0
                && CaelumWeaponCatalogue.GetPrimaryDamageType(id)==CaelumConstants.CATALOGUE_DAMAGE_SLASHING)
            || (CaelumWeaponCatalogue.GetSecondaryDamage(id)>0
                && CaelumWeaponCatalogue.GetSecondaryDamageType(id)==CaelumConstants.CATALOGUE_DAMAGE_SLASHING));
    }
}

class CaelumBolas : Object play
{
    static CaelumBolasFlight Binding(Actor body)
    {
        let user=CaelumPlayer(body);let npc=CaelumCombatActor(body);
        return user!=null ? user.BolasBinding : npc!=null ? npc.BolasBinding : null;
    }

    static bool Restrained(Actor body)
    {let bind=Binding(body);return bind!=null && bind.Phase==1;}

    static void FireContact(Actor body)
    {let bind=Binding(body);if(bind!=null)bind.Resolve(true);}

    static void FireAttack(Actor body,Actor inflictor,Name mod)
    {
        let shot=CaelumActorProjectile(inflictor);
        if(mod=='Fire' || mod=='CaelumBurn' || (shot!=null && shot.CaelumElementalPayloadPrepared
            && shot.CaelumEssenceType==CaelumConstants.ESSENCE_FIRE && !shot.CaelumSecondaryElement))
            FireContact(body);
    }

    static bool Eligible(Actor body)
    {
        // Mismo dominio vivo de controles compartidos (sueño/elementos).
        // La bandera nativa de invulnerabilidad conserva su autoridad.
        return body!=null && body.health>0 && body.bSHOOTABLE && !body.bINVULNERABLE
            && (body is "CaelumPlayer" || body is "CaelumCombatActor");
    }

    static bool Interrupted(Actor body)
    {
        let user=CaelumPlayer(body);let npc=CaelumCombatActor(body);
        if(user!=null)return user.ForcedSleepTics>0 || user.LucidityPhysicalStunRemaining>0
            || user.PainImmobilizationRemaining>0 || user.CombatChannelModeActive
            || (user.ElementalStatus!=null && user.ElementalStatus.IsLightningStunned());
        return npc==null || npc.ForcedSleepTics>0 || npc.CombatLucidityPhysicalStunRemaining>0
            || (npc.ElementalStatus!=null && npc.ElementalStatus.IsLightningStunned())
            || (npc.FindState("Pain")!=null && npc.InStateSequence(npc.CurState,npc.FindState("Pain")));
    }

    static double CuttingDuration(Actor body)
    {
        double weight=-1;
        let model=new("CaelumWeaponModel");
        for(Inventory cursor=body.Inv;cursor!=null;cursor=cursor.Inv)
        {
            let item=CaelumEquipmentItem(cursor);
            if(item==null || item.InMagicBox || item.EquipmentKind!=CaelumConstants.EQUIPMENT_KIND_WEAPON
                || item.Durability<=0 || !CaelumBolasRules.Cuts(item.ItemType))continue;
            double candidate=model.GetWeightFor(item.ItemType,item.Tier,item.EquipmentSize);
            if(weight<0 || candidate<weight)weight=candidate;
        }
        let npc=CaelumCombatActor(body);let user=CaelumPlayer(body);
        if(npc!=null)
        {
            let sidearm=npc.GetPossessedSidearm();
            if(sidearm!=null && sidearm.Durability>0 && CaelumBolasRules.Cuts(sidearm.WeaponType))
            {
                double candidate=sidearm.GetWeightFor(sidearm.WeaponType,sidearm.Tier,sidearm.Size);
                if(weight<0 || candidate<weight)weight=candidate;
            }
        }
        if(weight<0)return -1;
        double factor,gloves,capacity;
        if(user!=null && user.DerivedStats!=null)
        {
            factor=user.DerivedStats.AttackDurationMultiplier;
            gloves=user.ArmorModel==null ? 0 : user.ArmorModel.GetWeight(CaelumConstants.ARMOR_SLOT_HANDS);
            capacity=user.DerivedStats.CarryCapacity;
        }
        else if(npc!=null)
        {
            factor=100.0/npc.CalculateActorType4Percent(npc.CombatDexterity
                +npc.GetCombatArmorAttributeBonus(CaelumConstants.ATTRIBUTE_DEXTERITY));
            gloves=npc.CombatArmor==null ? 0 : npc.CombatArmor.GetWeight(CaelumConstants.ARMOR_SLOT_HANDS);
            capacity=npc.Mass*npc.CalculateActorType4Percent(npc.CombatStrength)/100.0;
        }
        else return -1;
        double duration=CaelumAttackRules.Duration(factor,weight,gloves,capacity);
        return duration<=0 ? -1 : duration/CaelumAttackRules.BASE_TICS
            *CaelumBolasRules.CUT_BASE_TICS/CaelumThermalEffects.Speed(body);
    }

    static void RequestCut(Actor body)
    {
        let bind=Binding(body);
        if(bind!=null && !Interrupted(body) && CuttingDuration(body)>0)bind.Cutting=true;
    }

    static bool CanPrepare(CaelumPlayer user)
    {
        return user!=null && user.health>0 && user.player!=null && user.CharacterCreationComplete
            && user.WeaponModel!=null && user.WeaponModel.Equipped && user.DerivedStats!=null
            && user.WeaponModel.WeaponType==CaelumConstants.WEAPON_TYPE_BOLAS
            && user.player.ReadyWeapon is "CaelumBolasSelectorWeapon"
            && !user.IsPhysicallyImmobilized() && !user.CombatBlockModeActive
            && !user.EquipmentMenuOpen && !user.CraftingMenuOpen && !user.CreationWizardOpen
            && (user.player.PendingWeapon==null || user.player.PendingWeapon==WP_NOCHANGE
                || user.player.PendingWeapon==user.player.ReadyWeapon);
    }

    static void Update(CaelumPlayer user)
    {
        if(Restrained(user))
        {
            if((user.player.cmd.buttons&BT_RELOAD)!=0 && (user.player.oldbuttons&BT_RELOAD)==0)RequestCut(user);
            user.Vel.X=0;user.Vel.Y=0;if(user.bNOGRAVITY)user.Vel.Z=0;
        }
        if(!CanPrepare(user) || (user.player.cmd.buttons&BT_ALTATTACK)==0
            || (user.BolasPreparedItem!=0 && user.BolasPreparedItem!=user.ActiveWeaponItemId))
        {user.BolasPreparedTics=0;user.BolasPreparedItem=0;return;}
        user.BolasPreparedItem=user.ActiveWeaponItemId;
        user.BolasPreparedTics=Min(CaelumBolasRules.PREPARE_TICS,user.BolasPreparedTics+1);
    }

    static bool Throw(CaelumPlayer user)
    {
        if(!CanPrepare(user) || user.EquippedWeaponCooldownRemaining>0)return false;
        let item=user.FindNativeEquipmentItemById(user.ActiveWeaponItemId);
        if(item==null || item.Owner!=user || !item.Equipped || item.InMagicBox
            || item.ItemType!=CaelumConstants.WEAPON_TYPE_BOLAS || item.Durability<=0)return false;
        double cost=CaelumBolasRules.AIR_COST*user.DerivedStats.AirConsumptionMultiplier*CaelumThermalEffects.HeatCost(user);
        if(user.CurrentAir<cost)return false;
        user.UpdateLucidityAccuracyEffects();user.UpdateCrouchEffects();
        double movement=user.IsCrouching ? user.CrouchAccuracyMultiplier
            : user.IsRunningOnGround() ? CaelumConstants.RUNNING_ACCURACY_MULTIPLIER : 1;
        double spread=CaelumBolasRules.Spread(user.BolasPreparedTics)
            *100/Max(1.0,user.EffectivePhysicalAccuracyPercent*movement);
        double yaw=user.Angle+Random[CaelumBolasYaw](-100000,100000)/100000.0*spread;
        double pitch=user.Pitch+Random[CaelumBolasPitch](-100000,100000)/100000.0*spread;
        vector3 origin=user.Pos+(Cos(user.Angle)*32,Sin(user.Angle)*32,user.Height*0.65);
        let flight=CaelumBolasFlight(Actor.Spawn("CaelumBolasFlight",origin,NO_REPLACE));
        if(flight==null)return false;
        flight.SourceItem=item;flight.Target=user;flight.SourceMap=level.MapName;
        user.RemoveInventory(item);item.Equipped=false;item.AttachToOwner(flight);
        user.CurrentAir-=cost;user.UpdateAirStateEffects();user.MarkCombatActivity();user.BolasPreparedTics=0;user.BolasPreparedItem=0;
        user.WeaponModel.Equipped=false;user.ActiveWeaponItemId=0;
        user.CancelWeaponCharge();user.CancelRangedAim();
        double speed=CaelumConstants.PROJECTILE_SPEED_SLOW*Sqrt(Max(0.0,user.DerivedStats.PhysicalPushMultiplier));
        flight.Angle=yaw;flight.Vel=(Cos(yaw)*Cos(pitch),Sin(yaw)*Cos(pitch),-Sin(pitch))*speed;
        user.BolasReleaseUntil=level.time+CaelumAttackRules.BASE_TICS;
        user.RefreshCarriedInventorySummary();user.ApplyCharacterProfile();user.PersistCharacterState();
        // Sin selector alternativo inmediato: deja visible la salida y recuperación.
        return true;
    }
}

// El mismo actor posee la única pieza nativa durante vuelo y sujeción.
class CaelumBolasFlight : Actor
{
    CaelumEquipmentItem SourceItem;
    Actor Victim;
    Actor Ropes[2];
    Actor BackRopes[2];
    int Phase,Remaining,Revision,ExpiryRolls;
    bool Cutting;
    double CutProgress;
    String SourceMap;
    Default { +MISSILE +NOBLOCKMONST Radius 4; Height 4; Damage 0; Gravity 1; }
    States
    {
    Spawn: CBOL B -1; Stop;
    Death: TNT1 A 0 {let bola=CaelumBolasFlight(self);if(bola!=null)bola.Resolve(false);} Stop;
    Attached: TNT1 A -1; Stop;
    }

    override int SpecialMissileHit(Actor victim)
    {
        if(victim==Target)return MHIT_PASS;
        if(Phase!=0)return MHIT_PASS;
        if(!CaelumBolas.Eligible(victim) || CaelumBolas.Restrained(victim))
        {Resolve(false);return MHIT_PASS;}
        AttachVictim(victim);return MHIT_PASS;
    }

    void AttachVictim(Actor body)
    {
        if(Phase!=0 || !CaelumBolas.Eligible(body))return;
        Victim=body;Phase=1;Remaining=CaelumBolasRules.RESTRAINT_TICS;Revision=CaelumBolasRules.REVISION;
        Vel=(0,0,0);bMISSILE=false;bNOGRAVITY=true;bNOCLIP=true;bINVISIBLE=true;
        SetStateLabel("Attached");
        let user=CaelumPlayer(body);let npc=CaelumCombatActor(body);
        if(user!=null)
        {
            user.BolasBinding=self;user.CancelRangedReload();user.CancelWeaponCharge();
            user.CancelCombatBlockMode();user.CancelPendingStaffCast(false);user.PhysicalAttackPending=false;
            CaelumUtilityStaff.EndEmission(user);
        }
        if(npc!=null)npc.BolasBinding=self;
        let bull=CaelumBull(body);if(bull!=null)bull.StopBullCharge();
        body.Vel.X=0;body.Vel.Y=0;if(body.bNOGRAVITY)body.Vel.Z=0;
        UpdateVisuals();
    }

    void UpdateVisuals()
    {
        if(Victim==null)return;
        SetOrigin(Victim.Pos,false);
        // Sólo cambia el desplazamiento de dibujo, nunca posición ni colisión.
        // La profundidad sigue la vista local también al rodear al personaje.
        let camera=players[consoleplayer].camera;
        vector2 depth=camera!=null ? AngleToVector(camera.Angle,CaelumBolasRules.WRAP_DEPTH) : (0,0);
        for(int i=0;i<2;i++)
        {
            vector3 point=Victim.Pos+(0,0,Victim.Height*(i==0 ? CaelumBolasRules.ARMS_HEIGHT : CaelumBolasRules.LEGS_HEIGHT));
            if(Ropes[i]==null)Ropes[i]=Spawn("CaelumBolasRopes",point,NO_REPLACE);
            if(Ropes[i]==null)continue;
            Ropes[i].master=self;Ropes[i].SetOrigin(point,false);Ropes[i].frame=i;
            double scale=Min(Victim.Radius*CaelumBolasRules.WRAP_WIDTH_FACTOR,Victim.Height*CaelumBolasRules.WRAP_HEIGHT_LIMIT)/CaelumBolasRules.SPRITE_SIZE;
            Ropes[i].Scale=(scale,scale);
            Ropes[i].WorldOffset=Victim.WorldOffset-(depth.X,depth.Y,0);
            // Las partidas de revisión 1 conservan sus capas delanteras;
            // las dos posteriores ausentes se añaden una sola vez.
            if(BackRopes[i]==null)BackRopes[i]=Spawn("CaelumBolasRopes",point,NO_REPLACE);
            if(BackRopes[i]!=null)
            {
                BackRopes[i].master=self;BackRopes[i].SetOrigin(point,false);BackRopes[i].frame=i+2;
                BackRopes[i].Scale=(scale,scale);
                BackRopes[i].WorldOffset=Victim.WorldOffset+(depth.X,depth.Y,0);
            }
        }
        Revision=CaelumBolasRules.REVISION;
    }

    void Resolve(bool broken)
    {
        if(Phase==2)return;
        Phase=2;
        let user=CaelumPlayer(Victim);let npc=CaelumCombatActor(Victim);
        if(user!=null && user.BolasBinding==self)user.BolasBinding=null;
        if(npc!=null && npc.BolasBinding==self)npc.BolasBinding=null;
        for(int i=0;i<2;i++)if(Ropes[i]!=null){Ropes[i].Destroy();Ropes[i]=null;}
        for(int i=0;i<2;i++)if(BackRopes[i]!=null){BackRopes[i].Destroy();BackRopes[i]=null;}
        let item=SourceItem;SourceItem=null;
        if(item!=null)
        {
            RemoveInventory(item);
            if(broken)item.Destroy();
            else
            {
                item.BecomePickup();item.SetOrigin(Victim!=null ? Victim.Pos : Pos,false);
                item.Vel=(0,0,0);item.bDROPPED=true;item.bSPECIAL=true;
                item.UpdateWorldSprite();
            }
        }
        Destroy();
    }

    override void Tick()
    {
        if(Phase==1)
        {
            if(Victim==null || Victim.bDestroyed || Victim.health<=0){Resolve(false);return;}
            UpdateVisuals();
            if(CaelumBolas.Interrupted(Victim)){Cutting=false;CutProgress=0;}
            else
            {
                if(Victim is "CaelumCombatActor" && !Cutting)CaelumBolas.RequestCut(Victim);
                if(Cutting)
                {
                    double duration=CaelumBolas.CuttingDuration(Victim);
                    if(duration<=0){Cutting=false;CutProgress=0;}
                    else CutProgress+=1.0/duration;
                    if(CutProgress>=1){Resolve(true);return;}
                }
            }
            if(--Remaining<=0)
            {
                let user=CaelumPlayer(Victim);let npc=CaelumCombatActor(Victim);
                int strength=user!=null && user.Attributes!=null ? user.Attributes.Strength : npc!=null ? npc.CombatStrength : 0;
                ExpiryRolls++;
                Resolve(CaelumBolasRules.Breaks(strength,Random[CaelumBolasBreak](0,999999)));return;
            }
        }
        Super.Tick();
    }

    override void OnDestroy()
    {
        // Cualquier retiro temprano conserva la pieza salvo resolución explícita.
        if(Phase!=2)Resolve(false);
        Super.OnDestroy();
    }
}

class CaelumBolasRopes : Actor
{
    Default { +NOINTERACTION +NOGRAVITY }
    States { Spawn: CBND A -1; Stop; }
    override void Tick(){Super.Tick();if(master==null || master.bDestroyed)Destroy();}
}

class CaelumBolasSelectorWeapon : CaelumPhysicalSelectorWeapon
{
    Default { Weapon.SelectionOrder 102; Weapon.SlotNumber 1; }
    override int GetCaelumWeaponType(){return CaelumConstants.WEAPON_TYPE_BOLAS;}
}

class CaelumBolasFrames : Actor
{
    States (Actor,Weapon,Overlay)
    {
    Ready: DBOL A -1; Stop;
    Spin: DBOL B -1; Stop;
    Release: DBOL C -1; Stop;
    Recover: TNT1 A -1; Stop;
    Pickup: CBOL A -1; Stop;
    }
}
