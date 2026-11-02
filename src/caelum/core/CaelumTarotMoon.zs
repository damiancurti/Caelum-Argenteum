// Las ilusiones conservan copias privadas; ninguna identidad material sale de ellas.
class CaelumMoonEquipment : CaelumEquipmentItem
{
    CaelumTarotClone Illusion;
    bool Awakened;
    override bool TryPickup(in out Actor toucher)
    {return toucher==Illusion && Super.TryPickup(toucher);}
    override Inventory CreateTossable(int amount){return null;}
    override void Tick()
    {
        if(Illusion==null || Illusion.bDestroyed){Destroy();return;}
        Super.Tick();
    }
}

class CaelumMoonHead : Actor
{
    void UpdateVisual()
    {
        let body=CaelumTarotClone(master);
        if(body==null || body.Look==null){Destroy();return;}
        let look=body.Look;
        bInvisible=body.bInvisible || look.Race==CaelumConstants.RACE_BEAST_MAN;
        if(bInvisible)return;
        SetOrigin(body.Pos,true);Prev=body.Prev;Angle=body.Angle;Scale=body.Scale;
        WorldOffset=body.WorldOffset;FloorClip=body.FloorClip;
        sprite=CaelumAppearance.HeadSprite(look.Race,look.Sex,look.SkinTone,look.Face,look.HairStyle,look.HairColor);
        int group;vector2 offset;
        [group,offset]=CaelumAppearanceDetailsRegistry.Anchor(look.Sex,body.Gloves,body.VisualPose);
        frame=group;SpriteOffset=(offset.X*Scale.X,offset.Y*Scale.Y);
    }
    override void Tick(){Super.Tick();UpdateVisual();}
    Default {+NOBLOCKMAP +NOINTERACTION +NOGRAVITY}
    States {Spawn:TNT1 A -1;Stop;}
}

class CaelumMoonState : Inventory
{
    int Revision;
    CaelumTarotClone Bodies[2];
    void End()
    {for(int i=0;i<2;i++){let body=Bodies[i];Bodies[i]=null;if(body!=null)body.Destroy();}}
    override void PreTravelled(){End();}
    override void OnDestroy(){End();Super.OnDestroy();}
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}

class CaelumTarotClone : CaelumFolkloreCombatActor
{
    int Revision,RemainingTics,VisualPose,LastMotionTic;
    CaelumMoonState Binding;
    CaelumPlayer Caster;
    CaelumCharacterProfile Look;
    CaelumMoonHead Head;
    bool Gloves,StrongFists;
    Array<Inventory> Copies;
    Array<CaelumActorProjectile> Shots;
    void RegisterShot(CaelumActorProjectile shot)
    {for(int i=Shots.Size()-1;i>=0;i--)if(Shots[i]==null)Shots.Delete(i);Shots.Push(shot);}

    override int GetArmorRace(){return Look!=null?Look.Race:CaelumConstants.RACE_HUMAN;}
    override CaelumWeaponModel GetPossessedSidearm()
    {return Companion!=null && Companion.Loadout!=null?Companion.Loadout.Tools.GetSidearm():null;}

    CaelumMoonEquipment CopyPiece(CaelumEquipmentItem source)
    {
        let item=CaelumMoonEquipment(Spawn('CaelumMoonEquipment',Pos,NO_REPLACE));
        if(item==null)return null;
        item.Illusion=self;item.Awakened=CaelumAwakening.Factor(source)>1;
        item.EquipmentKind=source.EquipmentKind;item.ItemType=source.ItemType;
        item.ArmorSlot=source.ArmorSlot;item.Tier=source.Tier;item.EquipmentSize=source.EquipmentSize;
        item.Durability=source.Durability;item.EssenceType=source.EssenceType;item.UnitWeight=source.UnitWeight;
        item.ThermalWaterKg=source.ThermalWaterKg;
        item.ContaminationState=source.ContaminationState!=null?source.ContaminationState.Copy():null;
        item.Equipped=true;item.PickupDataInitialized=item.AcquisitionResolved=true;
        item.SizePolicy=CaelumEquipmentRules.FIXED_SIZE;item.SizePolicyRevision=CaelumEquipmentRules.SIZE_POLICY_REVISION;
        item.AttachToOwner(self);item.AwakeningHalfWear=source.AwakeningHalfWear;Copies.Push(item);return item;
    }

