// Datos de absorción aprobados en #52. Compartidos por combate y presentación.
class CaelumArmorRules : Object
{
    const PALOMO_DEFENSE = 77.0;

    // #136: sólo atraviesa la pieza equipada, nunca la defensa racial ni Dureza.
    static double WeaponBypass(int type,int tier)
    {
        if(type==CaelumConstants.WEAPON_TYPE_CARBINE)return 0.60+0.10*Clamp(tier,1,3);
        if(type==CaelumConstants.WEAPON_TYPE_SHOTGUN)return 0.50+0.10*Clamp(tier,1,3);
        return 0;
    }
    static double EquipmentRetention(Actor inflictor,Actor source=null)
    {
        if(inflictor is "CaelumCannonProjectile")return 0;
        let projectile=CaelumActorProjectile(inflictor);
        double existing=projectile!=null && projectile.CaelumWeaponWearPrepared
            ? WeaponBypass(projectile.CaelumWearWeaponType,projectile.CaelumWearWeaponTier) : 0;
        return 1-Clamp(existing+CaelumPersonalityRules.AttackPenetration(inflictor,source),0.0,1.0);
    }

    // Curva histórica del atributo, sin limitar el porcentaje a 100.
    static clearscope double ToughnessReductionPercent(double toughness)
    {
        double level = Max(0.0, toughness);
        return CaelumGrowthRules.Bonus(level);
    }

    static clearscope double TierMultiplier(int tier)
    {
        return tier >= 3 ? 2.0 : tier == 2 ? 1.5 : 1.0;
    }

    static clearscope double EquipmentDefense(int armorType, int tier, bool magical = false)
    {
        double baseDefense = 0.0;
        switch (armorType)
        {
            case CaelumConstants.ARMOR_TYPE_MAGIC: baseDefense = magical ? 30.0 : 10.0; break;
            case CaelumConstants.ARMOR_TYPE_LIGHT: baseDefense = 15.0; break;
            case CaelumConstants.ARMOR_TYPE_MEDIUM: baseDefense = 22.5; break;
            case CaelumConstants.ARMOR_TYPE_HEAVY: baseDefense = 35.0; break;
        }
        return baseDefense * TierMultiplier(tier);
    }

    static clearscope double InnateDefense(int race, bool magical = false)
    {
        switch (race)
        {
            case CaelumConstants.RACE_BEAST_MAN: return magical ? 2.5 : 12.5;
            case CaelumConstants.RACE_CAELITH: return magical ? 5.0 : 10.0;
            case CaelumConstants.RACE_GOBLIN: return magical ? 10.0 : 5.0;
            default: return 7.5;
        }
    }

    static double EquippedDefense(CaelumArmorModel armor,int slot,bool magical=false,
        Actor receiver=null,Actor inflictor=null,Actor source=null)
    {
        return armor!=null ? Clamp(armor.GetDefense(slot,magical)
            *CaelumPersonalityRules.Absorption(receiver,magical)*EquipmentRetention(inflictor,source),0.0,100.0) : 0;
    }
    static double TotalDefense(double innateDefense,CaelumArmorModel armor,int slot,bool magical=false,
        Actor inflictor=null,Actor receiver=null,Actor source=null)
    {
        return Clamp(innateDefense+EquippedDefense(armor,slot,magical,receiver,inflictor,source),0.0,100.0);
    }

    static bool IsMagical(Actor inflictor, Name mod)
    {
        // La componente física no hereda el tipo mágico de su emisor.
        if(mod=='CaelumImpact' || mod=='Crush' || mod=='CaelumWeight'
            || mod=='Melee' || mod=='Hitscan' || CaelumToughnessRules.IsSustained(mod))return false;
        let projectile = CaelumActorProjectile(inflictor);
        return mod=='Fire' || mod=='Ice' || mod=='Electric' || mod=='Lightning'
            || mod == 'CaelumMagicTest' || mod == 'CaelumTrapMagic'
            || (mod == 'Electric' && inflictor is 'CaelumChannelEffect')
            || (projectile != null && projectile.CaelumMagicalAttack);
    }
}
