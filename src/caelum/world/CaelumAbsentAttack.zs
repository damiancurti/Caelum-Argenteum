// #415: descriptores de los ataques existentes del asedio. Los valores salen
// del catalogo y de las mismas fases que ejecutan los estados nativos.
class CaelumAbsentAttack : Object play
{
    enum AttackKind { NONE, MELEE, MAGIC, EXPLOSIVE, SLAM, CARBINE }
    int Kind,Weapon,Tier,Essence;
    double BaseDamage,Damage,Fire,Air,Anima,Preparation,Cycle,NativeCycleTics,Area,Accuracy,Critical;
    double Minimum,Maximum,ProjectileRadius,Penetration,Debuff,Push;
    bool SignedOffsets;
    vector3 Origin;

    bool Configure(CaelumCombatActor body,bool ranged)
    {
        Kind=NONE;Weapon=-1;Tier=1;Essence=-1;BaseDamage=Air=Anima=Area=0;
        let soldier=CaelumPortDefender(body);
        if(soldier!=null)
        {
            if(ranged && soldier.Carbine!=null && soldier.Carbine.Weapon!=null
                && soldier.Carbine.Weapon.Durability>0)
            {
                Kind=CARBINE;Weapon=CaelumConstants.WEAPON_TYPE_CARBINE;
                Tier=soldier.Carbine.Weapon.Tier;
                Air=CaelumWeaponCatalogue.GetPrimaryAirCost(CaelumConstants.CATALOGUE_WEAPON_CARBINE);
            }
            else if(soldier.Sword!=null && soldier.Sword.Durability>0)
            {
                Kind=MELEE;Weapon=CaelumConstants.WEAPON_TYPE_SWORD;Tier=soldier.Sword.Tier;
                BaseDamage=CaelumWeaponCatalogue.GetPrimaryDamage(CaelumConstants.CATALOGUE_WEAPON_SWORD);
                Air=CaelumWeaponCatalogue.GetPrimaryAirCost(CaelumConstants.CATALOGUE_WEAPON_SWORD);
            }
        }
        else if(body is 'CaelumMandinga')
        {
            Kind=ranged?MAGIC:MELEE;
            Weapon=ranged?CaelumConstants.WEAPON_TYPE_STAFF:CaelumConstants.WEAPON_TYPE_MACHETE;
            if(ranged)Essence=CaelumConstants.ESSENCE_FIRE;
            else
            {
                BaseDamage=CaelumConstants.MANDINGA_MACHETE_BASE_DAMAGE;
                Air=CaelumWeaponCatalogue.GetPrimaryAirCost(CaelumConstants.CATALOGUE_WEAPON_MACHETE);
            }
        }
        else if(body is 'CaelumZupayColossus')
        {
            Kind=ranged?EXPLOSIVE:SLAM;
            Weapon=ranged?CaelumConstants.WEAPON_TYPE_STATUETTE:-1;
            if(ranged)Essence=CaelumConstants.ESSENCE_EARTH;
            else{BaseDamage=CaelumConstants.ZUPAY_SLAM_BASE_DAMAGE;Air=CaelumAttackRules.SlamAir();}
        }
        if(Kind==NONE)return false;
        Refresh(body);
        if(Kind==SLAM)
        {
            double speed=CaelumThermalEffects.Speed(body);
            Preparation=Ceil(CaelumAttackRules.SLAM_PREPARATION_TICS/speed)/TICRATE;
            Cycle=Preparation+Ceil(CaelumAttackRules.SLAM_RECOVERY_TICS/speed)/TICRATE;
        }
        else
        {
            double tics=body.GetProfileWeaponDuration(Weapon);if(tics<=0){Kind=NONE;return false;}
            NativeCycleTics=tics;Cycle=Ceil(tics)/TICRATE;
            double fraction=Kind==CARBINE?0:Kind==EXPLOSIVE?CaelumAttackRules.ZUPAY_MAGIC_RELEASE
                :Kind==MAGIC?CaelumAttackRules.MANDINGA_MAGIC_RELEASE
                :body is 'CaelumMandinga'?CaelumAttackRules.MANDINGA_MELEE_RELEASE:CaelumAttackRules.SWING_IMPACT;
            Preparation=Ceil(tics*fraction)/TICRATE;
        }
        return true;
    }

