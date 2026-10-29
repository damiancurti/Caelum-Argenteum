// Datos ya aceptados para el jugador, compartidos ahora con actores armados.
class CaelumRangedRules : Object
{
    // Mínimo nativo de crouch del jugador; no añade otro perfil de altura.
    const CROUCH_HEIGHT_FACTOR=0.5;
    // Altura del cañón en el atlas CAGC, medida desde el pivote de apoyo.
    const CROUCH_MUZZLE_PIXELS=116.0/1.909090909;

    static clearscope double LaunchHeight(Actor owner,int type)
    {
        let user=CaelumPlayer(owner);let soldier=CaelumPortDefender(owner);
        bool crouched=user!=null ? user.player!=null && user.player.crouchfactor<0.75
            : soldier!=null && soldier.Carbine!=null && soldier.Carbine.Crouched;
        return type==CaelumConstants.WEAPON_TYPE_CARBINE && crouched
            ? owner.Scale.Y*CROUCH_MUZZLE_PIXELS : owner.Height*0.65;
    }
    static bool IsFirearm(int type)
    {return type==CaelumConstants.WEAPON_TYPE_CARBINE || type==CaelumConstants.WEAPON_TYPE_SHOTGUN;}

    static int MagazineCapacity(int type)
    {
        if(type==CaelumConstants.WEAPON_TYPE_SHOTGUN)return CaelumShotgunRules.CAPACITY;
        if(type==CaelumConstants.WEAPON_TYPE_CARBINE)return 10;
        if(type==CaelumConstants.WEAPON_TYPE_CROSSBOW)return 20;
        if(type==CaelumConstants.WEAPON_TYPE_LONGBOW)return 50;
        return 0;
    }
    static double BaseReloadSeconds(int type)
    {
        if(type==CaelumConstants.WEAPON_TYPE_SHOTGUN)return BaseReloadSeconds(CaelumConstants.WEAPON_TYPE_CARBINE);
        if(type==CaelumConstants.WEAPON_TYPE_CARBINE || type==CaelumConstants.WEAPON_TYPE_CROSSBOW)return 5;
        if(type==CaelumConstants.WEAPON_TYPE_LONGBOW)return 3;
        return 0;
    }
    static double TierCriticalMultiplier(int tier)
    {return tier<=1 ? 1.0 : tier==2 ? 1.6 : 2.5;}

    static play CaelumCarbineProjectile Fire(Actor owner,CaelumWeaponModel weapon,
        double damage,bool critical,double push,double yaw,double pitch,double criticalChance=-1,double criticalRoll=0)
    {
        if(CaelumBattleCry.Active(owner))return null;
        Name type="CaelumCarbineProjectile";
        if(weapon.WeaponType==CaelumConstants.WEAPON_TYPE_SHOTGUN)type="CaelumShotgunPellet";
        else if(weapon.WeaponType==CaelumConstants.WEAPON_TYPE_LONGBOW)type="CaelumArrowProjectile";
        else if(weapon.WeaponType==CaelumConstants.WEAPON_TYPE_CROSSBOW)type="CaelumBoltProjectile";
        vector3 origin=owner.Pos+(Cos(yaw)*32,Sin(yaw)*32,LaunchHeight(owner,weapon.WeaponType));
        let projectile=CaelumCarbineProjectile(Actor.Spawn(type,origin,NO_REPLACE));
        if(projectile==null)return null;
        projectile.Target=owner;projectile.Angle=yaw;projectile.Pitch=pitch;
        projectile.ConfigureCaelumTravelDistance(weapon.GetRangedRangeFor(weapon.WeaponType));
        double speed=IsFirearm(weapon.WeaponType) ? CaelumConstants.WEAPON_CARBINE_PROJECTILE_SPEED : CaelumConstants.PROJECTILE_SPEED_VERY_FAST;
        vector3 direction=(Cos(pitch)*Cos(yaw),Cos(pitch)*Sin(yaw),-Sin(pitch));
        projectile.Vel=direction.Unit()*speed;
        projectile.StoreCaelumAttackResult(Max(0,int(damage+0.5)),true,critical,false,push);
        if(criticalChance>=0)projectile.StoreCaelumCriticalRoll(criticalChance,criticalRoll);
        projectile.StoreCaelumWeaponWearIdentity(weapon.WeaponType,weapon.Tier,weapon.Size);
        return projectile;
    }
}

