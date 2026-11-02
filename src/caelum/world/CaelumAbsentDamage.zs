// #415: expectativas por impacto. No lanza proyectiles, consume azar ni
// modifica recursos durante la fase simultanea de evaluacion.
class CaelumAbsentDamage : Object play
{
    double Life,ArmorWear[4],ShieldWear,WeaponWear,HitProbability,Lucidity;
    double FireDose,ThermalJoules;
    double DamagingHitProbability;

    static double Wear(double absorbed)
    {
        absorbed=Max(0,absorbed);
        double whole=Floor(absorbed/CaelumConstants.ARMOR_ABSORBED_DAMAGE_PER_GUARANTEED_DURABILITY);
        double remainder=absorbed-whole*CaelumConstants.ARMOR_ABSORBED_DAMAGE_PER_GUARANTEED_DURABILITY;
        return whole+Clamp(remainder/CaelumConstants.ARMOR_DAMAGE_PER_DURABILITY_CHANCE_PERCENT/100.0,0.0,1.0);
    }

    static double Equipped(CaelumCombatActor victim,int slot,bool magic,int weapon,int tier,double penetration)
    {
        if(victim.CombatArmor==null)return 0;
        double retention=1-Clamp(CaelumArmorRules.WeaponBypass(weapon,tier)+penetration,0.0,1.0);
        return Clamp(victim.CombatArmor.GetDefense(slot,magic)
            *CaelumPersonalityRules.Absorption(victim,magic)*retention,0.0,100.0)/100.0;
    }

    static double Defense(CaelumCombatActor victim,int slot,bool magic,int weapon,int tier,double penetration)
    {return Clamp(victim.GetInnateArmorDefense(magic)/100.0+Equipped(victim,slot,magic,weapon,tier,penetration),0.0,1.0);}

    static double Shield(CaelumCombatActor victim,bool magic,double penetration,bool blocking)
    {
        let soldier=CaelumPortDefender(victim);
        if(!blocking || soldier==null || soldier.Shield==null || soldier.Shield.Durability<=0)return 0;
        int kind=magic?CaelumConstants.SHIELD_DAMAGE_MAGICAL:CaelumConstants.SHIELD_DAMAGE_PHYSICAL;
        return Clamp(soldier.Shield.GetDefense(kind)/100.0
            *CaelumPersonalityRules.Absorption(victim,magic)*(1-penetration),0.0,1.0);
    }

    // Cuantizar cada rama normal/critica antes de promediar: Dureza es una
    // resta con suelo cero, por lo que no conmuta con el promedio del dano.
    void Region(CaelumCombatActor source,CaelumCombatActor victim,double damage,double fire,
        int location,int natural,bool critical,bool magic,int essence,int weapon,int tier,
        double penetration,double probability,bool blocking)
    {
        if(probability<=0 || victim==null || victim.health<=0)return;
        int slot=victim.GetArmorSlotForLocation(location);
        int effective=victim.GetEffectiveActorVulnerability(natural,location);
        double anatomy=victim.GetActorVulnerabilityMultiplier(effective);
        if(critical)anatomy*=anatomy+1;
        double block=Shield(victim,magic,penetration,blocking);
        double fireBlock=Shield(victim,true,penetration,blocking);
        ShieldWear+=Wear(damage*block+fire*fireBlock)*probability;
        double incoming=damage*(1-block)*anatomy;
        double incomingFire=fire*(1-fireBlock)*anatomy;
        double physical=incoming*(1-Defense(victim,slot,magic,weapon,tier,penetration));
        double afterFire=incomingFire*(1-Defense(victim,slot,true,weapon,tier,penetration));
        double retainedFire=afterFire*CaelumSealResistance.ForEssence(victim,CaelumConstants.ESSENCE_FIRE);
        double before=physical+retainedFire;
        double reduction=CaelumToughnessRules.ActorReduction(victim,CaelumToughnessRules.Effective(victim),magic);
        if(fire>0 && before>0)
            reduction=CaelumToughnessRules.ActorReduction(victim,CaelumToughnessRules.Effective(victim))
                *(physical+retainedFire*CaelumToughnessRules.MAGICAL_FACTOR)/before;
        double after=Max(0,before-reduction);
        int whole=Max(0,int(after*CaelumSealResistance.ForEssence(victim,essence)+0.5));
        int loss=NativeDamage(victim,source,whole,magic?Name('CaelumMagicTest'):Name('Melee'));
        Life+=loss*probability;
        if(loss>0)DamagingHitProbability+=probability;
        WeaponWear+=Wear(Min(loss,victim.health))*probability;
        HitProbability+=probability;
        ArmorWear[slot]+=Wear(incoming*Equipped(victim,slot,magic,weapon,tier,penetration)
            +incomingFire*Equipped(victim,slot,true,weapon,tier,penetration))*probability;
        if(fire>0 && before>0 && after>0 && loss>0)
            FireDose+=afterFire*after/before*loss/after*probability;
        if(loss>0 && natural==CaelumConstants.VULNERABILITY_CRITICAL_POINT)
            Lucidity+=CaelumConstants.CRITICAL_POINT_BASE_LUCIDITY_LOSS
                *(1-Defense(victim,slot,magic,weapon,tier,penetration))
                *(critical?victim.GetActorVulnerabilityMultiplier(effective)+1:1)
                *victim.GetActorPainLucidityMultiplier()*probability;
    }

