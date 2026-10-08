class CA135ManualMandinga : CaelumMandinga
{
    // El coste aislado usa el servicio real, sin regenerar entre pulsos.
    override void Tick() {}
}
class CA135Breath : EventHandler
{
    int Checks,Failures;
    CaelumCombatActor Demon,Victim,Far,Side,Drinker;
    double AnimaBefore,HeatBefore,Cost;
    void Check(bool ok,String label)
    {Checks++;if(!ok)Failures++;Console.Printf("CA135 %s %s",ok ? "PASS" : "FAIL",label);}
    CaelumCombatActor Body(Name name,Vector3 point)
    {
        let npc=CaelumCombatActor(Actor.Spawn(name,point,NO_REPLACE));
        npc.CaelumDiagnosticPassiveAI=true;npc.tics=-1;npc.Target=null;
        npc.ElementalStatus=new("CaelumElementalStatus");
        return npc;
    }
    void UseDrinker()
    {Drinker.CaelumDiagnosticPassiveAI=false;CaelumDemonService.UpdatePotions(Drinker);Drinker.CaelumDiagnosticPassiveAI=true;}
    void Pulse()
    {
        Demon.CaelumDiagnosticPassiveAI=false;CaelumDemonService.UpdateBreath(Demon);Demon.CaelumDiagnosticPassiveAI=true;
    }
    override void WorldTick()
    {
        let user=CaelumPlayer(players[0].mo);
        if(level.time==1){user.InitializeDirectMapCharacter();user.PersistCharacterState();}
        if(level.time==60)
        {
            Demon=Body('CA135ManualMandinga',(2048,2048,0));Demon.Angle=0;
            Victim=Body('CaelumMandinga',(2144,2048,0));
            Far=Body('CaelumMandinga',(2304,2048,0));
            Side=Body('CaelumMandinga',(2048,2144,0));
            Drinker=Body('CaelumZupayColossus',(3000,3000,0));
        }
        if(level.time==70)
        {
            Drinker.health=Drinker.CombatMaximumHealth/2;Drinker.CurrentCombatAnima=Drinker.MaximumCombatAnima/2;
            Drinker.CurrentCombatAir=Drinker.MaximumCombatAir/2;UseDrinker();
            Check(CaelumDemonService.Potion(Drinker,0).Amount==6 && CaelumDemonService.Potion(Drinker,1).Amount==6
                && CaelumDemonService.Potion(Drinker,2).Amount==6,"exactly fifty percent consumes no family");
            Drinker.health--;Drinker.CurrentCombatAnima--;Drinker.CurrentCombatAir--;UseDrinker();
            Check(CaelumDemonService.Potion(Drinker,0).Amount==5 && CaelumDemonService.Potion(Drinker,1).Amount==5
                && CaelumDemonService.Potion(Drinker,2).Amount==5,"three low resources consume one each concurrently");
            for(int i=0;i<20;i++)UseDrinker();
            Check(CaelumDemonService.Potion(Drinker,0).Amount==5 && CaelumDemonService.Potion(Drinker,1).Amount==5
                && CaelumDemonService.Potion(Drinker,2).Amount==5,"ongoing family prevents repeated automatic consumption");
            Demon.target=Victim;AnimaBefore=Demon.CurrentCombatAnima;
            CaelumThermalBody.Get(Demon,true);
            Cost=Demon.GetMagicAnimaCost(10);
            HeatBefore=Demon.ThermalState.AbsorbedContinuousJoules;
        }
        if(level.time>=70 && level.time<106)
        {
            Pulse();Victim.ElementalStatus.Tick(Victim);
        }
        if(level.time==106)
        {
            let flame=Demon.DemonBreath;
            Check(flame!=null,"combat target inside four meters starts sustained breath");
            Console.Printf("CA135 CONTACT direct=%d remaining=%.6f accumulator=%.6f damage=%d",
                flame.Contact(Victim),Victim.ElementalStatus.BurnRemaining,Victim.ElementalStatus.BurnTickAccumulator,
                Victim.ElementalStatus.BurnDamagePerSecond);
            for(int k=0;k<4;k++)
            {
                vector3 point=Victim.Pos+(-Victim.Radius,0,Victim.Height*(k+0.5)/4);
                vector3 ray=point-flame.Pos;
                FLineTraceData hit;
                bool blocked=flame.LineTrace(VectorAngle(ray.X,ray.Y),ray.Length(),-VectorAngle(ray.XY.Length(),ray.Z),
                    TRF_THRUACTORS|TRF_ABSPOSITION,flame.Pos.Z,flame.Pos.X,flame.Pos.Y,hit);
                Console.Printf("CA135 RAY d=%.3f cosine=%.6f visible=%d blocked=%d type=%d z=%.3f targetz=%.3f",
                    ray.Length(),(ray dot flame.Direction)/ray.Length(),flame.Visible(point),blocked,hit.HitType,flame.Pos.Z,point.Z);
            }
            Check(Abs(AnimaBefore-Demon.CurrentCombatAnima-Cost*36.0/35)<0.000001,"real ticks spend reduced ten Anima per second exactly once");
            Check(Abs(flame.TotalPaidSeconds-36.0/35)<0.000001,"emission counts only paid real ticks");
            Check(Demon.ThermalState.AbsorbedContinuousJoules>HeatBefore,"emitter receives actual thermal energy");
            Check(Victim.ElementalStatus.BurnRemaining>0 && Victim.health<Victim.CombatMaximumHealth,
                "sustained contact burns without endlessly resetting its damage clock");
            Check(!flame.Contact(Far) && Far.ElementalStatus.BurnRemaining==0 && Far.ThermalState.AbsorbedContinuousJoules>0,
                "heat propagates beyond four meters without direct burn");
            Check(!flame.Contact(Side) && Side.ElementalStatus.BurnRemaining==0 && Side.ThermalState.AbsorbedContinuousJoules>0,
                "outside cone receives radiation only");
            Console.Printf("CA135 BREATH cost=%.9f selfJ=%.9f farJ=%.9f burnHP=%d",Cost,
                Demon.ThermalState.AbsorbedContinuousJoules-HeatBefore,Far.ThermalState.AbsorbedContinuousJoules,
                Victim.CombatMaximumHealth-Victim.health);
            Demon.CurrentCombatAnima=0;Pulse();
            Check(Demon.DemonBreath==null && Demon.CurrentCombatAnima==0,"unpayable next tick stops without negative resource");
            Demon.target=null;Demon.CurrentCombatAnima=Demon.MaximumCombatAnima;
            Demon.ThermalState.Exposure=-15;Demon.ThermalState.Severity=1;Pulse();
            Check(Demon.DemonBreath!=null,"authoritative cold automatically starts breath with no enemy");
            Demon.SetState(Demon.FindState("RacialBreath")+2);
            Demon.ThermalState.Exposure=0;Demon.ThermalState.Severity=0;Pulse();
            Check(Demon.DemonBreath==null && !Demon.InStateSequence(Demon.CurState,Demon.FindState("RacialBreath")),
                "cleared cold stops emission and restores AI from a later animation phase");
            Demon.target=Victim;Pulse();Demon.ForcedSleepTics=35;Pulse();
            Check(Demon.DemonBreath==null,"sleep interrupts the racial ability");
            Demon.ForcedSleepTics=0;Pulse();Demon.RecoveryPhase=1;Pulse();
            Check(Demon.DemonBreath==null,"resource retreat retains its navigation instead of holding breath pose");
            Demon.RecoveryPhase=0;
            Demon.ForcedSleepTics=0;Pulse();Demon.DamageMobj(null,null,1000000,'None',DMG_NO_ARMOR,0);
            Check(Demon.DemonBreath==null,"actual death releases owned flame immediately");
        }
        if(level.time==430)
        {
            Check(Drinker.health<=Drinker.CombatMaximumHealth && Drinker.CurrentCombatAnima<=Drinker.MaximumCombatAnima
                && Drinker.CurrentCombatAir<=Drinker.MaximumCombatAir,"all automatic large doses clamp at resource maxima");
            Check(CaelumDemonService.Potion(Drinker,0).Amount==5 && CaelumDemonService.Potion(Drinker,1).Amount==5
                && CaelumDemonService.Potion(Drinker,2).Amount==5,"ten seconds of restoration retain finite supplies");
            Console.Printf("CA135 COMPLETE checks=%d failures=%d",Checks,Failures);
        }
    }
}
