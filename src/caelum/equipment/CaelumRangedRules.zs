// Datos ya aceptados para el jugador, compartidos ahora con actores armados.
class CaelumRangedRules : Object
{
    static int MagazineCapacity(int type)
    {
        if(type==CaelumConstants.WEAPON_TYPE_CARBINE)return 10;
        if(type==CaelumConstants.WEAPON_TYPE_CROSSBOW)return 20;
        if(type==CaelumConstants.WEAPON_TYPE_STANDARD_BOW || type==CaelumConstants.WEAPON_TYPE_LONGBOW)return 50;
        return 0;
    }
    static double BaseReloadSeconds(int type)
    {
        if(type==CaelumConstants.WEAPON_TYPE_CARBINE || type==CaelumConstants.WEAPON_TYPE_CROSSBOW)return 5;
        if(type==CaelumConstants.WEAPON_TYPE_STANDARD_BOW || type==CaelumConstants.WEAPON_TYPE_LONGBOW)return 3;
        return 0;
    }
    static double TierCriticalMultiplier(int tier)
    {return tier<=1 ? 1.0 : tier==2 ? 1.6 : 2.5;}

    static play CaelumCarbineProjectile Fire(Actor owner,CaelumWeaponModel weapon,
        double damage,bool critical,double push,double yaw,double pitch)
    {
        Name type="CaelumCarbineProjectile";
        if(weapon.WeaponType==CaelumConstants.WEAPON_TYPE_STANDARD_BOW || weapon.WeaponType==CaelumConstants.WEAPON_TYPE_LONGBOW)type="CaelumArrowProjectile";
        else if(weapon.WeaponType==CaelumConstants.WEAPON_TYPE_CROSSBOW)type="CaelumBoltProjectile";
        vector3 origin=owner.Pos+(Cos(yaw)*32,Sin(yaw)*32,owner.Height*0.65);
        let projectile=CaelumCarbineProjectile(Actor.Spawn(type,origin,NO_REPLACE));
        if(projectile==null)return null;
        projectile.Target=owner;projectile.Angle=yaw;projectile.Pitch=pitch;
        projectile.ConfigureCaelumTravelDistance(weapon.GetRangedRangeFor(weapon.WeaponType));
        double speed=weapon.WeaponType==CaelumConstants.WEAPON_TYPE_CARBINE ? CaelumConstants.WEAPON_CARBINE_PROJECTILE_SPEED : CaelumConstants.PROJECTILE_SPEED_VERY_FAST;
        projectile.Vel=(Cos(pitch)*Cos(yaw)*speed,Cos(pitch)*Sin(yaw)*speed,-Sin(pitch)*speed);
        projectile.StoreCaelumAttackResult(Max(1,int(damage+0.5)),true,critical,false,push);
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
        if(owner.sprite==owner.GetSpriteIndex("CAGN") && owner.CurState!=null)
        {owner.sprite=owner.CurState.sprite;owner.frame=owner.CurState.Frame;}
    }
    static void Apply(Actor owner,bool held,bool moving,bool firing,double reload,double total)
    {
        if(!held || owner.health<=0 || owner.CurState==null)return;
        bool pose=owner.InStateSequence(owner.CurState,owner.SpawnState)
            || owner.InStateSequence(owner.CurState,owner.SeeState);
        let user=CaelumPlayer(owner);
        if(user!=null)
        {
            if(CaelumRestState.IsActive(user) || user.ForcedSleepTics>0)return;
            pose=pose || user.InStateSequence(user.CurState,user.FindState("Run"))
                || user.InStateSequence(user.CurState,user.FindState("IdleBreathing"))
                || user.InStateSequence(user.CurState,user.FindState("CrouchIdle"))
                || user.InStateSequence(user.CurState,user.FindState("CrouchWalk"))
                || user.InStateSequence(user.CurState,user.MissileState);
            // Esta pose se comprime con la altura nativa al agacharse.
            if(pose)user.crouchsprite=0;
        }
        if(!pose)return;
        owner.sprite=owner.GetSpriteIndex("CAGN");
        owner.frame=reload>0 ? (reload>total*0.5 ? 4 : 5)
            : firing ? 3 : moving ? 1+(level.time/4)%2 : 0;
    }
}

// Una carabina concreta por soldado: reserva infinita sin pilas físicas.
// Cargador, recarga, desgaste y último disparo se serializan con el actor.
class CaelumCityCarbine : Object play
{
    int Revision,Magazine,NextShotTic,ShotCount,ReloadCount;
    double ReloadRemaining,ReloadTotal;
    bool Held;
    vector3 PreviousPosition;
    CaelumWeaponModel Weapon;