    static int NativeDamage(CaelumCombatActor victim,Actor source,int damage,Name mod)
    {
        if(damage<=0 || (victim.IsTarotDeity() && !CaelumUnifiedTarot.Active(CaelumPlayer(source)))
            || victim.bInvulnerable || victim.bNoDamage || victim.bSpectral
            || (!victim.bShootable && !victim.bVulnerable)
            || !CaelumRedemption.AllowsDamage(source,victim,mod))return 0;
        int retained=victim.GetModifiedDamage(mod,damage,true,source,source,DMG_NO_ARMOR);
        if(retained>0)retained=victim.ApplyDamageFactor(mod,retained);
        double previous=victim.RallyDamageFactor;
        victim.RallyDamageFactor=CaelumRally.DamageFactor(victim,source)*CaelumSupportMagic.DamageFactor(victim,source);
        if(retained>=0)retained=victim.TakeSpecialDamage(source,source,retained,mod);
        victim.RallyDamageFactor=previous;
        return Max(0,retained);
    }

    void Impact(Actor source,CaelumCombatActor victim,double received,double deltaSpeed,
        vector3 normal,CaelumImpactArea area)
    {
        if(victim==null || victim.DisableCaelumImpactContacts || area==null || received<=0)return;
        double absorption=victim.ImpactAbsorptionSpeed(deltaSpeed,CaelumConstants.IMPACT_KIND_ENVIRONMENT,normal);
        double retained=deltaSpeed>0?Max(0,deltaSpeed-absorption)/deltaSpeed:1;
        double joules=received*retained*retained;
        double innate=Clamp(victim.GetInnateArmorDefense()/100.0,0.0,1.0);
        double total=area.TotalArea>0?joules*area.NeutralArea/area.TotalArea*(1-innate):joules*(1-innate);
        double head=0,wearBySlot[4];
        if(area.TotalArea>0 && victim.AnatomyProfile!=null)
            for(int r=0;r<victim.AnatomyProfile.RegionCount;r++)
            {
                double weight=area.RegionArea[r]/area.TotalArea;if(weight<=0)continue;
                int location=victim.AnatomyProfile.GetLocation(r),natural=victim.AnatomyProfile.GetVulnerability(r);
                int slot=victim.GetArmorSlotForLocation(location);
                double multiplier=victim.GetActorVulnerabilityMultiplier(victim.GetEffectiveActorVulnerability(natural,location));
                double defense=Defense(victim,slot,false,-1,1,0);
                total+=joules*weight*multiplier*(1-defense);
                wearBySlot[slot]+=joules*weight*multiplier*Equipped(victim,slot,false,-1,1,0);
                if(natural==CaelumConstants.VULNERABILITY_CRITICAL_POINT)
                    head+=CaelumConstants.CRITICAL_POINT_BASE_LUCIDITY_LOSS*weight*(1-defense);
            }
        double after=CaelumToughnessRules.Apply(victim,total);
        Life=NativeDamage(victim,source,Max(0,int(after+0.5)),'CaelumImpact');
        for(int i=0;i<4;i++)ArmorWear[i]=Wear(wearBySlot[i]);
        if(after>0)Lucidity=Min(victim.CurrentCombatLucidity,head);
        HitProbability=1;
        DamagingHitProbability=Life>0?1:0;
    }

