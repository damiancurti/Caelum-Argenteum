// Memoizacion exacta del integrador puro durante un intervalo de ausencia.
// Cada cuerpo conserva sus reservas, diagnosticos y consecuencias nativas.
class CaelumAbsentThermalEntry : Object play
{
    CaelumThermalState Before,After;
    double WorldSeconds,ActiveSeconds,Activity,Magic,Fire,Firearm,Dose;
    int Next;
    bool Matches(CaelumThermalState b,double dw,double dr,double work,double magic,double fire,double firearm)
    {
        if(WorldSeconds!=dw || ActiveSeconds!=dr || Activity!=work || Magic!=magic || Fire!=fire || Firearm!=firearm)return false;
        let a=Before;
        if(a.Available!=b.Available || a.Sweats!=b.Sweats || a.CanShiver!=b.CanShiver || a.Bare!=b.Bare
            || a.CanBreathe!=b.CanBreathe || a.Roof!=b.Roof || a.Inertia!=b.Inertia || a.SurfaceArea!=b.SurfaceArea
            || a.BodyMassKg!=b.BodyMassKg || a.ComfortC!=b.ComfortC || a.Toughness!=b.Toughness
            || a.Exposure!=b.Exposure || a.Acclimation!=b.Acclimation || a.AcclimationMultiplier!=b.AcclimationMultiplier
            || a.BreathingAirRatio!=b.BreathingAirRatio || a.ShiveringHunger!=b.ShiveringHunger
            || a.ShiveringHungerPerMetSecond!=b.ShiveringHungerPerMetSecond || a.Hydration!=b.Hydration
            || a.DrinkOffset!=b.DrinkOffset || a.DrinkRemaining!=b.DrinkRemaining || a.AirC!=b.AirC
            || a.Humidity!=b.Humidity || a.WindMps!=b.WindMps || a.RainMmHour!=b.RainMmHour
            || a.ClimateC!=b.ClimateC || a.SurfaceC!=b.SurfaceC)return false;
        for(int i=0;i<4;i++)
            if(a.Material[i]!=b.Material[i] || a.Coverage[i]!=b.Coverage[i] || a.SubmergedCoverage[i]!=b.SubmergedCoverage[i]
                || a.SubmergedTemperatureC[i]!=b.SubmergedTemperatureC[i] || a.WorkWaterKg[i]!=b.WorkWaterKg[i]
                || a.SurfaceCoverage[i]!=b.SurfaceCoverage[i])return false;
        return true;
    }
    void Apply(CaelumThermalState target)
    {
        let a=After;let b=Before;
        target.Exposure=a.Exposure;target.Acclimation=a.Acclimation;target.ActivityWatts=a.ActivityWatts;
        target.ShiveringHunger=a.ShiveringHunger;target.Hydration=a.Hydration;target.SweatRateKgHour=a.SweatRateKgHour;
        target.DrinkRemaining=a.DrinkRemaining;target.WetnessPercent=a.WetnessPercent;
        target.Conductance=a.Conductance;target.Imbalance=a.Imbalance;target.Severity=a.Severity;
        for(int i=0;i<4;i++)target.WorkWaterKg[i]=a.WorkWaterKg[i];
        // Los contadores acumulados no forman parte de la clave fisica.
        target.ActivityJoules+=a.ActivityJoules-b.ActivityJoules;
        target.ActionJoules+=a.ActionJoules-b.ActionJoules;
        target.ShiveringJoules+=a.ShiveringJoules-b.ShiveringJoules;
        target.SweatKg+=a.SweatKg-b.SweatKg;
        target.SweatRunoffKg+=a.SweatRunoffKg-b.SweatRunoffKg;
        target.ClothingRunoffKg+=a.ClothingRunoffKg-b.ClothingRunoffKg;
        target.EvaporatedKg+=a.EvaporatedKg-b.EvaporatedKg;
        target.EvaporationJoules+=a.EvaporationJoules-b.EvaporationJoules;
        target.RespirationJoules+=a.RespirationJoules-b.RespirationJoules;
        target.AbsorbedContinuousJoules+=a.AbsorbedContinuousJoules-b.AbsorbedContinuousJoules;
    }
}
class CaelumAbsentThermal : Object play
{
    // Limites tecnicos de memoria y colisiones; no son magnitudes de juego.
    const BUCKETS=64;
    const LIMIT=128;
    Array<CaelumAbsentThermalEntry> Rows;
    int Head[64];
    double Epoch;
    bool Ready;
    int Hits,Misses;
    double Integrate(CaelumThermalState body,double epoch,double dw,double dr,double work,double magic,double fire,double firearm)
    {
        if(!Ready || Epoch!=epoch)
        {Ready=true;Epoch=epoch;Rows.Clear();for(int i=0;i<BUCKETS;i++)Head[i]=-1;}
        int bucket=int(Clamp(body.BodyMassKg*13+body.Exposure*100+body.Hydration*7,-100000000.0,100000000.0))&(BUCKETS-1);
        for(int i=Head[bucket];i>=0;i=Rows[i].Next)
            if(Rows[i].Matches(body,dw,dr,work,magic,fire,firearm))
            {Hits++;Rows[i].Apply(body);return Rows[i].Dose;}
        Misses++;
        if(Rows.Size()>=LIMIT)return CaelumThermalService.Integrate(body,dw,dr,work,magic,fire,0,firearm);
        let row=new('CaelumAbsentThermalEntry');row.Before=body.CopyForForecast();
        row.Before.SurfaceC=body.SurfaceC;for(int i=0;i<4;i++)row.Before.SurfaceCoverage[i]=body.SurfaceCoverage[i];
        row.WorldSeconds=dw;row.ActiveSeconds=dr;row.Activity=work;row.Magic=magic;row.Fire=fire;row.Firearm=firearm;
        row.Dose=CaelumThermalService.Integrate(body,dw,dr,work,magic,fire,0,firearm);
        row.After=body.CopyForForecast();row.Next=Head[bucket];Head[bucket]=Rows.Size();Rows.Push(row);
        return row.Dose;
    }
}