    void Initialize(CaelumPortDefender owner)
    {
        if(Revision>=1)return;
        Weapon=new("CaelumWeaponModel");Weapon.InitializeDefaults();
        Weapon.WeaponType=CaelumConstants.WEAPON_TYPE_CARBINE;Weapon.Tier=CaelumPortData.EQUIPMENT_TIER;
        Weapon.Durability=Weapon.GetMaximumDurability();Weapon.Equipped=true;
        Magazine=CaelumRangedRules.MagazineCapacity(Weapon.WeaponType);
        Held=true;Revision=1;PreviousPosition=owner.Pos;
    }
    void Select(bool carbine)
    {
        Held=carbine && Weapon!=null && Weapon.Durability>0;
        if(!Held){ReloadRemaining=0;ReloadTotal=0;}
        if(Weapon!=null)Weapon.Equipped=Held;
    }
    void Tick(CaelumPortDefender owner)
    {
        bool moving=(owner.Pos.XY-PreviousPosition.XY).Length()>0.01;
        bool interrupted=owner.health<=0 || owner.ForcedSleepTics>0 || owner.CombatLucidityPhysicalStunRemaining>0
            || owner.InStateSequence(owner.CurState,owner.FindState("Pain")) || !Held;
        if(interrupted)
        {ReloadRemaining=0;ReloadTotal=0;}
        if(ReloadRemaining>0)
        {
            double progress=moving ? CaelumConstants.RELOAD_MOVEMENT_AND_PROGRESS_MULTIPLIER : 1;
            CaelumThermalEffects.RecordFirearmWork(owner,Min(1.0/TICRATE,ReloadRemaining/progress),true);
            ReloadRemaining=Max(0.0,ReloadRemaining-progress/TICRATE);
            owner.Speed*=CaelumConstants.RELOAD_MOVEMENT_AND_PROGRESS_MULTIPLIER;
            if(ReloadRemaining<=0){Magazine=CaelumRangedRules.MagazineCapacity(Weapon.WeaponType);ReloadCount++;}
        }
        else if(!interrupted && ShotCount>0 && level.time<=NextShotTic)
            CaelumThermalEffects.RecordFirearmWork(owner,1.0/TICRATE,false);
        PreviousPosition=owner.Pos;
        CaelumCarbineWorld.Apply(owner,Held,moving,ShotCount>0 && level.time<NextShotTic,ReloadRemaining,ReloadTotal);
    }
    bool InRange(CaelumPortDefender owner,Actor victim)
    {
        if(Weapon==null || Weapon.Durability<=0 || victim==null || victim.health<=0 || !victim.bShootable || victim.bFriendly)return false;
        vector3 origin=owner.Pos+(0,0,owner.Height*0.65);
        return (victim.Pos+(0,0,victim.Height/2)-origin).Length()<=Weapon.GetRangedRangeFor(Weapon.WeaponType) && owner.CheckSight(victim);
    }
    bool Attack(CaelumPortDefender owner,Actor victim)
    {
        if(owner==null || owner.health<=0 || owner.ForcedSleepTics>0 || owner.CombatLucidityPhysicalStunRemaining>0
            || owner.InStateSequence(owner.CurState,owner.FindState("Pain")))return false;
        if(!InRange(owner,victim))return false;
        Select(true);owner.target=victim;owner.A_FaceTarget();owner.Vel.X=0;owner.Vel.Y=0;
        if(ReloadRemaining>0 || level.time<NextShotTic)return true;
        if(Magazine<=0)
        {
            int dexterity=owner.CombatDexterity+owner.GetCombatArmorAttributeBonus(CaelumConstants.ATTRIBUTE_DEXTERITY);
            ReloadTotal=CaelumRangedRules.BaseReloadSeconds(Weapon.WeaponType)*100/Max(1.0,owner.CalculateActorType4Percent(dexterity));
            ReloadRemaining=ReloadTotal;return true;
        }
        owner.AttackResourceWeapon=Weapon.WeaponType;owner.AttackResourceMagical=false;
        owner.AttackResourceBaseCost=CaelumWeaponCatalogue.GetPrimaryAirCost(CaelumConstants.CATALOGUE_WEAPON_CARBINE);
        owner.AttackResourceResume=owner.SeeState;
        if(!owner.HasAttackResource()){owner.WaitForAttackResource();return true;}
        owner.UpdateCombatHealthEffects();owner.UpdateActorOffensiveStatistics();
        double accuracy=Max(1.0,owner.CombatPhysicalAccuracyPercent*owner.CombatLucidityAccuracyMultiplier
            *(owner.ElementalStatus==null ? 1.0 : owner.ElementalStatus.GetAccuracyMultiplier()));
        double minimum=CaelumWeaponCatalogue.GetMinimumSpread(CaelumConstants.CATALOGUE_WEAPON_CARBINE)*100/accuracy;
        double maximum=CaelumWeaponCatalogue.GetMaximumSpread(CaelumConstants.CATALOGUE_WEAPON_CARBINE)*100/accuracy;
        double spread=minimum+(maximum-minimum)*Random[CaelumCarbineSpread](0,100000)/100000.0;
        double yaw=owner.Angle+Random[CaelumCarbineYaw](-100000,100000)/100000.0*spread;
        vector3 aim=victim.Pos+(0,0,victim.Height/2)-(owner.Pos+(0,0,owner.Height*0.65));
        double pitch=-VectorAngle(aim.XY.Length(),aim.Z)+Random[CaelumCarbinePitch](-100000,100000)/100000.0*spread;
        double chance=Clamp(CaelumWeaponCatalogue.GetCriticalChancePercent(CaelumConstants.CATALOGUE_WEAPON_CARBINE)
            *CaelumRangedRules.TierCriticalMultiplier(Weapon.Tier)
            +Max(0.0,owner.CombatPhysicalCriticalChancePercent-CaelumConstants.BASE_CRITICAL_CHANCE_PERCENT),0.0,100.0);
        bool critical=Random[CaelumCarbineCritical](0,999999)/10000.0<chance;
        let projectile=CaelumRangedRules.Fire(owner,Weapon,Weapon.GetDamage()*owner.CombatHealthPerformanceMultiplier,critical,owner.CombatPhysicalPushMultiplier,yaw,pitch);
        if(projectile==null)return true;
        double cost=owner.GetEffectiveAttackAir(owner.AttackResourceBaseCost);
        if(!owner.TrySpendCombatAir(cost)){projectile.Destroy();owner.WaitForAttackResource();return true;}
        owner.MarkActorCombatActivity();
        Magazine--;ShotCount++;NextShotTic=level.time+int(Ceil(owner.GetProfileWeaponDuration(Weapon.WeaponType)));
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
