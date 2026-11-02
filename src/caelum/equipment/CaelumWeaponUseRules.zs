// #195: fórmulas comunes a la activación del jugador y de herramientas NPC.
class CaelumWeaponUseRules : Object
{
    static double PhysicalDamage(double baseDamage,double tier,double power,bool charged)
    {
        return baseDamage*tier*power
            *(charged ? CaelumConstants.WEAPON_CHARGED_DAMAGE_MULTIPLIER : 1);
    }
    static double WearChance(double damage)
    {
        double unit=CaelumConstants.ARMOR_ABSORBED_DAMAGE_PER_GUARANTEED_DURABILITY;
        return Clamp((damage-int(damage/unit)*unit)
            /CaelumConstants.ARMOR_DAMAGE_PER_DURABILITY_CHANCE_PERCENT,0.0,100.0);
    }
    static int WearLoss(double damage,int durability,double roll,bool limit=true)
    {
        if(damage<=0 || durability<=0)return 0;
        int loss=int(damage/CaelumConstants.ARMOR_ABSORBED_DAMAGE_PER_GUARANTEED_DURABILITY)
            +(roll<WearChance(damage) ? 1 : 0);
        return limit?Min(durability,loss):loss;
    }
    static play int Wear(CaelumEquipmentItem item,double damage)
    {
        if(item==null || damage<=0)return 0;
        item.MigrateWeaponDurability();
        int loss=WearLoss(damage,item.Durability,Random[CaelumWeaponDurability](0,999999)/10000.0,false);
        loss=Min(item.Durability,CaelumAwakening.Wear(item,loss));
        item.Durability-=loss;return loss;
    }
}
