class CA195Target : CaelumCombatActor
{
    override void Tick() {}
    Default { Radius 16; Height 56; Mass 80; Health 1000000; +SHOOTABLE; +SOLID; +NOGRAVITY; }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA195Bull : StaticEventHandler
{
    int Age,Passes,Failures;
    CaelumBull Bull;
    CaelumCombatActor TargetBody;
    vector3 Previous;
    CaelumCombatActor Residents[8];
    void Check(String label,double actual,double expected,double tolerance=0.000001)
    {
        bool ok=Abs(actual-expected)<=tolerance;
        if(ok)Passes++;else Failures++;
        Console.Printf("CA195 %s %s actual=%.9f expected=%.9f",ok?"PASS":"FAIL",label,actual,expected);
    }
    override void UiTick(){if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    void Profiles()
    {
        Class<CaelumCombatActor> types[]={"CaelumRulo","CaelumRonnie","CaelumArgento","CaelumCaella",
            "CaelumPrisonerBestia","CaelumPrisonerFederal","CaelumPrisonerTarot","CaelumPrisonerUnitario"};
        int packed[]={0,52,77,7};double power[]={1,2.8125,2.8125,1.875};
        for(int i=0;i<8;i++)
        {
            let npc=Residents[i];
            npc.EnsureCombatPersonality();
            Check(String.Format("profile %d",i),CaelumPersonalityRules.Pack(npc.CombatPersonality),packed[i%4]);
            Check("personality power",CaelumPersonalityRules.MagicPower(CaelumPersonalityRules.Profile(npc)),power[i%4]);
            Check("magical push power",npc.CombatMagicalPushMultiplier,
                CaelumGrowthRules.Multiplier(npc.CombatEffectiveIntelligence,3)*power[i%4]);
            Check("outgoing magic power",npc.PrepareActorOutgoingDamage(100,true),int(100*power[i%4]+0.5));
            double critical=npc.CombatPhysicalCriticalChancePercent,evasion=npc.EffectiveCombatEvasionChance;
            double adrenaline=npc.CombatAdrenalineGainMultiplier;
            let profile=npc.CombatPersonality;npc.CombatPersonality=null;
            npc.UpdateActorOffensiveStatistics();npc.UpdateCombatHealthEffects();
            Check("critical functional profile",critical,npc.CombatPhysicalCriticalChancePercent*CaelumPersonalityRules.Alternative(profile,1));
            Check("evasion functional profile",evasion,npc.EffectiveCombatEvasionChance*CaelumPersonalityRules.Alternative(profile,2));
            Check("adrenaline functional profile",adrenaline,npc.CombatAdrenalineGainMultiplier*CaelumPersonalityRules.Alternative(profile,0));
            npc.CombatPersonality=profile;npc.UpdateActorOffensiveStatistics();npc.UpdateCombatHealthEffects();
            int health=npc.health;double air=npc.CurrentCombatAir;
            npc.EnsureCombatPersonality();npc.EnsureCombatPersonality();
            Check("profile idempotent health",npc.health,health);Check("profile idempotent air",npc.CurrentCombatAir,air);
            if(i>=4){let prisoner=CaelumAnchoredResident(npc);prisoner.EnsureResidentTools();Check("prisoner no tools",prisoner.ResidentTools==null,1);}
            npc.Destroy();
        }
        Check("unassigned profile remains null",TargetBody.CombatPersonality==null,1);
    }
    void Defense()
    {
        Bull.CombatHealthPerformanceMultiplier=1;Bull.CombatAgility=20;Bull.BullChargeActive=true;
        Check("natural mass",Bull.GetCollisionEffectiveMass(),900);
        Check("cushion fraction agility20",Bull.GetHorizontalImpactAbsorptionFraction(),0.226376777273,0.00000001);
        Check("horizontal retained energy",Bull.RetainImpactEnergy(1000,1,CaelumConstants.IMPACT_KIND_ACTOR,(1,0,0)),598.492890584,0.00001);
        Check("toughness physical",CaelumToughnessRules.Reduction(900,20),1353.6);
        Bull.CombatAgility=0;Check("agility zero",Bull.GetHorizontalImpactAbsorptionFraction(),0);
        Bull.CombatAgility=100;Check("cushion cap",Bull.GetHorizontalImpactAbsorptionFraction(),0.5);
        Bull.CombatAgility=20;Bull.CombatHealthPerformanceMultiplier=0.5;
        Check("impaired cushion",Bull.GetHorizontalImpactAbsorptionFraction(),0);
        Bull.CombatHealthPerformanceMultiplier=1;Bull.StopBullCharge();
        Check("not charging no horizontal cushion",Bull.GetHorizontalImpactAbsorptionFraction(),0);
        Bull.BullChargeRevision=0;Bull.BullChargeActive=true;Bull.CollisionEffectiveMassMultiplier=2;
        Bull.Vel=(100,0,0);Bull.EnsureBullChargeRevision();
        Check("old charge removes doubled mass",Bull.GetCollisionEffectiveMass(),900);
        Check("old charge caps velocity",Bull.Vel.XY.Length(),10*32.0/35.0);
        Check("old charge continues",Bull.BullChargeActive,1);
        Bull.StopBullCharge();
        Name types[]={'Melee','CaelumMagicTest','CaelumElementalDOT'};
        for(int kind=0;kind<3;kind++)for(int sample=0;sample<2;sample++)
        {
            int results[2];
            for(int charging=0;charging<2;charging++)
            {
                Bull.health=Bull.CombatMaximumHealth;Bull.CurrentCombatAdrenaline=0;Bull.UpdateCombatHealthEffects();
                Bull.SetStateLabel("Spawn");Bull.BullChargeActive=charging;
                Bull.RegisterDirectionalAnatomyImpact(TargetBody,0.5);
                results[charging]=Bull.DamageMobj(null,null,sample==0 ? 5000 : 7000,types[kind],DMG_THRUSTLESS,0);
            }
            Check("ordinary damage unchanged by charging",results[1],results[0]);
            Check("ordinary damage not immune",results[1]>0,1);
            Console.Printf("CA195 TRACE ordinary kind=%d sample=%d damage=%d",kind,sample,results[1]);
        }
        Bull.health=Bull.CombatMaximumHealth;Bull.CurrentCombatAdrenaline=0;Bull.CombatLucidityPhysicalStunRemaining=0;
        Bull.CurrentCombatLucidity=100;Bull.UpdateActorLucidityState();Bull.UpdateCombatHealthEffects();
        Bull.StopBullCharge();Bull.SetStateLabel("Spawn");
    }
    override void WorldTick()
    {
        Age++;
        if(Age==5)
        {
            Bull=CaelumBull(Actor.Spawn("CaelumBull",(-800,0,0)));
            TargetBody=CaelumCombatActor(Actor.Spawn("CA195Target",(150,0,0)));
            Class<CaelumCombatActor> types[]={"CaelumRulo","CaelumRonnie","CaelumArgento","CaelumCaella",
                "CaelumPrisonerBestia","CaelumPrisonerFederal","CaelumPrisonerTarot","CaelumPrisonerUnitario"};
            for(int i=0;i<8;i++)Residents[i]=CaelumCombatActor(Actor.Spawn(types[i],(800+i*100,1200,0)));
        }
        if(Age==6)
        {
            Bull.target=TargetBody;Profiles();Defense();
            Bull.BeginBullCharge();Previous=Bull.Pos;
        }
        if(Age>6 && Age<=46)
        {
            int t=Age-6;
            if(t==1 || t==17 || t==35 || t==40)
            {
                double expected=Min(10.0,t*10.0/35);
                Check(String.Format("acceleration tic%d",t),Bull.BullChargeSpeed*35/32,expected);
                vector3 displacement=Bull.Pos-Previous;
                Console.Printf("CA195 TRACE motion tic=%d speed=%.9f displacement=%.9f active=%d",t,
                    Bull.Vel.XY.Length()*35/32,displacement.XY.Length()*35/32,Bull.BullChargeActive);
                Check("final velocity never above cap",Bull.Vel.XY.Length()<=10*32.0/35+0.00001,1);
            }
            Previous=Bull.Pos;
        }
        if(Age==47)TargetBody.SetOrigin((Bull.Pos.X+500,200,0),false);
        if(Age==49){Check("tracks moving target",Bull.Vel.Y>0,1);Bull.SetStateLabel("Pain");}
        if(Age==50){Check("pain stops charge",Bull.BullChargeActive,0);Check("pain mass",Bull.GetCollisionEffectiveMass(),900);}
        if(Age==61)
        {
            Bull.target=TargetBody;Bull.BeginBullCharge();
            let binding=CaelumBolasFlight(Actor.Spawn("CaelumBolasFlight",Bull.Pos));binding.AttachVictim(Bull);
            Check("bolas stop charge",Bull.BullChargeActive,0);
            Check("bolas exit charge loop",Bull.InStateSequence(Bull.CurState,Bull.FindState("BullChargeLoop")),0);
            binding.Resolve(false);
        }
        if(Age==70)
        {
            Check("released binding",CaelumBolas.Restrained(Bull),0);
            Bull.StopBullCharge();Bull.SetStateLabel("Spawn");
            Console.Printf("CA195 DONE failures=%d passes=%d",Failures,Passes);
        }
    }
}
