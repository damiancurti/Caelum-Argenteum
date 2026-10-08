// Un dueño por estado y un balance por intervalo: ambiente en tiempo del mundo,
// trabajo/magia en segundos reales y cada impulso aplicado una sola vez.
class CaelumThermalService : Object play
{
    static CaelumThermalState CaptureForecast(Actor body)
    {
        let live=CaelumThermalBody.Get(body,true);
        if(live==null)return null;
        let copy=live.CopyForForecast();
        CaelumThermalBody.Refresh(body,copy);
        CaelumThermalEnvironment.Sample(body,copy);
        copy.Bare=CaelumThermalBody.FurryAnimal(body);
        for(int slot=0;slot<4;slot++)
        {
            copy.Material[slot]=CaelumThermalBody.Material(body,slot);
            copy.WorkWaterKg[slot]=CaelumThermalBody.Water(body,live,slot);
        }
        return copy;
    }

    static void CommitForecast(Actor body,CaelumThermalState projection)
    {
        let live=CaelumThermalBody.Get(body,true);
        if(live==null || projection==null)return;
        live.Exposure=projection.Exposure;live.Acclimation=projection.Acclimation;
        live.ActivityWatts=projection.ActivityWatts;live.ActivityJoules=projection.ActivityJoules;
        live.EvaporatedKg=projection.EvaporatedKg;live.EvaporationJoules=projection.EvaporationJoules;
        live.SweatKg=projection.SweatKg;live.SweatRunoffKg=projection.SweatRunoffKg;
        live.SweatRateKgHour=projection.SweatRateKgHour;
        // La previsión de provisiones ya aplicó la misma pérdida al jugador.
        let user=CaelumPlayer(body);
        live.Hydration=user!=null ? user.CurrentThirst : projection.Hydration;
        live.Severity=projection.Severity;live.WetnessPercent=projection.WetnessPercent;
        for(int slot=0;slot<4;slot++)CaelumThermalBody.SetWater(body,live,slot,projection.WorkWaterKg[slot]);
        // La geometría y el reloj del destino se muestrean al llegar.
        live.SourceMap="";live.MotionInitialized=false;
    }

    static void Impulse(Actor body,double joules,bool muscular=false)
    {
        let npc=CaelumCombatActor(body);
        if(npc!=null)CaelumThermalRuntime.NPCStep(npc,true);
        let thermal=CaelumThermalBody.Get(body,true);
        if(thermal==null || body.health<=0)return;
        CaelumThermalBody.Refresh(body,thermal);
        if(thermal.Inertia<=0)return;
        thermal.Exposure+=joules/thermal.Inertia;
        if(muscular)thermal.ActionJoules+=joules;
        else thermal.AbsorbedImpactJoules+=joules;
        thermal.Severity=CaelumThermalRules.Severity(thermal.Exposure,thermal.Toughness);
    }

    static void ProfiledAction(Actor body,double nominalAir,double nominalJumpAir)
    {
        let thermal=CaelumThermalBody.Get(body,true);
        if(thermal==null)return;
        CaelumThermalBody.Refresh(body,thermal);
        Impulse(body,CaelumThermalRules.ProfiledActionHeat(thermal.ReferenceJumpHeat,nominalAir,nominalJumpAir),true);
    }

    static void ApplyDamage(Actor body,CaelumThermalState thermal,double severitySeconds)
    {
        let user=CaelumPlayer(body);let npc=CaelumCombatActor(body);
        double maximum=user!=null ? user.CaelumMaximumHealth : npc!=null ? npc.CombatMaximumHealth : 0;
        thermal.DamageRemainder+=Max(0.0,severitySeconds)*maximum/100.0
            *(1-CaelumThermalRules.DamageResistance(thermal.Toughness));
        int damage=int(thermal.DamageRemainder+CaelumThermalData.THRESHOLD_EPSILON);
        if(damage<=0 || body.health<=0)return;
        thermal.DamageRemainder=Max(0.0,thermal.DamageRemainder-damage);
        thermal.AppliedDamageHP+=Min(damage,body.health);
        body.health=Max(0,body.health-damage);
        if(user!=null)
        {
            user.player.health=user.health;
            CaelumRestState.Interrupt(user,"CA_REST_THERMAL");
        }
        if(body.health<=0)body.Die(null,null,0,'CaelumThermal');
    }

    static void Drink(Actor body,bool hot)
    {
        let thermal=CaelumThermalBody.Get(body,true);
        if(thermal==null)return;
        // Un efecto refrescable, nunca suma ilimitada ni salto instantáneo de E.
        thermal.DrinkOffset=hot ? CaelumThermalData.DRINK_OFFSET_C : -CaelumThermalData.DRINK_OFFSET_C;
        thermal.DrinkRemaining=CaelumThermalData.DRINK_SECONDS;
    }

