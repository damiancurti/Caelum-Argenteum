class CA449Port : CaelumPortSiege replaces CaelumPortSiege { override void Tick() {} }
class CA449Body : CaelumMandinga { override void Tick() {} }
class CA449Checks : EventHandler
{
    CaelumCannon Gun;
    CaelumBatteringRam Ram;
    CaelumPortSiege Port;
    Actor SavedBlock;
    int Failures;
    void Check(bool okay,String label)
    {if(!okay)Failures++;Console.Printf("CA449 %s %s",okay?"PASS":"FAIL",label);}
    void Seed()
    {
        Port=CaelumPortSiege.Get();if(Port==null)Port=CaelumPortSiege(Actor.Spawn('CA449Port',(0,0,0)));
        Gun=CaelumCannon(Actor.Spawn('CaelumCannon',(0,512,0)));Gun.InitializeCannon(false);Port.RegisterMachine(Gun);
        Ram=CaelumBatteringRam(Actor.Spawn('CaelumBatteringRam',(-1024,512,0)));Ram.InitializeRam();Port.RegisterMachine(Ram);
        let body=CaelumCombatActor(Actor.Spawn('CA449Body',(0,768,0)));let guard=Port.RegisterAttacker(body);Gun.RememberGuard(guard);
        Port.SealRoster();Gun.ActivateCannon(0);guard.ConfirmedDead=true;body.health=0;Gun.ObserveGuards();
        Ram.DestroyByTarot();Port.Victory=true;SavedBlock=Gun.Blocks[0];
    }
    void Initial()
    {
        Check(Gun.Neutralized && !Gun.TarotDestroyed,"original pre-449 save records guard-death neutralization without physical destruction");
        Check(Ram.TarotDestroyed && Port.Victory,"original save retains a genuinely destroyed ram and won encounter");
        Console.Printf("CA449 CHECKPOINT READY failures=%d",Failures);
    }
    void LegacyRestored()
    {
        // BEGIN CURRENT VERIFICATION
        Gun.EnsureMachine();Ram.EnsureMachine();
        Check(Gun.MachineRevision==1 && Gun.Structure!=null,"old machine gains its revisioned structural owner");
        Check(Gun.Blocks[0]==SavedBlock && SavedBlock.master==Gun.Structure,"migration binds the original physical pieces without duplication");
        Check(!Gun.Neutralized && !Gun.Captured && !Gun.ObjectiveNeutralized(),"alive former guard-death machine uses the new explicit objective rule");
        Check(Ram.TarotDestroyed && Ram.ObjectiveNeutralized() && Ram.Structure.Broken,"actual original destruction remains irreversible");
        Check(Port.Victory,"migration preserves already won encounters");
        let structure=Gun.Structure;Gun.EnsureMachine();Check(Gun.Structure==structure,"migration repeats without recreating structure");
        // END CURRENT VERIFICATION
        Console.Printf("CA449 LEGACY %s failures=%d",Failures==0?"PASS":"FAIL",Failures);
    }
    override void NetworkProcess(ConsoleEvent e)
    {if(e.Name=="ca449_seed")Seed();else if(e.Name=="ca449_initial")Initial();else if(e.Name=="ca449_legacy")LegacyRestored();}
}
