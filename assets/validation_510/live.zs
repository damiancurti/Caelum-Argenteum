// Native simulation fixture. Uses the accepted direct-map profile entry point.
class CA130Live : StaticEventHandler
{
    CaelumPlayer User;
    CaelumCombatActor Demon;
    int Checks,Failures;
    double PlayerStartDamage,NPCStartDamage;
    int CivilDay,CivilTic;
    void Verify(bool passed,String label)
    {Checks++;if(!passed)Failures++;Console.Printf("CA130 %s tic=%d %s",passed?"PASS":"FAIL",level.time,label);}
    override void WorldTick()
    {
        if(level.time==1)
        {
            User=CaelumPlayer(players[0].mo);
            User.InitializeDirectMapCharacter();User.PersistCharacterState();
            let marker=Actor.Spawn("CaelumClimateRegion",(0,0,0),NO_REPLACE);
            marker.args[0]=1;marker.args[1]=5;
            Demon=CaelumCombatActor(Actor.Spawn("CaelumMandinga",(1500,1500,0),NO_REPLACE));
            return;
        }
        if(User==null)return;
        // Keep unrelated healing out of this damage dose measurement.
        if(User.DerivedStats!=null)User.DerivedStats.HealthRegenerationPerSecond=0;
        if(level.time==44)
        {
            CaelumThermalRuntime.NPCStep(Demon,true);
            let pt=CaelumThermalBody.Get(User,true);let nt=CaelumThermalBody.Get(Demon,true);
            CaelumThermalBody.Refresh(User,pt);CaelumThermalBody.Refresh(Demon,nt);
            Verify(User.CharacterCreationComplete && !User.CreationWizardOpen,"confirmed direct-map character");
            Verify(pt.Available,"player samples live climate");
            pt.Exposure=-100*CaelumThermalRules.ThresholdScale(pt.Toughness);
            nt.Exposure=-100*CaelumThermalRules.ThresholdScale(nt.Toughness);
            pt.DamageRemainder=0;nt.DamageRemainder=0;
            PlayerStartDamage=pt.AppliedDamageHP;NPCStartDamage=nt.AppliedDamageHP;
            User.health=User.CaelumMaximumHealth;User.player.health=User.health;
            let clock=CaelumWorldClock.Get(User);let calendar=CaelumCalendarState.Get(User);
            if(CaelumWorldCatalogue.IsLimboMap(level.MapName))calendar.SetAnchor(clock,CaelumCalendarRules.ToSerial(1889,11,3),0,false);
            CivilDay=calendar.DateSerial(clock);CivilTic=calendar.CivilDayTics(clock);
            Demon.health=Demon.CombatMaximumHealth;
            Console.Printf("CA130 LIVE START player maxhp=%d D=%.6f npc maxhp=%d D=%.6f",
                User.CaelumMaximumHealth,pt.Toughness,Demon.CombatMaximumHealth,nt.Toughness);
        }
        if(level.time==114)
        {
            CaelumThermalRuntime.NPCStep(Demon,true);
            let pt=CaelumThermalBody.Get(User);let nt=CaelumThermalBody.Get(Demon);
            double playerDose=User.CaelumMaximumHealth*0.03*2*(1-CaelumThermalRules.DamageResistance(pt.Toughness));
            double npcDose=Demon.CombatMaximumHealth*0.03*2*(1-CaelumThermalRules.DamageResistance(nt.Toughness));
            double delivered=pt.AppliedDamageHP-PlayerStartDamage+pt.DamageRemainder;
            Verify(Abs(delivered-playerDose)<0.000001,"player two real seconds exact thermal dose");
            double npcDelivered=nt.AppliedDamageHP-NPCStartDamage+nt.DamageRemainder;
            Verify(Abs(npcDelivered-npcDose)<0.000001,"offscreen NPC two real seconds exact thermal dose");
            Console.Printf("CA130 LIVE DOSE player=%.9f expected=%.9f npc=%.9f expected=%.9f Eplayer=%.9f Enpc=%.9f",
                delivered,playerDose,npcDelivered,npcDose,pt.Exposure,nt.Exposure);
            double hp=pt.AppliedDamageHP,fraction=pt.DamageRemainder;
            for(int i=0;i<100;i++)User.AdvancePersonalTimeTic(false);
            Verify(pt.AppliedDamageHP==hp && pt.DamageRemainder==fraction,"extra personal steps do not invent real damage");
            Verify(pt.Exposure<0 && pt.Exposure>-100*CaelumThermalRules.ThresholdScale(pt.Toughness),"extra world steps advance exposure response");
            bool limbo=CaelumWorldCatalogue.IsLimboMap(level.MapName);
            Verify(CaelumThermalRuntime.WorldTicSeconds()==(limbo ? 1.0 : 20.0)/TICRATE,"map calendar scale preserved");
            if(limbo)
            {
                let clock=CaelumWorldClock.Get(User);
                let calendar=CaelumCalendarState.Get(User);
                Verify(CivilDay>=0 && calendar.DateSerial(clock)==CivilDay && calendar.CivilDayTics(clock)==CivilTic,"Limbo keeps civil calendar frozen");
            }
            Console.Printf("CA130 COMPLETE checks=%d failures=%d",Checks,Failures);
        }
    }
}