    void Initialize(CaelumPlayer user,CaelumMoonState binding,int duration)
    {
        Revision=CaelumMajorArcanaData.MOON_REVISION;Caster=user;self.Binding=binding;RemainingTics=duration;
        master=user;SetFriendPlayer(user.player);Angle=user.Angle;Mass=user.Mass;
        DamageMultiply=user.DamageMultiply*CaelumMajorArcanaData.MOON_POWER;
        MeleeRange=user.MeleeRange;StrongFists=user.FindInventory('PowerStrength')!=null;
        A_SetSize(user.DerivedStats.ActorRadius,user.DerivedStats.ActorHeight);
        Look=new('CaelumCharacterProfile');Look.CopyFrom(user.CharacterProfile);
        CombatPersonality=new('CaelumCharacterProfile');CombatPersonality.CopyFrom(Look);
        CombatPersonalityRevision=GetApprovedPersonalityRevision();
        ClearCombatArmorToBaseClothing();
        let a=user.Attributes;
        InitializeCombatProfile(a.Strength,a.Toughness,a.Constitution,a.Agility,a.Dexterity,a.Resilience,
            a.Charisma,a.Empathy,a.Eloquence,a.Intelligence,a.Patience,a.Insight);
        CombatBaseSpeed=CaelumConstants.GZDOOM_BASE_MAX_WALK_SPEED*CalculateActorType4Percent(CombatAgility)/100;
        Companion=new('CaelumCompanionBond');Companion.Body=self;
        Companion.Loadout=new('CaelumCompanionLoadout');let loadout=Companion.Loadout;
        loadout.Initialize(self);loadout.ManualWeapon=true;
        user.SyncActiveModelsToNativeInventory();
        user.RepairActiveEquipmentItemReferences();
        for(Inventory cursor=user.Inv;cursor!=null;cursor=cursor.Inv)
        {
            let source=CaelumEquipmentItem(cursor);
            if(source==null || !source.Equipped || source.InMagicBox)continue;
            if(source.EquipmentKind==CaelumConstants.EQUIPMENT_KIND_WEAPON && source.ItemId!=user.ActiveWeaponItemId)continue;
            let item=CopyPiece(source);if(item==null)continue;
            int slot=item.ArmorSlot;
            switch(item.EquipmentKind)
            {
                case CaelumConstants.EQUIPMENT_KIND_ARMOR:
                    if(slot<0 || slot>=4)break;
                    loadout.Armor[slot]=item;CombatArmor.SourceItem[slot]=item;
                    CombatArmor.ArmorType[slot]=item.ItemType;CombatArmor.Tier[slot]=item.Tier;
                    CombatArmor.Size[slot]=item.EquipmentSize;CombatArmor.Durability[slot]=item.Durability;
                    CombatArmor.ContaminationState[slot]=item.ContaminationState;break;
                case CaelumConstants.EQUIPMENT_KIND_CLOTHING:
                    if(slot>=0 && slot<4){loadout.Clothing[slot]=item;loadout.ClothingManaged[slot]=true;}break;
                case CaelumConstants.EQUIPMENT_KIND_WEAPON:
                    loadout.SelectedWeapon=item;loadout.Tools.Melee=item;break;
                case CaelumConstants.EQUIPMENT_KIND_SHIELD:
                    loadout.ShieldItem=item;loadout.Shield=new('CaelumShieldModel');loadout.Shield.InitializeDefaults();
                    loadout.Shield.ShieldType=item.ItemType;loadout.Shield.Tier=item.Tier;loadout.Shield.Size=item.EquipmentSize;
                    loadout.Shield.Durability=item.Durability;loadout.Shield.ContaminationState=item.ContaminationState;
                    loadout.Shield.Equipped=true;loadout.Shield.SourceItem=item;break;
                case CaelumConstants.EQUIPMENT_KIND_AMULET:loadout.Amulet=item;break;
                case CaelumConstants.EQUIPMENT_KIND_SEAL:loadout.Seal=item;break;
            }
        }
        // Attributes ya incluye la joyería del personaje; no volver a sumarla.
        if(loadout.SelectedWeapon!=null && CaelumRangedRules.MagazineCapacity(loadout.SelectedWeapon.ItemType)>0)
        {
            int type=loadout.SelectedWeapon.ItemType;
            Name ammunition=CaelumInventoryService.GetAmmunitionClassName(null,CaelumRangedRules.AmmoType(type));
            for(Inventory source=user.Inv;source!=null;source=source.Inv)
                if(source.GetClassName()==ammunition && source.Amount>0 && !CaelumContainerRules.Boxed(source))
                {
                    let copy=Inventory(Spawn(source.GetClass(),Pos,NO_REPLACE));
                    if(copy!=null){copy.Amount=source.Amount;copy.AttachToOwner(self);Copies.Push(copy);}
                }
            loadout.Ranged=new('CaelumCompanionRanged');loadout.Ranged.Loadout=loadout;
            loadout.Ranged.Magazine[loadout.Ranged.Slot(type)]=user.GetRangedMagazineCount(type);
        }
        RecalculateCombatStatistics();
        CombatMaximumHealth=Max(1,int(user.DerivedStats.MaximumHealth*CaelumMajorArcanaData.MOON_POWER));
        health=Max(1,Min(CombatMaximumHealth,int(Max(0,user.health)*CaelumMajorArcanaData.MOON_POWER)));
        CurrentCombatAnima=Min(MaximumCombatAnima,user.CurrentAnima);
        CurrentCombatAir=Min(MaximumCombatAir,user.CurrentAir);
        CurrentCombatAdrenaline=Min(MaximumCombatAdrenaline,user.CurrentAdrenaline);
        CurrentCombatLucidity=user.CurrentLucidity;
        Gloves=CaelumAppearanceHands.HasGloves(user);
        Head=CaelumMoonHead(Spawn('CaelumMoonHead',Pos,NO_REPLACE));if(Head!=null)Head.master=self;
        CaelumActorMaintenance.InventoryChanged(self);UpdateCombatHealthEffects();UpdateVisual();
    }

