class CA211SavedBull : CaelumBull { override void Tick(){} }
class CA211Persistence : StaticEventHandler
{
    int Age,Passes,Failures;
    bool Loaded;
    CaelumBull Bull;
    override void WorldLoaded(WorldEvent e){Loaded=e.IsSaveGame;Age=0;}
    override void UiTick(){if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    void Check(String label,bool ok)
    {if(ok)Passes++;else Failures++;Console.Printf("CA211 %s %s",ok?"PASS":"FAIL",label);}
    override void WorldTick()
    {
        Age++;
        if(!Loaded && Age==5)
        {
            Bull=CaelumBull(Actor.Spawn("CA211SavedBull",(512,512,0)));Bull.ChangeTid(44211);
        }
        if(!Loaded && Age==6)
        {
            Bull.CombatAgility=20;Bull.CombatLucidityPhysicalStunRemaining=0;
            Bull.BullChargeActive=true;Bull.BullChargeSpeed=3.25;
            Bull.health=2345;Bull.CollisionEffectiveMassMultiplier=1;
            Bull.SetStateLabel("BullChargeLoop");
            Check("saved active charge prepared",Bull.BullChargeActive && Bull.BullChargeSpeed==3.25);
            Console.Printf("CA211 DONE failures=%d passes=%d",Failures,Passes);
        }
        if(Loaded && Age==1)
        {
            Bull=CaelumBull(ActorIterator.Create(44211,"CA211SavedBull").Next());
            Check("saved bull retained",Bull!=null);if(Bull==null)return;
            Check("saved charge active",Bull.BullChargeActive);
            Check("saved speed and health",Bull.BullChargeSpeed==3.25 && Bull.health==2345);
            Check("saved charge state",Bull.InStateSequence(Bull.CurState,Bull.FindState("BullChargeLoop")));
            double capacity=Bull.GetBiologicalLandingAbsorptionSpeed();
            Check("loaded capacity recalculated",Abs(Bull.ImpactAbsorptionSpeed(100,CaelumConstants.IMPACT_KIND_ACTOR,(1,0,0))-capacity)<0.000001);
            Bull.EnsureBullChargeRevision();Bull.EnsureBullChargeRevision();
            Check("repeated ensure preserves existing charge",Bull.BullChargeActive && Bull.BullChargeSpeed==3.25 && Bull.health==2345);
            Bull.StopBullCharge();
            Check("loaded charge stops normally",!Bull.BullChargeActive && Bull.ImpactAbsorptionSpeed(100,CaelumConstants.IMPACT_KIND_ACTOR,(1,0,0))==0);
            Console.Printf("CA211 DONE failures=%d passes=%d",Failures,Passes);
        }
    }
}
