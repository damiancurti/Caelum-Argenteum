// #461: verifica el cuerpo real y sus referencias, sin encuentros de campana.
class CA680Camera : Actor
{
    Default { CameraHeight 0; Height 0; Radius 0; +NOINTERACTION +NOGRAVITY }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA680Blocker : Actor
{
    Default { +SOLID +NOGRAVITY }
    States { Spawn: TNT1 A -1; Stop; }
}
// Se crea despues del cuerpo: aplica la pose una vez terminado su Tick nativo.
class CA680PoseDriver : Actor
{
    CaelumBestiary003 Subject;
    State Frozen;
    Default { +NOINTERACTION +NOGRAVITY }
    States { Spawn: TNT1 A -1; Stop; }
    override void Tick()
    {
        Super.Tick();
        if(Subject==null || Frozen==null)return;
        Subject.SetOrigin((0,0,0),false);Subject.Vel=(0,0,0);Subject.Angle=0;
        Subject.SetState(Frozen,true);Subject.tics=-1;
    }
}
class CA680Events : EventHandler
{
    CaelumBestiary003 Subject;
    CaelumMandinga Control;
    CA680Camera Camera;
    CA680PoseDriver Driver;
    CaelumConsumableItem Stock;
    State Frozen, Snapshot;
    int Failures, SavedStock, SavedHealth;
    void Check(bool okay,String label)
    {
        if(!okay)Failures++;
        Console.Printf("CA680 %s %s",okay?"PASS":"FAIL",label);
    }
    void Prepare()
    {
        if(Subject!=null)return;
        let user=CaelumPlayer(players[0].mo);
        user.CharacterCreationComplete=true;user.CreationWizardOpen=false;
        user.bNOTARGET=true;user.bInvulnerable=true;user.bInvisible=true;
        Subject=CaelumBestiary003(Actor.Spawn('CaelumBestiary003',(0,0,0),NO_REPLACE));
        Control=CaelumMandinga(Actor.Spawn('CaelumMandinga',(512,512,0),NO_REPLACE));
        Subject.CaelumDiagnosticPassiveAI=true;Control.CaelumDiagnosticPassiveAI=true;
        Subject.Angle=0;
        Camera=CA680Camera(Actor.Spawn('CA680Camera',(0,0,0),NO_REPLACE));
        Driver=CA680PoseDriver(Actor.Spawn('CA680PoseDriver',(0,0,0),NO_REPLACE));Driver.Subject=Subject;
        players[0].camera=Camera;
        let hud=CaelumHUDOverlay(EventHandler.Find('CaelumHUDOverlay'));
        if(hud!=null)hud.HUDFont=null;
        Configure(0,0);
    }
    void SnapshotInventory()
    {
        if(SavedHealth!=0)return;
        Stock=CaelumDemonService.Potion(Subject,0);
        if(Stock==null){Check(false,"native stock initialized before snapshot");return;}
        Subject.TakeInventory(Stock.GetClassName(),1);SavedStock=Stock.Amount;
        SavedHealth=Subject.health;
    }
    State VisualState(int sprite,int frame)
    {
        Array<State> starts;
        starts.Push(Subject.FindState('Spawn'));starts.Push(Subject.FindState('IdleBreathing'));
        starts.Push(Subject.FindState('See'));starts.Push(Subject.FindState('RunSecondHalf'));
        starts.Push(Subject.FindState('WalkCycle'));starts.Push(Subject.FindState('LucidityStun'));
        starts.Push(Subject.FindState('Melee'));starts.Push(Subject.FindState('Missile'));
        starts.Push(Subject.FindState('Pain'));starts.Push(Subject.FindState('Death'));
        starts.Push(Subject.FindState('RacialBreath'));starts.Push(Subject.FindState('RestLying'));
        for(int index=0;index<starts.Size();index++)
        {
            State first=starts[index];State cursor=first;
            for(int step=0;cursor!=null && step<32;step++)
            {
                if(cursor.Sprite==sprite && cursor.Frame==frame && cursor.Tics!=0)return cursor;
                cursor=cursor.NextState;if(cursor==first)break;
            }
        }
        return null;
    }
    void Configure(int pose,int view)
    {
        if(Subject==null || Camera==null)return;
        if(pose==0)Frozen=VisualState(Actor.GetSpriteIndex('MIID'),0);
if(pose==1)Frozen=VisualState(Actor.GetSpriteIndex('MIID'),1);
if(pose==2)Frozen=VisualState(Actor.GetSpriteIndex('MIRN'),0);
if(pose==3)Frozen=VisualState(Actor.GetSpriteIndex('MIRN'),1);
if(pose==4)Frozen=VisualState(Actor.GetSpriteIndex('MIRN'),2);
if(pose==5)Frozen=VisualState(Actor.GetSpriteIndex('MIRN'),3);
if(pose==6)Frozen=VisualState(Actor.GetSpriteIndex('MIWK'),0);
if(pose==7)Frozen=VisualState(Actor.GetSpriteIndex('MIWK'),1);
if(pose==8)Frozen=VisualState(Actor.GetSpriteIndex('MNDG'),0);
if(pose==9)Frozen=VisualState(Actor.GetSpriteIndex('MNDG'),3);
if(pose==10)Frozen=VisualState(Actor.GetSpriteIndex('MNDG'),4);
if(pose==11)Frozen=VisualState(Actor.GetSpriteIndex('MNDG'),5);
if(pose==12)Frozen=VisualState(Actor.GetSpriteIndex('MNDG'),6);
if(pose==13)Frozen=VisualState(Actor.GetSpriteIndex('MNDG'),7);
if(pose==14)Frozen=VisualState(Actor.GetSpriteIndex('MNDG'),8);
if(pose==15)Frozen=VisualState(Actor.GetSpriteIndex('MNDG'),9);
if(pose==16)Frozen=VisualState(Actor.GetSpriteIndex('MNDG'),10);
if(pose==17)Frozen=VisualState(Actor.GetSpriteIndex('MNDG'),11);
if(pose==18)Frozen=VisualState(Actor.GetSpriteIndex('MDBR'),0);
if(pose==19)Frozen=VisualState(Actor.GetSpriteIndex('MDBR'),1);
if(pose==20)Frozen=VisualState(Actor.GetSpriteIndex('MDBR'),2);
if(pose==21)Frozen=VisualState(Actor.GetSpriteIndex('MDBR'),3);
if(pose==22)Frozen=VisualState(Actor.GetSpriteIndex('SLMD'),0);
        Driver.Frozen=Frozen;
        if(view==0){Camera.SetOrigin((75,-45,32),false);Camera.Angle=149.03624346792648;Camera.Pitch=3.9243099740178775;}
if(view==1){Camera.SetOrigin((90,0,30),false);Camera.Angle=180.0;Camera.Pitch=2.5448043798130953;}
if(view==2){Camera.SetOrigin((0,-90,30),false);Camera.Angle=90.0;Camera.Pitch=2.5448043798130953;}
if(view==3){Camera.SetOrigin((-90,0,30),false);Camera.Angle=0.0;Camera.Pitch=2.5448043798130953;}
if(view==4){Camera.SetOrigin((32,0,46),false);Camera.Angle=180.0;Camera.Pitch=2.0454084888872277;}
if(view==5){Camera.SetOrigin((28,-18,46),false);Camera.Angle=143.13010235415598;Camera.Pitch=1.9091524329963763;}
        Subject.SetOrigin((0,0,0),false);Subject.Vel=(0,0,0);Subject.Angle=0;
        Camera.ClearInterpolation();Subject.ClearInterpolation();
        players[0].camera=Camera;
        Console.Printf("CA680 VIEW pose=%d pos=(%.3f,%.3f,%.3f) scale=(%.3f,%.3f) sprite=%d frame=%d invisible=%d alpha=%.3f frozen=%d",
            pose,Subject.Pos.X,Subject.Pos.Y,Subject.Pos.Z,Subject.Scale.X,Subject.Scale.Y,Subject.sprite,Subject.frame,Subject.bInvisible,Subject.Alpha,Frozen!=null);
    }
    void Verify()
    {
        Check(Subject!=null && Control!=null && Camera!=null,"saved actor and camera references");
        if(Subject==null || Control==null)return;
        Check(Subject.GetClass()=='CaelumBestiary003' && Subject.BestiaryReference()=="CA-FOLK-003","original production class and identity");
        Check(Subject.Radius==Control.Radius && Subject.Height==Control.Height && Subject.Mass==Control.Mass,"unchanged provisional collision and mass");
        Check(Subject.bSolid==Control.bSolid && Subject.bShootable==Control.bShootable && Subject.bCorpse==Control.bCorpse && Subject.bKilled==Control.bKilled,"native body flags preserved");
        Check(Subject.Scale==Control.Scale,"unchanged native actor scale");
        Check(Subject.health==SavedHealth && Subject.CombatMaximumHealth==Control.CombatMaximumHealth,"health and derived maximum preserved");
        Check(Subject.CombatBaseSpeed==Control.CombatBaseSpeed && Subject.MaximumCombatAir==Control.MaximumCombatAir && Subject.MaximumCombatAnima==Control.MaximumCombatAnima,"speed and resource maxima preserved");
        Check(Stock!=null && Stock.Owner==Subject && Stock.Amount==SavedStock && CaelumDemonService.Potion(Subject,0)==Stock,"same finite inventory object and ownership");
        Check(Subject.MandingaBirthInitialized && Subject.DemonSupplyRevision==Control.DemonSupplyRevision,"initialization is not repeated on load");
        Check(Subject.FindState('Melee')==Control.FindState('Melee') && Subject.FindState('Missile')==Control.FindState('Missile') && Subject.FindState('Death')==Control.FindState('Death'),"inherited combat state identity");
        Check(Subject.IsAlliedMandinga(Control),"existing alliance retained");
        int covered=0;
        if(VisualState(Actor.GetSpriteIndex('MIID'),0)!=null)covered++;
if(VisualState(Actor.GetSpriteIndex('MIID'),1)!=null)covered++;
if(VisualState(Actor.GetSpriteIndex('MIRN'),0)!=null)covered++;
if(VisualState(Actor.GetSpriteIndex('MIRN'),1)!=null)covered++;
if(VisualState(Actor.GetSpriteIndex('MIRN'),2)!=null)covered++;
if(VisualState(Actor.GetSpriteIndex('MIRN'),3)!=null)covered++;
if(VisualState(Actor.GetSpriteIndex('MIWK'),0)!=null)covered++;
if(VisualState(Actor.GetSpriteIndex('MIWK'),1)!=null)covered++;
if(VisualState(Actor.GetSpriteIndex('MNDG'),0)!=null)covered++;
if(VisualState(Actor.GetSpriteIndex('MNDG'),3)!=null)covered++;
if(VisualState(Actor.GetSpriteIndex('MNDG'),4)!=null)covered++;
if(VisualState(Actor.GetSpriteIndex('MNDG'),5)!=null)covered++;
if(VisualState(Actor.GetSpriteIndex('MNDG'),6)!=null)covered++;
if(VisualState(Actor.GetSpriteIndex('MNDG'),7)!=null)covered++;
if(VisualState(Actor.GetSpriteIndex('MNDG'),8)!=null)covered++;
if(VisualState(Actor.GetSpriteIndex('MNDG'),9)!=null)covered++;
if(VisualState(Actor.GetSpriteIndex('MNDG'),10)!=null)covered++;
if(VisualState(Actor.GetSpriteIndex('MNDG'),11)!=null)covered++;
if(VisualState(Actor.GetSpriteIndex('MDBR'),0)!=null)covered++;
if(VisualState(Actor.GetSpriteIndex('MDBR'),1)!=null)covered++;
if(VisualState(Actor.GetSpriteIndex('MDBR'),2)!=null)covered++;
if(VisualState(Actor.GetSpriteIndex('MDBR'),3)!=null)covered++;
if(VisualState(Actor.GetSpriteIndex('SLMD'),0)!=null)covered++;
        Check(covered==23,"all native sprite and frame pairs reachable");
        Console.Printf("CA680 COMPLETE failures=%d",Failures);
    }
    void Collision()
    {
        let original=Subject.Pos;
        let obstacle=Actor.Spawn('CA680Blocker',original+(Subject.Radius*3,0,0),NO_REPLACE);
        obstacle.A_SetSize(Control.Radius,Control.Height);
        Check(!Subject.TryMove(obstacle.Pos.XY,0),"native solid-body collision");
        obstacle.Destroy();
        Check(Subject.TryMove(original.XY+(0,128),0),"native free-space movement");
        Subject.SetOrigin(original,false);
        Check(!Subject.TryMove((1024-Subject.Radius/2,0),0),"native wall collision");
        Subject.SetOrigin(original,false);
        Console.Printf("CA680 COMPLETE failures=%d",Failures);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca680_prepare")Prepare();
        else if(e.Name=="ca680_snapshot")SnapshotInventory();
        else if(e.Name=="ca680_verify")Verify();
        else if(e.Name=="ca680_view")Configure(e.Args[0],e.Args[1]);
        else if(e.Name=="ca680_hide")Subject.bInvisible=e.Args[0]!=0;
        else if(e.Name=="ca680_pose_verify")
            Check(Driver.Frozen!=null && Subject.CurState==Driver.Frozen && Subject.sprite==Driver.Frozen.Sprite && Subject.frame==Driver.Frozen.Frame,"native captured pose matches requested frame");
        else if(e.Name=="ca680_collision")Collision();
        else if(e.Name=="ca680_motion_start")
        { Frozen=null;Driver.Frozen=null;Subject.SetState(Subject.FindState('SiegeWithdrawal'),false);Snapshot=Subject.CurState; }
        else if(e.Name=="ca680_motion_verify")
        { Check(Subject.CurState!=Snapshot,"native animation state advancement");Console.Printf("CA680 COMPLETE failures=%d",Failures); }
    }
}