    static void Advance(Actor body,double worldSeconds,double realSeconds,
        double activityWatts=0,double magicWatts=0,double fireWatts=0)
    {
        let thermal=CaelumThermalBody.Get(body,true);
        if(thermal==null || body.health<=0)return;
        CaelumThermalBody.Refresh(body,thermal);
        if(thermal.Inertia<=0)return;
        if(thermal.Coverage[0]+thermal.Coverage[1]+thermal.Coverage[2]+thermal.Coverage[3]<=0)
            CaelumThermalBody.SampleCoverage(body,thermal,0);
        for(int slot=0;slot<4;slot++)
        {
            thermal.Material[slot]=CaelumThermalBody.Material(body,slot);
            thermal.WorkWaterKg[slot]=CaelumThermalBody.Water(body,thermal,slot);
        }
        thermal.Bare=CaelumThermalBody.FurryAnimal(body);
        double severitySeconds=Integrate(thermal,worldSeconds,realSeconds,activityWatts,magicWatts,fireWatts);
        let user=CaelumPlayer(body);
        if(user!=null)
        {
            user.CurrentThirst=thermal.Hydration;
            user.UpdateSurvivalStates();
        }
        for(int slot=0;slot<4;slot++)CaelumThermalBody.SetWater(body,thermal,slot,thermal.WorkWaterKg[slot]);
        ApplyDamage(body,thermal,severitySeconds);
    }

    // El pronóstico usa una copia independiente. Esta ruta no toca actores,
    // inventario, reloj, recursos ni daños: devuelve la dosis de severidad real.
    static double Integrate(CaelumThermalState thermal,double worldSeconds,double realSeconds,
        double activityWatts=0,double magicWatts=0,double fireWatts=0,double logicalActivitySeconds=0)
    {
        if(thermal==null)return 0;
        int steps=thermal.Sweats && thermal.Available ? Max(1,int(Ceil(Max(0.0,worldSeconds)/CaelumThermalData.SWEAT_STEP_SECONDS))) : 1;
        double dose=0;
        for(int i=0;i<steps;i++)dose+=IntegrateStep(thermal,worldSeconds/steps,realSeconds/steps,
            activityWatts,magicWatts,fireWatts,logicalActivitySeconds/steps);
        return dose;
    }

