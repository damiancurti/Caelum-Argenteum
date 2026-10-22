// #479: contrato aprobado; estos roles no son IDs de objetos ni slots nativos.
class CaelumSupportImplementData : Object
{
    const BOOK=0;
    const CENSER=1;
    const STATUETTE=2;
    const EFFIGY=3;
    const ROLE_COUNT=4;
    const BASE_PERCENT_PER_SECOND=1.0;
    const BASE_SECONDS=1.0;
    const AREA_ANIMA=70.0;
    const SINGLE_ANIMA=100.0;
    const TIER_TWO_COST=1.6;
    const TIER_THREE_COST=2.5;

    static clearscope bool ValidRole(int role){return role>=BOOK && role<ROLE_COUNT;}
    static clearscope bool Beneficial(int role){return role==CENSER || role==STATUETTE;}
    static clearscope bool Area(int role){return role==BOOK || role==CENSER;}
    static clearscope bool SecondaryModifiers(int role){return role==STATUETTE || role==EFFIGY;}
    static clearscope int Essence(){return CaelumConstants.ESSENCE_QUINTESSENCE;}
    static clearscope double BaseRadius(){return CaelumConstants.ESSENCE_EXPLOSION_BASE_RADIUS;}
    static clearscope int PreparationTics(){return CaelumAttackRules.BASE_TICS;}

    static clearscope double Power(double attribute)
    {return CaelumGrowthRules.Multiplier(attribute,2);}

    static clearscope double Rate(double attribute)
    {return BASE_PERCENT_PER_SECOND*Power(attribute);}

    static clearscope double Duration(double attribute)
    {return BASE_SECONDS*Power(attribute);}

    static clearscope double BaseAnimaCost(int role,int tier)
    {
        if(!ValidRole(role) || tier<1 || tier>3)return 0;
        return (Area(role)?AREA_ANIMA:SINGLE_ANIMA)
            *(tier==3?TIER_THREE_COST:tier==2?TIER_TWO_COST:1.0);
    }
}
