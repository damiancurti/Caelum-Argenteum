// Prueba aislada: perfiles reales, movimiento nativo y referencias guardadas.
class CA307Token : Inventory { Default { Inventory.MaxAmount 20; } }
class CA307Snapshot : Actor
{
    Array<CaelumAnchoredResident> Bodies;
    Array<double> Bases;
    Default { +NOINTERACTION }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA307Blocker : Actor
{
    Default { Radius 40; Height 128; Health 100; +SOLID +SHOOTABLE +NOGRAVITY }
    States { Spawn: TNT1 A -1; Stop; }
}
// Control de marcha nativa con la cadencia literal anterior a #307 y sin ataques.
class CA307WalkingControl : CaelumPrisonerUnitario
{
    States { NativeWalk: PUNC A 4 A_Chase(null,null); Loop; }
}
class CA307Probe : EventHandler
{
    CaelumPlayer User;
    CaelumAnchoredResident Body;
    int Passed, Failed, Age, CaseIndex, Trials, HeldHealth;
    bool Running, Baseline, Overspeed, Penalty, Moved;
    vector3 Previous, Stopped;
    double PreviousSpeed, PeakStep, PeakCommand;
    vector3 WalkStart;
    double NativeDistance;

    override void UiTick()
    { if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close(); }

    void Check(bool ok, String message)
    {
        if(ok)Passed++;else Failed++;
        Console.Printf("CA307 %s case=%d %s",ok?"PASS":"FAIL",CaseIndex,message);
    }

    Class<CaelumAnchoredResident> Kind(int index)
    {
        Class<CaelumAnchoredResident> kinds[]={"CaelumPrisonerUnitario","CaelumPrisonerFederal","CaelumPrisonerBestia","CaelumPrisonerTarot"};
        return kinds[index%4];
    }

    void Setup()
    {
        User=CaelumPlayer(players[consoleplayer].mo);
        User.CharacterCreationComplete=true;User.CreationWizardOpen=false;
        User.ApplyCharacterProfile();User.bInvulnerable=true;
        User.SetOrigin((0,0,0),false);User.Vel=(0,0,0);
        for(int i=0;i<4;i++)User.SetPlayerPrisonerRescueState(i,CaelumConstants.PRISONER_STATE_CAPTIVE);
    }

    void StartCase()
    {
        if(Body!=null)Body.Destroy();
        for(int i=0;i<4;i++)User.SetPlayerPrisonerRescueState(i,CaelumConstants.PRISONER_STATE_CAPTIVE);
        User.SetOrigin((0,0,0),false);User.Vel=(0,0,0);
        Body=CaelumAnchoredResident(Actor.Spawn(Kind(CaseIndex),(-512,0,0),NO_REPLACE));
        Age=0;Overspeed=false;Penalty=false;Moved=false;PeakStep=0;PeakCommand=0;
        Previous=Body.Pos;PreviousSpeed=0;
    }

    void Impair()
    {
        if(CaseIndex==4 || CaseIndex==7)
        {
            Body.health=Max(1,int(Body.CombatMaximumHealth*CaelumConstants.HEALTH_BADLY_WOUNDED_THRESHOLD));
            if(CaseIndex==7)Body.health=Max(1,Body.health-2);
            Body.CurrentCombatAdrenaline=0;
        }
        if(CaseIndex==5 || CaseIndex==7)
        {
            let thermal=CaelumThermalBody.Get(Body,true);
            CaelumThermalBody.Refresh(Body,thermal);
            thermal.Exposure=-CaelumThermalData.ExposureThreshold(2)*CaelumThermalRules.ThresholdScale(thermal.Toughness);
        }
        if(CaseIndex==6 || CaseIndex==7)
        {Body.ElementalStatus.FreezeRemaining=60;Body.ElementalStatus.FreezePowerPercent=50;}
        Body.UpdateCombatHealthEffects();
    }

