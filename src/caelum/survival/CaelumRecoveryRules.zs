// Costes por fracción realmente recuperada; compartidos por juego y previsión.
// No poseen reservas ni aplican recargos por exposición térmica.
class CaelumRecoveryRules : Object
{
    static clearscope double HungerCost(double maximum,double consumption)
    { return maximum>0 ? CaelumConstants.AIR_FULL_RECOVERY_HUNGER_COST*consumption/maximum : 0; }
    static clearscope double ThirstCost(double maximum,double consumption)
    { return maximum>0 ? CaelumConstants.AIR_FULL_RECOVERY_THIRST_COST*consumption/maximum : 0; }
    static clearscope double Affordable(double requested,double maximum,double hunger,double thirst,double consumption)
    {
        if(maximum<=0 || consumption<=0)return 0;
        return Max(0.0,Min(requested,Min(hunger/HungerCost(maximum,consumption),thirst/ThirstCost(maximum,consumption))));
    }
}