// Sólo cambia sprite/frame mundial. No reemplaza estados de dolor/muerte,
// traducciones, escala corporal ni sprites de primera persona.
class CaelumCarbineWorld : Object play
{
    static void Restore(Actor owner)
    {
        if((owner.sprite==owner.GetSpriteIndex("CAGN") || owner.sprite==owner.GetSpriteIndex("CAGC") || owner.sprite==owner.GetSpriteIndex("SHGW")) && owner.CurState!=null)
        {owner.sprite=owner.CurState.sprite;owner.frame=owner.CurState.Frame;}
    }
    static void Apply(Actor owner,bool held,bool moving,bool firing,double reload,double total)
    {
        if(owner.CurState==null)return;
        if(!held || owner.health<=0){Restore(owner);return;}
        bool pose=owner.InStateSequence(owner.CurState,owner.SpawnState)
            || owner.InStateSequence(owner.CurState,owner.SeeState);
        let user=CaelumPlayer(owner);
        bool shotgun=user!=null && user.WeaponModel!=null && user.WeaponModel.WeaponType==CaelumConstants.WEAPON_TYPE_SHOTGUN;
        let soldier=CaelumPortDefender(owner);
        bool crouched=soldier!=null && soldier.Carbine!=null && soldier.Carbine.Crouched;
        if(user!=null)
        {
            if(CaelumRestState.IsActive(user) || user.ForcedSleepTics>0)return;
            pose=pose || user.InStateSequence(user.CurState,user.FindState("Run"))
                || user.InStateSequence(user.CurState,user.FindState("IdleBreathing"))
                || user.InStateSequence(user.CurState,user.FindState("CrouchIdle"))
                || user.InStateSequence(user.CurState,user.FindState("CrouchWalk"))
                || user.InStateSequence(user.CurState,user.MissileState);
            // La pose de puntería ya está agachada. Al desplazarse conserva
            // la marcha anterior comprimida, sin inventar otro ciclo de pasos.
            crouched=!moving && user.player!=null && user.player.crouchfactor<0.75;
            if(pose)user.crouchsprite=crouched && !shotgun ? owner.GetSpriteIndex("CAGC") : 0;
        }
        if(!pose)return;
        owner.sprite=owner.GetSpriteIndex(shotgun ? "SHGW" : crouched ? "CAGC" : "CAGN");
        owner.frame=crouched && !shotgun ? (reload>0 ? (reload>total*0.5 ? 2 : 3) : firing ? 1 : 0)
            : reload>0 ? (reload>total*0.5 ? 4 : 5) : firing ? 3 : moving ? 1+(level.time/4)%2 : 0;
    }
}

// Los defensores conservan su reserva infinita; otros portadores pueden
// contar sus cartuchos reales, incluidos los que referencia el cargador.
// Cargador, recarga, desgaste y último disparo se serializan con el actor.
class CaelumCityCarbine : Object play
{
    int Revision,Magazine,NextShotTic,ShotCount,ReloadCount;
    double ReloadRemaining,ReloadTotal;
    bool Held;
    bool Crouched,Aiming;
    double StandingHeight,LastAccuracyPercent,LastCriticalChance,LastMinimumSpread,LastMaximumSpread;
    int LastAimTic;
    CaelumPortDefender Holder;
    vector3 PreviousPosition;
    CaelumWeaponModel Weapon;
    bool FiniteReserve;

    int Reserve()
    {let ammo=Holder==null?null:Holder.FindInventory('CaelumCarbineAmmo');return ammo==null?0:Max(0,ammo.Amount);}
    int LoadCount()
    {int capacity=Weapon==null?0:CaelumRangedRules.MagazineCapacity(Weapon.WeaponType);return FiniteReserve?Min(capacity,Reserve()):capacity;}
    bool HasAmmunition(){return !FiniteReserve || Reserve()>0;}
    void CommitRound()
    {
        Magazine=Max(0,Magazine-1);ShotCount++;
        if(FiniteReserve && Holder!=null)
        {Holder.TakeInventory('CaelumCarbineAmmo',1);CaelumActorMaintenance.InventoryChanged(Holder);}
    }

