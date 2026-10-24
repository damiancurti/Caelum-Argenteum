// Diagnóstico privado: las mutaciones de prueba no se empaquetan en src.
class CA413NPC : CaelumCombatActor
{
    int TestRace;
    override int GetArmorRace(){return TestRace;}
    Default { Health 1000; Radius 16; Height 56; +NOGRAVITY +FRIENDLY }
    States { Spawn: TNT1 A -1; Stop; }
}

class CA413Checks : EventHandler
{
    int Passed,Failed;
    CA413NPC SavedNPC;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA413 %s %s",ok?"PASS":"FAIL",label);}
    bool Near(double a,double b,double tolerance=0.000001){return Abs(a-b)<=tolerance;}
    void Result(){Console.Printf("CA413 RESULT passed=%d failed=%d map=%s",Passed,Failed,level.MapName);}
    void Place(CaelumPlayer u,int altitude)
    {
        CaelumAltitudeWorld.Get().AltitudeBaseMeters=altitude*2000;
        u.SetOrigin((256+altitude*1024,256,0),false);u.Vel=(0,0,0);
        CaelumAltitudeService.Update(u);
    }
    void Prepare(CaelumPlayer u)
    {
        CaelumRacialAbilityRules.Deactivate(u);
        u.bInvulnerable=true;u.CreationWizardOpen=false;u.DebugAttributesAt100=true;u.ApplyCharacterProfile();
        u.CharacterProfile.Race=CaelumConstants.RACE_HUMAN;u.Attributes.Resilience=0;
        let r=u.GetPersistentCharacterState(true);r.AltitudeState=new("CaelumAltitudeState");
        Place(u,0);u.CurrentAir=u.DerivedStats.MaximumAir;
    }
    void Report(CaelumPlayer u)
    {
        let s=CaelumAltitudeService.Update(u);if(s==null)return;
        Console.Printf("CA413 ALTITUDE %.2f m pressure=%.5f recovery=%.5f effort=%.5f adapted=%.8f target=%.8f race=%d resilience_factor=%.3f air=%.3f",
            s.LastHeight,s.Ratio,s.RecoveryFactor,s.EffortFactor,s.AdaptedDeficit,s.TargetDeficit,s.Race,s.GainMultiplier,u.CurrentAir);
    }
    void Model()
    {
        double r=CaelumAltitudeRules.PressureRatio(4000);
        Check(Near(CaelumAltitudeRules.PressureRatio(0),1),"sea reference neutral");
        Check(Near(CaelumAltitudeRules.PressureRatio(-200),1),"below sea does not add a bonus");
        Check(Near(CaelumAltitudeRules.PressureRatio(2000),0.785,0.003),"2000m physical reference");
        Check(Near(r,0.610,0.003),"4000m physical reference");
        Check(CaelumAltitudeRules.PressureRatio(26000)<CaelumAltitudeRules.PressureRatio(12000),"stratosphere remains finite and ordered");
        int human=CaelumConstants.RACE_HUMAN,caelith=CaelumConstants.RACE_CAELITH;
        Check(Near(CaelumAltitudeRules.Recovery(r,0,human),r),"human recovery baseline");
        Check(Near(CaelumAltitudeRules.Effort(r,0,human),1/r),"human effort baseline");
        Check(Near(1-CaelumAltitudeRules.Recovery(r,0,caelith),(1-r)*0.5),"Caelith halves recovery penalty");
        Check(Near(CaelumAltitudeRules.Effort(r,0,caelith)-1,(1/r-1)*0.5),"Caelith halves effort penalty");
        Check(Near(CaelumAltitudeRules.Recovery(r,0,CaelumConstants.RACE_BEAST_MAN),r),"Beast Man full reference");
        Check(Near(CaelumAltitudeRules.Recovery(r,0,CaelumConstants.RACE_GOBLIN),r),"goblin full reference");
        let s=new("CaelumAltitudeState");s.Initialize();s.SelectTarget(r,1);
        s.Advance(2.5*86400);Check(Near(s.AdaptedDeficit,(1-r)*0.5),"half adaptation after 2.5 days");
        s.Advance(2.5*86400);Check(Near(s.AdaptedDeficit,1-r),"full adaptation after 5 days");
        Check(Near(CaelumAltitudeRules.Recovery(r,s.AdaptedDeficit,human),1-(1-r)*0.75),"adaptation compensates exactly 25 percent");
        s.Advance(100*86400);Check(Near(s.AdaptedDeficit,1-r),"long residence cannot exceed cap");
        s.SelectTarget(1,1);s.Advance(7*86400);Check(Near(s.AdaptedDeficit,(1-r)*0.5),"half retention after 7 days below");
        s.Advance(7*86400);Check(Near(s.AdaptedDeficit,0),"excess expires after 14 days");
        s.SelectTarget(r,4);s.Advance(1.25*86400);Check(Near(s.AdaptedDeficit,1-r),"generic acquisition multiplier4 reaches cap in 1.25 days");
        double prior=s.AdaptedDeficit;s.Initialize();Check(s.AdaptedDeficit==prior,"revision initialization is idempotent");
        let c=s.Copy();c.SelectTarget(1,1);c.Advance(86400);Check(s.AdaptedDeficit==prior,"forecast is independent copy");
        Check(CaelumAltitudeData.NeutralAtmosphere("MAP01"),"Limbo mansion neutral");
        Check(!CaelumAltitudeData.NeutralAtmosphere("MAP03"),"Barracas uses physical altitude");
    }
    void Live(CaelumPlayer u)
    {
        Prepare(u);Place(u,2);
        let s=CaelumAltitudeService.Update(u);double r=s.Ratio,e=s.EffortFactor;
        Check(Near(s.LastHeight,4000),"native map datum is 4000m");
        CaelumAltitudeWorld.Get().AltitudeBaseMeters=3980;u.SetOrigin(u.Pos+(0,0,640),false);CaelumAltitudeService.Update(u);
        Check(Near(s.LastHeight,4000),"physical body height adds to geographical datum");Place(u,2);
        Check(Near(s.RecoveryFactor,r),"live human recovery factor");
        u.CurrentAir=100;Check(!CaelumAirPayment.CanAfford(u,100),"affordability uses adjusted cost");
        u.CurrentAir=1000;double removed=CaelumAirPayment.Spend(u,100);
        Check(Near(removed,100*e) && Near(u.CurrentAir,1000-100*e),"player effort charged exactly once");
        u.CurrentHunger=100;u.CurrentThirst=100;u.HealthPerformanceMultiplier=1;
        u.UnderwaterAirRecoveryDebt=0;u.UnderwaterAirRecoveryTicsRemaining=0;u.UnderwaterAirRecoveryAppliedThisTick=false;
        u.DebugShieldBlocking=false;u.IsSpendingRunningAir=false;u.CurrentAir=0;
        double expected=u.DerivedStats.AirRegenerationPerSecond*CaelumRestState.ResourceFactor(u)*CaelumBreathing.ActorFactor(u)*s.RecoveryFactor/TICRATE;
        CaelumPlayerResources.ApplyAirRegeneration(u);Check(Near(u.CurrentAir,expected),"live recovery applies one pressure factor");
        u.UnderwaterAirRecoveryDebt=5;double air=u.CurrentAir;
        CaelumPlayerResources.ApplyAirRegeneration(u);Check(u.CurrentAir==air,"underwater debt still blocks natural recovery");
        u.UnderwaterAirRecoveryDebt=0;
        let model=new("CaelumJourneyModel");model.Capture(u,true);
        Check(model.Altitude!=s && Near(model.Altitude.RecoveryFactor,s.RecoveryFactor),"journey captures private altitude state");
        double adaptation=s.AdaptedDeficit;model.Step(false);
        Check(s.AdaptedDeficit==adaptation,"forecast does not advance live adaptation");
        Check(model.Altitude.AdaptedDeficit>=adaptation,"journey projection advances adaptation");
        let expectedAdaptation=s.Copy();
        expectedAdaptation.Advance(35*CaelumThermalRuntime.WorldTicSeconds());
        for(int i=0;i<35;i++)CaelumTimeAdvanceState.SimulatePersonalTic(u);
        Check(Near(s.AdaptedDeficit,expectedAdaptation.AdaptedDeficit),"real accelerated wait counts elapsed altitude once");
        let clock=CaelumWorldClock.Get(u,true);double last=s.LastStamp;
        clock.AdvanceTics(CaelumWorldClock.TicsPerDay()*5);CaelumAltitudeService.Update(u);
        Check(Near(s.AdaptedDeficit,1-r),"elapsed game calendar acclimatizes player");
        double stable=s.AdaptedDeficit;CaelumAltitudeService.Update(u);
        Check(s.AdaptedDeficit==stable && s.LastStamp>last,"same stamp cannot duplicate adaptation");
        CaelumAltitudeService.StopClock(u);clock.AdvanceTics(CaelumWorldClock.TicsPerDay());CaelumAltitudeService.Update(u);
        Check(s.AdaptedDeficit==stable,"inactive clock does not count dead time");
        u.Attributes.Resilience=100;s.NextAttributeTic=0;CaelumAltitudeService.Update(u);
        Check(Near(s.GainMultiplier,2),"live Resilience uses existing climate curve");
        u.Attributes.Resilience=0;s.NextAttributeTic=0;
        u.CharacterProfile.Race=CaelumConstants.RACE_CAELITH;
        u.GetPersistentCharacterState(true).AltitudeState=new("CaelumAltitudeState");
        u.CurrentLucidity=100;u.CurrentSleep=100;u.UpdateLucidityState();
        u.LucidityPhysicalStunRemaining=0;u.PainImmobilizationRemaining=0;
        u.RacialAbilityInputLatched=false;u.CombatChannelModeActive=false;
        u.EquipmentMenuOpen=false;CaelumClassAbilityRules.Cancel(u);
        u.DerivedStats.AnimaCostReductionPercent=50;u.CurrentAnima=1000;u.CurrentAir=500;
        Check(CaelumRacialAbilityRules.Begin(u),"native Caelith breathing activation");
        CaelumRacialAbilityRules.Advance(u);
        double manaCost=CaelumAirPayment.AnimaCost(u,100*CaelumAltitudeService.Effort(u));
        Check(CaelumAirPayment.CanAfford(u,100),"altitude effort affordable through Anima");
        CaelumAirPayment.Spend(u,100);
        Check(Near(u.CurrentAnima,1000-manaCost) && u.CurrentAir==500,"supernatural effort substitutes adjusted demand once");
        double beforeMana=u.CurrentAnima;
        Check(CaelumAirPayment.PayWithAnima(u,20) && Near(beforeMana-u.CurrentAnima,CaelumAirPayment.AnimaCost(u,20)),"deprivation payment does not add atmospheric effort twice");
        CaelumRacialAbilityRules.Deactivate(u);
        let npc=CA413NPC(Actor.Spawn("CA413NPC",(2304,128,0),NO_REPLACE));
        Check(npc!=null,"native NPC created");
        if(npc!=null)
        {
            npc.CombatProfileInitialized=true;npc.CombatResilience=0;npc.TestRace=CaelumConstants.RACE_CAELITH;
            npc.CurrentCombatAir=1000;npc.MaximumCombatAir=2000;
            let ns=CaelumAltitudeService.Update(npc);
            Check(ns!=null && Near(ns.EffortFactor,1+(1/r-1)*0.5),"live NPC Caelith tolerance");
            double cost=100*CaelumThermalEffects.HeatCost(npc)*ns.EffortFactor;
            Check(npc.TrySpendCombatAir(100) && Near(npc.CurrentCombatAir,1000-cost),"NPC effort charged exactly once");
            npc.CurrentCombatAir=0;npc.CombatAirRegenerationPerSecond=35;npc.CombatAirSpending=false;
            double gain=35*(npc.IsCombatIdle()?CaelumRestRules.CHAIR_RESOURCE_FACTOR:1)*CaelumBreathing.ActorFactor(npc)*ns.RecoveryFactor/TICRATE;
            npc.CalculateCombatResourceRecovery(false);Check(Near(npc.CurrentCombatAir,gain),"NPC recovery follows same altitude rule");
            npc.Destroy();
        }
        Place(u,0);Check(Near(CaelumAltitudeService.Recovery(u),1) && Near(CaelumAltitudeService.Effort(u),1),"return to sea restores neutral factors");
        Report(u);
        Prepare(u);Place(u,2);
        let forecast=CaelumAltitudeService.Update(u).Copy();forecast.Advance(86400);forecast.RefreshFactors();
        CaelumWorldClock.Get(u,true).AdvanceTics(CaelumWorldClock.TicsPerDay());
        CaelumAltitudeService.CommitForecast(u,forecast);
        Check(Near(CaelumAltitudeService.Update(u).AdaptedDeficit,forecast.AdaptedDeficit),"accepted journey commits adaptation without replaying time");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Player<0 || e.Player>=MAXPLAYERS)return;
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=='ca413_suite'){Model();Live(u);Result();}
        else if(e.Name=='ca413_prepare'){Prepare(u);Report(u);Result();}
        else if(e.Name=='ca413_sea'){Place(u,0);Report(u);}
        else if(e.Name=='ca413_mid'){Place(u,1);Report(u);}
        else if(e.Name=='ca413_high'){Place(u,2);Report(u);}
        else if(e.Name=='ca413_adapt')
        {CaelumWorldClock.Get(u,true).AdvanceTics(CaelumWorldClock.TicsPerDay()*5);Report(u);}
        else if(e.Name=='ca413_spend'){u.CurrentAir=u.DerivedStats.MaximumAir;CaelumAirPayment.Spend(u,100);Report(u);}
        else if(e.Name=='ca413_race')
        {
            u.CharacterProfile.Race=u.CharacterProfile.Race==CaelumConstants.RACE_CAELITH ? CaelumConstants.RACE_HUMAN : CaelumConstants.RACE_CAELITH;
            CaelumAltitudeService.Get(u,true).NextAttributeTic=0;Report(u);
        }
        else if(e.Name=='ca413_seed')
        {
            Prepare(u);Place(u,2);
            SavedNPC=CA413NPC(Actor.Spawn("CA413NPC",(2304,128,0),NO_REPLACE));
            SavedNPC.CombatProfileInitialized=true;SavedNPC.CombatResilience=0;SavedNPC.TestRace=CaelumConstants.RACE_HUMAN;
            CaelumAltitudeService.Update(SavedNPC);
            CaelumWorldClock.Get(u,true).AdvanceTics(CaelumWorldClock.TicsPerDay()*2);
            let s=CaelumAltitudeService.Update(u);Check(Near(s.AdaptedDeficit,(1-s.Ratio)*0.4),"seed partial acclimatization");Report(u);Result();
            let ns=CaelumAltitudeService.Update(SavedNPC);Check(ns!=null && Near(ns.AdaptedDeficit,(1-ns.Ratio)*0.4),"seed NPC adaptation");Result();
        }
        else if(e.Name=='ca413_loaded')
        {
            let s=CaelumAltitudeService.Update(u);
            Check(s!=null && s.Revision==1,"saved additive altitude state restored");
            Check(s.AdaptedDeficit>0.15 && s.AdaptedDeficit<0.16,"partial adaptation survives save or hub travel");
            if(level.MapName=="CAA413")
            {
                Check(SavedNPC!=null,"saved NPC identity survives");
                if(SavedNPC!=null)
                {
                    let ns=CaelumAltitudeService.Update(SavedNPC);
                    Check(ns!=null && ns.AdaptedDeficit>0.15 && ns.AdaptedDeficit<0.16,"NPC adaptation survives save and unloaded hub interval");
                }
            }
            Report(u);Result();
        }
        else if(e.Name=='ca413_migrate')
        {
            let s=CaelumAltitudeService.Update(u);Check(s!=null && s.Revision==1,"old save initializes revision1");
            Check(s.AdaptedDeficit<0.0001,"old save receives no retroactive adaptation");
            Check(u.CharacterCreationComplete && u.health>0,"old character remains playable");
            Check(CaelumAltitudeWorld.Get()!=null,"old save receives map datum controller");Report(u);Result();
        }
        else if(e.Name=='ca413_report'){Report(u);Result();}
        else if(e.Name=='ca413_help')Console.Printf("#413: F1 nivel del mar; F2 2000m; F3 4000m; F4 avanzar 5 dias; F5 gastar 100 de Aire base; F6 informe; F7 humano/Caelith. Escape guardar/cargar. Sala privada; no modifica partidas de campana.");
    }
}
