// #188: Dureza biológica, independiente de vida máxima y masa de colisión.
class CaelumToughnessRules : Object
{
    const MAGICAL_FACTOR = 0.5;
    const STATUS_REVISION = 1;

    static double NaturalMass(Actor receiver)
    {
        let user=CaelumPlayer(receiver);
        if(user!=null && user.DerivedStats!=null)return Max(0.0,user.DerivedStats.BaseMass);
        return receiver!=null ? Max(0.0,double(receiver.Mass)) : 0.0;
    }

    static play double Effective(Actor receiver)
    {
        let user=CaelumPlayer(receiver);
        if(user!=null)return user.Attributes!=null ? Max(0.0,user.Attributes.Toughness) : 0.0;
        let npc=CaelumCombatActor(receiver);
        return npc!=null ? Max(0.0,npc.CombatToughness
            +npc.GetCombatArmorAttributeBonus(CaelumConstants.ATTRIBUTE_TOUGHNESS)) : 0.0;
    }

    static clearscope double Reduction(double naturalMass,double toughness,bool magical=false)
    {
        return Max(0.0,naturalMass)*CaelumGrowthRules.Multiplier(Max(0.0,toughness),3)
            *(magical ? MAGICAL_FACTOR : 1.0);
    }

    static clearscope double AfterDefenses(double damage,double naturalMass,double toughness,bool magical=false)
    { return Max(0.0,damage-Reduction(naturalMass,toughness,magical)); }

    static play double Apply(Actor receiver,double damage,bool magical=false)
    { return AfterDefenses(damage,NaturalMass(receiver),Effective(receiver),magical); }

    static clearscope double RetainedFraction(double before,double after)
    { return before>0.0 ? after/before : 1.0; }

    static clearscope double StatusResponse(double toughness)
    { return 1.0-CaelumGrowthRules.Bonus(Max(0.0,toughness))/100.0; }

    static clearscope bool IsSustained(Name mod)
    { return mod=='CaelumElementalDOT' || mod=='CaelumDiseaseDOT'; }

    // El impacto desgasta la parte absorbida por la pieza, aunque Dureza
    // termine anulando la pérdida de vida. Usa las reglas de desgaste existentes.
    static play int ImpactWear(CaelumArmorModel armor,int slot,double absorbed,double multiplier=1.0)
    {
        if(armor==null || armor.Durability[slot]<=0 || absorbed<=0)return 0;
        double eligible=absorbed*Max(0.0,multiplier);
        int loss=int(eligible/CaelumConstants.ARMOR_ABSORBED_DAMAGE_PER_GUARANTEED_DURABILITY);
        double remainder=eligible-loss*CaelumConstants.ARMOR_ABSORBED_DAMAGE_PER_GUARANTEED_DURABILITY;
        double chance=Clamp(remainder/CaelumConstants.ARMOR_DAMAGE_PER_DURABILITY_CHANCE_PERCENT,0.0,100.0);
        if(Random[CaelumImpactArmorDurability](0,999999)/10000.0<chance)loss++;
        loss=Min(loss,armor.Durability[slot]);armor.Durability[slot]-=loss;
        return loss;
    }
}
