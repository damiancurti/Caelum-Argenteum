class CA427Probe : CaelumCombatActor
{
    Default { Health 100; Radius 16; Height 56; Speed 4; +SHOOTABLE +ISMONSTER }
    override void Tick() { }
    States { Spawn: TNT1 A -1; Stop; See: TNT1 A -1; Stop; }
}
class CA427Walker : CaelumCombatActor
{
    Default { Health 100; Radius 16; Height 56; Speed 4; +SHOOTABLE +ISMONSTER }
    States
    {
        Spawn: TNT1 A 3 A_CaelumBudgetedLook; Loop;
        See: TNT1 A 3 A_CaelumBudgetedChase; Loop;
    }
}
class CA427Checks : EventHandler
{
    int Checks,Failures,Stage,Start,ObservationTic;
    bool WalkOnly,WallClear;
    CA427Probe Observer,Subject;
    CA427Walker Walker;
    Actor SearchGoal;
    vector3 OriginalPoint,BeforeSearch;
    void Check(bool ok,String label)
    {Checks++;if(!ok)Failures++;Console.Printf("CA427 %s %s",ok?"PASS":"FAIL",label);}
    void Seed(CaelumPlayer user)
    {
        user.player.cheats|=CF_GODMODE;user.SetOrigin((-1700,-1700,0),false);
        Observer=CA427Probe(Actor.Spawn("CA427Probe",(0,0,0)));
        Subject=CA427Probe(Actor.Spawn("CA427Probe",(256,0,0)));
        Observer.CombatEffectiveInsight=0;Subject.CombatAgility=0;Subject.bFriendly=true;
        Observer.Angle=0;Observer.CurSector.SetLightLevel(255);
        Walker=CA427Walker(Actor.Spawn("CA427Walker",(-1000,1000,0)));
        Walker.Angle=0;
        let noise=Actor.Spawn("CA427Probe",(-1200,1000,0));
        CaelumNoise.Emit(noise,CaelumNoiseData.DOOR);noise.Destroy();
        Check(Walker.VisualEvidence!=null && Walker.VisualEvidence.HasHeardNoise,"ordinary NPC hears door inside range");
        Check(CaelumVisualPerception.Acquire(Observer)==null,"unknown body still needs visual confirmation");
        Stage=1;Start=level.time;
    }
    override void WorldTick()
    {
        if(Stage==0 || Stage==6)return;
        int elapsed=level.time-Start;
        if(Stage==1)
        {
            Actor acquired=CaelumVisualPerception.Acquire(Observer);
            if(elapsed==35)
            {
                Console.Printf("CA427 WALK pos=(%.2f,%.2f) speed=%.2f heard=%d target=%s phase=%d sleep=%d",
                    Walker.Pos.X,Walker.Pos.Y,Walker.Speed,Walker.VisualEvidence.HasHeardNoise,
                    Walker.target==null?'none':Walker.target.GetClassName(),Walker.RecoveryPhase,Walker.ForcedSleepTics);
                Console.Printf("CA427 WALK goal=(%.2f,%.2f) noise=(%.2f,%.2f) angle=%.2f health=%d max=%d direction=%d count=%d",
                    Walker.target.Pos.X,Walker.target.Pos.Y,Walker.VisualEvidence.NoisePosition.X,Walker.VisualEvidence.NoisePosition.Y,
                    Walker.Angle,Walker.health,Walker.CombatMaximumHealth,Walker.movedir,Walker.movecount);
                Check(Walker.Pos.X<-1000 && Walker.target is "CaelumSearchPoint","ordinary NPC state machine investigates anonymous event");
                Check(Walker.VisualEvidence.IdentifiedSubject==null && Walker.VisualEvidence.GetMemory().Records.Size()==0,"investigation of vanished emitter creates no identity");
                Walker.Destroy();
                if(WalkOnly){Stage=6;Console.Printf("CA427 RESULT walker checks=%d failures=%d",Checks,Failures);return;}
            }
            if(elapsed==70)
            {
                Check(acquired==Subject,"two seconds confirm first identity");
                OriginalPoint=Subject.Pos;BeforeSearch=Observer.Pos;
                Subject.SetOrigin((-256,0,0),false);Observer.target=Subject;
                Check(CaelumVisualPerception.Acquire(Observer)==null,"hidden known body is not an attack target");
                SearchGoal=CaelumVisualPerception.SearchGoal(Observer);
                Check(SearchGoal!=null && SearchGoal.Pos==OriginalPoint,"search uses last visible snapshot");
                Observer.target=SearchGoal;
                Check(!Observer.WithinAttackRange(true),"private search marker can never authorize an attack");
                Stage=2;Start=level.time;
            }
        }
        else if(Stage==2)
        {
            Observer.ThermalChase(null,null,CHF_DONTLOOKALLAROUND);
            if(elapsed==35)
            {
                Check(Observer.Pos.X>BeforeSearch.X && Observer.Pos.X<=OriginalPoint.X,"native chase approaches last-known point");
                Subject.SetOrigin((-512,256,0),false);
                Check(CaelumVisualPerception.SearchGoal(Observer).Pos==OriginalPoint,"hidden movement cannot move search marker");
            }
            if(elapsed==40)
            {
                Subject.SetOrigin((512,0,0),false);Observer.Angle=0;
                Check(CaelumVisualPerception.Acquire(Observer)==Subject,"reappearance within memory reacquires immediately");
                Check(SearchGoal==null || SearchGoal.bDestroyed,"reacquisition removes private search marker");
                OriginalPoint=Subject.Pos;ObservationTic=level.time;Subject.SetOrigin((-512,0,0),false);
                Stage=3;Start=level.time;
            }
        }
        else if(Stage==3)
        {
            CaelumVisualPerception.Acquire(Observer);
            if(elapsed==35)
            {
                CaelumNoise.Emit(Subject,CaelumNoiseData.FIREARM);
                Check(Observer.VisualEvidence.GetMemory().Find(Subject).ObservedTic==ObservationTic,"anonymous noise cannot renew identified memory");
                Check(CaelumVisualPerception.SearchGoal(Observer).Pos==OriginalPoint,"valid current threat retains its recorded position over unrelated noise");
            }
            if(elapsed==30*TICRATE-1)
                Check(Observer.VisualEvidence.GetMemory().Find(Subject)!=null,"memory remains valid until final active tic");
            if(elapsed==30*TICRATE)
            {
                Check(Observer.VisualEvidence.GetMemory().Find(Subject)==null,"memory expires at thirty active seconds");
                Check(!Observer.VisualEvidence.GetMemory().HasFocus(Observer),"expired target focus clears");
                Subject.SetOrigin((512,0,0),false);Observer.Angle=0;
                Check(!CaelumVisualPerception.Identify(Observer,Subject),"forgotten identity requires observation again");
                Stage=4;Start=level.time;
            }
        }
        else if(Stage==4)
        {
            bool known=CaelumVisualPerception.Identify(Observer,Subject);
            if(elapsed==35)Check(!known,"one second cannot identify forgotten body");
            if(elapsed==70)
            {
                Check(known,"forgotten body identified after two new seconds");
                Observer.VisualEvidence.GetMemory().Focus=Subject;
                Subject.SetOrigin(Observer.Pos+(32,0,0),false);Observer.Angle=0;
                CaelumVisualPerception.Identify(Observer,Subject);
                Observer.EnsureRecoveryRevision();Observer.MaximumCombatAir=100;Observer.MaximumCombatAnima=100;
                Observer.RecoveryThreat=Subject;Observer.RecoveryThreatPerceivedRange=Subject.MeleeRange;
                Observer.CurrentCombatAir=0;Observer.CurrentCombatAnima=0;Observer.RecoveryPhase=1;
                Subject.SetOrigin((-512,0,0),false);
                double beforeRetreat=Observer.Pos.X;Observer.PulseResourceRecovery();
                Check(Observer.RecoveryGoal!=null && Observer.RecoveryGoal.Pos.X<beforeRetreat,"resource retreat uses last-known threat point, not hidden movement");
                Observer.EndResourceRecovery();Observer.CurrentCombatAir=Observer.MaximumCombatAir;
                Observer.CurrentCombatAnima=Observer.MaximumCombatAnima;
                Subject.SetOrigin((512,0,0),false);Observer.Angle=0;CaelumVisualPerception.Identify(Observer,Subject);
                let other=CA427Probe(Actor.Spawn("CA427Probe",Observer.Pos+(32,0,0)));
                other.bFriendly=true;other.CombatAgility=0;
                Check(CaelumVisualPerception.Identify(Observer,other),"physical contact confirms second body");
                Check(CaelumVisualPerception.Acquire(Observer)==Subject,"nearer threat does not replace valid current target");
                Subject.health=0;
                Check(CaelumVisualPerception.Acquire(Observer)==other,"dead target replaced by valid perceived threat");
                other.Destroy();
                Check(Observer.VisualEvidence.GetMemory().Find(other)==null,"removed actor cannot remain a valid memory");
                Observer.VisualEvidence.HasVisualPoint=false;Observer.VisualEvidence.HasHeardNoise=false;
                Check(CaelumVisualPerception.SearchGoal(Observer)==null,"no stale search after all evidence is gone");
                Subject.health=100;Subject.SetOrigin((-512,0,0),false);
                CaelumNoise.Emit(Subject,CaelumNoiseData.FIREARM);SearchGoal=CaelumVisualPerception.SearchGoal(Observer);
                Check(SearchGoal!=null && SearchGoal.Pos==Subject.Pos,"anonymous sound alone creates point investigation");
                Observer.health=0;Stage=5;Start=level.time;
            }
        }
        else if(Stage==5 && elapsed>=2)
        {
            Check(SearchGoal==null || SearchGoal.bDestroyed,"observer death removes its private search marker");
            Stage=6;Console.Printf("CA427 RESULT checks=%d failures=%d",Checks,Failures);
        }
        else if(Stage==7)
        {
            if(Walker.Pos.X>496 && Walker.Pos.X<592 && Walker.Pos.Y>496 && Walker.Pos.Y<1040)WallClear=false;
            if(elapsed==105)
            {
                Check(Walker.Pos.X>384,"native investigation approaches obstructing wall");
                Check(WallClear,"search movement never crosses solid pillar");
                Check(Walker.VisualEvidence.IdentifiedSubject==null,"obstructed sound does not disclose identity");
                Stage=6;Console.Printf("CA427 RESULT wall checks=%d failures=%d",Checks,Failures);
            }
        }
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let user=CaelumPlayer(players[e.Player].mo);if(user==null)return;
        if(e.Name=="ca427_seed")Seed(user);
        if(e.Name=="ca427_walk"){WalkOnly=true;Seed(user);}
        if(e.Name=="ca427_wall")
        {
            user.player.cheats|=CF_GODMODE;user.SetOrigin((-1700,-1700,0),false);
            Walker=CA427Walker(Actor.Spawn("CA427Walker",(384,768,0)));Walker.Angle=0;
            let noise=Actor.Spawn("CA427Probe",(704,768,0));
            CaelumNoise.Emit(noise,CaelumNoiseData.MAGIC);noise.Destroy();
            Stage=7;Start=level.time;WallClear=true;
        }
        if(e.Name=="ca427_reload")
        {
            Check(Stage==3,"saved investigation phase restored");
            let record=Observer.VisualEvidence.GetMemory().Find(Subject);
            Check(record!=null && record.Position==OriginalPoint && record.ObservedTic==ObservationTic,"recorded position and original observation tic survive save");
            Check(level.time>ObservationTic && level.time-ObservationTic<30*TICRATE,"loading does not restart memory age");
            Check(Observer.VisualEvidence.IdentifiedSubject==null,"hidden body remains unavailable for attack after load");
        }
        if(e.Name=="ca427_migration")
        {
            Check(Stage==6 && Observer.health==321,"pre-memory actor state preserved");
            Check(Observer.VisualEvidence.Memory==null,"pre-memory save has no invented recognized records");
            Check(Observer.VisualEvidence.HasHeardNoise && Observer.VisualEvidence.NoisePosition==OriginalPoint,"previous anonymous noise survives");
            let memory=Observer.VisualEvidence.GetMemory();
            Check(memory.Revision==CaelumPerceptionMemoryData.REVISION && memory.Records.Size()==0,"idempotent empty recognition migration");
            Check(CaelumVisualPerception.SearchGoal(Observer).Pos==OriginalPoint,"preserved sound can be investigated after migration");
            Check(memory==Observer.VisualEvidence.GetMemory(),"memory migration preserves object identity");
            Console.Printf("CA427 RESULT checks=%d failures=%d",Checks,Failures);
        }
    }
}
