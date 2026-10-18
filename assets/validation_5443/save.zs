// Sonda común para guardados anterior/actual y retorno al runtime anterior.
class CA353SaveProbe : EventHandler
{
    int Age,ExpectedHealth,ExpectedUnits,Passes,Failures;
    double ExpectedAnima,ExpectedAir,ExpectedLucidity,ExpectedWeight;
    bool Prepared;
    CaelumCombatActor Body;

    void Check(bool valid,String label)
    { if(valid)Passes++;else{Failures++;Console.Printf("CA282 FAIL %s",label);} }
    override void WorldTick()
    {
        if(Prepared)return;
        Age++;let user=CaelumPlayer(players[0].mo);if(user==null)return;
        if(Age==5){user.CharacterCreationComplete=true;user.CreationWizardOpen=false;user.ApplyCharacterProfile();user.bInvulnerable=true;}
        if(Age==35)
        {
            Body=CaelumCombatActor(Actor.Spawn("CaelumMandinga",(1024,0,0),NO_REPLACE));
            Body.bDormant=true;Body.bInvulnerable=true;
        }
    }
    void Snapshot()
    {
        Check(Body!=null && Body.CombatProfileInitialized,"initialized save body");
        Body.ChangeStatNum(CaelumHouseResidents.PARKED_STAT);
        for(Inventory item=Body.Inv;item!=null;item=item.Inv)item.ChangeStatNum(CaelumHouseResidents.PARKED_STAT);
        Body.health=Max(1,Body.CombatMaximumHealth*71/100);
        Body.CurrentCombatAnima=Body.MaximumCombatAnima*0.25;
        Body.CurrentCombatAir=Body.MaximumCombatAir*0.75;
        Body.CurrentCombatLucidity=CaelumConstants.MAXIMUM_LUCIDITY*0.2;
        let potion=CaelumDemonService.Potion(Body,0);potion.Amount=3;
        // CURRENT_BEGIN
        CaelumActorMaintenance.InventoryChanged(Body);
        CaelumPopulationState.Get().HighDensity=true;
        Body.GetActorMaintenance();
        // CURRENT_END
        Body.UpdateCombatHealthEffects();Body.UpdateActorOffensiveStatistics();
        ExpectedHealth=Body.health;ExpectedAnima=Body.CurrentCombatAnima;ExpectedAir=Body.CurrentCombatAir;
        ExpectedLucidity=Body.CurrentCombatLucidity;ExpectedWeight=Body.GetAttackCarriedWeight();ExpectedUnits=potion.Amount;
        Prepared=true;
        Console.Printf("CA353 SAVE_READY hp=%d anima=%.12f air=%.12f lucidity=%.12f weight=%.12f units=%d",ExpectedHealth,ExpectedAnima,ExpectedAir,ExpectedLucidity,ExpectedWeight,ExpectedUnits);
    }
    void Verify()
    {
        Check(Prepared && Body!=null,"saved body reference retained");if(Body==null)return;
        Check(Body.health==ExpectedHealth,"saved actual health");
        Check(Body.CurrentCombatAnima==ExpectedAnima && Body.CurrentCombatAir==ExpectedAir && Body.CurrentCombatLucidity==ExpectedLucidity,"saved actual resources");
        let potion=CaelumDemonService.Potion(Body,0);
        Check(potion!=null && potion.Amount==ExpectedUnits,"saved finite inventory");
        Check(Body.GetAttackCarriedWeight()==ExpectedWeight,"saved weight recomputed");
        // CURRENT_BEGIN
        CaelumPopulationState.Get().HighDensity=true;
        let cache=Body.GetActorMaintenance();
        Check(cache!=null && Body.MaintenanceRevision==CaelumActorMaintenance.REVISION,"cache schema migration");
        Check(Body.GetActorMaintenance()==cache,"cache migration idempotent");
        Body.UpdateCombatHealthEffects();double speed=Body.Speed;
        Body.CalculateCombatHealthEffects();Check(Body.Speed==speed,"loaded health cache equality");
        Check(Body.GetAttackCarriedWeight()==Body.CalculateAttackCarriedWeight(),"loaded weight cache equality");
        // CURRENT_END
        Console.Printf("CA353 SAVE_CHECK passes=%d failures=%d",Passes,Failures);
        if(Failures==0)Console.Printf("CA282 DONE passes=%d failures=0",Passes);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca353_save_prepare")Snapshot();
        if(e.Name=="ca353_save_verify")Verify();
    }
}
