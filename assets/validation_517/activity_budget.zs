// Engine-side conservation checks, independent of the filter implementation.
class CA136ActivityBudget : EventHandler
{
    int Checks,Failures;
    void Check(bool ok,String label)
    {Checks++;if(!ok)Failures++;Console.Printf("CA136 %s %s",ok ? "PASS" : "FAIL",label);}
    double Budget(CaelumThermalState s)
    {return s.ActivityJoules;}
    CaelumThermalState Sample(int race,int material)
    {
        let s=new("CaelumThermalState");s.Initialize();
        s.BodyMassKg=80;s.SurfaceArea=CaelumThermalRules.Area(80,1.75);
        s.Inertia=CaelumThermalRules.Inertia(80);s.Available=true;
        s.ComfortC=CaelumThermalRules.Comfort(race,false);s.AirC=s.ComfortC;
        s.ClimateC=s.ComfortC;s.Humidity=55;s.Hydration=100;s.AcclimationMultiplier=1;
        s.Sweats=true;s.CanBreathe=true;s.BreathingAirRatio=1;s.Toughness=20;
        for(int slot=0;slot<4;slot++){s.Coverage[slot]=0.25;s.Material[slot]=material;}
        return s;
    }
    override void WorldTick()
    {
        if(level.time!=2)return;
        for(int clock=0;clock<2;clock++)
        {
            double dw=clock==0 ? 1.0/35 : 20.0/35;
            let s=new("CaelumThermalState");s.Initialize();s.Inertia=1000;
            CaelumThermalService.Integrate(s,dw,1.0/35,5000);
            for(int n=0;n<400;n++)CaelumThermalService.Integrate(s,dw,1.0/35);
            Check(Abs(Budget(s)-5000.0/35)<0.000001 && s.ActivityWatts==0,"one native tic heats once; stopped action produces zero heat on both clocks");
            Check(Abs(s.Exposure*s.Inertia-s.ActivityJoules)<0.000001,"unavailable climate applies emitted heat exactly once");
            double prior=Budget(s);
            CaelumThermalService.Integrate(s,120,0);
            Check(Abs(Budget(s)-prior)<0.000001,"personal time without action produces no effort heat");
            CaelumThermalService.Integrate(s,0,1,700);
            Check(Abs(Budget(s)-prior-700)<0.000001,"real work heats immediately even with zero world time");
        }
        let one=new("CaelumThermalState");one.Initialize();one.Inertia=1000;
        CaelumThermalService.Integrate(one,1,1,5000);
        double initial=one.Exposure;
        CaelumThermalService.Integrate(one,120,120);
        Check(one.ActivityWatts==0 && one.Exposure==initial && Abs(Budget(one)-5000)<0.000001,"one second at 5000 watts adds exactly 5000 joules and no recovery heat");
        Check(CaelumThermalRules.ActivityPower(5000,0,1)==0 && CaelumThermalRules.AverageActivityPower(5000,0,1)==0,"legacy adapters cannot reinstate a recovery tail");
        Check(Abs(CaelumThermalEffects.SwimmingWatts(2,false)-582)<0.000001,"moderate swimming is six MET minus already counted rest");
        Check(Abs(CaelumThermalEffects.SwimmingWatts(2,true)-1047.6)<0.000001,"fast swimming is ten MET minus already counted rest");
        Check(Abs(CaelumThermalEffects.PushingWatts(2)-582)<0.000001,"pushing is six MET independent of amplified jump energy");
        double before=Budget(one);let travel=one.CopyForForecast();
        CaelumThermalService.Integrate(travel,60,0,300,0,0,60);
        Check(Abs(Budget(travel)-before-18000)<0.000001 && Budget(one)==before,"journey projection adds logical work once and leaves source untouched");
        for(int race=0;race<4;race++)for(int material=0;material<5;material++)
        {
            let s=Sample(race,material);double input=0;
            for(int n=0;n<120;n++)
            {
                double power=n<20 ? 800 : 0;
                input+=power*0.1;
                CaelumThermalService.Integrate(s,2,0.1,power);
            }
            Check(Abs(Budget(s)-input)<0.000001 && s.Exposure==s.Exposure && s.Exposure<10,"four races by five materials conserve effort with coupled sweat and environment");
        }
        let old=Sample(0,3);old.Revision=6;old.ActivityWatts=6393;old.Exposure=24.268;
        old.DamageRemainder=0.4;old.WorkWaterKg[0]=0.08;old.Hydration=42;
        old.Initialize();
        Check(old.Revision==7 && old.ActivityWatts==0 && old.Exposure==24.268 && old.DamageRemainder==0.4
            && old.WorkWaterKg[0]==0.08 && old.Hydration==42,"revision 7 removes only unfunded legacy tail");
        old.ActivityWatts=12;old.Initialize();
        Check(old.ActivityWatts==12,"revision 7 migration is idempotent");
        Console.Printf("CA136 BUDGET COMPLETE checks=%d failures=%d",Checks,Failures);
    }
}
