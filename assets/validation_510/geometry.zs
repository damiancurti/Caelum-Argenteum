class CA130Probe : Actor
{
    Default { Radius 16; Height 56; +NOGRAVITY +NOINTERACTION }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA130Geometry : StaticEventHandler
{
    int Checks,Failures;
    void Verify(bool passed,String label)
    {Checks++;if(!passed)Failures++;Console.Printf("CA130 %s %s",passed?"PASS":"FAIL",label);}
    void CheckAt(double x,bool wind,bool roof,String label)
    {
        let probe=Actor.Spawn("CA130Probe",(x,0,0),NO_REPLACE);
        Verify(CaelumThermalShelter.WindBlocked(probe)==wind,label.." wind");
        Verify(CaelumThermalShelter.Roof(probe)==roof,label.." roof");
        probe.Destroy();
    }
    override void WorldTick()
    {
        if(level.time!=2)return;
        CheckAt(-8000,true,false,"three walls without roof");
        CheckAt(-4000,false,false,"two walls without roof");
        CheckAt(0,true,false,"rotated three walls");
        CheckAt(5000,false,false,"distant walls do not shelter");
        CheckAt(11000,true,true,"four walls and roof");
        Verify(CaelumThermalEnvironment.WaterTemperature(level.Sectors[0],18)==7,"explicit volume water temperature");
        Verify(CaelumThermalEnvironment.WaterTemperature(level.Sectors[1],18)==18,"missing water property uses declared ground fallback");
        let wet=Actor.Spawn("CA130Probe",(14000,0,0),NO_REPLACE);wet.Height=128;
        let thermal=new("CaelumThermalState");
        double fraction=CaelumThermalEnvironment.SampleWater(wet,thermal,18);
        Verify(Abs(fraction-0.75)<0.000001 && thermal.WaterRowMask==65520,"native 3D water covers upper body without wetting dry feet");
        Verify(Abs(thermal.WaterC-29.0/3.0)<0.000001,"distinct water volumes retain their actual temperatures");
        CaelumThermalBody.SampleCoverage(wet,thermal,fraction,thermal.WaterRowMask);
        int slot=CaelumConstants.ARMOR_SLOT_BODY;
        Verify(Abs(thermal.SubmergedCoverage[slot]-0.75)<0.000001,"water mask maps to actual submerged anatomy");
        Verify(Abs(thermal.SubmergedTemperatureC[slot]-29.0/3.0)<0.000001,"regional water temperature weighted by submerged coverage");
        thermal.Available=true;thermal.Bare=true;thermal.ComfortC=22;thermal.ClimateC=22;thermal.AirC=22;
        thermal.SurfaceArea=CaelumThermalRules.Area(80,1.75);thermal.Inertia=CaelumThermalRules.Inertia(80);
        thermal.Material[slot]=-1;thermal.SubmergedCoverage[slot]=1;thermal.Humidity=50;
        CaelumThermalService.Integrate(thermal,1,0);
        Verify(Abs(thermal.Conductance-thermal.SurfaceArea*100)<0.000001,"full immersion replaces air with hc100 and no wet factor duplication");
        Verify(thermal.WetnessPercent==100 && thermal.EvaporatedKg==0,"full immersion saturates without evaporation cooling");
        let probe=Actor.Spawn("CA130Probe",(-8000,0,0),NO_REPLACE);
        let fire=CaelumThermalFireSource(Actor.Spawn("CaelumThermalFireSource",(-7800,0,0),NO_REPLACE));
        fire.args[0]=3;fire.args[1]=8;fire.args[2]=32;
        Verify(CaelumThermalFire.Absorbed(probe,thermal,fire)==0,"wall occludes physical fire radiation");
        fire.SetOrigin((-8000,-200,0),false);
        Verify(CaelumThermalFire.Absorbed(probe,thermal,fire)>0,"open side transmits physical fire radiation");
        Console.Printf("CA130 COMPLETE checks=%d failures=%d",Checks,Failures);
    }
}