    void Refresh(CaelumCombatActor body)
    {
        body.UpdateCombatHealthEffects();body.UpdateActorOffensiveStatistics();
        bool magic=Kind==MAGIC || Kind==EXPLOSIVE;
        SignedOffsets=true;Minimum=Maximum=ProjectileRadius=Fire=0;
        Penetration=Kind==CARBINE?0:CaelumPersonalityRules.Penetration(body.CombatPersonality);
        Critical=Clamp(magic?body.CombatMagicalCriticalChancePercent:body.CombatPhysicalCriticalChancePercent,0.0,100.0)/100.0;
        Accuracy=Clamp((magic?body.CombatMagicalAccuracyPercent:body.CombatPhysicalAccuracyPercent)
            *(Kind==SLAM?body.CombatLucidityAccuracyMultiplier:1)
            *(body.ElementalStatus!=null?body.ElementalStatus.GetAccuracyMultiplier():1),0.0,100.0)/100.0;
        Origin=body.Pos+(0,0,body.Height/2);
        if(magic)
        {
            Damage=body.CalculateActorOutgoingDamage(body.GetTierOneMagicDamage(Weapon),true);
            Anima=body.GetTierOneMagicAnimaCost(Weapon);
            Origin=body.Pos+(0,0,body.Height*CaelumAttackRules.NPC_MAGIC_LAUNCH_HEIGHT);
            ProjectileRadius=GetDefaultByType('CaelumActorSimpleElementalProjectile').Radius;
            if(body.UsesWeaponProjectileDispersion())
            {Minimum=CaelumCombatAim.MagicMinimum(body,Weapon);Maximum=Minimum*10;}
            if(Kind==EXPLOSIVE)Area=body.GetTierOneStatuetteExplosionRadius();
        }
        else if(Kind==CARBINE)
        {
            let gun=CaelumPortDefender(body).Carbine;
            Damage=Max(1,int(gun.Weapon.GetDamage()*body.CombatHealthPerformanceMultiplier+0.5));
            Accuracy=1;Critical=CaelumCombatAim.CarbineCritical(body,Tier)/100.0;
            Minimum=CaelumCombatAim.CarbineMinimum(body,Tier);Maximum=CaelumCombatAim.CarbineMaximum(body,Tier);
            SignedOffsets=false;Origin=body.Pos+(0,0,CaelumRangedRules.LaunchHeight(body,Weapon));
            ProjectileRadius=GetDefaultByType('CaelumCarbineProjectile').Radius;
        }
        else
        {
            Damage=body.CalculateActorOutgoingDamage(Max(1,BaseDamage*body.CalculateActorType1Percent(body.CombatStrength)/100.0),false);
            if(Kind==SLAM)Area=CaelumConstants.ZUPAY_SLAM_RADIUS_MAP_UNITS;
            else
            {
                Minimum=CaelumWeaponCatalogue.GetMinimumSpread(CaelumCraftingRules.GetCatalogueWeaponForPlayableType(Weapon),Tier,
                    body.CurrentCombatLucidity)*100.0/CaelumCombatAim.Accuracy(body,false);
                Maximum=Minimum*10;
                if(body is 'CaelumMandinga')Fire=body.CalculateActorOutgoingDamage(BaseDamage
                    *body.CalculateActorType1Percent(body.CombatEffectiveIntelligence)/100.0,true);
            }
        }
        Debuff=CaelumElementalStream.Power(body);
        Push=magic?body.CombatMagicalPushMultiplier:body.CombatPhysicalPushMultiplier;
    }

    bool CanPay(CaelumCombatActor body)
    {
        if(Kind==NONE)return false;
        if(Kind==MAGIC || Kind==EXPLOSIVE)return body.CurrentCombatAnima>=Anima;
        return body.CurrentCombatAir>=body.GetEffectiveAttackAir(Air)
            *CaelumThermalEffects.HeatCost(body)*CaelumAltitudeService.Effort(body);
    }

    bool Pay(CaelumCombatActor body)
    {
        if(!CanPay(body))return false;
        if(Kind==MAGIC || Kind==EXPLOSIVE)body.CurrentCombatAnima=Max(0,body.CurrentCombatAnima-Anima);
        else if(!body.TrySpendCombatAir(body.GetEffectiveAttackAir(Air)))return false;
        body.MarkActorCombatActivity();return true;
    }

