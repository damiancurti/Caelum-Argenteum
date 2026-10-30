// #426: el emisor sólo sirve para la consulta geométrica síncrona. El oyente
// guarda un punto y una fecha, nunca el puntero de quien produjo el sonido.
class CaelumNoise : Object play
{
    static double Intensity(CaelumCombatActor listener,Actor origin,double baseRange)
    {
        if(!CaelumVisualPerception.Living(listener) || origin==null || origin.bDestroyed
            || listener==origin || listener.bDormant || listener.ForcedSleepTics>0
            || listener.CombatLucidityPhysicalStunRemaining>0 || baseRange<=0)return 0;
        double range=baseRange*CaelumVisualPerception.InsightFactor(listener);
        double distance=listener.Distance3D(origin);
        if(distance>=range)return 0;
        if(!listener.CheckSight(origin,SF_IGNOREVISIBILITY))range*=CaelumNoiseData.OBSTACLE_FACTOR;
        return range>0 ? Clamp(1-distance/range,0.0,1.0) : 0;
    }

    static void Deliver(CaelumCombatActor listener,Actor origin,int kind,double range)
    {
        double intensity=Intensity(listener,origin,range);
        if(intensity<=0)return;
        let evidence=CaelumVisualPerception.Evidence(listener);
        evidence.Decay();
        evidence.Suspicion=Min(CaelumPerceptionData.SUSPICION_MAXIMUM,
            evidence.Suspicion+CaelumNoiseData.MAXIMUM_SUSPICION*intensity);
        evidence.NoiseRevision=CaelumNoiseData.REVISION;
        evidence.NoisePosition=origin.Pos;evidence.NoiseTic=level.time;
        evidence.NoiseKind=kind;evidence.NoiseIntensity=intensity;evidence.HasHeardNoise=true;
        evidence.LastEvidenceTic=level.time;evidence.HasEvidence=true;
    }

    static void Emit(Actor origin,int kind,double overrideRange=-1)
    {
        if(origin==null || origin.bDestroyed)return;
        double range=overrideRange>=0 ? overrideRange : CaelumPhysicsUnits.MapUnits(CaelumNoiseData.MetersFor(kind));
        if(range<=0)return;
        let population=CaelumPopulationState.Get();
        double maximum=population!=null ? Max(1.0,population.PerceptionMaximumInsightFactor) : 1;
        let nearby=BlockThingsIterator.Create(origin,range*maximum);
        while(nearby.Next())
        {
            let listener=CaelumCombatActor(nearby.thing);
            if(listener!=null)Deliver(listener,origin,kind,range);
        }
        if(population!=null)for(int i=0;i<population.UnlinkedGuards.Size();i++)
        {
            let entry=population.UnlinkedGuards[i];
            if(entry!=null && entry.Body!=null && entry.Body.bNoBlockmap)
                Deliver(entry.Body,origin,kind,range);
        }
    }

    static double SurfaceFactor(Actor body)
    {
        let terrain=body.GetFloorTerrain();
        return CaelumNoiseData.TerrainFactor(terrain.TerrainName,body.WaterLevel==1);
    }

    static double EquipmentFactor(Actor body)
    {
        for(int slot=0;slot<CaelumConstants.ARMOR_SLOT_COUNT;slot++)
            if(CaelumThermalBody.Material(body,slot)==CaelumThermalData.METAL_CLOTH)
                return CaelumNoiseData.METAL_EQUIPMENT_FACTOR;
        return 1;
    }

    static void NPCStep(CaelumCombatActor body,bool running,double movedMass)
    {
        if(body==null || body.health<=0 || body.WaterLevel>=2
            || body.Pos.Z>body.FloorZ+0.01 || body.bNoGravity)return;
        if(body.NoiseStepScheduled && level.time<body.NextNoiseStepTic)return;
        body.NoiseStepScheduled=true;
        body.NextNoiseStepTic=level.time+int(Ceil(CaelumConstants.MOVEMENT_NOISE_INTERVAL_SECONDS*TICRATE));
        let soldier=CaelumPortDefender(body);
        bool crouched=soldier!=null && soldier.Carbine!=null && soldier.Carbine.Crouched;
        double movement=crouched ? CaelumConstants.MOVEMENT_NOISE_CROUCH_MULTIPLIER
            : running ? CaelumConstants.MOVEMENT_NOISE_RUN_MULTIPLIER : 1;
        double range=CaelumConstants.MOVEMENT_NOISE_BASE_RANGE_MU*movement*Max(0.0,movedMass/100.0)
            *(1-CaelumVisualPerception.Stealth(body)/100.0)*SurfaceFactor(body)*EquipmentFactor(body);
        Emit(body,CaelumNoiseData.STEP,range);
    }
}
