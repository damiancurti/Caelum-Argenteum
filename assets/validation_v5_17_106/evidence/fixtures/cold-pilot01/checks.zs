// Private regression: a technical route must not erase ongoing visual recognition.
class CA853FrozenMandinga : CaelumMandinga { override void Tick() {} }
class CA855FrozenZupay : CaelumZupayColossus { override void Tick() {} }
class CA853VisualTarget : Actor
{
    Default { Health 1000; Radius 16; Height 56; +SHOOTABLE +INVULNERABLE +NOGRAVITY }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA853NavigationProbe : EventHandler
{
    const BOSS=false;
    const COLD=true;
    CaelumCombatActor Observer;
    Actor Victim,Goal;
    int Started,Checks,Failures;
    bool Running;
    bool SnapshotReady,SavedVisible;
    double SavedAnima,SavedPaid;
    int SavedContinuity;
    Actor SavedSubject,SavedIdentified,SavedFlame;
    void Check(bool okay,String label)
    {Checks++;if(!okay)Failures++;Console.Printf("CA836 EDGE %s navigation: %s",okay?"PASS":"FAIL",label);}
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=='ca855reload')
        {
            Checks=Failures=0;
            Check(SnapshotReady && Observer!=null && Victim!=null && Goal!=null,"saved native identities retained");
            let evidence=CaelumVisualPerception.Evidence(Observer);
            Check(evidence.Subject==SavedSubject && evidence.IdentifiedSubject==SavedIdentified
                && evidence.PreviousSampleVisible==SavedVisible && evidence.ContinuousSightTics==SavedContinuity,"saved visual evidence retained exactly");
            Check(Observer.target==Goal && Abs(Observer.CurrentCombatAnima-SavedAnima)<0.0000001,"saved route and Anima retained");
            Check(Observer.DemonBreath==SavedFlame,"saved owned breath identity retained");
            if(COLD)
            {
                Check(Observer.DemonBreath!=null && Observer.DemonBreath.Emitter==Observer,"saved emitter ownership retained");
                Check(Abs(Observer.DemonBreath.TotalPaidSeconds-SavedPaid)<0.0000001,"saved paid duration retained");
                Check(Observer.InStateSequence(Observer.CurState,Observer.FindState("RacialBreath")),"saved breathing state retained");
            }
            Console.Printf("CA836 EDGE_RESULT checks=%d failures=%d result=%s",Checks,Failures,Failures==0?"PASS":"FAIL");
            return;
        }
        if(e.Name!='ca853seed')return;
        let user=CaelumPlayer(players[0].mo);user.player.cheats|=CF_GODMODE;user.SetOrigin((-1700,-1700,0),false);
        Observer=CaelumCombatActor(Actor.Spawn(BOSS?'CA855FrozenZupay':'CA853FrozenMandinga',(-512,0,0),NO_REPLACE));
        Victim=Actor.Spawn('CA853VisualTarget',(-256,0,0),NO_REPLACE);
        Goal=Actor.Spawn('CaelumSewerEscapeTarget',(-512,1500,0),NO_REPLACE);
        Check(Observer!=null && Victim!=null && Goal!=null,"native bodies exist");
        Observer.Angle=0;Observer.CombatEffectiveInsight=0;Observer.SetStateLabel("RestLying");
        Observer.CaelumDiagnosticPassiveAI=false;Observer.CaelumMassAIScheduleActive=false;
        Observer.ForcedSleepTics=0;Observer.CombatLucidityPhysicalStunRemaining=0;Observer.RecoveryPhase=0;
        Observer.CurrentCombatAnima=Observer.MaximumCombatAnima;
        if(Observer.ThermalState==null)Observer.ThermalState=new('CaelumThermalState');
        Observer.ThermalState.Exposure=COLD?-1:0;Observer.ThermalState.Severity=COLD?1:0;
        Observer.CurSector.SetLightLevel(255);
        if(COLD)
        {
            Observer.target=Goal;CaelumDemonService.UpdateBreath(Observer);
            Check(Observer.DemonBreath!=null,"cold starts a legitimate paid emission before recognition");
        }
        let evidence=CaelumVisualPerception.Evidence(Observer);
        Check(CaelumVisualPerception.CanSee(Observer,Victim),"real target visible through native predicates");
        evidence.Observe(Observer,Victim);
        Check(evidence.PreviousSampleVisible && evidence.ContinuousSightTics==0,"recognition begins without prior identity");
        Check(Goal.bShootable && Goal.health>0 && !CaelumDemonBreath.CanReach(Observer,Goal),"live route marker is explicitly excluded from breath");
        Started=level.time;Running=true;
    }
    override void WorldTick()
    {
        if(!Running)return;
        int age=level.time-Started;
        let evidence=CaelumVisualPerception.Evidence(Observer);
        if(age==TICRATE)
        {
            evidence.Observe(Observer,Victim);
            Check(evidence.ContinuousSightTics==TICRATE && evidence.PreviousSampleVisible,"one real second of visual recognition retained");
            int before=evidence.ContinuousSightTics;double anima=Observer.CurrentCombatAnima;
            let flame=Observer.DemonBreath;double paid=flame!=null?flame.TotalPaidSeconds:0;
            Observer.target=Goal;CaelumDemonService.UpdateBreath(Observer);
            Console.Printf("CA853 NAVIGATION before=%d after=%d previous_visible=%d subject=%s",before,evidence.ContinuousSightTics,evidence.PreviousSampleVisible,evidence.Subject!=null?evidence.Subject.GetClassName():'None');
            Check(evidence.ContinuousSightTics==before && evidence.PreviousSampleVisible,"excluded navigation preserves ongoing recognition");
            if(COLD)
            {
                double cost=Observer.GetMagicAnimaCost(CaelumDemonBreathRules.ANIMA_PER_SECOND)/TICRATE;
                Check(Observer.DemonBreath!=null && Observer.DemonBreath==flame,"cold keeps the same owned emission");
                Check(Abs(Observer.CurrentCombatAnima-(anima-cost))<0.0000001,"cold emission pays exactly one native tic");
                Check(flame!=null && Abs(flame.TotalPaidSeconds-paid-1.0/TICRATE)<0.0000001,"paid path advances emission duration exactly once");
            }
            else Check(Observer.DemonBreath==null && Observer.CurrentCombatAnima==anima,"route does not start breath or spend Anima");
        }
        if(age==TICRATE*2)
        {
            evidence.Observe(Observer,Victim);
            Check(evidence.IdentifiedSubject==Victim,"real target identifies after two observed seconds");
            SavedAnima=Observer.CurrentCombatAnima;SavedFlame=Observer.DemonBreath;
            SavedPaid=Observer.DemonBreath!=null?Observer.DemonBreath.TotalPaidSeconds:0;
            SavedSubject=evidence.Subject;SavedIdentified=evidence.IdentifiedSubject;
            SavedContinuity=evidence.ContinuousSightTics;SavedVisible=evidence.PreviousSampleVisible;SnapshotReady=true;
            Console.Printf("CA836 EDGE_RESULT checks=%d failures=%d result=%s",Checks,Failures,Failures==0?"PASS":"FAIL");
            Running=false;
        }
    }
}
