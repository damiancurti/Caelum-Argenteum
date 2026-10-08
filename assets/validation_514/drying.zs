class CA140Drying : StaticEventHandler
{
    int Failures;
    void Check(bool ok,String label)
    {if(!ok)Failures++;Console.Printf("CA140 %s %s",ok ? "PASS" : "FAIL",label);}
    CaelumThermalState Sample()
    {
        let s=new("CaelumThermalState");s.Initialize();s.Available=true;s.Sweats=true;s.CanShiver=true;s.CanBreathe=false;
        s.BodyMassKg=100;s.HeightMeters=1.75;s.SurfaceArea=CaelumThermalRules.Area(100,1.75);s.Inertia=CaelumThermalRules.Inertia(100);
        s.ComfortC=22;s.ClimateC=20.5;s.AirC=20.5;s.Humidity=65;s.WindMps=2.5;s.Roof=true;s.Hydration=100;
        s.ShiveringHunger=100;s.ShiveringHungerPerMetSecond=0.0005;
        for(int i=0;i<4;i++){s.Coverage[i]=0.25;s.Material[i]=CaelumThermalData.METAL_CLOTH;s.WorkWaterKg[i]=0.1;}
        return s;
    }
    override void WorldTick()
    {
        if(level.time!=25)return;
        let probe=Actor.Spawn("CA130Probe",(-8000,0,0));let thermal=Sample();
        let fire=CaelumThermalFireSource(Actor.Spawn("CaelumThermalFireSource",(-7800,0,0)));
        fire.args[0]=3;fire.args[1]=8;fire.args[2]=32;
        double blocked=CaelumThermalFire.Absorbed(probe,thermal,fire);
        fire.SetOrigin((-8000,-200,0),false);double open=CaelumThermalFire.Absorbed(probe,thermal,fire);
        fire.SetOrigin((-8000,-400,0),false);double distant=CaelumThermalFire.Absorbed(probe,thermal,fire);
        Check(blocked==0 && open>distant && distant>0,"native wall and distance attenuate declared flame power before drying");
        let cold=Sample();let warm=Sample();let behind=Sample();
        for(int i=0;i<1200;i++)
        {
            CaelumThermalService.Integrate(cold,1,0,0,0,0);
            CaelumThermalService.Integrate(warm,1,0,0,0,open);
            CaelumThermalService.Integrate(behind,1,0,0,0,blocked);
        }
        double retained=0;for(int i=0;i<4;i++)retained+=warm.WorkWaterKg[i];
        Check(warm.EvaporatedKg>cold.EvaporatedKg && warm.ShiveringJoules<cold.ShiveringJoules,"received flame energy accelerates wet-cloth evaporation and reduces required shivering");
        Check(behind.EvaporatedKg==cold.EvaporatedKg && behind.Exposure==cold.Exposure,"occluded flame supplies no hidden drying bonus");
        Check(Abs(warm.EvaporationJoules-warm.EvaporatedKg*2450000)<1e-6
            && Abs(0.4+warm.SweatKg-warm.SweatRunoffKg-retained-warm.EvaporatedKg)<1e-9,"drying conserves water and charges latent heat once");
        Console.Printf("CA140 DRYING sourceW=%.6f openW=%.6f distantW=%.6f blockedW=%.6f seconds=1200 suppliedFireJ=%.6f noFireEvaporatedMl=%.6f fireEvaporatedMl=%.6f noFireShiverJ=%.6f fireShiverJ=%.6f retainedMl=%.6f failures=%d",
            fire.Watts(),open,distant,blocked,open*1200,cold.EvaporatedKg*1000,warm.EvaporatedKg*1000,cold.ShiveringJoules,warm.ShiveringJoules,retained*1000,Failures);
    }
}
