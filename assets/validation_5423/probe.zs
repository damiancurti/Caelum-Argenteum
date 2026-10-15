// Escenario del piloto sobre el jugador real.
class CA283Probe : StaticEventHandler
{
    CaelumDomingoPilotPlayer User;
    int Passed,Failed;
    bool Ready;
    Actor Camera;
    CaelumRestFurniture Furniture;
    bool WalkSeen,RunSeen,AttackSeen;
    Array<Actor> RenderProxies;
    bool BenchActive;
    int BenchSerial,BenchCount,BenchModel;
    int ManualRest,ManualCamera;
    bool Manual;
    ui int SeenSerial,FrameCount;
    ui double LastFrameMS,FrameSum,FrameMin,FrameMax;
    void Check(bool ok,String text)
    {if(ok)Passed++;else Failed++;Console.Printf("CA283 %s %s",ok?"PASS":"FAIL",text);}
    override void UiTick()
    {if(!Manual && Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    void Setup()
    {
        User=CaelumDomingoPilotPlayer(players[0].mo);
        Check(User!=null,"opt-in native player subclass");if(User==null)return;
        User.CharacterCreationComplete=true;User.CreationWizardOpen=false;
        User.CharacterProfile.Race=CaelumConstants.RACE_HUMAN;
        User.CharacterProfile.Sex=CaelumConstants.SEX_MALE;User.ApplyCharacterProfile();
        User.CurrentSleep=User.CurrentLucidity=100;User.CurrentHunger=User.CurrentThirst=75;
        User.bInvulnerable=true;User.Angle=180;
        let session=new('CA259Session');session.Choice=4;session.Tier=1;session.Equip(User);
        let item=CaelumEquipmentItem(Actor.Spawn('CaelumShieldPickup'));
        item.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_SHIELD;item.ItemType=CaelumConstants.SHIELD_TYPE_BUCKLER;item.Tier=1;
        item.EquipmentSize=User.WeaponModel.Size;
        item.Durability=User.ShieldModel.GetMaximumDurabilityFor(item.ItemType,item.Tier,item.EquipmentSize);
        item.UnitWeight=User.ShieldModel.GetWeightFor(item.ItemType,item.Tier,item.EquipmentSize);
        item.PickupDataInitialized=true;item.AcquisitionResolved=true;item.AttachToOwner(User);
        User.EnsureEquipmentItemId(item);User.EquipmentSelectionItemId=item.ItemId;
        User.EquipmentSelectionKind=CaelumConstants.EQUIPMENT_KIND_SHIELD;
        User.RefreshEquipmentSelectionPreview();User.EquipSelectedNativeEquipment();
        User.EquipmentMenuOpen=false;User.PersistCharacterState();
        User.GetPersistentCharacterState(true).ProfileCommitted=true;
        Check(item.Equipped && User.ShieldModel.Equipped,"native shield equipment");
        Ready=true;User.UpdatePilotVisual();
        Check(User.PilotBody!=null,"native MD3 body created");
        Camera=Actor.Spawn('CA283Camera',(180,0,User.Height*.55));Camera.Angle=180;
        User.Angle=0;players[0].camera=Camera;
        Console.Printf("CA283 GEOMETRY height=%.4f scale=(%.4f,%.4f) sprite=%d",User.Height,User.Scale.X,User.Scale.Y,User.sprite);
    }
    override void WorldTick()
    {
        if(!Ready || User==null || User.PilotBody==null)return;
        if(User.PilotBody.Pose==CaelumDomingoPilotFrames.WALK)WalkSeen=true;
        if(User.PilotBody.Pose==CaelumDomingoPilotFrames.RUN)RunSeen=true;
        if(User.PilotBody.Pose==CaelumDomingoPilotFrames.MELEE
            || User.PilotBody.Pose==CaelumDomingoPilotFrames.MISSILE)AttackSeen=true;
    }
    override void RenderOverlay(RenderEvent e)
    {
        if(BenchActive)
        {
            double now=MSTimeF();
            if(SeenSerial!=BenchSerial)
            {SeenSerial=BenchSerial;FrameCount=0;FrameSum=0;FrameMin=100000;FrameMax=0;LastFrameMS=0;}
            if(LastFrameMS>0)
            {
                double ms=now-LastFrameMS;FrameCount++;FrameSum+=ms;
                FrameMin=Min(FrameMin,ms);FrameMax=Max(FrameMax,ms);
            }
            LastFrameMS=now;
        }
        else if(LastFrameMS>0)
        {
            Console.Printf("CA283 RENDER count=%d model=%d frames=%d mean_ms=%.6f min_ms=%.6f max_ms=%.6f",
                BenchCount,BenchModel,FrameCount,FrameSum/Max(1,FrameCount),FrameMin,FrameMax);
            LastFrameMS=0;
        }
    }
    void Benchmark(int count,bool model)
    {
        for(int i=0;i<RenderProxies.Size();i++)if(RenderProxies[i]!=null)RenderProxies[i].Destroy();
        RenderProxies.Clear();BenchCount=count;BenchModel=int(model);
        User.SetOrigin((-1024,0,0),false);User.bInvisible=true;
        Camera.SetOrigin((0,0,65),false);Camera.Angle=0;Camera.Pitch=5;
        int columns=int(Ceil(Sqrt(count)));
        for(int i=0;i<count;i++)
        {
            let body=Actor.Spawn(model?'CA283ModelProxy':'CA283SpriteProxy',
                (200+(i/columns)*45,(i%columns-(columns-1)*0.5)*40,0));
            body.Angle=180;body.Scale=User.Scale;RenderProxies.Push(body);
        }
        Console.Printf("CA283 BENCH_SETUP count=%d model=%d",count,int(model));
    }
    void Audit()
    {
        int hp=User.health,weapon=User.WeaponModel.Durability,shield=User.ShieldModel.Durability;
        double air=User.CurrentAir,anima=User.CurrentAnima,radius=User.Radius,height=User.Height;
        vector3 pos=User.Pos,vel=User.Vel;State state=User.CurState;
        for(int i=0;i<100;i++)User.UpdatePilotVisual();
        Check(User.health==hp && User.CurrentAir==air && User.CurrentAnima==anima,"visual update preserves resources");
        Check(User.WeaponModel.Durability==weapon && User.ShieldModel.Durability==shield,"visual update preserves equipment");
        Check(User.Pos==pos && User.Vel==vel && User.Radius==radius && User.Height==height,"visual update preserves physical body");
        Check(User.CurState==state,"native state remains authoritative");
        Check(User.AppearanceHead==null,"no duplicate modular head");
    }
    void Fallback()
    {
        User.PilotOriginalSprites=true;User.UpdateWorldCarbineVisual();
        Check(User.sprite==User.CurState.sprite && User.PilotBody.bInvisible,"explicit original sprite comparison");
        User.PilotOriginalSprites=false;User.UpdateWorldCarbineVisual();
        Check(User.sprite==User.GetSpriteIndex('TNT1') && !User.PilotBody.bInvisible,"model comparison restored");
        let session=new('CA259Session');session.Choice=5;session.Tier=1;session.Equip(User);
        User.UpdateWorldCarbineVisual();
        Check(User.PilotBody.bInvisible && User.sprite!=User.GetSpriteIndex('TNT1'),"unsupported firearm uses existing appearance");
        Check(User.AppearanceHead!=null,"normal modular head restored for fallback");
    }
    void Rest(bool sleep,bool ground)
    {
        CaelumRestState.Cancel(User);
        if(Furniture!=null){Furniture.Destroy();Furniture=null;}
        User.SetOrigin((70,0,0),false);User.Vel=(0,0,0);User.player.onground=true;
        User.CombatTimeRemaining=0;
        if(!ground)Furniture=CaelumRestFurniture(Actor.Spawn(sleep?'CaelumRestBed':'CaelumRestChair',(0,0,0)));
        bool begun=CaelumRestState.Begin(User,sleep?CaelumRestRules.MODE_SLEEP:CaelumRestRules.MODE_WAIT,60,Furniture);
        Check(begun,sleep?"native sleep begins":"native chair rest begins");
        if(begun && Furniture!=null)Check(Furniture.Occupant==User,"native furniture occupancy");
        if(begun)User.UpdateWorldCarbineVisual();
        Camera.SetOrigin(User.Pos+(-160,-120,65),false);Camera.Angle=Camera.AngleTo(User);Camera.Pitch=0;
        Console.Printf("CA283 REST result=%d reason=%s position=(%.2f,%.2f,%.2f) offset=(%.2f,%.2f,%.2f)",
            begun,CaelumRestState.BlockReason(User),User.Pos.X,User.Pos.Y,User.Pos.Z,User.WorldOffset.X,User.WorldOffset.Y,User.WorldOffset.Z);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=='c283_setup')Setup();
        if(e.Name=='c283_manual'){Manual=true;players[0].camera=User;}
        if(e.Name=='c283_compare')User.PilotOriginalSprites=!User.PilotOriginalSprites;
        if(e.Name=='c283_next_rest')
        {
            ManualRest=(ManualRest+1)%4;
            if(ManualRest==0)CaelumRestState.Cancel(User);
            else Rest(ManualRest!=1,ManualRest==3);
        }
        if(e.Name=='c283_orbit')
        {
            ManualCamera=(ManualCamera+1)%5;
            if(ManualCamera==0)players[0].camera=User;
            else
            {
                double yaw=User.Angle+(ManualCamera-1)*90;
                Camera.SetOrigin(User.Pos+(Cos(yaw)*180,Sin(yaw)*180,65),false);
                Camera.Angle=Camera.AngleTo(User);Camera.Pitch=0;players[0].camera=Camera;
            }
        }
        if(e.Name=='c283_bench')Benchmark(e.Args[0],e.Args[1]!=0);
        if(e.Name=='c283_record'){BenchSerial++;BenchActive=true;}
        if(e.Name=='c283_record_end')BenchActive=false;
        if(e.Name=='c283_hide')
        {
            let hud=EventHandler.Find('CaelumHUDOverlay');if(hud!=null)hud.Destroy();
        }
        if(e.Name=='c283_original')User.PilotOriginalSprites=true;
        if(e.Name=='c283_model')User.PilotOriginalSprites=false;
        if(e.Name=='c283_front')User.Angle=0;
        if(e.Name=='c283_side')User.Angle=90;
        if(e.Name=='c283_rear')User.Angle=180;
        if(e.Name=='c283_audit')Audit();
        if(e.Name=='c283_fallback')Fallback();
        if(e.Name=='c283_kill')
        {User.bInvulnerable=false;User.DamageMobj(Camera,Camera,10000000,'CaelumPhysicalTest',DMG_FORCED,0);}
        if(e.Name=='c283_dead')
        {
            Check(User.health<=0,"native death resolved");
            Check(User.PilotBody!=null && !User.PilotBody.bInvisible,"death retains model presentation");
            if(User.PilotBody!=null)Check(User.PilotBody.Pose==CaelumDomingoPilotFrames.DEATH
                && User.PilotBody.ModelFrame==CaelumDomingoPilotFrames.Start(CaelumDomingoPilotFrames.DEATH)
                    +CaelumDomingoPilotFrames.Count(CaelumDomingoPilotFrames.DEATH)-1,"stable terminal corpse frame");
            User.WeaponModel.Equipped=false;User.UpdatePilotVisual();
            Check(User.PilotBody!=null && !User.PilotBody.bInvisible,"corpse presentation survives equipment cleanup");
        }
        if(e.Name=='c283_loaded')
        {
            User=CaelumDomingoPilotPlayer(players[0].mo);
            Check(User!=null && User.PilotRevision==1,"pilot source state restored");
            if(User!=null)
            {
                Check(User.PilotBody!=null && User.PilotBody.Master==User,"bound body after load or travel");
                int bodies=0;let it=ThinkerIterator.Create('CaelumDomingoPilotBody');CaelumDomingoPilotBody body;
                while((body=CaelumDomingoPilotBody(it.Next()))!=null)if(body.Master==User)bodies++;
                Check(bodies==1,"exactly one local model body");Audit();
            }
        }
        if(e.Name=='c283_moved'){Check(WalkSeen,"native walking selects model walk");Check(RunSeen,"native running selects model run");}
        if(e.Name=='c283_attacked')Check(AttackSeen,"native weapon selects supported attack");
        if(e.Name=='c283_chair')Rest(false,false);
        if(e.Name=='c283_bed')Rest(true,false);
        if(e.Name=='c283_ground')Rest(true,true);
        if(e.Name=='c283_stand')
        {
            CaelumRestState.Cancel(User);User.UpdateWorldCarbineVisual();
            Check(!CaelumRestState.IsActive(User),"native rest cancellation");
            Check(Furniture==null || Furniture.Occupant==null,"native furniture released");
        }
        if(e.Name=='c283_done')Console.Printf("CA283 DONE passes=%d failures=%d",Passed,Failed);
    }
}

class CA283Camera : Actor
{
    Default { +NOINTERACTION +NOGRAVITY }
    States { Spawn: TNT1 A -1; Stop; }
}

class CA283ModelProxy : CaelumDomingoPilotFrames
{ Default { +NOINTERACTION +NOGRAVITY } }
class CA283SpriteProxy : Actor
{
    Default { +NOINTERACTION +NOGRAVITY }
    States { Spawn: DOID AAABBBB 10; Loop; }
}