    CaelumAbsentDamage Direct(CaelumCombatActor body,CaelumCombatActor victim,bool blocking=false)
    {
        let result=new('CaelumAbsentDamage');
        if(Kind==NONE || Kind==SLAM || victim==null || victim.AnatomyProfile==null)return result;
        let shape=new('CaelumAbsentAnatomy');
        shape.Build(victim,Origin,ProjectileRadius,Minimum,Maximum,SignedOffsets);
        bool magic=Kind==MAGIC || Kind==EXPLOSIVE;
        double damage=Kind==EXPLOSIVE?Max(1,int(Damage*CaelumConstants.ESSENCE_EXPLOSIVE_DIRECT_DAMAGE_RATIO+0.5)):Damage;
        damage=CaelumThermalEffects.Incoming(victim,body,body,int(damage),magic?Name('CaelumMagicTest'):Name('Melee'));
        double fire=Fire>0?CaelumThermalEffects.Incoming(victim,body,body,int(Fire),'Fire'):0;
        double hit=Accuracy*(1-Clamp(victim.EffectiveCombatEvasionChance/100.0,0.0,1.0));
        if(magic)
        {
            // Los proyectiles elementales simples actuales no entregan una
            // localizacion: la ruta nativa adopta el torso sensible sin el
            // critico localizado. La explosion conserva su critico propio.
            double total=0;for(int i=0;i<victim.AnatomyProfile.RegionCount;i++)total+=shape.Weights[i];
            result.Region(body,victim,damage,0,CaelumConstants.HIT_LOCATION_TORSO,
                CaelumConstants.VULNERABILITY_SENSITIVE_POINT,false,true,Essence,Weapon,Tier,
                Penetration,total*hit,blocking);
            if(Essence==CaelumConstants.ESSENCE_FIRE)
                result.ThermalJoules=100*Push
                    *CaelumThermalMagic.ArmorRetention(victim,CaelumConstants.ARMOR_SLOT_BODY)*total*hit;
            result.WeaponWear=0;return result;
        }
        for(int i=0;i<victim.AnatomyProfile.RegionCount;i++)
        {
            double p=shape.Weights[i]*hit;if(p<=0)continue;
            int location=victim.AnatomyProfile.GetLocation(i),grade=victim.AnatomyProfile.GetVulnerability(i);
            result.Region(body,victim,damage,fire,location,grade,false,magic,Essence,Weapon,Tier,Penetration,p*(1-Critical),blocking);
            result.Region(body,victim,damage,fire,location,grade,true,magic,Essence,Weapon,Tier,Penetration,p*Critical,blocking);
        }
        if(Kind==CARBINE)result.WeaponWear=CaelumAbsentDamage.Wear(Damage)*result.HitProbability;
        else if(!(body is 'CaelumPortDefender'))result.WeaponWear=0;
        return result;
    }

    CaelumAbsentDamage Splash(CaelumCombatActor body,CaelumCombatActor victim,vector3 origin,
        double impactProbability=1,bool blocking=false)
    {
        let result=new('CaelumAbsentDamage');
        if(Area<=0 || victim==null || (Kind!=SLAM && Kind!=EXPLOSIVE))return result;
        // A_Explode sin RADF_CIRCULAR usa la distancia al cuadrado de colision
        // en XY (GZDoom 4.14.2 GetRadiusDamage), no al cilindro circular.
        vector2 delta=victim.Pos.XY-origin.XY;
        double horizontal=Max(0,Max(Abs(delta.X),Abs(delta.Y))-victim.Radius);
        double vertical=Max(0,Max(victim.Pos.Z-origin.Z,origin.Z-victim.Pos.Z-victim.Height));
        // El golpe de suelo existente si pide XF_CIRCULAR: Distance3D entre
        // los origenes, sin descontar el radio del receptor.
        double distance=Kind==SLAM?(victim.Pos-origin).Length():Sqrt(horizontal*horizontal+vertical*vertical);
        if(distance>=Area)return result;
        bool magic=Kind==EXPLOSIVE;
        if(victim.bNoRadiusDmg)return result;
        double damage=Max(0,int(Damage*(1-distance/Area)*victim.RadiusDamageFactor));
        let thermal=CaelumThermalBody.Get(victim);
        if(thermal!=null)damage=int(damage*CaelumThermalRules.ColdAttack(thermal.Exposure,thermal.Toughness,Kind==SLAM)+0.5);
        double probability=Accuracy*impactProbability;
        result.Area(body,victim,origin,Area,damage,false,magic,Essence,Penetration,probability*(1-Critical),blocking);
        result.Area(body,victim,origin,Area,damage,true,magic,Essence,Penetration,probability*Critical,blocking);
        return result;
    }
}