    override void WorldTick()
    {
        if(!Running || Body==null)return;
        Age++;
        // Fijar sólo la salud del control frío aísla su marcha: el frío letal
        // mataba al sujeto antes de completar la segunda aproximación.
        if((CaseIndex==5 || CaseIndex==7) && Age>4)Body.health=HeldHealth;
        if(CaseIndex==7 && Age%35==0)Console.Printf("CA307 COMBINED age=%d x=%.6f distance=%.6f speed=%.6f vel=%.6f health=%d recovery=%d sleep=%d stun=%.6f follow=%d air=%.6f",Age,Body.Pos.X,Body.Distance2D(User),Body.Speed,Body.Vel.XY.Length(),Body.health,Body.RecoveryPhase,Body.ForcedSleepTics,Body.CombatLucidityPhysicalStunRemaining,Body.InStateSequence(Body.CurState,Body.FindState("EscortFollow")),Body.CurrentCombatAir);
        if(Age==4)
        {
            if(CaseIndex<4)Check(Body.Pos==Previous && Body.bInvulnerable,"captive remains stationary before release");
            else {Body.SetOrigin((-160,0,0),false);Body.Vel=(0,0,0);}
            Impair();HeldHealth=Body.health;Penalty=Body.Speed<Body.CombatBaseSpeed;
            Body.ReleaseEscortPrisoner(User);
            Previous=Body.Pos;PreviousSpeed=Body.Speed/4.0;
        }
        if(Age>4)
        {
            double step=(Body.Pos.XY-Previous.XY).Length();
            double command=Body.Vel.XY.Length();
            PeakStep=Max(PeakStep,step);PeakCommand=Max(PeakCommand,command);
            if(step>Max(PreviousSpeed,Body.Speed/4.0)+0.001 || command>Max(PreviousSpeed,Body.Speed/4.0)+0.001)Overspeed=true;
            if(step>0.001)Moved=true;
            Previous=Body.Pos;PreviousSpeed=Body.Speed/4.0;
        }
        if(Age==354)Stopped=Body.Pos;
        if(Age==355)
        {
            Check(Moved,"native follower physically approaches the player");
            Check(Baseline?Overspeed:!Overspeed,Baseline?"previous runtime reproduces boosted movement":"every observed step and command respects normal speed");
            Check(Body.Distance2D(User)<=CaelumConstants.PRISONER_FOLLOW_DISTANCE+0.01 && Body.Vel.XY.Length()==0,"follower settles at the existing nearby radius");
            Check(Body.Pos==Stopped,"settled follower remains still");
            if(CaseIndex>=4)Check(Penalty,"test exercises a resolved movement penalty");
            Stopped=Body.Pos;User.SetOrigin((96,0,0),false);User.Vel=(0,0,0);
        }
        if(Age==755)
        {
            Check((Body.Pos.XY-Stopped.XY).Length()>1,"follower resumes after the leader moves away");
            Check(Body.Distance2D(User)<=CaelumConstants.PRISONER_FOLLOW_DISTANCE+0.01,"follower regains proximity without changing the radius");
            Check(Baseline?Overspeed:!Overspeed,Baseline?"baseline boost remains observable":"resumed movement also respects normal speed");
            Console.Printf("CA307 TRACE case=%d base=%.6f speed=%.6f peakstep=%.6f peakcommand=%.6f distance=%.6f",CaseIndex,Body.CombatBaseSpeed,Body.Speed,PeakStep,PeakCommand,Body.Distance2D(User));
            CaseIndex++;
            if(CaseIndex>=Trials){Running=false;Body.Destroy();Body=null;}
            else StartCase();
        }
    }

    void Contracts()
    {Body=CaelumAnchoredResident(Actor.Spawn(Kind(0),(-512,0,0),NO_REPLACE));}

