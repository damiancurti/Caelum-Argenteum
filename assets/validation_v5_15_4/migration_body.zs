    void Restored()
    {
        let user=CaelumPlayer(players[0].mo);let record=user.GetPersistentCharacterState(false);
        Check(CaelumBattleConsequences.View(user)==null,"untouched previous save has no invented city outcome");
        let outcome=CaelumBattleConsequences.Get(user,true);
        Check(outcome!=null && outcome.Revision==1 && !outcome.Observed && !outcome.Defeated && !outcome.Won,"new revision initializes without retroactive consequences");
        Check(CaelumBattleConsequences.Get(user,true)==outcome,"consequence migration is idempotent");
        Check(Port.Reinforcements.Remaining==6200 && Port.Reinforcements.Withheld==100,"old spent and withheld reserve remain unchanged");
        Check(Gun.CapturedIntact && Gun.OwnerFaction==0,"old captured machine retains ownership and intact identity");
        Check(CaelumBattleTactics.Get(user).IntelligenceDelivered && record.FactionReputation[0]==Reputation[0]+50,"previous preparation and reward remain unchanged");
        // Un estado de victoria antiguo construido explícitamente no tiene fecha ni padrón fiable.
        Port.args[0]=CaelumCityData.LAYOUT_REVISION;Port.Victory=true;Port.EnsureDirector();
        Check(outcome.Won && outcome.LegacyVictory && outcome.VictoryCivil<0 && outcome.Reward==null,"unknown legacy victory date never invents participants or retroactive rewards");
        CaelumBattleConsequences.Update(user);Port.ObserveBattle();
        Check(!CaelumBattleConsequences.Closed(user) && record.FactionReputation[0]==Reputation[0]+50,"legacy victory remains open without duplicate reputation");
        Console.Printf("CA451 RESULT %s failures=%d",Failures==0?"PASS":"FAIL",Failures);
    }
