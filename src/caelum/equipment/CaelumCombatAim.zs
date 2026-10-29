// #415: parámetros compartidos; consultar no consume azar ni altera el actor.
class CaelumCombatAim : Object
{
    static play double Accuracy(CaelumCombatActor body,bool magical,bool aimed=false)
    {
        double value=magical ? body.CombatMagicalAccuracyPercent : body.CombatPhysicalAccuracyPercent;
        value*=body.ElementalStatus!=null ? body.ElementalStatus.GetAccuracyMultiplier() : 1.0;
        if(aimed)
        {value*=CaelumConstants.CROUCH_ACCURACY_MULTIPLIER;value*=CaelumConstants.RANGED_AIM_ACCURACY_MULTIPLIER;}
        return Max(1.0,value);
    }

    static play double MagicMinimum(CaelumCombatActor body,int weaponType)
    {
        return CaelumDispersionRules.EffectiveTier(CaelumDispersionRules.MagicBase(weaponType),1,
            body.CurrentCombatLucidity)*100.0/Accuracy(body,true);
    }

    static play double CarbineMinimum(CaelumCombatActor body,int tier,double accuracy=-1)
    {
        return CaelumWeaponCatalogue.GetMinimumSpread(CaelumConstants.CATALOGUE_WEAPON_CARBINE,
            tier,body.CurrentCombatLucidity)*100/(accuracy<0 ? Accuracy(body,false,true) : Max(1.0,accuracy));
    }

    static play double CarbineMaximum(CaelumCombatActor body,int tier,double accuracy=-1)
    {
        return CaelumWeaponCatalogue.GetMaximumSpread(CaelumConstants.CATALOGUE_WEAPON_CARBINE,
            tier,body.CurrentCombatLucidity)*100/(accuracy<0 ? Accuracy(body,false,true) : Max(1.0,accuracy));
    }

    static play double CarbineCritical(CaelumCombatActor body,int tier)
    {
        return Clamp((CaelumWeaponCatalogue.GetCriticalChancePercent(CaelumConstants.CATALOGUE_WEAPON_CARBINE)
            *CaelumRangedRules.TierCriticalMultiplier(tier)
            +Max(0.0,body.CombatPhysicalCriticalChancePercent-CaelumConstants.BASE_CRITICAL_CHANCE_PERCENT))
            *CaelumConstants.CROUCH_CRITICAL_CHANCE_MULTIPLIER,0.0,100.0);
    }
}

// Integrales continuas de las dos distribuciones nativas, sin tirar dados.
// Son estimaciones del muestreo discreto nativo; no trazan trayectorias ni LOS.
class CaelumMeanAim : Object
{
    static double Overlap(double low,double high,double begin,double end)
    {return Max(0.0,Min(high,end)-Max(low,begin));}

    // WeaponAimOffset: cada eje elige signo y módulo entre mínimo y máximo.
    static double SignedAxis(double low,double high,double minimum,double maximum)
    {
        if(high<=low)return 0;
        minimum=Max(0.0,minimum);maximum=Max(minimum,maximum);
        if(maximum==0)return low<=0 && high>=0 ? 1 : 0;
        if(maximum==minimum)
            return ((low<=minimum && high>=minimum ? 1 : 0)
                +(low<=-minimum && high>=-minimum ? 1 : 0))*0.5;
        return (Overlap(low,high,minimum,maximum)+Overlap(low,high,-maximum,-minimum))
            /(2*(maximum-minimum));
    }

    static double SignedRectangle(double left,double right,double bottom,double top,double minimum,double maximum)
    {return SignedAxis(left,right,minimum,maximum)*SignedAxis(bottom,top,minimum,maximum);}

    // Carabina: el mismo semiancho aleatorio s para yaw/pitch; después cada
    // eje es uniforme en [-s,s]. No se multiplican sus probabilidades medias.
    static double Quadrant(double x,double y,double minimum,double maximum)
    {
        if(x==0 || y==0)return 0;
        double direction=(x<0 ? -1.0 : 1.0)*(y<0 ? -1.0 : 1.0);
        double small=Min(Abs(x),Abs(y)),large=Max(Abs(x),Abs(y));
        if(maximum==minimum)
            return direction*0.25*Min(1.0,small/maximum)*Min(1.0,large/maximum);
        double integral=Max(0.0,Min(maximum,small)-minimum);
        double lo=Max(minimum,small),hi=Min(maximum,large);
        if(hi>lo)integral+=small*Log(hi/lo);
        lo=Max(minimum,large);hi=maximum;
        if(hi>lo)integral+=small*large*(1/lo-1/hi);
        return direction*integral/(4*(maximum-minimum));
    }

    static double CarbineRectangle(double left,double right,double bottom,double top,double minimum,double maximum)
    {
        if(right<=left || top<=bottom)return 0;
        minimum=Max(0.0,minimum);maximum=Max(minimum,maximum);
        if(maximum==0)return left<=0 && right>=0 && bottom<=0 && top>=0 ? 1 : 0;
        return Clamp(Quadrant(right,top,minimum,maximum)-Quadrant(left,top,minimum,maximum)
            -Quadrant(right,bottom,minimum,maximum)+Quadrant(left,bottom,minimum,maximum),0.0,1.0);
    }

    // Silueta angular del cilindro de colisión en las posiciones registradas.
    // La mira nominal apunta al centro. El radio del proyectil ensancha el
    // volumen; la pendiente se conserva sin simular balística ni obstáculos.
    static double BodyProbability(vector3 origin,vector3 position,double radius,double height,
        double projectileRadius,double minimum,double maximum,bool signedOffsets=false)
    {
        radius=Max(0.0,radius)+Max(0.0,projectileRadius);
        double distance=(position.XY-origin.XY).Length();
        double lower=position.Z-origin.Z-Max(0.0,projectileRadius);
        double upper=position.Z+Max(0.0,height)-origin.Z+Max(0.0,projectileRadius);
        if(distance<=radius && lower<=0 && upper>=0)return 1;
        double halfWidth=distance<=radius ? 90 : ASin(Clamp(radius/distance,0.0,1.0));
        double centre=VectorAngle(distance,position.Z+height/2-origin.Z);
        double bottom=VectorAngle(distance,lower)-centre;
        double top=VectorAngle(distance,upper)-centre;
        return signedOffsets ? SignedRectangle(-halfWidth,halfWidth,bottom,top,minimum,maximum)
            : CarbineRectangle(-halfWidth,halfWidth,bottom,top,minimum,maximum);
    }
}
