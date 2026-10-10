// #154: curva y operación son conceptos distintos. El nivel efectivo puede
// superar 100; sólo cada consumidor limita probabilidades o restos negativos.
class CaelumGrowthRules : Object
{
    const REVISION = 1;
    const PLAYER_BALANCE_VERSION = 4;
    const LINEAR_WEIGHT = 25.0;
    const PERCENT_DIVISOR = 125.0;
    const TYPE_TWO_FACTOR = 3.0;
    const TYPE_THREE_FACTOR = 7.0;

    static clearscope double Bonus(double level,int family=1)
    {
        double base=(level*level+LINEAR_WEIGHT*level)/PERCENT_DIVISOR;
        return base*(family==3 ? TYPE_THREE_FACTOR : family==2 ? TYPE_TWO_FACTOR : 1.0);
    }

    static clearscope double Percent(double level,int family=1)
    { return 100.0+Bonus(level,family); }

    static clearscope double Multiplier(double level,int family=1)
    { return Percent(level,family)/100.0; }

    static clearscope double Remaining(double level)
    { return Clamp(1.0-Bonus(level)/100.0,0.0,1.0); }
}
