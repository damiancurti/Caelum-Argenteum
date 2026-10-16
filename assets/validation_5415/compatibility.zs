// Same test actor identity on both runtimes; only pre-#260 gameplay fields used.
class CA260Player : CaelumPlayer
{
    int TestMass,TestLoad,Mode;
    bool SnapshotEnabled;
    double SavedFactor,SavedSeconds,SavedStep;
    override void Tick()
    {
        Super.Tick();
        if(SnapshotEnabled)
        {SavedFactor=MovementAccelerationFactor;SavedSeconds=MovementAccelerationSeconds;}
    }
}
class CA260Probe : StaticEventHandler
{
    int Passed,Failed;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA260 %s %s",ok?"PASS":"FAIL",label);}
    override void UiTick(){if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    override void WorldLoaded(WorldEvent e)
    {
        if(!e.IsSaveGame)return;
        let u=CA260Player(players[0].mo);
        Check(u!=null && u.SavedFactor>0 && u.SavedFactor<1,"copied save contains a partial ramp");
        Check(Abs(u.MovementAccelerationFactor-u.SavedFactor)<0.00000001,"native load preserves saved fraction without a bridge");
        Check(Abs(u.MovementAccelerationSeconds-u.SavedSeconds)<0.00000001,"native load preserves elapsed time without a bridge");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CA260Player(players[0].mo);
        if(e.Name=="c260_setup")
        {
            u.CreationWizardOpen=false;u.CharacterCreationComplete=true;u.bInvulnerable=true;
            u.TestMass=100;u.TestLoad=0;u.ShieldModel.Equipped=false;u.CombatBlockModeActive=false;
            u.SetOrigin((0,0,0),false);u.Vel=(0,0,0);u.Angle=0;
            u.MovementAccelerationFactor=0;u.MovementAccelerationSeconds=0;u.SnapshotEnabled=true;
        }
        if(e.Name=="c260_done")Console.Printf("CA260 DONE failures=%d passes=%d",Failed,Passed);
    }
    override void WorldTick()
    {
        let u=CA260Player(players[0].mo);if(u==null || !u.SnapshotEnabled)return;
        u.Attributes.SetAllForDebug(0);u.DerivedStats.Recalculate(u.Attributes,u.CharacterProfile);
        u.DerivedStats.BaseMass=u.TestMass;u.DerivedStats.CarriedItemWeight=0;
        u.DerivedStats.DebugWeight=u.TestLoad;u.DerivedStats.RefreshCarriedWeightTotals();u.DerivedStats.LoadRatio=0;
        u.CurrentAir=u.DerivedStats.MaximumAir;u.CurrentHunger=100;u.CurrentThirst=100;u.CurrentSleep=100;
        u.health=u.CaelumMaximumHealth;u.player.health=u.health;
        u.UpdateAirStateEffects();u.ApplyPhysicalMovement();
    }
}