    void UpdateVisual()
    {
        if(Look==null || CurState==null)return;
        VisualPose=CaelumAppearance.PoseFor(CurState.sprite,CurState.Frame);
        let loadout=Companion!=null?Companion.Loadout:null;
        bool moving=level.time-LastMotionTic<CaelumConstants.PRISONER_WALK_STATE_TICS;
        if(InStateSequence(CurState,SeeState) && !moving)VisualPose=0;
        if(loadout!=null && loadout.SelectedWeapon!=null && CaelumRangedRules.IsFirearm(loadout.SelectedWeapon.ItemType))
        {
            let ranged=loadout.Ranged;
            int picture=ranged!=null && ranged.ReloadRemaining>0 ? (ranged.ReloadRemaining>ranged.ReloadTotal/2?4:5)
                : ranged!=null && ranged.Cooldown>0?3:moving?1+(level.time/4)%2:0;
            VisualPose=CaelumAppearance.PoseFor(CaelumAppearance.RegisteredSprite(
                loadout.SelectedWeapon.ItemType==CaelumConstants.WEAPON_TYPE_SHOTGUN?"SourceSHGW":"SourceCAGN"),picture);
        }
        if(loadout!=null && loadout.Magic!=null && loadout.Magic.Pending!=null)VisualPose=11;
        if(Companion!=null && Companion.Loadout!=null && Companion.Loadout.Tools.Phase==CaelumResidentTools.MELEE_CYCLE)
            VisualPose=Companion.Loadout.Tools.CycleProgress<Companion.Loadout.Tools.CycleDuration/2?9:10;
        sprite=CaelumAppearance.SpriteFor(Look.Race,Look.Sex,Look.BeastForm,Look.SkinTone,VisualPose,Gloves);
        frame=VisualPose%26;Scale=CaelumAppearance.ScaleFor(Look.Race,Look.Sex,Look.BeastForm,Height,Gloves);
        if(Head!=null)Head.UpdateVisual();
    }
    void AdvanceEffect()
    {
        if(Caster!=null && Caster.SessionIdentityPending)return;
        if(Caster==null || Binding==null || --RemainingTics<=0){Destroy();return;}
    }
    override void Tick()
    {
        AdvanceEffect();if(bDestroyed)return;
        if(CurState!=null){sprite=CurState.sprite;frame=CurState.Frame;}
        vector3 before=Pos;Super.Tick();if((Pos.XY-before.XY).Length()>0.01)LastMotionTic=level.time;
        if(!bDestroyed)UpdateVisual();
    }
    action void A_MoonChase()
    {
        let clone=CaelumTarotClone(self);if(clone==null || clone.Companion==null)return;
        clone.target=CaelumVisualPerception.Acquire(clone,clone.target);
        // Completar la observación visible antes de perseguir un ruido anterior.
        // El candidato todavía no es un objetivo identificado ni se sigue oculto.
        let evidence=CaelumVisualPerception.Evidence(clone);
        if(clone.target==null && evidence.VisibleNow
            && CaelumVisualPerception.Opponent(clone,evidence.Subject)
            && CaelumVisualPerception.CanSee(clone,evidence.Subject))
        {clone.Angle=clone.AngleTo(evidence.Subject);clone.Vel.X=clone.Vel.Y=0;return;}
        if(clone.target!=null && clone.Companion.Loadout.TryAttack())return;
        if(clone.Companion.Loadout.SelectedWeapon==null && clone.target!=null
            && CaelumVisualPerception.Identify(clone,clone.target) && clone.CheckMeleeRange()
            && clone.CurrentCombatAir>=clone.GetEffectiveAttackAir(CaelumAttackRules.NaturalAir())
                *CaelumThermalEffects.HeatCost(clone)*CaelumAltitudeService.Effort(clone))
        {clone.SetStateLabel("Melee");return;}
        clone.ThermalChase(null,null);
    }
    action void A_MoonFistStart()
    {
        let body=CaelumTarotClone(self);
        if(body==null || !body.TrySpendCombatAir(body.GetEffectiveAttackAir(CaelumAttackRules.NaturalAir())))
        {SetStateLabel("See");return;}
        CaelumNoise.Emit(body,CaelumNoiseData.SWING);
    }
    action void A_MoonFistImpact()
    {
        let body=CaelumTarotClone(self);
        if(body==null || CaelumBolas.Interrupted(body) || !CaelumVisualPerception.Identify(body,body.target))return;
        body.A_CaelumFacePerceivedTarget();
        double direction=body.Angle+CaelumUnarmedWeapon.DirectionOffset();
        double distance=body.MeleeRange+MELEEDELTA;
        double aim=body.AimLineAttack(direction,distance,null,0,ALF_CHECK3D);
        FTranslatedLineTarget hit;
        body.LineAttack(direction,distance,aim,CaelumUnarmedWeapon.RollDamage(body.StrongFists),
            'Melee',"CaelumSilentDetectionPuff",LAF_ISMELEEATTACK,hit);
        if(hit.linetarget!=null)CaelumNoise.Emit(body,CaelumNoiseData.IMPACT);
    }
    override void Die(Actor source,Actor inflictor,int flags,Name mod){Destroy();}
    override void OnDestroy()
    {
        if(Binding!=null)for(int i=0;i<2;i++)if(Binding.Bodies[i]==self)Binding.Bodies[i]=null;
        if(Head!=null)Head.Destroy();
        if(Companion!=null && Companion.Loadout!=null)Companion.Loadout.Tools.Cancel();
        for(int i=0;i<Shots.Size();i++)if(Shots[i]!=null)Shots[i].Destroy();
        Shots.Clear();
        for(int i=0;i<Copies.Size();i++)if(Copies[i]!=null)
        {
            let flight=CaelumBolasFlight(Copies[i].Owner);
            if(flight!=null){flight.Resolve(true);continue;}
            if(Copies[i]!=null)Copies[i].Destroy();
        }
        Copies.Clear();Super.OnDestroy();
    }
    Default {Tag "$CA_TAROT_MOON_CLONE";Health 1;Radius 16;Height 56;Mass 80;PainChance 0;+ISMONSTER +FRIENDLY +SOLID +SHOOTABLE -COUNTKILL}
    States
    {
        Spawn:DOID A 1;Goto See;
        See:DOWK AB 4 A_MoonChase;Loop;
        ResidentToolUse:DOMI K 1;Loop;
        Melee:
            DOMI C CaelumUnarmedWeapon.WINDUP_TICS A_MoonFistStart;
            DOMI F CaelumUnarmedWeapon.WINDUP_TICS A_MoonFistImpact;
            DOMI G CaelumUnarmedWeapon.RECOVERY_TICS;
            DOMI H CaelumUnarmedWeapon.WINDUP_TICS;
            DOMI I CaelumUnarmedWeapon.RECOVERY_TICS;
            Goto See;
        Pain:DOMI B 4;Goto See;
        Death:TNT1 A 0;Stop;
    }
}

