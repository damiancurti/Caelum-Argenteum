class CA195NeutralBull : CaelumBull
{
    bool NeutralInnate;
    override void Tick() {}
    override double GetInnateArmorDefense(bool magical){return NeutralInnate ? 0 : Super.GetInnateArmorDefense(magical);}
}
class CA195Contacts : StaticEventHandler
{
    int Age,Passes,Failures;
    CaelumBull Bull;
    CaelumAnchoredResident Body;
    void Check(String label,double actual,double expected,double tolerance=0.000001)
    {
        bool ok=Abs(actual-expected)<=tolerance;if(ok)Passes++;else Failures++;
        Console.Printf("CA195 %s %s actual=%.9f expected=%.9f",ok?"PASS":"FAIL",label,actual,expected);
    }
    override void UiTick(){if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    void RunCase(int resident,int motion,bool neutral,bool reversed)
    {
        Class<CaelumAnchoredResident> types[]={"CaelumRulo","CaelumRonnie","CaelumArgento","CaelumCaella"};
        let bull=Bull;let body=Body;
        CA195NeutralBull(bull).NeutralInnate=neutral;
        body.StoryAnchored=true;body.EnsureResidentTools();body.bInvulnerable=false;body.Angle=180;
        bull.target=body;bull.BullChargeActive=true;
        if(neutral)
        {
            bull.AnatomyProfile.ClearRegions();bull.AnatomyProfile.AddRegion(CaelumConstants.HIT_LOCATION_TORSO,3,0,1,0,1);
            body.AnatomyProfile.ClearRegions();body.AnatomyProfile.AddRegion(CaelumConstants.HIT_LOCATION_TORSO,3,0,1,0,1);
        }
        double mass=body.GetCollisionEffectiveMass();
        double relative=motion==0 ? 10 : motion==1 ? 5 : 15;
        bull.Vel=(10*32.0/35,0,0);body.Vel=((motion==0 ? 0 : motion==1 ? 5 : -5)*32.0/35,0,0);
        double joules=0.5*(900*mass/(900+mass))*relative*relative;
        let a=bull.BuildImpactPhysicsBody(),b=body.BuildImpactPhysicsBody(),result=new("ImpactResult");
        if(reversed)
        {
            ImpactPhysics.ResolveBodies(b,a,(-1,0,0),result);
            CaelumImpactEnergy.Pair(body,bull,b,a,result,CaelumConstants.IMPACT_KIND_ACTOR);
        }
        else
        {
            ImpactPhysics.ResolveBodies(a,b,(1,0,0),result);
            CaelumImpactEnergy.Pair(bull,body,a,b,result,CaelumConstants.IMPACT_KIND_ACTOR);
        }
        Check("bilateral raw bull",bull.LastImpactReceivedJoules,joules);
        Check("bilateral raw resident",body.LastImpactReceivedJoules,joules);
        Check("bull personal cushion",bull.LastImpactCushionedJoules,joules*0.598492890584,0.00001);
        Check("resident energy not reduced by bull cushion",body.LastImpactCushionedJoules,joules);
        if(neutral)Check("neutral bull armor then toughness once",bull.LastImpactFinalDamage,int(Max(0,joules*0.598492890584-1353.6)+0.5));
        Console.Printf("CA195 TRACE contact npc=%d motion=%d neutral=%d reversed=%d mass=%.3f raw=%.3f bull=%d npc=%d anatomy=%.4f/%.4f",
            resident,motion,neutral,reversed,mass,joules,bull.LastImpactFinalDamage,body.LastImpactFinalDamage,
            bull.LastImpactWeightedVulnerabilityMultiplier,body.LastImpactWeightedVulnerabilityMultiplier);
        bull.Destroy();body.Destroy();
    }
    override void WorldTick()
    {
        Age++;
        if(Age<5 || Age>=101)return;
        int index=(Age-5)/2;
        if((Age-5)%2==0)
        {
            Class<CaelumAnchoredResident> types[]={"CaelumRulo","CaelumRonnie","CaelumArgento","CaelumCaella"};
            Bull=CaelumBull(Actor.Spawn("CA195NeutralBull",(0,0,0)));
            Body=CaelumAnchoredResident(Actor.Spawn(types[index/12],(32,0,0)));
        }
        else
        {
            RunCase(index/12,(index%12)/4,(index%4)/2,index%2);
            if(index==47)Console.Printf("CA195 DONE failures=%d passes=%d",Failures,Passes);
        }
    }
}
