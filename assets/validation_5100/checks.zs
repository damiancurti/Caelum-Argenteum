class CA425Probe : CaelumCombatActor
{
    Default { Health 100; Radius 16; Height 56; +SHOOTABLE +ISMONSTER +NOGRAVITY }
    override void Tick() { }
    States { Spawn: TNT1 A -1; Stop; }
}

class CA425Witness : CA425Probe
{
    override void Tick() { if(PendingTheftTarget!=null)CaelumTheftWitnesses.UpdatePending(self); }
    States { See: TNT1 A -1; Stop; Melee: TNT1 A -1; Stop; }
}

class CA425Checks : EventHandler
{
    int Checks,Failures,Stage,Start;
    CA425Probe Observer,Subject;
    CaelumCombatActor LegacyActive;
    CaelumCannon Gun;
    CA425Witness Witness;
    CaelumPlayer Owner;
    void Check(bool ok,String label)
    { Checks++;if(!ok)Failures++;Console.Printf("CA425 %s %s",ok?"PASS":"FAIL",label); }
    void Seed(CaelumPlayer user)
    {
        user.player.cheats|=CF_GODMODE;user.SetOrigin((-1700,-1700,0),false);
        Observer=CA425Probe(Actor.Spawn("CA425Probe",(0,0,0)));
        Subject=CA425Probe(Actor.Spawn("CA425Probe",(256,0,0)));
        Observer.CombatEffectiveInsight=0;Subject.CombatAgility=0;Subject.bFriendly=true;
        Observer.Angle=0;Observer.CurSector.SetLightLevel(255);
        Check(Abs(CaelumVisualPerception.Range(Observer,Subject)-1024)<.001,"32 metres at Insight zero");
        Check(CaelumVisualPerception.CanSee(Observer,Subject),"front visible");
        Observer.Angle=180;Check(!CaelumVisualPerception.CanSee(Observer,Subject),"rear outside 180-degree field");
        Observer.Angle=90;Check(CaelumVisualPerception.CanSee(Observer,Subject),"90-degree edge included");Observer.Angle=0;
        Subject.SetOrigin((1200,0,0),false);Check(!CaelumVisualPerception.CanSee(Observer,Subject),"outside base range");
        Observer.CombatEffectiveInsight=100;Check(CaelumVisualPerception.CanSee(Observer,Subject),"Insight M2 extends range fourfold");
        Observer.CombatEffectiveInsight=0;Subject.SetOrigin((256,0,0),false);
        Observer.CurSector.SetLightLevel(0);Check(Abs(CaelumVisualPerception.Range(Observer,Subject)-102.4)<.001,"darkness ten percent");
        Check(!CaelumVisualPerception.CanSee(Observer,Subject),"dark distant body unseen");Observer.CurSector.SetLightLevel(255);
        Subject.Height=28;Check(Abs(CaelumVisualPerception.Range(Observer,Subject)-512)<.001,"visible height counted once");Subject.Height=56;
        Subject.CombatAgility=100;Check(!CaelumVisualPerception.CanSee(Observer,Subject),"full stealth defeats normal sight");
        Subject.SetOrigin((32,0,0),false);Observer.Angle=180;
        Check(CaelumVisualPerception.CanSee(Observer,Subject),"contact reveals behind observer despite stealth");
        Subject.CombatAgility=0;Subject.SetOrigin((256,0,0),false);Observer.Angle=0;
        Observer.VisualEvidence=new("CaelumVisualEvidence");Observer.VisualEvidence.Initialize();
        Observer.SetOrigin((384,768,0),false);Subject.SetOrigin((704,768,0),false);
        Check(!CaelumVisualPerception.CanSee(Observer,Subject),"solid pillar occludes an otherwise visible body");
        Observer.SetOrigin((0,0,0),false);Subject.SetOrigin((256,0,0),false);
        Observer.bFriendly=true;Subject.bFriendly=false;
        Gun=CaelumCannon(Actor.Spawn("CaelumCannon",(-100,0,0)));Gun.InitializeCannon(true);
        Check(!Gun.OperatorsSee(Subject),"uncrewed cannon cannot observe");
        Check(Gun.AssignOperator(Observer),"real operator assigned");
        Check(Gun.OperatorsSee(Subject),"living operator perceives from own origin");
        Observer.Angle=180;Check(!Gun.OperatorsSee(Subject),"barrel orientation cannot override operator field");Observer.Angle=0;
        Check(!Gun.OperatorsIdentify(Subject),"cannon operator must identify before requesting target");
        Check(!CaelumVisualPerception.Identify(Observer,Subject),"first visual sample does not identify");
        user.SetOrigin((1000,-1000,0),false);user.EffectiveStealthPercent=0;Owner=user;
        Witness=CA425Witness(Actor.Spawn("CA425Witness",(900,-1000,0)));Witness.bFriendly=true;Witness.Angle=0;
        CaelumTheftWitnesses.Alert(user);
        Check(Witness.PendingTheftTarget==user && Witness.TheftTarget==null && Witness.bFriendly,"crime witness awaits recognition before hostility");
        Stage=1;Start=level.time;
    }
    override void WorldTick()
    {
        if(Stage==0 || Observer==null || Subject==null)return;
        int elapsed=level.time-Start;
        if(Stage==1)
        {
            bool identified=CaelumVisualPerception.Identify(Observer,Subject);
            if(Stage==1)Gun.OperatorsIdentify(Subject);
            if(elapsed==35)Check(!identified && Abs(Observer.VisualEvidence.Suspicion-50)<.001,"one active second is fifty suspicion");
            if(elapsed==70)
            {
                Check(identified,"two continuous active seconds identify");
                CaelumTheftWitnesses.UpdatePending(Witness);
                Check(Witness.TheftTarget==Owner && !Witness.bFriendly,"recognized visible theft preserves lawful reaction");
                Check(Gun.OperatorsIdentify(Subject),"operator identifies after two actual seconds");
                Observer.health=0;Check(!Gun.OperatorsSee(Subject) && !Gun.OperatorsIdentify(Subject),"dead crew cannot update cannon perception");Observer.health=100;
                Subject.SetOrigin((-256,0,0),false);Observer.target=Subject;
                Observer.A_CaelumFacePerceivedTarget();
                Check(Observer.Angle==0,"preparation cannot turn toward an unseen live position");
                Check(!Observer.WithinAttackRange(true),"final release gate rejects hidden target");
                Stage=2;Start=level.time;
            }
        }
        else if(Stage==2)
        {
            bool identified=CaelumVisualPerception.Identify(Observer,Subject);
            if(Stage==1)Gun.OperatorsIdentify(Subject);
            if(elapsed==35)Check(!identified && Observer.VisualEvidence.Suspicion==100,"hidden target cannot be attacked during grace");
            if(elapsed==105)
            {
                Check(Abs(Observer.VisualEvidence.Suspicion-80)<.001,"decay twenty per second after grace");
                Observer.VisualEvidence.Damaged(Observer,Subject);
                Check(Observer.VisualEvidence.Suspicion==100 && Observer.VisualEvidence.IdentifiedSubject==null,"hidden damage alerts without identity");
                Subject.SetOrigin((256,0,0),false);
                Check(!CaelumVisualPerception.Identify(Observer,Subject) && Observer.VisualEvidence.Suspicion==100,"full alert does not identify a newly visible body");
                Observer.target=Subject;Observer.LastEnemy=Subject;Observer.VisualEvidence=null;
                CaelumVisualPerception.Evidence(Observer);
                Check(Observer.target==null && Observer.LastEnemy==null && Observer.VisualEvidence.Suspicion==0,"legacy perception reset preserves actor");
                Check(Observer.health==100,"migration preserves health");
                Stage=0;Console.Printf("CA425 RESULT checks=%d failures=%d",Checks,Failures);
            }
        }
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let user=CaelumPlayer(players[e.Player].mo);if(user==null)return;
        if(e.Name=="ca425_seed")Seed(user);
        if(e.Name=="ca425_reload")
        {
            Check(Stage==1 && Observer!=null && Subject!=null,"partial observation graph restored");
            Check(Observer.VisualEvidence!=null && Observer.VisualEvidence.Suspicion>0 && Observer.VisualEvidence.Suspicion<100,"partial suspicion survives without restart");
            Check(Observer.VisualEvidence.Subject==Subject,"private observed subject restored");
        }
        if(e.Name=="ca425_legacy")
        {
            Check(Observer!=null && Subject!=null && Observer.VisualEvidence==null,"old save has no invented perception");
            CaelumVisualPerception.Evidence(Observer);
            Check(Observer.target==null && Observer.LastEnemy==null && Observer.VisualEvidence.Suspicion==0,"old live target reset on migration");
            Check(Observer.health==321,"old actor health preserved");
            Check(LegacyActive!=null && LegacyActive.VisualEvidence!=null && LegacyActive.target==null,"normal production NPC migrated during Tick");
            let record=Observer.VisualEvidence;CaelumVisualPerception.Evidence(Observer);
            Check(record==Observer.VisualEvidence,"migration idempotent");
            Console.Printf("CA425 RESULT checks=%d failures=%d",Checks,Failures);
        }
    }
}