    static double IntegrateStep(CaelumThermalState thermal,double worldSeconds,double realSeconds,
        double activityWatts=0,double magicWatts=0,double fireWatts=0,double logicalActivitySeconds=0)
    {
        if(thermal==null || thermal.Inertia<=0)return 0;
        double dw=Max(0.0,worldSeconds),dr=Max(0.0,realSeconds);
        thermal.SweatRateKgHour=0;
        if(!thermal.Available)
        {
            // Un mapa sin clima no inventa aire ni recuperación ambiental.
            // La energía real y las consecuencias de E siguen siendo válidas.
            double activity=CaelumThermalRules.AverageActivityPower(thermal.ActivityWatts,activityWatts,dw);
            thermal.ActivityWatts=CaelumThermalRules.ActivityPower(thermal.ActivityWatts,activityWatts,dw);
            double logicalPower=dw>0 ? activity*Max(0.0,logicalActivitySeconds)/dw : 0;
            double dose=CaelumThermalRules.SeveritySeconds(thermal.Exposure,logicalPower,0,
                thermal.Inertia,dw,dr,thermal.Toughness,magicWatts+activity);
            thermal.Exposure=CaelumThermalRules.Advance(thermal.Exposure,logicalPower,0,
                thermal.Inertia,dw,dr,magicWatts+activity);
            thermal.ActivityJoules+=activity*(dr+Max(0.0,logicalActivitySeconds));thermal.AbsorbedContinuousJoules+=magicWatts*dr;
            thermal.Severity=CaelumThermalRules.Severity(thermal.Exposure,thermal.Toughness);
            thermal.Conductance=0;thermal.Imbalance=0;
            thermal.DrinkRemaining=Max(0.0,thermal.DrinkRemaining-dr);
            return dose;
        }
        double oldAcclimation=thermal.Acclimation;
        thermal.Acclimation=CaelumThermalRules.Acclimation(oldAcclimation,thermal.ClimateC,thermal.ComfortC,dw,thermal.AcclimationMultiplier);
        // El centro sólo entra en B; E no recibe también el mismo desplazamiento.
        double center=thermal.ComfortC+(oldAcclimation+thermal.Acclimation)/2.0;
        double area=thermal.SurfaceArea;
        double film=CaelumThermalRules.AirConvection(thermal.WindMps)+CaelumThermalData.REFERENCE_RADIATION;
        bool bare=thermal.Bare;
        double referenceG=bare ? area*(CaelumThermalRules.AirConvection(CaelumThermalData.NATURAL_WIND_MPS)
            +CaelumThermalData.REFERENCE_RADIATION) : CaelumThermalRules.ReferenceConductance(area);
        double rest=area*CaelumThermalData.MET_WATTS_M2;
        double referenceOffset=referenceG>0 ? rest/referenceG : 0;
        double nodeC=center+referenceOffset+thermal.Exposure;
        double conductance=0,imbalance=rest+Max(0.0,fireWatts),wetness=0;
        double evaporated=0;
        double points=CaelumThermalRules.HydrationPointsPerKg(thermal.BodyMassKg);
        double sweat=thermal.Sweats ? Min(Max(0.0,thermal.Hydration)/points,
            CaelumThermalRules.SweatRate(thermal.Exposure,area,thermal.Hydration)*dw/3600.0) : 0;
        thermal.Hydration=Max(0.0,thermal.Hydration-sweat*points);
        thermal.SweatKg+=sweat;
        if(dw>0)thermal.SweatRateKgHour=sweat*3600.0/dw;
        for(int slot=0;slot<4;slot++)
        {
            int material=thermal.Material[slot];
            double fraction=thermal.Coverage[slot];
            double submerged=Min(fraction,thermal.SubmergedCoverage[slot]);
            double exposed=Max(0.0,fraction-submerged);
            double pieceArea=area*fraction;
            double capacity=pieceArea*CaelumThermalMoisture.CapacityPerArea(material);
            double water=thermal.WorkWaterKg[slot];
            // Entrada por inmersión no se confunde con evaporación ni escurrido.
            if(fraction>0)water=Max(water,capacity*submerged/fraction);
            double beforeWet=CaelumThermalMoisture.WetPercent(water,pieceArea,material);
            if(dw>0 && !thermal.Roof && fraction>0)
                water=Min(capacity,water+capacity*exposed/fraction*Max(0.0,thermal.RainMmHour)
                    *CaelumThermalData.RAIN_PERCENT_PER_MINUTE_MM*dw/6000.0);
            // El sudor se paga completo, incluso sumergido o si escurre. Sólo
            // el agua que efectivamente evapora retira energía una vez.
            double retained=Min(Max(0.0,capacity-water),sweat*exposed);
            water+=retained;
            thermal.SweatRunoffKg+=sweat*fraction-retained;
            // Superficie exterior de la ropa sobre la resistencia total. La
            // evaporación retira calor una vez del nodo, sin otro factor mojado.
            double surfaceC=thermal.AirC+(nodeC-thermal.AirC)
                /(1+CaelumThermalData.CLO_RESISTANCE*CaelumThermalData.Clo(material)*film);
            double loss=CaelumThermalMoisture.Evaporated(water,area*exposed,material,
                surfaceC,thermal.AirC,thermal.Humidity,thermal.WindMps,dw);
            water=Max(0.0,water-loss);evaporated+=loss;
            thermal.WorkWaterKg[slot]=water;
            double afterWet=CaelumThermalMoisture.WetPercent(water,pieceArea,material);
            wetness+=fraction*afterWet;
            double wetFactor=1+CaelumThermalData.WET_EXCHANGE_PER_PERCENT*(beforeWet+afterWet)/2.0;
            double clo=CaelumThermalData.Clo(material);
            double airG=area*exposed*CaelumThermalRules.ConductancePerArea(clo,film)*wetFactor;
            double waterG=area*submerged*CaelumThermalRules.ConductancePerArea(clo,CaelumThermalData.WATER_CONVECTION);
            conductance+=airG+waterG;
            imbalance+=airG*(thermal.AirC-center-referenceOffset)
                +waterG*(thermal.SubmergedTemperatureC[slot]-center-referenceOffset);
        }
        thermal.EvaporatedKg+=evaporated;
        thermal.EvaporationJoules+=evaporated*CaelumThermalData.LATENT_J_PER_KG;
        if(dw>0)imbalance-=evaporated*CaelumThermalData.LATENT_J_PER_KG/dw;
        double drinkFraction=dr>0 ? Min(dr,thermal.DrinkRemaining)/dr : thermal.DrinkRemaining>0 ? 1 : 0;
        imbalance+=conductance*thermal.DrinkOffset*drinkFraction;
        thermal.DrinkRemaining=Max(0.0,thermal.DrinkRemaining-dr);
        double activity=CaelumThermalRules.AverageActivityPower(thermal.ActivityWatts,activityWatts,dw);
        thermal.ActivityWatts=CaelumThermalRules.ActivityPower(thermal.ActivityWatts,activityWatts,dw);
        if(dw>0)imbalance+=activity*Max(0.0,logicalActivitySeconds)/dw;
        double realPower=magicWatts+activity;
        double severitySeconds=CaelumThermalRules.SeveritySeconds(thermal.Exposure,imbalance,
            conductance,thermal.Inertia,dw,dr,thermal.Toughness,realPower);
        thermal.Exposure=CaelumThermalRules.Advance(thermal.Exposure,imbalance,
            conductance,thermal.Inertia,dw,dr,realPower);
        thermal.AbsorbedContinuousJoules+=magicWatts*dr;
        thermal.ActivityJoules+=activity*(dr+Max(0.0,logicalActivitySeconds));
        thermal.Conductance=conductance;thermal.Imbalance=imbalance;thermal.WetnessPercent=wetness;
        thermal.Severity=CaelumThermalRules.Severity(thermal.Exposure,thermal.Toughness);
        return severitySeconds;
    }
}
