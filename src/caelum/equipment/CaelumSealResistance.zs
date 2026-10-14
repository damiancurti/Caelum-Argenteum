// #261: factor de HP del único sello equipado; nunca se acumula al recalcular.
class CaelumSealResistance : Object
{
    const MATCHED_FACTOR = 0.5;
    const QUINTESSENCE_FACTOR = 0.85;

    static CaelumEquipmentItem Equipped(Actor owner)
    {
        if(owner==null)return null;
        for(Inventory item=owner.Inv;item!=null;item=item.Inv)
        {
            let seal=CaelumEquipmentItem(item);
            if(seal!=null && seal.Equipped && !seal.InMagicBox
                && seal.EquipmentKind==CaelumConstants.EQUIPMENT_KIND_SEAL)
                return seal;
        }
        return null;
    }

    static clearscope double Factor(int sealType,int essence)
    {
        if(essence<0 || essence>=CaelumConstants.ELEMENT_TYPE_COUNT)return 1;
        if(sealType==CaelumConstants.SEAL_QUINTESSENCE)return QUINTESSENCE_FACTOR;
        return sealType==essence ? MATCHED_FACTOR : 1;
    }

    static clearscope double ReductionPercent(int sealType)
    {
        // La descripción de Quintaesencia usa una familia protegida, no su identidad.
        int element=sealType==CaelumConstants.SEAL_QUINTESSENCE
            ? CaelumConstants.ESSENCE_FIRE : sealType;
        return 100*(1-Factor(sealType,element));
    }

    static clearscope String DescriptionKey(int sealType)
    {
        switch(sealType)
        {
            case CaelumConstants.SEAL_FIRE:return "CA_SEAL_RESIST_FIRE";
            case CaelumConstants.SEAL_WATER:return "CA_SEAL_RESIST_WATER";
            case CaelumConstants.SEAL_EARTH:return "CA_SEAL_RESIST_EARTH";
            case CaelumConstants.SEAL_AIR:return "CA_SEAL_RESIST_AIR";
            default:return "CA_SEAL_RESIST_QUINTESSENCE";
        }
    }

    static double ForEssence(Actor owner,int essence)
    {
        let seal=Equipped(owner);
        return Factor(seal!=null ? seal.ItemType : -1,essence);
    }

    static int Essence(Actor inflictor,Name mod)
    {
        // Un impacto físico del mismo proyectil no hereda su carga elemental.
        // Los pulsos de estado ya incorporan su factor antes de acumular HP.
        if(mod=='CaelumImpact' || mod=='Crush' || mod=='CaelumWeight' || mod=='CaelumPressure'
            || mod=='Melee' || mod=='Hitscan' || mod=='Bullet' || mod=='Drowning'
            || CaelumToughnessRules.IsSustained(mod))return -1;
        let shot=CaelumActorProjectile(inflictor);
        if(shot!=null && shot.CaelumMagicalAttack && shot.CaelumElementalPayloadPrepared)
            return shot.CaelumEssenceType;
        if(mod=='Fire' || mod=='Light')return CaelumConstants.ESSENCE_FIRE;
        if(mod=='Water' || mod=='Ice')return CaelumConstants.ESSENCE_WATER;
        if(mod=='Earth' || mod=='Poison')return CaelumConstants.ESSENCE_EARTH;
        if(mod=='Air' || mod=='Wind' || mod=='Electric' || mod=='Lightning')return CaelumConstants.ESSENCE_WIND;
        if(mod=='Quintessence')return CaelumConstants.ESSENCE_QUINTESSENCE;
        // La magia sin identidad elemental no se deduce de su color ni emisor.
        return -1;
    }

    static int HealthDamage(Actor owner,Actor inflictor,double damage,Name mod)
    {
        if(damage<=0)return int(damage);
        return Max(0,int(damage*ForEssence(owner,Essence(inflictor,mod))+0.5));
    }

    static play int PayloadDamage(CaelumPlayer owner,Actor inflictor,double beforeSeal,int actualLoss,Name mod)
    {
        // La dosis nace antes del sello: su factor se cobrará en cada pulso.
        // Conservar la retención nativa observada y su cuantización de HP.
        int retained=HealthDamage(owner,inflictor,beforeSeal,mod);
        if(retained<=0 || actualLoss<=0)return 0;
        if(owner.health==1 && CaelumTutorialSafety.Protects(owner))return actualLoss;
        return Max(0,int(actualLoss*double(Max(0,int(beforeSeal+0.5)))/retained+0.5));
    }
}
