// Fixture compartida por el paquete anterior y el actual: observa combate
// nativo y conserva los mismos cuerpos en las pruebas de guardado.
class CA369ProbeBase : EventHandler
{
    CaelumPlayer User;
    CaelumBull Subject,Dead,Archived;
    CaelumM00Bull Trial,Grace;
    int Passed,Failed,TraceStart;
    bool Tracing,Manual;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA369 %s %s",ok?"PASS":"FAIL",label);}
    override void UiTick(){if(!Manual && Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    void UserSetup()
    {
        User=CaelumPlayer(players[consoleplayer].mo);User.InitializeDirectMapCharacter();
        User.CharacterCreationComplete=true;User.CreationWizardOpen=false;User.ApplyCharacterProfile();
        User.bInvulnerable=true;User.bNOTARGET=true;User.CurrentHunger=User.CurrentThirst=75;User.CurrentSleep=User.CurrentLucidity=100;
    }
    void Setup()
    {
        UserSetup();User.SetOrigin((-128,-100,0),false);User.Angle=38;User.Pitch=5;
        Subject=CaelumBull(Actor.Spawn('CaelumBull',(0,0,0),NO_REPLACE));Subject.Angle=180;Subject.bDormant=true;Subject.SetStateLabel("Spawn");
    }
    void Cast()
    {
        Setup();
        Dead=CaelumBull(Actor.Spawn('CaelumBull',(160,0,0),NO_REPLACE));
        Archived=CaelumBull(Actor.Spawn('CaelumBull',(320,0,0),NO_REPLACE));
        Trial=CaelumM00Bull(Actor.Spawn('CaelumM00Bull',(0,160,0),NO_REPLACE));Trial.SetStateLabel("TrialIdle");
        Grace=CaelumM00Bull(Actor.Spawn('CaelumM00Bull',(160,160,0),NO_REPLACE));Grace.PrepareEncounter(User);Grace.TrialGraceTicks=10000;
    }
    void KillCast()
    {
        // PostBeginPlay inicializa salud en el siguiente tic del Spawn nativo.
        Subject.SetStateLabel("RestLying");Subject.target=null;Subject.Vel=(0,0,0);
        Dead.DamageMobj(User,User,1000000,'None',DMG_FORCED);
        Archived.DamageMobj(User,User,1000000,'None',DMG_FORCED);
    }
    void Archive()
    {
        Archived.GiveInventory('CaelumArchivedCorpse',1);
        CaelumArchivedCorpse(Archived.FindInventory('CaelumArchivedCorpse')).Suspend();
    }
    void CheckCast()
    {
        Check(Subject!=null && Subject.health>0,"saved live bull identity");
        Check(Dead!=null && Dead.health<=0 && Dead.bCorpse,"saved ordinary corpse identity");
        Check(Archived!=null && CaelumCorpseArchive.Suspended(Archived),"saved archived corpse remains suspended");
        Check(Trial!=null && !Trial.TrialReleased && Trial.TrialFighter==null,"saved tutorial idle gate");
        Check(Grace!=null && !Grace.TrialReleased && Grace.TrialGraceTicks>0,"saved tutorial grace gate");
        Check(Subject.Radius==15.6 && Subject.Height==51.8 && Subject.Mass==900,"native collision dimensions and mass retained");
        Console.Printf("CA369 BODY health=%d air=%.9f speed=%.9f chargecap=%.9f damagebase=%.9f",Subject.health,Subject.CurrentCombatAir,Subject.Speed,Subject.GetBullRunningSpeed(),CaelumConstants.BULL_GORE_BASE_DAMAGE);
    }
    void Encounter()
    {
        UserSetup();User.bNOTARGET=false;
        let controller=CaelumMainM00QuestController(EventHandler.Find('CaelumMainM00QuestController'));
        Trial=controller.TrialBull;Subject=Trial;
        Check(Trial!=null,"authored MAP01 bull exists");
        User.SetOrigin((-2400,0,0),false);User.Angle=0;User.Pitch=0;Trial.PrepareEncounter(User);
        TraceStart=level.time;Tracing=true;
    }
    override void WorldTick()
    {
        if(!Tracing || Subject==null)return;
        int elapsed=level.time-TraceStart;
        Console.Printf("CA369 TRACE %d %d %d %d %d %.9f %.9f %.9f %.9f %.9f %.9f %.9f %d",elapsed,
            Subject.CurState.sprite,Subject.CurState.Frame,Subject.tics,Subject.health,
            Subject.Pos.X,Subject.Pos.Y,Subject.Pos.Z,Subject.CurrentCombatAir,Subject.BullChargeSpeed,
            User.Pos.X,User.Pos.Y,User.health);
        if(elapsed>=180){Tracing=false;Check(Trial.TrialReleased,"MAP01 native grace releases encounter");}
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="c369_setup")Setup();
        else if(e.Name=="c369_user")UserSetup();
        else if(e.Name=="c369_cast")Cast();
        else if(e.Name=="c369_killcast")KillCast();
        else if(e.Name=="c369_archive")Archive();
        else if(e.Name=="c369_checkcast")CheckCast();
        else if(e.Name=="c369_encounter")Encounter();
        else if(e.Name=="c369_done")Console.Printf("CA369 DONE passes=%d failures=%d",Passed,Failed);
    }
}
