// Modelo numérico compartido por personajes, NPC y previsiones de viaje/espera.
// No modifica Aire, inventario ni reloj; conserva sólo adaptación fisiológica.
class CaelumAltitudeRules : Object
{
    static clearscope double PressureKPa(double meters)
    {
        double h=Max(0.0,meters);
        if(h<=CaelumAltitudeData.TROPOSPHERE_TOP_M)
        {
            double temperature=CaelumAltitudeData.SEA_TEMPERATURE_C
                -CaelumAltitudeData.TROPOSPHERE_LAPSE_C_PER_M*h;
            return CaelumAltitudeData.SEA_PRESSURE_KPA*
                (((temperature+CaelumAltitudeData.KELVIN_OFFSET)/CaelumAltitudeData.REFERENCE_TEMPERATURE_K)
                **CaelumAltitudeData.TROPOSPHERE_EXPONENT);
        }
        if(h<=CaelumAltitudeData.LOWER_STRATOSPHERE_TOP_M)
            return CaelumAltitudeData.STRATOSPHERE_PRESSURE_KPA*Exp(
                CaelumAltitudeData.STRATOSPHERE_EXPONENT_OFFSET-CaelumAltitudeData.STRATOSPHERE_EXPONENT_PER_M*h);
        double temperature=CaelumAltitudeData.UPPER_TEMPERATURE_OFFSET_C
            +CaelumAltitudeData.UPPER_LAPSE_C_PER_M*h;
        return CaelumAltitudeData.UPPER_PRESSURE_KPA*
            (((temperature+CaelumAltitudeData.KELVIN_OFFSET)/CaelumAltitudeData.UPPER_REFERENCE_K)
            **CaelumAltitudeData.UPPER_EXPONENT);
    }
    static clearscope double PressureRatio(double meters)
    {
        // La normalización elimina el pequeño error de redondeo a nivel del mar.
        return Clamp(PressureKPa(meters)/PressureKPa(0),0.0,1.0);
    }
    static clearscope double RacePenalty(int race)
    { return race==CaelumConstants.RACE_CAELITH ? CaelumAltitudeData.CAELITH_PENALTY : 1.0; }
    static clearscope double Compensation(double ratio,double adaptedDeficit)
    {
        double deficit=1.0-ratio;
        return deficit>0 ? CaelumAltitudeData.MAX_COMPENSATION*Clamp(adaptedDeficit/deficit,0.0,1.0) : 0;
    }
    static clearscope double Recovery(double ratio,double adaptedDeficit,int race)
    { return 1.0-(1.0-ratio)*RacePenalty(race)*(1.0-Compensation(ratio,adaptedDeficit)); }
    static clearscope double Effort(double ratio,double adaptedDeficit,int race)
    {
        // Salvaguarda numérica de división; no constituye una altura jugable nueva.
        double safeRatio=Max(1e-12,ratio);
        return 1.0+(1.0/safeRatio-1.0)*RacePenalty(race)*(1.0-Compensation(ratio,adaptedDeficit));
    }
}

class CaelumAltitudeState : Object play
{
    int Revision;
    double AdaptedDeficit, StartDeficit, TargetDeficit, TransitionSeconds, DurationSeconds;
    double GainMultiplier;
    bool ClockReady;
    double LastStamp;
    String LastMap;
    int LastTic, NextAttributeTic;
    double LastHeight, Ratio;
    int Race;
    double RecoveryFactor, EffortFactor;

    void Initialize()
    {
        if(Revision>=CaelumAltitudeData.REVISION)return;
        // Un guardado anterior no recibe exposición ni adaptación retroactivas.
        Revision=CaelumAltitudeData.REVISION;GainMultiplier=1;Ratio=1;
        RecoveryFactor=1;EffortFactor=1;ClockReady=false;LastTic=-1;
    }
    void SelectTarget(double ratio,double multiplier)
    {
        double target=Clamp(1.0-ratio,0.0,1.0),gain=Max(1.0,multiplier);
        if(TargetDeficit==target && GainMultiplier==gain && DurationSeconds>0)return;
        StartDeficit=AdaptedDeficit;TargetDeficit=target;TransitionSeconds=0;GainMultiplier=gain;
        // Resiliencia acelera la adquisición; no aumenta el límite aprobado
        // ni reduce los catorce días de conservación al bajar de altitud.
        DurationSeconds=CaelumThermalData.WORLD_DAY_SECONDS
            *(target>StartDeficit ? CaelumAltitudeData.ADAPT_DAYS/gain : CaelumAltitudeData.DECAY_DAYS);
    }
    void Advance(double seconds)
    {
        if(seconds<=0 || DurationSeconds<=0)return;
        TransitionSeconds=Min(DurationSeconds,TransitionSeconds+seconds);
        AdaptedDeficit=StartDeficit+(TargetDeficit-StartDeficit)*TransitionSeconds/DurationSeconds;
    }
    void RefreshFactors()
    {
        RecoveryFactor=CaelumAltitudeRules.Recovery(Ratio,AdaptedDeficit,Race);
        EffortFactor=CaelumAltitudeRules.Effort(Ratio,AdaptedDeficit,Race);
    }
    CaelumAltitudeState Copy()
    {
        let copy=new("CaelumAltitudeState");
        copy.Revision=Revision;copy.AdaptedDeficit=AdaptedDeficit;copy.StartDeficit=StartDeficit;
        copy.TargetDeficit=TargetDeficit;copy.TransitionSeconds=TransitionSeconds;
        copy.DurationSeconds=DurationSeconds;copy.GainMultiplier=GainMultiplier;
        copy.ClockReady=ClockReady;copy.LastStamp=LastStamp;copy.LastMap=LastMap;
        copy.LastTic=LastTic;copy.NextAttributeTic=NextAttributeTic;copy.LastHeight=LastHeight;copy.Ratio=Ratio;copy.Race=Race;
        copy.RecoveryFactor=RecoveryFactor;copy.EffortFactor=EffortFactor;
        return copy;
    }
}
