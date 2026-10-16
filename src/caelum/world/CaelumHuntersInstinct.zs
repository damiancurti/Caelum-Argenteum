// #239: factores temporales; los atributos y las tiradas originales se conservan.
class CaelumHuntersInstinctEffect : CaelumRacialAbilityEffect
{
    override double BaseAnimaPerSecond(CaelumPlayer user)
    {return CaelumHuntersInstinct.ANIMA_PER_SECOND;}
}

class CaelumHuntersInstinct : Object
{
    const ANIMA_PER_SECOND=10.0;
    const MULTIPLIER=3.0;
    const CRITICAL_REVISION=1;

    static clearscope bool Active(CaelumPlayer user)
    {return user!=null && user.health>0 && user.RacialAbilityActive && user.RacialAbility is "CaelumHuntersInstinctEffect";}

    static clearscope bool Behind(Actor user,Actor victim)
    {
        if(user==null || victim==null || user==victim)return false;
        vector2 offset=user.Pos.XY-victim.Pos.XY;
        return offset.Length()>0 && Abs(victim.DeltaAngle(victim.Angle,VectorAngle(offset.X,offset.Y)))>90.0;
    }

    static clearscope double Stealth(CaelumPlayer user,double current)
    {return Clamp(current*(Active(user)?MULTIPLIER:1.0),0.0,100.0);}

    static clearscope double Chance(CaelumPlayer user,Actor victim,double current)
    {return RearChance(user,victim,current,Active(user));}

    static clearscope double RearChance(Actor source,Actor victim,double current,bool eligible)
    {return Clamp(current*(eligible && Behind(source,victim)?MULTIPLIER:1.0),0.0,100.0);}
}
