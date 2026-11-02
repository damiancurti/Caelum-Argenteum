// Fuente local persistente. Cierra sus intervalos antes de cambiar de estado;
// una captura no deja contaminación ambiental futura en objetos ni superficies.
class CaelumTarotDirtyRock : CaelumTarotRock
{
    int FieldRevision,NextFieldTic;
    bool FieldActive,Refreshing;
    vector3 FieldCenter;
    CaelumContaminationMap Sheet;
    Array<CaelumContaminationTile> Tiles;
    Array<Actor> Recipients;

    bool Affects(Actor body)
    {
        if(!FieldActive || (bDestroyed && !Refreshing) || body==null)return false;
        vector3 point=body.Pos+(0,0,body.Height/2);
        vector3 ray=point-FieldCenter;
        if(ray.Length()>CaelumMajorArcanaData.ROCK_CONTAMINATION_RADIUS*CaelumPhysicsUnits.MAP_UNITS_PER_METER)return false;
        if(ray.Length()<0.001)return true;
        FLineTraceData hit;
        return !LineTrace(VectorAngle(ray.X,ray.Y),ray.Length(),-VectorAngle(ray.XY.Length(),ray.Z),
            TRF_ABSPOSITION|TRF_THRUACTORS,FieldCenter.Z,FieldCenter.X,FieldCenter.Y,hit);
    }
    void Remember(Actor body)
    {if(!Refreshing && Recipients.Find(body)==Recipients.Size())Recipients.Push(body);}

    void RefreshField(bool enable)
    {
        if(Refreshing)return;
        let world=CaelumThermalWorld.Get();
        let user=world!=null && world.ReferenceClock!=null?CaelumPlayer(world.ReferenceClock.Owner):null;
        if(user==null)return;
        Refreshing=true;
        Array<Actor> previous;
        for(int i=0;i<Recipients.Size();i++)previous.Push(Recipients[i]);
        Recipients.Clear();
        // Incluye los receptores que salieron del radio desde su última muestra,
        // sin rastrear todo el mapa ni retener visitantes indefinidamente.
        for(int i=0;i<previous.Size();i++)
        {
            let body=previous[i];if(body==null || body.bDestroyed)continue;
            let entry=CaelumContaminationStorage.Get(body);
            if(entry!=null && entry.Exposure!=null)entry.Exposure.SettleNow();
            let npc=CaelumCombatActor(body);if(npc!=null)CaelumThermalRuntime.NPCStep(npc,true);
        }
        double now=CaelumContaminationSurfaces.Now(user);
        for(int i=0;i<Tiles.Size();i++)
        {
            let tile=Tiles[i];if(tile==null)continue;
            if(Sheet!=null)Sheet.Sync(tile,now);
            tile.RockSources=Max(0,tile.RockSources-1);tile.WeatherReady=false;
        }
        Tiles.Clear();FieldActive=false;
        FieldCenter=Pos+(0,0,Height/2);
        if(enable && !Contained && !bDestroyed)
        {
            FieldActive=true;
            let field=new('CaelumTarotPollutionSurfaces');field.Rock=self;field.Caster=user;
            field.Center=FieldCenter;
            field.Radius=CaelumMajorArcanaData.ROCK_CONTAMINATION_RADIUS*CaelumPhysicsUnits.MAP_UNITS_PER_METER;
            field.Probe=Actor.Spawn('CaelumTarotContaminationProbe',FieldCenter,NO_REPLACE);
            if(field.Probe!=null)
            {field.Surfaces();Sheet=field.Sheet;field.Probe.Destroy();}
        }
        FieldRevision=1;NextFieldTic=level.maptime+CaelumThermalData.ENVIRONMENT_SAMPLE_TICS;
        Refreshing=false;
        // Reabrir con la fuente nueva conserva la edad anterior y evita que una
        // salida de mapa propague el último valor de una fuente ya guardada.
        for(int i=0;i<previous.Size();i++)
        {
            let body=previous[i];if(body==null || body.bDestroyed)continue;
            let entry=CaelumContaminationStorage.Get(body);
            if(entry!=null && entry.Exposure!=null)entry.Exposure.Advance();
            if(Affects(body))Remember(body);
        }
    }
    override void StopEmissions(){RefreshField(false);}
    override void UpdateComponents()
    {
        Super.UpdateComponents();
        let world=CaelumContaminationWorld.Get();if(world!=null)world.RegisterRock(self);
        if(Contained){if(FieldActive)RefreshField(false);return;}
        if(FieldRevision<1 || !FieldActive || FieldCenter!=Pos+(0,0,Height/2)
            || level.maptime>=NextFieldTic || NextFieldTic>level.maptime+CaelumThermalData.ENVIRONMENT_SAMPLE_TICS)
            RefreshField(true);
    }
    override void OnDestroy()
    {
        Super.OnDestroy();
        let world=CaelumContaminationWorld.Get();if(world!=null)world.ForgetRock(self);
    }
    Default {Tag "$CA_TAROT_DIRTY_ROCK";}
}

// Reutiliza las consultas geométricas locales del pulso, sin aplicar un pulso:
// el campo modifica la fuente ambiental, no la concentración de sus receptores.
class CaelumTarotPollutionSurfaces : CaelumTarotContamination
{
    CaelumTarotDirtyRock Rock;
    override void Paint(CaelumContaminationTile tile,vector3 point)
    {
        if(tile==null || Rock.Tiles.Find(tile)<Rock.Tiles.Size())return;
        // Ya no pertenece a una cohorte de clima invariable desde el origen.
        tile.RockTouched=true;
        Probe.SetOrigin(point+(0,0,0.01),false);
        if(tile.Profile==0)CaelumContaminationSurfaceContact.ConfigureObject(Probe,tile);
        Sheet.Sync(tile,CaelumContaminationSurfaces.Now(Caster));
        CaelumContaminationSurfaceContact.ConfigureObject(Probe,tile);
        tile.RockSources++;tile.WeatherReady=false;Rock.Tiles.Push(tile);SurfaceCount++;
    }
}
