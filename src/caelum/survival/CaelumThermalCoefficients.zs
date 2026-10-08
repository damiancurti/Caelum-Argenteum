// Proyección descartable: no posee exposición, agua ni energía del personaje.
// Las claves comprueban entradas físicas; nunca se conserva un flujo constante.
class CaelumThermalCoefficients : Object play
{
    bool Ready,Bare,AmbientReady,CoverageReady;
    double Area,Mass,Wind,Air,Humidity;
    double Rest,ReferenceOffset,HydrationPoints,MaximumSweat,Film,Convection,VaporAir,RespirationConductance;
    double Fraction[4],Immersion[4],PieceArea[4],ExposedArea[4],Capacity[4];
    int Material[4];
    double AirConductance[4],WaterConductance[4],SurfaceScale[4],EvaporationFactor[4];
    CaelumAnatomyProfile Anatomy;
    int AnatomyGeneration;
    double RowCoverage[64];
    int GeometryBuilds,MaterialBuilds,FilmBuilds,AmbientBuilds,CoverageBuilds,Hits,Misses,FluxUpdates,EnvironmentSamples;

    static CaelumThermalCoefficients Get(CaelumThermalState thermal)
    {
        if(thermal.Coefficients==null)thermal.Coefficients=new("CaelumThermalCoefficients");
        return thermal.Coefficients;
    }

    void Prepare(CaelumThermalState thermal)
    {
        bool geometry=!Ready || Area!=thermal.SurfaceArea || Mass!=thermal.BodyMassKg || Bare!=thermal.Bare;
        bool windChanged=!Ready || Wind!=thermal.WindMps;
        bool changed=geometry || windChanged;
        if(geometry)
        {
            Area=thermal.SurfaceArea;Mass=thermal.BodyMassKg;Bare=thermal.Bare;GeometryBuilds++;
            double reference=CaelumThermalRules.Area(CaelumThermalData.REFERENCE_MASS_KG,CaelumThermalData.REFERENCE_HEIGHT_METERS);
            MaximumSweat=CaelumThermalData.SWEAT_MAX_KG_HOUR*Max(0.0,Area)/reference;
            HydrationPoints=CaelumThermalRules.HydrationPointsPerKg(Mass);
            Rest=Area*CaelumThermalData.MET_WATTS_M2;
            RespirationConductance=CaelumThermalData.BREATHING_LITERS_MINUTE/1000.0/60.0
                *CaelumThermalData.AIR_DENSITY_KG_M3*CaelumThermalData.AIR_SPECIFIC_HEAT_J_KG_K
                *Max(0.001,Mass)/CaelumThermalData.REFERENCE_MASS_KG;
            double referenceG=Bare ? Area*(CaelumThermalRules.AirConvection(CaelumThermalData.NATURAL_WIND_MPS)
                +CaelumThermalData.REFERENCE_RADIATION) : CaelumThermalRules.ReferenceConductance(Area);
            ReferenceOffset=referenceG>0 ? Rest/referenceG : 0;
        }
        if(windChanged)
        {
            Wind=thermal.WindMps;Convection=CaelumThermalRules.AirConvection(Wind);
            Film=Convection+CaelumThermalData.REFERENCE_RADIATION;FilmBuilds++;
        }
        if(!AmbientReady || Air!=thermal.AirC || Humidity!=thermal.Humidity)
        {
            Air=thermal.AirC;Humidity=thermal.Humidity;
            VaporAir=CaelumThermalMoisture.VaporKpa(Air)*Clamp(Humidity,0.0,100.0)/100.0;
            AmbientReady=true;AmbientBuilds++;changed=true;
        }
        for(int slot=0;slot<4;slot++)
        {
            bool shape=geometry || !Ready || Fraction[slot]!=thermal.Coverage[slot]
                || Immersion[slot]!=thermal.SubmergedCoverage[slot];
            bool materialChanged=!Ready || Material[slot]!=thermal.Material[slot];
            if(shape || materialChanged)
            {
                Fraction[slot]=thermal.Coverage[slot];Immersion[slot]=thermal.SubmergedCoverage[slot];
                Material[slot]=thermal.Material[slot];MaterialBuilds++;changed=true;
                PieceArea[slot]=Area*Fraction[slot];
                ExposedArea[slot]=Area*Max(0.0,Fraction[slot]-Min(Fraction[slot],Immersion[slot]));
                Capacity[slot]=PieceArea[slot]*CaelumThermalMoisture.CapacityPerArea(Material[slot]);
            }
            if(shape || materialChanged || windChanged)
            {
                double clo=CaelumThermalData.Clo(Material[slot]);
                AirConductance[slot]=ExposedArea[slot]*CaelumThermalRules.ConductancePerArea(clo,Film);
                WaterConductance[slot]=Area*Min(Fraction[slot],Immersion[slot])
                    *CaelumThermalRules.ConductancePerArea(clo,CaelumThermalData.WATER_CONVECTION);
                SurfaceScale[slot]=1.0/(1+CaelumThermalData.CLO_RESISTANCE*clo*Film);
                EvaporationFactor[slot]=CaelumThermalData.Permeability(Material[slot])*CaelumThermalData.LEWIS_K_PER_KPA
                    *Convection/CaelumThermalData.LATENT_J_PER_KG;
            }
        }
        if(changed)Misses++;else Hits++;
        Ready=true;
    }

    // La anatomía sólo cambia por sus constructores. Su generación se invalida
    // al añadir/reconstruir regiones; la caché completa se descarta al cargar.
    void PrepareCoverage(CaelumAnatomyProfile profile)
    {
        int generation=profile!=null ? profile.ShapeGeneration : 0;
        if(CoverageReady && Anatomy==profile && AnatomyGeneration==generation)return;
        Anatomy=profile;AnatomyGeneration=generation;CoverageReady=true;CoverageBuilds++;
        for(int i=0;i<64;i++)RowCoverage[i]=0;
        int count=CaelumThermalData.SURFACE_SAMPLES;
        double weight=1.0/(count*count);
        for(int z=0;z<count;z++)for(int side=0;side<count;side++)
        {
            int region=profile!=null ? profile.FindRegion((z+0.5)/count,(side+0.5)/count) : -1;
            int slot=region>=0 ? Clamp(profile.RegionLocation[region]-1,0,3) : CaelumConstants.ARMOR_SLOT_BODY;
            RowCoverage[z*4+slot]+=weight;
        }
    }
}
