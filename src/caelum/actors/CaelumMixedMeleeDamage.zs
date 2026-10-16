// #284: dos componentes, una esquiva, un crítico y una pérdida de salud.
// El contexto sólo vive dentro de la llamada síncrona del machetazo.
class CaelumMixedMeleeDamage : Object play
{
    Actor Attacker,Victim;
    bool Critical;
    double FireDamage,FireAfterShield,FireAfterArmor,DebuffPower;
    double BeforeToughness,AfterToughness,FireDose;

    static CaelumMixedMeleeDamage ForHit(Actor victim,Actor inflictor,Actor source,Name mod)
    {
        let npc=CaelumCombatActor(source);
        if(npc==null || inflictor!=source || mod!='Melee')return null;
        let hit=npc.PendingMixedMelee;
        return hit!=null && hit.Victim==victim ? hit : null;
    }

    void PrepareFire(Actor victim)
    {
        FireDamage=CaelumThermalEffects.Incoming(victim,Attacker,Attacker,int(FireDamage),'Fire');
        FireAfterShield=FireDamage;
    }

    double BlockFire(Actor victim,double defense,Actor inflictor,Actor source)
    {
        double absorbed=FireDamage*Clamp(defense/100.0
            *CaelumPersonalityRules.Absorption(victim,true)
            *(1-CaelumPersonalityRules.AttackPenetration(inflictor,source)),0.0,1.0);
        FireAfterShield=Max(0.0,FireDamage-absorbed);
        return absorbed;
    }

    double Resolve(Actor victim,double physical,double fire)
    {
        FireAfterArmor=Max(0.0,fire);
        double retainedFire=FireAfterArmor*CaelumSealResistance.ForEssence(victim,CaelumConstants.ESSENCE_FIRE);
        BeforeToughness=Max(0.0,physical)+retainedFire;
        double weightedReduction=BeforeToughness>0
            ? CaelumToughnessRules.ActorReduction(victim,CaelumToughnessRules.Effective(victim))
                *(Max(0.0,physical)+retainedFire*CaelumToughnessRules.MAGICAL_FACTOR)/BeforeToughness : 0;
        AfterToughness=Max(0.0,BeforeToughness-weightedReduction);
        // La dosis no guarda el sello ni Arenga; cada pulso aplica sus factores.
        FireDose=BeforeToughness>0 ? FireAfterArmor*AfterToughness/BeforeToughness : 0;
        return AfterToughness;
    }

    void ApplyBurn(Actor victim,int healthBefore)
    {
        if(victim.health<=0 || victim.health>=healthBefore || AfterToughness<=0 || FireDose<=0)return;
        let status=CaelumElementalStream.Status(victim);if(status==null)return;
        double actual=healthBefore-victim.health;
        let user=CaelumPlayer(victim);
        if(user!=null)actual=CaelumRally.PayloadLoss(user,int(actual));
        else actual/=CaelumRally.PendingFactor(victim);
        double dose=FireDose*actual/AfterToughness;
        CaelumBolas.FireContact(victim);
        status.ApplyDamageOverTime(CaelumConstants.ELEMENTAL_EFFECT_BURN,
            CaelumConstants.ELEMENTAL_BASE_DURATION_SECONDS*DebuffPower,DebuffPower,
            Max(1,int(dose*CaelumConstants.ELEMENTAL_DOT_DAMAGE_RATIO*DebuffPower+0.5)),Attacker,victim);
    }
}
