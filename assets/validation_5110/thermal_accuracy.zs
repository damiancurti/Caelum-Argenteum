// #431: escenarios matematicos; ninguna constante de juego se modifica.
class CA511ThermalAccuracy : EventHandler
{
    int Age;
    CaelumThermalState ThermalSample(int index)
    {
        // Input grid reused from validation_514/checks.zs, without its old solver.
        let s=new("CaelumThermalState");s.Initialize();s.CanBreathe=false;s.CanShiver=false;s.Sweats=index%7!=0;s.Bare=!s.Sweats;s.Available=true;
        s.BodyMassKg=40+40*(index%5);s.HeightMeters=1.2+0.2*(index%5);
        s.SurfaceArea=CaelumThermalRules.Area(s.BodyMassKg,s.HeightMeters);s.Inertia=CaelumThermalRules.Inertia(s.BodyMassKg);
        s.ComfortC=index%3==0?17:index%3==1?22:32;s.ClimateC=s.ComfortC+index%11-5;
        s.AirC=-10+index%61;s.WindMps=(index%6)*1.3;s.Humidity=(index%6)*20;
        s.RainMmHour=index%4;s.Roof=index%2==0;s.Exposure=-35+index%71;s.Toughness=index%101;
        s.Hydration=index%5==0?5:100;s.ActivityWatts=index%4*223.333333333;
        s.Coverage[0]=0.125;s.Coverage[1]=0.375;s.Coverage[2]=0.25;s.Coverage[3]=0.25;
        for(int i=0;i<4;i++){s.Material[i]=index%7==0?-1:(index+i)%5;s.WorkWaterKg[i]=(index%4)*0.02;s.SubmergedCoverage[i]=index%3==0?s.Coverage[i]*0.5:0;s.SubmergedTemperatureC[i]=index%30;}
        return s;
    }
    double ThermalInterval(CaelumThermalState s,int tics,int index,bool fire)
    {
        double dr=double(tics)/TICRATE,dw=tics*CaelumThermalRuntime.WorldTicSeconds(),dose=0;
        int steps=Max(1,int(Ceil(dw/60.0)));
        for(int i=0;i<steps;i++)dose+=CaelumThermalService.Integrate(s,dw/steps,dr/steps,(index%4)*223.333333333,0,fire?800:0,0,index%2==0?116.4:0);
        return dose;
    }

    void Compare(int interval,int index)
    {
        let a=ThermalSample(index);let b=a.CopyForForecast();
        int la=0,lb=0;double da=0,db=0,maxGap=0;bool fire=false;
        int firstA=-1,firstB=-1;
        for(int tic=1;tic<=700;tic++)
        {
            bool event=index>=12 && (tic==175 || tic==350 || tic==525);
            if(tic%35==0 || event || tic==700)
            {da+=ThermalInterval(a,tic-la,index,fire);la=tic;if(firstA<0 && a.Severity>0)firstA=tic;}
            if(tic%interval==0 || event || tic==700)
            {db+=ThermalInterval(b,tic-lb,index,fire);lb=tic;if(firstB<0 && b.Severity>0)firstB=tic;}
            maxGap=Max(maxGap,Abs(a.Exposure-b.Exposure));
            if(event)
            {
                fire=!fire;a.Roof=!a.Roof;b.Roof=a.Roof;
                a.WindMps+=0.3;b.WindMps=a.WindMps;
                for(int k=0;k<4;k++){a.SubmergedCoverage[k]=fire?a.Coverage[k]:0;b.SubmergedCoverage[k]=a.SubmergedCoverage[k];}
            }
        }
        double water=0;for(int i=0;i<4;i++)water=Max(water,Abs(a.WorkWaterKg[i]-b.WorkWaterKg[i]));
        Console.Printf("CA511 THERMAL case=%d interval=%d current=%.12f candidate=%.12f max_gap=%.12f water_error=%.12f hydration_error=%.12f current_dose=%.12f candidate_dose=%.12f activity_error=%.12f first_current=%d first_candidate=%d",index,interval,a.Exposure,b.Exposure,maxGap,water,Abs(a.Hydration-b.Hydration),da,db,Abs(a.ActivityJoules-b.ActivityJoules),firstA,firstB);
        if(la!=700 || lb!=700)Console.Printf("CA511 FAIL elapsed-time conservation");
    }
    override void WorldTick()
    {
        Age++;
        if(Age==5)
        {
            let user=CaelumPlayer(players[0].mo);
            user.CharacterCreationComplete=true;user.CreationWizardOpen=false;user.ApplyCharacterProfile();user.bInvulnerable=true;
        }
        if(Age!=10)return;
        for(int index=0;index<24;index++){Compare(1,index);Compare(35,index);Compare(175,index);}
        Console.Printf("CA511 RESULT thermal accuracy grid complete");
    }
}