class CaelumTarotMoon : Object play
{
    static clearscope CaelumMoonState View(CaelumPlayer user)
    {return user!=null?CaelumMoonState(user.FindInventory('CaelumMoonState')):null;}
    static CaelumPlayer Commander(Actor body)
    {let clone=CaelumTarotClone(body);return clone!=null?clone.Caster:null;}
    static bool Start(CaelumPlayer user,int duration)
    {
        if(user==null || user.CharacterProfile==null || user.DerivedStats==null || duration<=0)return false;
        let binding=View(user);if(binding==null)binding=CaelumMoonState(user.GiveInventoryType('CaelumMoonState'));
        if(binding==null)return false;
        binding.End();binding.Revision=CaelumMajorArcanaData.MOON_REVISION;
        int count=0;
        // Búsqueda geométrica acotada alrededor del lanzador, con su colisión real.
        for(int side=0;side<2;side++)for(int step=0;step<8;step++)
        {
            double facing=user.Angle+(side==0?90:-90)+step*45;
            double distance=user.Radius+user.DerivedStats.ActorRadius+1;
            vector3 point=user.Pos+(Cos(facing)*distance,Sin(facing)*distance,0);
            if(!CaelumTarotJustice.Fits(user,point))continue;
            let body=CaelumTarotClone(Actor.Spawn('CaelumTarotClone',point,NO_REPLACE));if(body==null)continue;
            if(!user.CheckSight(body)){body.Destroy();continue;}
            body.Initialize(user,binding,duration);binding.Bodies[side]=body;count++;break;
        }
        CaelumMajorWorldEvents.TimeSourcesChanged();return count>0;
    }
    static bool Swap(CaelumPlayer user,CaelumTarotClone body)
    {
        if(user==null || body==null || body.Caster!=user || body.health<=0
            || !CaelumMajorTargets.Visible(user,body) || CaelumJusticeLink.Bound(user) || CaelumJusticeLink.Bound(body))return false;
        let record=user.GetPersistentCharacterState(false);
        if(!CaelumTarotLoadout.Passive(record,18) || !CaelumTarotService.ValidUser(user)
            || CaelumRacialAbilityRules.Interrupted(user) || CaelumRacialAbilityRules.MenuBlocked(user)
            || user.CraftingTaskActive || user.StaffCastPending)return false;
        vector3 first=user.Pos,second=body.Pos;double angle=user.Angle,other=body.Angle;
        // Ignorar solamente los dos cuerpos intercambiados durante la prueba; nunca telefrag.
        bool userSolid=user.bSolid,cloneSolid=body.bSolid;user.bSolid=body.bSolid=false;
        bool safe=CaelumTarotJustice.Fits(user,second) && CaelumTarotJustice.Fits(body,first);
        user.bSolid=userSolid;body.bSolid=cloneSolid;
        if(!safe)return false;
        CaelumTarotJustice.Move(user,second,angle);CaelumTarotJustice.Move(body,first,other);return true;
    }
    static bool Input(CaelumPlayer user)
    {
        let binding=View(user);if(binding==null || (binding.Bodies[0]==null && binding.Bodies[1]==null))return false;
        let clone=CaelumTarotClone(CaelumMajorTargets.Aim(user));
        return clone!=null && Swap(user,clone);
    }
}
