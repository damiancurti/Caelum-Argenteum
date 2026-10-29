// #242: racial sin cuota fija; cada esfuerzo paga su propio coste real.
class CaelumSupernaturalBreathingEffect : CaelumRacialAbilityEffect
{
}

class CaelumAirPayment : Object play
{
    static bool Substituting(CaelumPlayer user)
    {
        return user!=null && user.RacialAbilityActive
            && user.RacialAbility is "CaelumSupernaturalBreathingEffect";
    }

    static double AnimaCost(CaelumPlayer user,double airCost)
    {
        return CaelumRacialAbilityRules.ModifiedCost(user,
            Max(0.0,airCost)*CaelumConstants.SUPERNATURAL_BREATHING_ANIMA_PER_AIR);
    }

    static bool CanSubstitute(CaelumPlayer user,double airCost)
    {
        CaelumRacialAbilityRules.Guard(user);
        if(!Substituting(user))return false;
        if(user.CurrentAnima>0 && user.CurrentAnima+1e-8>=AnimaCost(user,airCost))return true;
        // No repartir un esfuerzo entre ambas reservas ni consumir el resto.
        CaelumRacialAbilityRules.Deactivate(user);
        return false;
    }

    static bool CanAfford(CaelumPlayer user,double airCost)
    {
        airCost=Max(0.0,airCost)*CaelumAltitudeService.Effort(user);
        return CanSubstitute(user,airCost) || user.CurrentAir>=airCost;
    }

    static bool PayWithAnima(CaelumPlayer user,double airCost)
    {
        if(!CanSubstitute(user,airCost))return false;
        user.CurrentAnima=Max(0.0,user.CurrentAnima-AnimaCost(user,airCost));
        if(user.CurrentAnima<=0)CaelumRacialAbilityRules.Deactivate(user);
        return true;
    }

    // Devuelve solamente el Aire retirado; la deuda submarina no incluye Ánima.
    static double Spend(CaelumPlayer user,double airCost)
    {
        airCost=Max(0.0,airCost)*CaelumAltitudeService.Effort(user);
        if(PayWithAnima(user,airCost))return 0;
        double removed=Min(Max(0.0,user.CurrentAir),Max(0.0,airCost));
        user.CurrentAir=Max(0.0,user.CurrentAir-removed);
        return removed;
    }

    static bool HasSupply(CaelumPlayer user)
    {return user.CurrentAir>0 || (Substituting(user) && user.CurrentAnima>0);}
}