    void Area(CaelumCombatActor source,CaelumCombatActor victim,vector3 origin,double radius,
        double incoming,bool critical,bool magic,int essence,double penetration,double probability,bool blocking)
    {
        if(probability<=0 || incoming<=0 || victim==null || victim.AnatomyProfile==null)return;
        int mask=victim.AnatomyProfile.GetExplosionTouchedRegionMask(victim,origin,radius);
        if(mask==0)return;
        double block=Shield(victim,magic,penetration,blocking);
        ShieldWear+=Wear(incoming*block)*probability;incoming*=1-block;
        double total=0,headLoss=0;
        for(int r=0;r<victim.AnatomyProfile.RegionCount;r++)
        {
            if(!(mask&(1<<r)))continue;
            int location=victim.AnatomyProfile.GetLocation(r),natural=victim.AnatomyProfile.GetVulnerability(r);
            int slot=victim.GetArmorSlotForLocation(location);
            int effective=victim.GetEffectiveActorVulnerability(natural,location);
            double multiplier=victim.GetActorVulnerabilityMultiplier(effective);
            double anatomy=critical?multiplier*(multiplier+1):multiplier;
            double damage=incoming*anatomy;
            double defense=Defense(victim,slot,magic,-1,1,penetration);
            total+=damage*(1-defense);
            ArmorWear[slot]+=Wear(damage*Equipped(victim,slot,magic,-1,1,penetration))*probability;
            if(natural==CaelumConstants.VULNERABILITY_CRITICAL_POINT && headLoss==0)
                headLoss=CaelumConstants.CRITICAL_POINT_BASE_LUCIDITY_LOSS
                    *(critical?multiplier+1:1)*(1-defense)*victim.GetActorPainLucidityMultiplier();
        }
        double after=CaelumToughnessRules.Apply(victim,total,magic);
        int whole=Max(0,int(after*CaelumSealResistance.ForEssence(victim,essence)+0.5));
        int loss=NativeDamage(victim,source,whole,magic?Name('CaelumMagicTest'):Name('Melee'));
        Life+=loss*probability;HitProbability+=probability;
        if(loss>0)DamagingHitProbability+=probability;
        if(loss>0)Lucidity+=headLoss*probability;
    }
}

// Particion de la silueta en los limites existentes de la anatomia. Cada
// celda pertenece a la primera region coincidente, igual que FindRegion.
class CaelumAbsentAnatomy : Object play
{
    Array<double> Heights,Laterals;
    double Weights[16];

    void Insert(Array<double> values,double value)
    {
        value=Clamp(value,0.0,1.0);
        for(int i=0;i<values.Size();i++)
        {
            if(Abs(values[i]-value)<0.000000001)return;
            if(values[i]>value){values.Insert(i,value);return;}
        }
        values.Push(value);
    }

    void Build(CaelumCombatActor victim,vector3 origin,double projectileRadius,
        double minimum,double maximum,bool signedOffsets)
    {
        for(int i=0;i<16;i++)Weights[i]=0;
        Heights.Clear();Laterals.Clear();
        let profile=victim.AnatomyProfile;if(profile==null)return;
        double distance=(victim.Pos.XY-origin.XY).Length();
        double radius=victim.Radius+Max(0,projectileRadius);
        if(maximum<=0 || distance<=radius)
        {int region=profile.FindRegion(0.5,0);if(region>=0)Weights[region]=1;return;}
        Insert(Heights,0);Insert(Heights,1);Insert(Laterals,0);Insert(Laterals,1);
        for(int i=0;i<profile.RegionCount;i++)
        {
            Insert(Heights,profile.RegionMinimumHeight[i]);Insert(Heights,profile.RegionMaximumHeight[i]);
            Insert(Laterals,profile.RegionMinimumLateral[i]);Insert(Laterals,profile.RegionMaximumLateral[i]);
        }
        double centre=VectorAngle(distance,victim.Pos.Z+victim.Height/2-origin.Z);
        double width=ASin(Clamp(radius/distance,0.0,1.0));
        for(int h=0;h+1<Heights.Size();h++)for(int l=0;l+1<Laterals.Size();l++)
        {
            int region=profile.FindRegion((Heights[h]+Heights[h+1])/2,(Laterals[l]+Laterals[l+1])/2);
            if(region<0)continue;
            double low=victim.Pos.Z+Heights[h]*victim.Height-origin.Z-(h==0?projectileRadius:0);
            double high=victim.Pos.Z+Heights[h+1]*victim.Height-origin.Z+(h+2==Heights.Size()?projectileRadius:0);
            double bottom=VectorAngle(distance,low)-centre,top=VectorAngle(distance,high)-centre;
            double left=width*Laterals[l],right=width*Laterals[l+1];
            double positive=signedOffsets?CaelumMeanAim.SignedRectangle(left,right,bottom,top,minimum,maximum)
                :CaelumMeanAim.CarbineRectangle(left,right,bottom,top,minimum,maximum);
            double negative=signedOffsets?CaelumMeanAim.SignedRectangle(-right,-left,bottom,top,minimum,maximum)
                :CaelumMeanAim.CarbineRectangle(-right,-left,bottom,top,minimum,maximum);
            Weights[region]+=positive+negative;
        }
    }
}
