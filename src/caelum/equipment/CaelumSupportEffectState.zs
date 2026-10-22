// #479: una instancia por clase de efecto y receptor, compartida por lanzadores.
// No modifica atributos base, actores, resistencias ni relojes de otras acciones.
// La integración devuelve HP fraccionarios sin redondear; el receptor deberá
// aplicar la mitigación y conservar su resto al incorporarse el sistema al combate.
class CaelumSupportEffectState : Object
{
    const CURRENT_REVISION=1;
    // Tolerancia numérica, no extensión de duración ni dato de balance.
    const TIME_EPSILON=0.000000001;
    int Revision;
    double IntensityPercent;
    double RemainingSeconds;

    bool EnsureRevision()
    {
        if(Revision==0)Revision=CURRENT_REVISION;
        return Revision==CURRENT_REVISION;
    }

    bool Apply(double attribute)
    {
        if(!EnsureRevision())return false;
        if(RemainingSeconds<=0)IntensityPercent=0;
        IntensityPercent+=CaelumSupportImplementData.Rate(attribute);
        RemainingSeconds=CaelumSupportImplementData.Duration(attribute);
        return true;
    }

    clearscope bool Active()
    {return Revision==CURRENT_REVISION && RemainingSeconds>0 && IntensityPercent>0;}

    clearscope double Factor()
    {return Active()?1.0+IntensityPercent/100.0:1.0;}

    double Advance(double elapsedSeconds,double currentMaximumHealth)
    {
        if(!EnsureRevision() || !Active() || elapsedSeconds<=0)return 0;
        double elapsed=Min(elapsedSeconds,RemainingSeconds);
        double amount=Max(0,currentMaximumHealth)*IntensityPercent/100.0*elapsed;
        RemainingSeconds=Max(0,RemainingSeconds-elapsed);
        if(RemainingSeconds<TIME_EPSILON)RemainingSeconds=0;
        if(RemainingSeconds<=0)IntensityPercent=0;
        return amount;
    }
}
