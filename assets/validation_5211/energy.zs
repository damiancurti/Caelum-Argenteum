// Valores esperados independientes del código de producción.
class CA194Target : CaelumCombatActor
{
    override void Tick() {}
    Default { Radius 16; Height 56; Mass 80; Health 1000000; +SHOOTABLE; +SOLID; +NOGRAVITY; }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA194Scenery : CaelumEnvironmentProp
{
    Default { Radius 16; Height 56; Health 0; Mass 100; +SOLID; +NOGRAVITY; -SHOOTABLE; }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA194Energy : StaticEventHandler
{
    int Age,Passes,Failures;
    void Check(String label,double actual,double expected,double tolerance=0.000001)
    {
        bool ok=Abs(actual-expected)<=tolerance;
        if(ok)Passes++;else Failures++;
        Console.Printf("CA194 %s %s actual=%.9f expected=%.9f",ok?"PASS":"FAIL",label,actual,expected);
    }
    override void UiTick() { if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close(); }
    void Mathematics()
    {
        Check("200/70 8m/s",ImpactPhysics.ReceivedEnergySI(200,70,8),1659.259259259);
        Check("70/200 8m/s",ImpactPhysics.ReceivedEnergySI(70,200,8),1659.259259259);
        Check("200/70 approach 16m/s",ImpactPhysics.ReceivedEnergySI(200,70,16),6637.037037037);
        Check("200/200",ImpactPhysics.ReceivedEnergySI(200,200,8),3200);
        Check("70/70",ImpactPhysics.ReceivedEnergySI(70,70,8),1120);
        Check("anchored",ImpactPhysics.ReceivedEnergySI(200,0,8),6400);
        Check("cannon free",ImpactPhysics.ReceivedEnergySI(4.3,200,500),526186.979931474,0.0001);
        Check("cannon anchored",ImpactPhysics.ReceivedEnergySI(4.3,0,500),537500);
        Check("rest",ImpactPhysics.ReceivedEnergySI(200,70,0),0);
        Check("separating",ImpactPhysics.ReceivedEnergySI(200,70,-8),0);
        Check("engine SI",CaelumImpactEnergy.Received(200,70,8*32.0/35.0),1659.259259259);
        let first=new("ImpactBody"), second=new("ImpactBody"), result=new("ImpactResult");
        first.Mass=200;second.Mass=70;first.Height=second.Height=56;
        for(int order=0;order<2;order++)for(int offset=0;offset<3;offset++)
        {
            first.Velocity=((8+offset*100)*32.0/35.0,99,0);
            second.Velocity=(offset*100*32.0/35.0,-57,0);
            if(order==0)ImpactPhysics.ResolveBodies(first,second,(1,0,0),result);
            else ImpactPhysics.ResolveBodies(second,first,(-1,0,0),result);
            Check("relative normal/frame/initiator",CaelumImpactEnergy.Received(200,70,result.ClosingSpeed),1659.259259259);
        }
        first.Velocity=(0,50,0);second.Velocity=(0,0,0);
        ImpactPhysics.ResolveBodies(first,second,(1,0,0),result);
        Check("tangential zero",result.Valid,0);
        first.Velocity=(0,50,-8*32.0/35.0);
        ImpactPhysics.ResolveBodies(first,second,(0,0,-1),result);
        Check("vertical normal",CaelumImpactEnergy.Received(200,70,result.ClosingSpeed),1659.259259259);
        let contact=new("ImpactContactState");
        contact.LastSustainedTick=-1;
        Check("work SI",CaelumImpactEnergy.Work(10*32.0/35.0,4*32.0/35.0),20);
        contact.RegisterSustainedTransfer(1,4,10,2,20);
        contact.RegisterSustainedTransfer(1,4,10,2,20);
        Check("work once per tic",contact.PendingWorkJoules,20);
        Check("work interval",contact.RegisterSustainedTransfer(2,4,10,2,20),1);
        Check("work sum",contact.PendingWorkJoules,40);
    }
    void Geometry()
    {
        let actor=Actor.Spawn("CA194Target",(1024,1024,32));actor.Angle=0;
        let source=Actor.Spawn("CA194Target",(1056,1024,32));
        let profile=new("CaelumAnatomyProfile");profile.InitializeHumanoid();
        let area=new("CaelumImpactArea");area.Build(actor,source,profile,0,1,(1,0,0));
        Check("face square meters",area.TotalArea,32*56.0/(32*32));
        Check("head area",area.RegionArea[0]/area.TotalArea,0.2);
        Check("arms area priority",area.RegionArea[1]/area.TotalArea,0.1);
        Check("torso excludes arms",area.RegionArea[2]/area.TotalArea,0.35);
        Check("legs exclude arms",area.RegionArea[3]/area.TotalArea,0.35);
        Check("covered area",area.NeutralArea,0);
        actor.Angle=90;area.Build(actor,source,profile,0,1,(1,0,0));
        Check("rotated arms",area.RegionArea[1]/area.TotalArea,0.2);
        Check("rotated torso",area.RegionArea[2]/area.TotalArea,0.3);
        area.Build(actor,source,profile,0.6,0.6,(1,0,0));
        Check("unknown degenerate neutral",area.TotalArea,0);
        area.Build(actor,source,profile,0,0,(0,0,-1));
        Check("edge only zero physical area",area.TotalArea,0);
        source.SetOrigin(actor.Pos,false);area.Build(actor,source,profile,0,0,(0,0,-1));
        Check("floor physical area",area.TotalArea,1);
        Check("floor legs only",area.RegionArea[3],1);
        profile.ClearRegions();
        profile.AddRegion(0,0,0,0.75,0,1);profile.AddRegion(1,1,0.75,1,0,1);
        actor.Angle=0;source.SetOrigin(actor.Pos+(32,0,0),false);
        area.Build(actor,source,profile,0,1,(1,0,0));
        Check("75 percent area",area.RegionArea[0]/area.TotalArea,0.75);
        Check("25 percent area",area.RegionArea[1]/area.TotalArea,0.25);
        Check("100J localized 125",100*(area.RegionArea[0]+2*area.RegionArea[1])/area.TotalArea,125);
        profile.InitializeBullQuadruped();
        area.Build(actor,source,profile,0,1,(1,0,0));
        Check("bull front head",area.RegionArea[0]/area.TotalArea,0.58);
        Check("bull front legs survive shared boundary",(area.RegionArea[2]+area.RegionArea[3]+area.RegionArea[4]+area.RegionArea[5])/area.TotalArea,0.42);
        source.SetOrigin(actor.Pos+(0,32,0),false);
        area.Build(actor,source,profile,0,1,(0,1,0));
        Check("bull side head physical area",area.RegionArea[0]/area.TotalArea,0.1595);
        Check("bull side torso physical area",area.RegionArea[1]/area.TotalArea,0.4205);
        for(int angle=0;angle<360;angle+=15)
        {
            actor.Angle=angle;area.Build(actor,source,profile,0,1,(0,1,0));
            double sum=area.NeutralArea;for(int i=0;i<profile.RegionCount;i++)sum+=area.RegionArea[i];
            Check("rotated area partition no loss/overlap",sum,area.TotalArea);
        }
        profile.InitializeHumanoid();actor.Angle=0;source.A_SetSize(16,28);
        area.Build(actor,source,profile,0,1,(0,1,0));
        Check("crouching source clips physical height",area.TotalArea,0.875);
        Check("crouching source excludes head",area.RegionArea[0],0);
        actor.Destroy();source.Destroy();
    }
    override void WorldTick()
    {
        Age++;
        if(Age==3)
        {
            Mathematics();Geometry();
            Console.Printf("CA194 DONE failures=%d passes=%d",Failures,Passes);
        }
    }
}
