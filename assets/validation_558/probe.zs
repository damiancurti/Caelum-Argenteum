// #369: fixture privada; las comprobaciones no se empaquetan con el juego.
class CA369Probe : CA369ProbeBase
{
    double PoseMotion;
    int SavedModelFrame;
    int ManualResetAt,ManualStopAt;
    bool SawPrepareTrial,SawCharge,EncounterObserved;
    CaelumBullModelBody FadingModel;
    override void WorldTick()
    {
        if(Tracing && Subject!=null && Subject.BullModel!=null)
        {
            EncounterObserved=true;
            SawPrepareTrial|=Subject.BullModel.Pose==CaelumBullModelFrames.PREPARETRIAL;
            SawCharge|=Subject.BullModel.Pose==CaelumBullModelFrames.CHARGE;
        }
        Super.WorldTick();
        if(ManualResetAt>0 && level.time>=ManualResetAt){ManualResetAt=0;PoseView(0);}
        if(ManualStopAt>0 && level.time>=ManualStopAt){ManualStopAt=0;PoseMotion=0;}
        if(PoseMotion>0 && Subject!=null)
        {Subject.SetOrigin(Subject.Pos+(PoseMotion,0,0),false);User.SetOrigin(User.Pos+(PoseMotion,0,0),false);}
    }
    void PoseView(int stage)
    {
        PoseMotion=0;Subject.StopBullCharge();Subject.target=null;
        Subject.Angle=0;User.SetOrigin(Subject.Pos+(20,-150,0),false);User.Angle=90;User.Pitch=5;
        if(stage==0){Subject.SetState(Subject.SpawnState,true);Subject.tics=-1;}
        else if(stage==1 || stage==2)
        {Subject.SetState(Subject.SeeState.NextState,true);Subject.tics=-1;PoseMotion=stage==1?.4:2;}
        else if(stage==3){Subject.SetState(Subject.MeleeState,true);Subject.tics=-1;}
        else if(stage==4){Subject.SetState(Subject.FindState('Pain').NextState,true);Subject.tics=6;}
        else if(stage==5)
        {
            vector3 camera=User.Pos;User.SetOrigin(Subject.Pos+(16,0,0),false);Subject.target=User;
            Subject.A_CaelumBullModelGore(45);User.SetOrigin(camera,false);
            Subject.SetState(Subject.MeleeState,true);Subject.tics=3;
        }
        else if(stage==6)Subject.DamageMobj(User,User,1000000,'None',DMG_FORCED);
        else if(stage==7)Subject.SetStateLabel("RestLying");
        else if(stage==8){Subject.CombatLucidityPhysicalStunRemaining=10;Subject.SetState(Subject.FindState('LucidityStun'),true);Subject.tics=-1;}
    }
    void ModelCheck()
    {
        Check(Subject!=null && Subject.BullModel!=null,"bull creates local model helper");
        if(Subject.BullModel==null)return;
        Check(Subject.BullModel.Master==Subject,"helper keeps original owner");
        Check(Subject.BullModel.bNoInteraction && Subject.BullModel.bNOBLOCKMAP && !Subject.BullModel.bSolid,"helper has no collision");
        Check(Subject.sprite==Actor.GetSpriteIndex('TNT1'),"native sprite hidden while model active");
        Check(Subject.BullModel.Pos==Subject.Pos && Subject.BullModel.Angle==Subject.Angle,"model follows owner position and angle");
        Check(Subject.BullModel.Radius>=Subject.Radius && Subject.BullModel.Height>=Subject.Height,"render bounds contain native cylinder");
        Check(Subject.BullModelRevision==1,"visual migration revision is current");
        Check(Subject.Radius==15.6 && Subject.Height==51.8 && Subject.Mass==900,"native collision dimensions and mass retained");
    }
    void CheckModels()
    {
        ModelCheck();
        Check(Dead.BullModel!=null && Dead.BullModel.Pose==CaelumBullModelFrames.CORPSE,"dead bull keeps final corpse model");
        Check(Archived.BullModel==null,"archived corpse owns no active model thinker");
        Check(Trial.BullModel!=null && Trial.BullModel.Pose==CaelumBullModelFrames.IDLE,"tutorial early-return idle remains visible");
        Check(Grace.BullModel!=null && Grace.BullModel.Pose==CaelumBullModelFrames.IDLE,"tutorial grace remains visible");
    }
    void Disabled()
    {
        Check(Subject.BullModel==null && Dead.BullModel==null && Archived.BullModel==null && Trial.BullModel==null && Grace.BullModel==null,"toggle removes all five current-map helpers");
        Check(Subject.sprite==Subject.CurState.sprite && Dead.sprite==Dead.CurState.sprite && Trial.sprite==Trial.CurState.sprite,"toggle restores native sprites");
        Check(CaelumBullModelRegistry.Get().Bodies.Size()==0,"registry is empty after disabling");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        Super.NetworkProcess(e);
        if(e.Name=="c369_check")ModelCheck();
        else if(e.Name=="c369_checkmodels")CheckModels();
        else if(e.Name=="c369_disabled")Disabled();
        else if(e.Name=="c369_pose")PoseView(e.Args[0]);
        else if(e.Name=="c369_expect")
        {Check(Subject.BullModel!=null && Subject.BullModel.Pose==e.Args[0],String.Format("native presentation pose %d actual %d frame %d tics %d gore_remaining %d",e.Args[0],Subject.BullModel!=null?Subject.BullModel.Pose:-1,Subject.CurState.Frame,Subject.tics,Subject.BullModelGoreUntil-level.time));}
        else if(e.Name=="c369_stop")
        {PoseMotion=0;SavedModelFrame=Subject.BullModel.ModelFrame;}
        else if(e.Name=="c369_stopped")
        {Check(Subject.BullModel.ModelFrame==SavedModelFrame && Subject.BullModel.DistanceDriven,"stopped distance-driven gait holds its mesh sample");}
        else if(e.Name=="c369_hide")
        {Subject.GiveInventory('CaelumRedemptionBody',1);CaelumRedemptionBody(Subject.FindInventory('CaelumRedemptionBody')).HideForPlacement();}
        else if(e.Name=="c369_hidden")
        {Check(Subject.BullModel.bInvisible && Subject.bInvisible,"Redemption pending owner hides its model");}
        else if(e.Name=="c369_place")
        {CaelumRedemptionBody(Subject.FindInventory('CaelumRedemptionBody')).Place(Subject.Pos);}
        else if(e.Name=="c369_visible")
        {Check(!Subject.BullModel.bInvisible && !Subject.bInvisible,"Redemption placement restores model visibility");}
        else if(e.Name=="c369_recall")CaelumCorpseArchive.Recall(Archived);
        else if(e.Name=="c369_recalled")
        {Check(Archived.BullModel!=null && !CaelumCorpseArchive.Suspended(Archived),"archive Recall recreates exactly the owner model");}
        else if(e.Name=="c369_fade")
        {Trial.bShootable=true;Trial.DamageMobj(User,User,1000000,'None',DMG_FORCED);FadingModel=Trial.BullModel;}
        else if(e.Name=="c369_fading")
        {Check(Trial!=null && Trial.Alpha<1 && Trial.BullModel!=null && Abs(Trial.Alpha-Trial.BullModel.Alpha)<=.100001,"tutorial native corpse fade propagates to model");}
        else if(e.Name=="c369_faded")
        {Check(Trial==null && FadingModel==null,"tutorial owner and model are both destroyed after native fade");}
        else if(e.Name=="c369_done" && EncounterObserved)
        {Check(SawPrepareTrial,"actual MAP01 encounter displays tutorial preparation");Check(SawCharge,"actual MAP01 encounter displays charge");Console.Printf("CA369 DONE passes=%d failures=%d",Passed,Failed);}
        else if(e.Name=="c369_manual")Manual=true;
        else if(e.Name=="c369_reset")
        {if(Subject!=null)Subject.Destroy();Setup();ManualResetAt=level.time+3;PoseMotion=0;}
        else if(e.Name=="c369_manualpose" && Subject!=null && Subject.health>0)
        {PoseView(e.Args[0]);ManualStopAt=level.time+2*CaelumBullModelFrames.Duration(e.Args[0]==1?CaelumBullModelFrames.WALK:CaelumBullModelFrames.RUN);}
        else if(e.Name=="c369_manualmap")
        {
            Manual=true;UserSetup();User.SetOrigin((-2400,0,0),false);User.Angle=0;User.Pitch=0;
            let controller=CaelumMainM00QuestController(EventHandler.Find('CaelumMainM00QuestController'));
            Trial=controller.TrialBull;Subject=Trial;
        }
        else if(e.Name=="c369_manualkill" && Subject!=null)
        {Subject.bShootable=true;Subject.DamageMobj(User,User,1000000,'None',DMG_FORCED);}
    }
}