    void ContractCheck()
    {
        Body.ReleaseEscortPrisoner(User);
        Body.bInConversation=true;Body.Vel=(10,0,0);Body.A_CaelumPrisonerFollow();
        Check(Body.Vel.Length()==0,"conversation pauses following");Body.bInConversation=false;
        int health=User.health;User.health=0;Body.Vel=(10,0,0);Body.A_CaelumPrisonerFollow();
        Check(Body.Vel.Length()==0,"dead leader stops following");User.health=health;
        Body.MoveEscortPrisonerTowardLeader(null);
        Check(Body.Vel.Length()==0,"missing leader stops movement");
        Body.SetOrigin((-96,0,0),false);Body.MoveEscortPrisonerTowardLeader(User);
        Check(Body.Vel.XY.Length()==0,"exact follow radius does not propel the body");
        Body.SetOrigin((-96.25,0,0),false);Body.MoveEscortPrisonerTowardLeader(User);
        Check(abs(Body.Vel.XY.Length()-0.25)<0.00001,"last step cannot overshoot proximity");
        Body.Speed=0;Body.SetOrigin((-512,0,0),false);Body.MoveEscortPrisonerTowardLeader(User);
        Check(Body.Vel.XY.Length()==0,"zero resolved speed remains immobilized");Body.UpdateCombatHealthEffects();
        Body.Speed=-1;Body.MoveEscortPrisonerTowardLeader(User);
        Check(Body.Vel.XY.Length()==0,"invalid negative speed cannot reverse following");Body.UpdateCombatHealthEffects();
        Body.Speed=Body.CombatBaseSpeed*0.5;Body.MoveEscortPrisonerTowardLeader(User);
        Check(abs(Body.Vel.XY.Length()-Body.Speed/4.0)<0.00001,"custom resolved speed retains the original walking cadence");Body.UpdateCombatHealthEffects();
        Body.SetOrigin((-2048,0,0),false);User.Angle=0;
        double spacing=Body.Radius+24;
        let obstacle=Actor.Spawn("CA307Blocker",(-spacing,0,0));
        Body.UpdateEscortPrisoner();
        Check(Body.Distance2D(User)<CaelumConstants.PRISONER_FOLLOW_DISTANCE && Body.health>0,"distant follower retains recovery teleport");
        Check(Body.Distance2D(obstacle)>=Body.Radius+obstacle.Radius,"recovery teleport avoids an occupied candidate");
        obstacle.Destroy();
        Body.SetOrigin((400,0,0),false);Body.Vel=(0,0,0);User.SetOrigin((800,0,0),false);
        Body.BeginEscortFollow();
    }

    void WallCheck()
    {
        Check(Body.Pos.X<=512-Body.Radius+0.01 && Body.Pos.X>400,"native wall blocks following without tunnelling");
        User.SetOrigin((2400,0,0),false);Body.UpdateEscortPrisoner();
        Check(Body.Distance2D(User)<CaelumConstants.PRISONER_FOLLOW_DISTANCE,"stalled follower recovers only beyond existing teleport threshold");
        let enemy=CaelumCombatActor(Actor.Spawn("CaelumMandinga",Body.Pos+(128,0,0),NO_REPLACE));
        Body.UpdateEscortPrisoner();
        Check(Body.Target==enemy && Body.InEscortCombatState(),"nearby hostile still interrupts ordinary following for combat");
        enemy.Destroy();Body.Destroy();Body=null;
    }

    void Seed()
    {
        let saved=CA307Snapshot(Actor.Spawn("CA307Snapshot",User.Pos,NO_REPLACE));
        for(int i=0;i<4;i++)
        {
            let body=CaelumAnchoredResident(Actor.Spawn(Kind(i),(-512,-600+i*400,0),NO_REPLACE));
            saved.Bodies.Push(body);
        }
    }

    void Activate()
    {
        let saved=CA307Snapshot(ThinkerIterator.Create("CA307Snapshot").Next());
        for(int i=0;i<4;i++)
        {
            let body=saved.Bodies[i];saved.Bases.Push(body.CombatBaseSpeed);
            let token=CA307Token(body.GiveInventoryType("CA307Token"));token.Amount=i+3;
            body.health=Max(1,int(body.CombatMaximumHealth*0.8));
            body.ReleaseEscortPrisoner(User);
            Check(body.EscortPrisonerId==i && User.GetPrisonerRescueState(i)==CaelumConstants.PRISONER_STATE_FOLLOWING,"save seed retains released identity and state");
        }
    }

