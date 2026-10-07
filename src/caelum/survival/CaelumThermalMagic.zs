// Julios independientes del daño: la Dureza sustractiva y la vulnerabilidad
// anatómica no son filtros energéticos. Sólo la intercepción y la pieza real.
class CaelumThermalMagic : Object play
{
    static double ArmorRetention(Actor body,int slot)
    {
        let user=CaelumPlayer(body);let npc=CaelumCombatActor(body);
        double defense=user!=null && user.ArmorModel!=null ? user.ArmorModel.GetDefense(slot,true)
            : npc!=null && npc.CombatArmor!=null ? npc.CombatArmor.GetDefense(slot,true) : 0;
        return 1-Clamp(defense/100.0,0.0,1.0);
    }

    static double AreaRetention(Actor body,int regionMask=-1)
    {
        let user=CaelumPlayer(body);let npc=CaelumCombatActor(body);
        let anatomy=user!=null ? user.AnatomyProfile : npc!=null ? npc.AnatomyProfile : null;
        if(anatomy==null)return ArmorRetention(body,CaelumConstants.ARMOR_SLOT_BODY);
        double total=0,count=0;
        int resolution=CaelumThermalData.SURFACE_SAMPLES;
        for(int z=0;z<resolution;z++)for(int side=0;side<resolution;side++)
        {
            int region=anatomy.FindRegion((z+0.5)/resolution,(side+0.5)/resolution);
            if(region<0 || (regionMask & (1<<region))==0)continue;
            total+=ArmorRetention(body,Clamp(anatomy.RegionLocation[region]-1,0,3));count++;
        }
        return count>0 ? total/count : 1;
    }

    static void Impact(Actor body,Actor inflictor,double retention)
    {
        let shot=CaelumActorProjectile(inflictor);
        if(shot==null || !shot.CaelumMagicalAttack || !shot.CaelumElementalPayloadPrepared)return;
        double sign=shot.CaelumEssenceType==CaelumConstants.ESSENCE_FIRE && !shot.CaelumSecondaryElement ? 1
            : shot.CaelumEssenceType==CaelumConstants.ESSENCE_WATER && shot.CaelumSecondaryElement ? -1 : 0;
        if(sign==0 || CaelumThermalBody.Get(body,true)==null)return;
        for(int i=0;i<shot.ThermalRecipients.Size();i++)if(shot.ThermalRecipients[i]==body)return;
        shot.ThermalRecipients.Push(body);
        CaelumThermalService.Impulse(body,sign*100.0*shot.CaelumPushMultiplier*Clamp(retention,0.0,1.0));
    }

    static void Continuous(Actor body,double watts,double seconds)
    {
        let thermal=CaelumThermalBody.Get(body,true);
        if(thermal==null || body.health<=0)return;
        double joules=watts*Max(0.0,seconds)*AreaRetention(body);
        CaelumThermalService.Impulse(body,joules);
        thermal.AbsorbedImpactJoules-=joules;
        thermal.AbsorbedContinuousJoules+=joules;
    }
}
