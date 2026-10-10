// Same fixture runs on 5.1.14 and the shared-service implementation.
class CA162DemonBody : CaelumMandinga { override void Tick() {} }
class CA162Demon : EventHandler
{
    CaelumCombatActor Emitter,Victim,Far,Side;
    int Passed,Failed;
    double AnimaBefore,HeatBefore,Cost;
    void Check(String label,bool ok)
    {if(ok)Passed++;else Failed++;Console.Printf("CA162 %s %s",ok?"PASS":"FAIL",label);}
    CaelumCombatActor Body(Vector3 point)
    {
        let body=CaelumCombatActor(Actor.Spawn("CA162DemonBody",point,NO_REPLACE));
        body.CaelumDiagnosticPassiveAI=true;body.tics=-1;body.target=null;
        body.ElementalStatus=new("CaelumElementalStatus");return body;
    }
    void Pulse()
    {Emitter.CaelumDiagnosticPassiveAI=false;CaelumDemonService.UpdateBreath(Emitter);Emitter.CaelumDiagnosticPassiveAI=true;}
    override void WorldTick()
    {
        let u=CaelumPlayer(players[0].mo);
        if(level.time==1)u.InitializeDirectMapCharacter();
        if(level.time==60)
        {
            u.SetOrigin((1000,1000,0),false);
            Emitter=Body((2048,2048,0));Emitter.Angle=0;
            Victim=Body((2144,2048,0));Far=Body((2304,2048,0));Side=Body((2048,2144,0));
        }
        if(level.time==70)
        {
            Emitter.target=Victim;AnimaBefore=Emitter.CurrentCombatAnima;Cost=Emitter.GetMagicAnimaCost(10);
            CaelumThermalBody.Get(Emitter,true);HeatBefore=Emitter.ThermalState.AbsorbedContinuousJoules;
        }
        if(level.time>=70 && level.time<106){Pulse();Victim.ElementalStatus.Tick(Victim);}
        if(level.time==106)
        {
            let flame=Emitter.DemonBreath;Check("demon still emits approved cone",flame!=null);
            if(flame==null)return;
            Check("demon pays exact reduced cost",Abs(AnimaBefore-Emitter.CurrentCombatAnima-Cost*36.0/35)<0.000001);
            Check("demon contact burn clock advances",Victim.ElementalStatus.BurnRemaining>0 && Victim.health<Victim.CombatMaximumHealth);
            Check("demon radiation heats its emitter",Emitter.ThermalState.AbsorbedContinuousJoules>HeatBefore);
            Check("demon distant body gets heat without burn",!flame.Contact(Far) && Far.ElementalStatus.BurnRemaining==0 && Far.ThermalState.AbsorbedContinuousJoules>0);
            Check("demon side body gets heat without burn",!flame.Contact(Side) && Side.ElementalStatus.BurnRemaining==0 && Side.ThermalState.AbsorbedContinuousJoules>0);
            Console.Printf("CA162 DEMON cost=%.9f selfJ=%.9f farJ=%.9f sideJ=%.9f burnHP=%d",Cost,
                Emitter.ThermalState.AbsorbedContinuousJoules-HeatBefore,Far.ThermalState.AbsorbedContinuousJoules,
                Side.ThermalState.AbsorbedContinuousJoules,Victim.CombatMaximumHealth-Victim.health);
            Emitter.CurrentCombatAnima=0;Pulse();Check("demon exhaustion still stops",Emitter.DemonBreath==null);
            Console.Printf("CA162 RESULT passed=%d failed=%d",Passed,Failed);
        }
    }
}
