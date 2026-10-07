// Isolated native checks. No production shortcuts or fixture actors are shipped.
class CA130Checks : StaticEventHandler
{
    int Checks,Failures;
    CaelumCombatActor Bull,Rat,Demon,Boss;
    void Verify(bool condition,String label)
    {
        Checks++;
        if(!condition)Failures++;
        Console.Printf("CA130 %s %s",condition?"PASS":"FAIL",label);
    }
    bool Near(double actual,double expected,double tolerance=0.000001)
    {return Abs(actual-expected)<=tolerance;}
    void BodyChecks()
    {
        let bull=Bull;let rat=Rat;
        let bt=CaelumThermalBody.Get(bull,true);let rt=CaelumThermalBody.Get(rat,true);
        CaelumThermalBody.Refresh(bull,bt);CaelumThermalBody.Refresh(rat,rt);
        Verify(bt.ComfortC==17 && rt.ComfortC==17,"furry animals share authored comfort");
        Verify(bt.BodyMassKg==900 && rt.BodyMassKg==10,"animal biological mass preserved");
        Verify(bt.Toughness==20 && rt.Toughness==1,"animal individual Toughness preserved");
        Verify(CaelumThermalData.Clo(CaelumThermalBody.Material(bull,0))==0,"unarmored animal no invented clothing or extra fur clo");
        CaelumThermalService.Impulse(bull,100);CaelumThermalService.Impulse(rat,100);
        Verify(Near(rt.Exposure/bt.Exposure,90),"equal absorbed energy rat exposure ninety times bull");
        Verify(bt.SurfaceArea>rt.SurfaceArea,"animal surface uses actual collider dimensions");
        Console.Printf("CA130 ANIMALS bull area=%.6f C=%.6f E100J=%.9f rat area=%.6f C=%.6f E100J=%.9f",
            bt.SurfaceArea,bt.Inertia,bt.Exposure,rt.SurfaceArea,rt.Inertia,rt.Exposure);
        // Unit fixture at exactly 75% thermal resistance, separate from the
        // integral runtime attribute fixtures above. Native HP/armor path used.
        bull.CombatMaximumHealth=10000;bull.health=10000;
        bt.Toughness=(-1+Sqrt(1+4*7575.0))/2;bt.DamageRemainder=0;
        double adrenaline=bull.CurrentCombatAdrenaline;
        CaelumThermalService.ApplyDamage(bull,bt,1);
        Verify(bull.health==9975,"75 percent resistance tier one quarter percent HP");
        CaelumThermalService.ApplyDamage(bull,bt,2);
        Verify(bull.health==9925,"75 percent resistance tier two half percent HP");
        CaelumThermalService.ApplyDamage(bull,bt,3);
        Verify(bull.health==9850,"75 percent resistance tier three three quarters percent HP");
        Verify(bull.CurrentCombatAdrenaline==adrenaline,"thermal HP route grants no combat adrenaline");
        bt.Toughness=0;bt.DamageRemainder=0;bull.health=10000;
        for(int tick=0;tick<TICRATE;tick++)CaelumThermalService.ApplyDamage(bull,bt,1.0/TICRATE);
        Verify(bull.health==9900 && bt.DamageRemainder<0.000001,"fractional HP survives thirty five small updates");
        bt.Toughness=100;CaelumThermalService.ApplyDamage(bull,bt,3);
        Verify(bull.health==9900,"D100 thermal damage is zero");
        bt.WorkWaterKg[0]=0.2;
        let forecast=bt.CopyForForecast();forecast.Exposure=100;forecast.WorkWaterKg[0]=0;
        Verify(bt.Exposure!=100 && bt.WorkWaterKg[0]==0.2,"forecast state and arrays are independent");
        bull.Destroy();rat.Destroy();
        let demon=Demon;let boss=Boss;
        int demonHealth=demon.health,bossHealth=boss.health;
        let dt=CaelumThermalBody.Get(demon,true);let zt=CaelumThermalBody.Get(boss,true);
        CaelumThermalBody.Refresh(demon,dt);CaelumThermalBody.Refresh(boss,zt);
        Verify(dt.ComfortC==32 && zt.ComfortC==32,"both demon classes use comfort32");
        Verify(dt.BodyMassKg==66 && zt.BodyMassKg==666,"demon mass not copied from humans");
        let weather=new("CaelumWeatherSample");
        int date=CaelumCalendarRules.ToSerial(1889,11,3);
        weather.Evaluate(2,date,9*CaelumWorldClock.TicsPerHour(),1);
        dt.Available=true;zt.Available=true;dt.Roof=true;zt.Roof=true;
        dt.AirC=weather.AirTemperatureC;zt.AirC=weather.AirTemperatureC;
        dt.ClimateC=weather.AirTemperatureC;zt.ClimateC=weather.AirTemperatureC;
        dt.Humidity=weather.RelativeHumidityPercent;zt.Humidity=weather.RelativeHumidityPercent;
        CaelumThermalBody.SampleCoverage(demon,dt,0);CaelumThermalBody.SampleCoverage(boss,zt,0);
        int firstDemon=0,firstBoss=0;
        for(int elapsed=20;elapsed<=4*3600;elapsed+=20)
        {
            // Explicit solver exercise, not a claim of four live wall-clock hours.
            CaelumThermalService.Advance(demon,20,0);
            CaelumThermalService.Advance(boss,20,0);
            if(firstDemon==0 && dt.Severity>0)firstDemon=elapsed;
            if(firstBoss==0 && zt.Severity>0)firstBoss=elapsed;
        }
        Console.Printf("CA130 SEWERS date=1889-11-03 09:00 seed=1 air=%.6f RH=%.6f Mandinga threshold_seconds=%d E=%.6f tier=%d Zupay threshold_seconds=%d E=%.6f tier=%d",
            weather.AirTemperatureC,weather.RelativeHumidityPercent,firstDemon,dt.Exposure,dt.Severity,firstBoss,zt.Exposure,zt.Severity);
        Verify(dt.Exposure<0 && zt.Exposure<0,"sewer environment cools both demon classes");
        Verify(demon.health==demonHealth && boss.health==bossHealth,"world-only forecast causes no fabricated HP damage");
        demon.Destroy();boss.Destroy();
        for(int material=0;material<4;material++)
        {
            double capacity=CaelumThermalMoisture.CapacityPerArea(material);
            let drying=new("CaelumThermalState");
            drying.Available=true;drying.BodyMassKg=80;drying.HeightMeters=1.75;
            drying.SurfaceArea=CaelumThermalRules.Area(80,1.75);drying.Inertia=CaelumThermalRules.Inertia(80);
            drying.ComfortC=22;drying.ClimateC=22;drying.AirC=22;drying.Humidity=50;drying.WindMps=1;
            drying.Coverage[0]=1;drying.Material[0]=material;drying.WorkWaterKg[0]=capacity*drying.SurfaceArea;
            int drySeconds=0;
            do
            {
                CaelumThermalService.Integrate(drying,1,0);drySeconds++;
            }while(drying.WetnessPercent>CaelumThermalData.DRY_PERCENT_TOLERANCE && drySeconds<20000);
            Verify(Abs(drySeconds-CaelumThermalData.DryingSeconds(material))<=2,
                String.Format("material %d coupled reference drying",material));
            Verify(Near(drying.EvaporatedKg+drying.WorkWaterKg[0],capacity*drying.SurfaceArea),"drying conserves available water");
            Verify(Near(drying.EvaporationJoules,drying.EvaporatedKg*CaelumThermalData.LATENT_J_PER_KG),"evaporation latent energy accounted once");
            Console.Printf("CA130 DRY material=%d seconds=%d wet=%.9f evaporatedkg=%.9f E=%.9f",
                material,drySeconds,drying.WetnessPercent,drying.EvaporatedKg,drying.Exposure);
            Verify(CaelumThermalMoisture.Evaporated(capacity,1,material,22,22,100,1,3600)==0,
                String.Format("material %d saturated air no evaporation gradient",material));
        }
    }
    override void WorldTick()
    {
        if(level.time==1)
        {
            Bull=CaelumCombatActor(Actor.Spawn("CaelumBull",(512,512,0),NO_REPLACE));
            Rat=CaelumCombatActor(Actor.Spawn("CaelumGiantRat",(768,512,0),NO_REPLACE));
            Demon=CaelumCombatActor(Actor.Spawn("CaelumMandinga",(-512,512,0),NO_REPLACE));
            Boss=CaelumCombatActor(Actor.Spawn("CaelumZupayColossus",(-1024,512,0),NO_REPLACE));
            return;
        }
        if(level.time!=2)return;
        Verify(CaelumThermalRules.Comfort(CaelumConstants.RACE_HUMAN)==22,"human comfort");
        Verify(CaelumThermalRules.Comfort(CaelumConstants.RACE_GOBLIN)==22,"duende comfort");
        Verify(CaelumThermalRules.Comfort(CaelumConstants.RACE_BEAST_MAN)==17,"beast comfort");
        Verify(CaelumThermalRules.Comfort(CaelumConstants.RACE_CAELITH)==17,"Caelith comfort");
        Verify(CaelumThermalRules.Comfort(CaelumConstants.RACE_GOBLIN,true)==32,"author demon comfort");
        Verify(CaelumThermalRules.Severity(9.99,0)==0,"below first threshold");
        Verify(CaelumThermalRules.Severity(10,0)==1,"exact first threshold");
        Verify(CaelumThermalRules.Severity(-20,0)==2,"exact second threshold");
        Verify(CaelumThermalRules.Severity(30,0)==2,"exact third threshold stays tier two");
        Verify(CaelumThermalRules.Severity(-30.00001,0)==3,"past third threshold");
        Verify(Near(CaelumThermalRules.ThresholdScale(100),2),"D100 thresholds doubled");
        Verify(Near(CaelumThermalRules.DamageResistance(100),1),"D100 thermal immunity");
        Verify(CaelumThermalRules.ThresholdScale(200)>4,"thresholds uncapped");
        Verify(Near(CaelumThermalRules.ColdAttack(-31,0,true),3.375),"extreme cold blunt");
        Verify(Near(CaelumThermalRules.ColdAttack(-31,0,false),2.1875),"extreme cold other");
        Verify(Near(CaelumThermalRules.Speed(-31,0),1.0/2.1875),"extreme cold speed");
        Verify(CaelumThermalRules.HeatCost(31,0)==4,"extreme heat costs");
        double area=CaelumThermalRules.Area(80,1.75);
        double g=CaelumThermalRules.ReferenceConductance(area);
        double c=CaelumThermalRules.Inertia(80);
        Verify(Near(area,1.95149,0.00001),"body surface reference");
        Verify(Near(c,11291.795,0.01),"gameplay inertia reference");
        Verify(Near(100/c,0.00885599,0.00000001),"100 joule impulse");
        Verify(Near(100/CaelumThermalRules.Inertia(40),0.01771198,0.00000001),"40 kg impulse");
        Verify(Near(100/CaelumThermalRules.Inertia(160),0.00442799,0.00000001),"160 kg impulse");
        Verify(Near(CaelumThermalRules.Inertia(40)/CaelumThermalRules.ReferenceConductance(
            CaelumThermalRules.Area(40,1.75))/60,13.426,0.01),"40 kg response time");
        Verify(Near(CaelumThermalRules.Inertia(160)/CaelumThermalRules.ReferenceConductance(
            CaelumThermalRules.Area(160,1.75))/60,29.794,0.01),"160 kg response time");
        Verify(CaelumThermalRules.ReferenceConductance(CaelumThermalRules.Area(80,2.0))>g,
            "height raises conductance at unchanged mass inertia");
        Verify(Near(CaelumThermalRules.Advance(0,10*g,g,c,1200),6.321205588),"20 minute response");
        Verify(Near(CaelumThermalRules.Advance(0,10*g,g,c,2400),8.646647168),"40 minute response");
        Verify(Near(CaelumThermalRules.Advance(0,10*g,g,c,3600),9.502129316),"60 minute response");
        Verify(Near(CaelumThermalRules.Advance(10,0,g,c,1200),3.678794412),"symmetric recovery");
        Verify(CaelumThermalRules.Advance(0,0,g,c,3600)==0,"neutral reference no drift");
        Verify(Near(CaelumThermalRules.Advance(0,0,g,c,0,1,100),100/c),"zero world duration magic");
        Verify(Near(CaelumThermalRules.ActivityPower(100,0,120),50),"two world minute excess heat half life");
        Verify(Near(CaelumThermalRules.AverageActivityPower(100,0,120),50/Log(2.0)),"recovery integrated energy budget");
        Verify(Near(CaelumThermalRules.LocomotionHeat(80,5/3.6,0,false,9.81),223.333333333),"walking reference watts");
        Verify(Near(CaelumThermalRules.LocomotionHeat(80,10/3.6,0,true,9.81),893.333333333),"running reference watts");
        Verify(Near(CaelumThermalRules.LocomotionHeat(100,5/3.6,0,false,9.81),279.166666667),"loaded walking reference watts");
        Verify(Near(CaelumThermalRules.LocomotionHeat(160,5/3.6,0,false,9.81),446.666666667),"body mass doubles locomotor heat");
        Verify(Near(CaelumThermalRules.LocomotionHeat(80,5/3.6,0.05,false,9.81),369.833333333),"ascent external work subtracted once");
        Verify(Near(CaelumThermalRules.JumpHeat(80,0,Sqrt(2*9.81*0.5)),1177.2),"jump launch reference joules");
        Verify(CaelumThermalRules.JumpHeat(80,3,2)==0,"no positive launch work no impulse");
        Verify(CaelumThermalRules.ActivityPower(0,2000,1)==2000,"no obsolete met ceiling");
        Verify(CaelumThermalData.DownhillCostRatio(-0.1,false)<1,"moderate descent lowers walking effort");
        Verify(CaelumThermalData.DownhillCostRatio(-0.45,false)>CaelumThermalData.DownhillCostRatio(-0.1,false),"steep descent increases braking effort");
        Verify(Near(CaelumThermalData.DownhillCostRatio(0,true),1),"downhill and level costs join continuously");
        Verify(CaelumThermalRules.LocomotionHeat(80,0,-0.1,false,9.81)==0,"no supported displacement no locomotion heat");
        Verify(Near(CaelumThermalRules.ProfiledActionHeat(1177.2,2.5,5),588.6),"author action ratio anchored to jump");
        Verify(CaelumThermalRules.Acclimation(0,50,22,86400)==1,"one degree per world day");
        Verify(CaelumThermalRules.Acclimation(4.9,50,22,86400)==5,"acclimation bound");
        Verify(Near(CaelumThermalRules.SeveritySeconds(0,40,0,1,1,1,0),1.5),"integrated severity crossing");
        BodyChecks();
        Console.Printf("CA130 COMPLETE checks=%d failures=%d",Checks,Failures);
    }
}