    void Initialize(CaelumPortDefender owner)
    {
        Holder=owner;
        if(!Crouched)StandingHeight=owner.Height;
        if(Revision>=2)return;
        if(Revision>=1){Revision=2;return;}
        Weapon=new("CaelumWeaponModel");Weapon.InitializeDefaults();
        Weapon.WeaponType=CaelumConstants.WEAPON_TYPE_CARBINE;Weapon.Tier=CaelumPortData.EQUIPMENT_TIER;
        Weapon.Durability=Weapon.GetMaximumDurability();Weapon.Equipped=true;
        Magazine=CaelumRangedRules.MagazineCapacity(Weapon.WeaponType);
        Held=true;Revision=2;PreviousPosition=owner.Pos;
    }
    bool SetCrouched(CaelumPortDefender owner,bool wanted)
    {
        Initialize(owner);
        if(!wanted)Aiming=false;
        if(Crouched==wanted)return true;
        // A_SetSize(testpos=true) conserva la caja anterior si no cabe: no
        // atravesar techos, cuerpos ni plataformas al intentar incorporarse.
        if(!owner.A_SetSize(-1,StandingHeight*(wanted ? CaelumRangedRules.CROUCH_HEIGHT_FACTOR : 1),true))return false;
        Crouched=wanted;return true;
    }
    void Select(bool carbine)
    {
        Held=carbine && Weapon!=null && Weapon.Durability>0;
        if(!Held)
        {ReloadRemaining=0;ReloadTotal=0;Aiming=false;if(Holder!=null)SetCrouched(Holder,false);}
        if(Weapon!=null)Weapon.Equipped=Held;
    }
    void Tick(CaelumPortDefender owner)
    {
        Initialize(owner);
        bool moving=(owner.Pos.XY-PreviousPosition.XY).Length()>0.01;
        bool interrupted=(CaelumBolas.Restrained(owner) || CaelumTelekinesisRules.Held(owner)) || owner.health<=0 || owner.ForcedSleepTics>0 || owner.CombatLucidityPhysicalStunRemaining>0
            || owner.InStateSequence(owner.CurState,owner.FindState("Pain")) || !Held;
        if(interrupted)
        {ReloadRemaining=0;ReloadTotal=0;}
        bool keep=Crouched && !interrupted && (!moving || LastAimTic==level.time)
            && owner.RecoveryPhase==0 && InRange(owner,owner.target);
        if(!keep)SetCrouched(owner,false);
        if(ReloadRemaining>0)
        {
            double progress=moving ? CaelumConstants.RELOAD_MOVEMENT_AND_PROGRESS_MULTIPLIER : 1;
            CaelumThermalEffects.RecordReloadProgress(owner,Min(ReloadRemaining,progress/TICRATE),ReloadTotal);
            ReloadRemaining=Max(0.0,ReloadRemaining-progress/TICRATE);
            owner.Speed*=CaelumConstants.RELOAD_MOVEMENT_AND_PROGRESS_MULTIPLIER;
            if(ReloadRemaining<=0){Magazine=LoadCount();ReloadCount++;}
        }
        PreviousPosition=owner.Pos;
        CaelumCarbineWorld.Apply(owner,Held,moving,ShotCount>0 && level.time<NextShotTic,ReloadRemaining,ReloadTotal);
    }
    bool InRange(CaelumPortDefender owner,Actor victim)
    {
        if(Weapon==null || Weapon.Durability<=0 || victim==null || victim.health<=0 || !victim.bShootable || !owner.CarbineTarget(victim) || !HasAmmunition())return false;
        vector3 origin=owner.Pos+(0,0,CaelumRangedRules.LaunchHeight(owner,Weapon.WeaponType));
        return (victim.Pos+(0,0,victim.Height/2)-origin).Length()<=Weapon.GetRangedRangeFor(Weapon.WeaponType) && owner.CheckSight(victim);
    }
    bool Attack(CaelumPortDefender owner,Actor victim)
    {
        if(CaelumBattleCry.Active(owner))return false;
        if(owner==null || (CaelumBolas.Restrained(owner) || CaelumTelekinesisRules.Held(owner)) || owner.health<=0 || owner.ForcedSleepTics>0 || owner.CombatLucidityPhysicalStunRemaining>0
            || owner.InStateSequence(owner.CurState,owner.FindState("Pain")))return false;
        if(!InRange(owner,victim))return false;
        Initialize(owner);Select(true);owner.target=victim;owner.A_FaceTarget();owner.Vel.X=0;owner.Vel.Y=0;
        if(owner.RecoveryPhase!=0 || !SetCrouched(owner,true))return false;
        // Volver a comprobar visibilidad desde la altura física ya agachada.
        if(!InRange(owner,victim)){SetCrouched(owner,false);return false;}
        Aiming=true;LastAimTic=level.time;
        if(ReloadRemaining>0 || level.time<NextShotTic)return true;
        if(Magazine<=0)
        {
            int dexterity=owner.CombatDexterity+owner.GetCombatArmorAttributeBonus(CaelumConstants.ATTRIBUTE_DEXTERITY);
            ReloadTotal=CaelumRangedRules.BaseReloadSeconds(Weapon.WeaponType)*100/Max(1.0,owner.CalculateActorType4Percent(dexterity));
            ReloadRemaining=ReloadTotal;CaelumThermalEffects.BeginFirearmReload(owner);return true;
        }
        owner.AttackResourceWeapon=Weapon.WeaponType;owner.AttackResourceMagical=false;
        owner.AttackResourceBaseCost=CaelumWeaponCatalogue.GetPrimaryAirCost(CaelumConstants.CATALOGUE_WEAPON_CARBINE);
        owner.AttackResourceResume=owner.SeeState;
        if(!owner.HasAttackResource()){owner.WaitForAttackResource();return true;}
        owner.UpdateCombatHealthEffects();owner.UpdateActorOffensiveStatistics();
        double accuracy=CaelumCombatAim.Accuracy(owner,false,true);
        double minimum=CaelumCombatAim.CarbineMinimum(owner,Weapon.Tier,accuracy);
        double maximum=CaelumCombatAim.CarbineMaximum(owner,Weapon.Tier,accuracy);
        double spread=minimum+(maximum-minimum)*Random[CaelumCarbineSpread](0,100000)/100000.0;
        double yawOffset=Random[CaelumCarbineYaw](-100000,100000)/100000.0*spread;
        double yaw=owner.Angle+yawOffset;
        vector3 aim=victim.Pos+(0,0,victim.Height/2)-(owner.Pos+(0,0,CaelumRangedRules.LaunchHeight(owner,Weapon.WeaponType)));
        double pitchOffset=Random[CaelumCarbinePitch](-100000,100000)/100000.0*spread;
        double pitch=-VectorAngle(aim.XY.Length(),aim.Z)+pitchOffset;
        double chance=CaelumCombatAim.CarbineCritical(owner,Weapon.Tier);
        LastAccuracyPercent=accuracy;LastCriticalChance=chance;
        LastMinimumSpread=minimum;LastMaximumSpread=maximum;
        bool critical=Random[CaelumCarbineCritical](0,999999)/10000.0<chance;
        let projectile=CaelumRangedRules.Fire(owner,Weapon,Weapon.GetDamage()*owner.CombatHealthPerformanceMultiplier,critical,owner.CombatPhysicalPushMultiplier,yaw,pitch);
        if(projectile==null)return true;
        projectile.StoreSummaryAim(victim,Weapon.WeaponType,Weapon.Tier,minimum,maximum,false);
        CaelumBallistics.AimProjectile(projectile,victim.Pos+(0,0,victim.Height/2),yawOffset,pitchOffset);
        double cost=owner.GetEffectiveAttackAir(owner.AttackResourceBaseCost);
        if(!owner.TrySpendCombatAir(cost)){projectile.Destroy();owner.WaitForAttackResource();return true;}
        owner.MarkActorCombatActivity();
        CaelumThermalEffects.RecordFirearmShot(owner);
        CommitRound();NextShotTic=level.time+int(Ceil(owner.GetProfileWeaponDuration(Weapon.WeaponType)));
        owner.tics=Max(owner.tics,NextShotTic-level.time);
        owner.A_StartSound("caelum/weapons/carabine_fire",CHAN_WEAPON);return true;
    }
    void Wear(int damage)
    {
        if(Weapon==null || damage<=0)return;
        int loss=int(damage/CaelumConstants.ARMOR_ABSORBED_DAMAGE_PER_GUARANTEED_DURABILITY);
        double remainder=damage-loss*CaelumConstants.ARMOR_ABSORBED_DAMAGE_PER_GUARANTEED_DURABILITY;
        if(Random[CaelumWeaponDurability](0,999999)/10000.0<remainder/CaelumConstants.ARMOR_DAMAGE_PER_DURABILITY_CHANCE_PERCENT)loss++;
        Weapon.Durability=Max(0,Weapon.Durability-loss);
    }
}