    void Loaded()
    {
        User=CaelumPlayer(players[consoleplayer].mo);
        let saved=CA307Snapshot(ThinkerIterator.Create("CA307Snapshot").Next());
        Check(saved!=null && saved.Bodies.Size()==4,"native save retains all follower references");
        if(saved==null)return;
        for(int i=0;i<4;i++)
        {
            let body=saved.Bodies[i];
            Check(body!=null,"map-local snapshot retains a follower reference");
            if(body==null)continue;
            int count=0;let it=ThinkerIterator.Create(Kind(i));Actor candidate;
            while((candidate=Actor(it.Next()))!=null){count++;Check(candidate==body,"saved reference points to the original world actor");}
            Check(count==1 && body.EscortPrisonerId==i,"load does not duplicate or change prisoner identity");
            Check(body.CombatBaseSpeed==saved.Bases[i] && body.health>0 && body.health<body.CombatMaximumHealth,"load preserves base speed and wounded health");
            let token=CA307Token(body.FindInventory("CA307Token"));
            Check(token!=null && token.Owner==body && token.Amount==i+3,"load preserves individual inventory");
            Check(User.GetPrisonerRescueState(i)==CaelumConstants.PRISONER_STATE_FOLLOWING,"rescue progression remains following");
            body.MoveEscortPrisonerTowardLeader(User);
            Check(body.Vel.XY.Length()<=body.Speed/4.0+0.00001,"loaded follower uses normal resolved speed immediately");
        }
    }

    void WalkStartControl(bool nativeWalk)
    {
        User.SetOrigin((0,1000,0),false);User.Vel=(0,0,0);
        Body.SetOrigin((-512,1000,0),false);Body.Vel=(0,0,0);
        if(nativeWalk)
        {
            Body.EscortPrisonerPort=true;Body.bFriendly=false;
            Body.Target=User;Body.movedir=0;Body.movecount=1000;
            Body.SetStateLabel("NativeWalk");
        }
        else Body.ReleaseEscortPrisoner(User);
        WalkStart=Body.Pos;
    }

    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="c307_setup")Setup();
        else if(e.Name=="c307_motion" || e.Name=="c307_baseline")
        {Baseline=e.Name=="c307_baseline";Trials=Baseline?1:8;CaseIndex=0;Running=true;StartCase();}
        else if(e.Name=="c307_combined")
        {Baseline=false;Trials=8;CaseIndex=7;Running=true;StartCase();}
        else if(e.Name=="c307_contracts")Contracts();
        else if(e.Name=="c307_contractcheck")ContractCheck();
        else if(e.Name=="c307_wallcheck")WallCheck();
        else if(e.Name=="c307_seed")Seed();
        else if(e.Name=="c307_activate")Activate();
        else if(e.Name=="c307_loaded")Loaded();
        else if(e.Name=="c307_walkseed")Body=CaelumAnchoredResident(Actor.Spawn("CA307WalkingControl",(-512,1000,0),NO_REPLACE));
        else if(e.Name=="c307_walkstart")WalkStartControl(true);
        else if(e.Name=="c307_walkrecord")
        {
            NativeDistance=(Body.Pos.XY-WalkStart.XY).Length();
            Check(NativeDistance>0,"native A_Chase control physically walks");
            Console.Printf("CA307 WALK native distance=%.6f speed=%.6f",NativeDistance,Body.Speed);
            Body.Destroy();Body=CaelumAnchoredResident(Actor.Spawn(Kind(0),(-512,1000,0),NO_REPLACE));
        }
        else if(e.Name=="c307_followstart")WalkStartControl(false);
        else if(e.Name=="c307_followrecord")
        {
            double distance=(Body.Pos.XY-WalkStart.XY).Length();
            Check(distance>0 && abs(distance-NativeDistance)<=Body.Speed+0.001,"continuous following matches native walking distance over equal tics");
            Console.Printf("CA307 WALK following distance=%.6f native=%.6f speed=%.6f",distance,NativeDistance,Body.Speed);
        }
        else if(e.Name=="c307_done")
        {Check(!Running,"scheduled movement observation completed");Console.Printf("CA307 DONE passes=%d failures=%d",Passed,Failed);}
    }
}
