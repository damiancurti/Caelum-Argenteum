// Private fixture: common saved fields and class names also compile on baseline.
class CA857WardrobeProbe : EventHandler
{
    CaelumDomingoPilotPlayer User;
    CaelumDomingoPilotPlayer DeadUser;
    CaelumEquipmentItem Armor;
    Actor Camera;
    int Checks,Failures;
    int SavedIds[4],SavedDurability[4],SavedKinds[4];
    double SavedWeight[4];
    bool Seeded;
    bool SeenPoses[24];
    bool Measuring;double PreviousTic;Array<double> TicIntervals;
    void Check(bool okay,String label)
    {Checks++;if(!okay)Failures++;Console.Printf("CA836 EDGE %s wardrobe: %s",okay?"PASS":"FAIL",label);}
    bool Candidate(){return User!=null && User.PilotBody!=null && User.PilotBody.GetClassName()=='CaelumWardrobePilotBody';}
    void Select(CaelumEquipmentItem item)
    {User.EquipmentSelectionKind=item.EquipmentKind;User.EquipmentSelectionItemId=item.ItemId;User.RefreshEquipmentSelectionPreview();}
    void Refresh()
    {
        int health=User.health,weapon=User.ActiveWeaponItemId,shield=User.EquippedShieldItemId;
        double anima=User.CurrentAnima,air=User.CurrentAir,height=User.Height,radius=User.Radius;
        User.UpdatePilotVisual();
        Check(User.health==health && User.CurrentAnima==anima && User.CurrentAir==air && User.Height==height
            && User.Radius==radius && User.ActiveWeaponItemId==weapon && User.EquippedShieldItemId==shield,"synchronous visual refresh preserves owner state");
    }
    // SETUP
    void Seed()
    {
        Setup();
        int types[4];types[0]=CaelumClothingData.HP;types[1]=CaelumClothingData.F;
        types[2]=CaelumClothingData.GP;types[3]=CaelumClothingData.BP;
        int size=CaelumEquipmentRules.GetDefaultSizeForCharacterTier(User.CharacterProfile.GetSizeTier());
        for(int region=0;region<4;region++)
        {
            let item=CaelumClothing.Create(User,types[region],size);item.AttachToOwner(User);User.EnsureEquipmentItemId(item);
            Select(item);User.EquipSelectedNativeEquipment();
            Check(item.Equipped && CaelumClothing.Equipped(User,region)==item,"seed is equipped through native operation");
        }
        Armor=CaelumEquipmentItem(Actor.Spawn('CaelumArmorPickup',User.Pos,NO_REPLACE));
        Armor.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_ARMOR;Armor.ItemType=CaelumConstants.ARMOR_TYPE_LIGHT;
        Armor.ArmorSlot=CaelumConstants.ARMOR_SLOT_BODY;Armor.Tier=1;Armor.EquipmentSize=size;
        Armor.Durability=User.ArmorModel.GetMaximumDurabilityFor(Armor.ItemType,Armor.Tier,size);
        Armor.UnitWeight=User.ArmorModel.GetWeightFor(Armor.ArmorSlot,Armor.ItemType,Armor.Tier,size);
        Armor.PickupDataInitialized=true;Armor.AcquisitionResolved=true;Armor.AttachToOwner(User);User.EnsureEquipmentItemId(Armor);
        User.EquipmentMenuOpen=false;User.PersistCharacterState();Seeded=true;Snapshot();Refresh();
        Camera=Actor.Spawn('CA857Camera',User.Pos+(110,0,User.Height*.55),NO_REPLACE);
        Camera.CameraFOV=55;Camera.Angle=180;User.Angle=0;players[0].camera=Camera;
        CA857Camera(Camera).Subject=User;
    }
    void Snapshot()
    {
        for(int region=0;region<4;region++)
        {
            let item=CaelumClothing.Equipped(User,region);
            SavedIds[region]=item!=null?item.ItemId:0;SavedDurability[region]=item!=null?item.Durability:0;
            SavedWeight[region]=item!=null?item.UnitWeight:0;
        }
        Witness();
    }
    void Witness()
    {
        let witness=CA857Witness(User.FindInventory('CA857Witness'));
        if(witness==null && Seeded)
        {
            witness=CA857Witness(Actor.Spawn('CA857Witness',User.Pos,NO_REPLACE));witness.AttachToOwner(User);
            for(int region=0;region<4;region++)
            {witness.Ids[region]=SavedIds[region];witness.Wear[region]=SavedDurability[region];witness.Weights[region]=SavedWeight[region];}
        }
        else if(witness!=null && !Seeded)
        {
            for(int region=0;region<4;region++)
            {SavedIds[region]=witness.Ids[region];SavedDurability[region]=witness.Wear[region];SavedWeight[region]=witness.Weights[region];}
            Seeded=true;
        }
    }
    void Loaded(bool expectedCandidate)
    {
        User=CaelumDomingoPilotPlayer(players[0].mo);
        if(User!=null)Witness();
        Check(Seeded && User!=null,"saved fixture and original player survive");if(User==null)return;
        Refresh();Check(Candidate()==expectedCandidate,"expected candidate or existing presentation selected");
        Check(User.PilotBody!=null && !User.PilotBody.bInvisible,"owned visual is visible");
        for(int region=0;region<4;region++)
        {
            let item=CaelumClothing.Equipped(User,region);
            Check(item!=null && item.ItemId==SavedIds[region] && item.Durability==SavedDurability[region]
                && item.UnitWeight==SavedWeight[region] && item.Owner==User,"saved native clothing identity and properties survive");
        }
        // CANDIDATE_CHECKS
    }
    void Fallback()
    {
        Check(Candidate(),"candidate active before unsupported combination");
        Check(Armor!=null,"native armor retained for fallback");
        if(Armor!=null)
        {
            Select(Armor);User.EquipSelectedNativeEquipment();Refresh();
            Check(Armor.Equipped && !Candidate() && User.PilotBody!=null && !User.PilotBody.bInvisible,"armor retains existing presentation");
            User.UnequipSelectedNativeEquipment();Refresh();Check(Candidate(),"removing armor reconstructs candidate");
        }
        int face=User.CharacterProfile.Face;User.CharacterProfile.Face=face+1;Refresh();
        Check(!Candidate() && User.PilotBody!=null && !User.PilotBody.bInvisible,"unmodeled face retains existing presentation");
        User.CharacterProfile.Face=face;Refresh();Check(Candidate(),"reference face restores candidate");
        let shield=User.FindNativeEquipmentItemById(User.EquippedShieldItemId);Select(shield);User.UnequipSelectedNativeEquipment();Refresh();
        Check(User.PilotBody==null || User.PilotBody.bInvisible,"unsupported attachment returns native sprite presentation");
        Select(shield);User.EquipSelectedNativeEquipment();Refresh();Check(Candidate() && !User.PilotBody.bInvisible,"native shield restoration resumes candidate");
        User.EquipmentMenuOpen=false;
    }
    void Dead()
    {
        User=DeadUser!=null?DeadUser:CaelumDomingoPilotPlayer(players[0].mo);Refresh();
        Check(User.health<=0 && Candidate() && !User.PilotBody.bInvisible,"death retains last legitimate candidate outfit");
        // DEATH_CHECKS
    }
    override void WorldTick()
    {
        if(User!=null && User.PilotBody!=null)SeenPoses[Clamp(User.PilotBody.Pose,0,23)]=true;
        if(Measuring)
        {double now=MSTimeF();if(PreviousTic>0)TicIntervals.Push(now-PreviousTic);PreviousTic=now;}
    }
    void Motion()
    {
        Check(SeenPoses[CaelumDomingoPilotFrames.WALK],"native walk pose observed");
        Check(SeenPoses[CaelumDomingoPilotFrames.RUN],"native run pose observed");
        Check(SeenPoses[CaelumDomingoPilotFrames.MELEE] || SeenPoses[CaelumDomingoPilotFrames.MISSILE],"native attack pose observed");
        Check(SeenPoses[CaelumDomingoPilotFrames.GUARDIDLEBREATHING],"native guard pose observed");
        Check(SeenPoses[CaelumDomingoPilotFrames.JUMPPREPARE],"native jump preparation observed");
        Check(SeenPoses[CaelumDomingoPilotFrames.JUMPAIR],"native jump air pose observed");
        Check(SeenPoses[CaelumDomingoPilotFrames.LANDING],"native landing pose observed");
        Loaded(true);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=='ca857seed')Seed();
        if(e.Name=='ca857loaded')Loaded(e.Args[0]!=0);
        if(e.Name=='ca857fallback')Fallback();
        if(e.Name=='ca857snapshot')Snapshot();
        if(e.Name=='ca857kill'){DeadUser=User;User.bInvulnerable=false;User.DamageMobj(Camera,Camera,10000000,'CaelumPhysicalTest',DMG_FORCED,0);}
        if(e.Name=='ca857respawned')Check(players[0].mo!=DeadUser && players[0].mo.health>0,"native respawn permits saving the retained corpse");
        if(e.Name=='ca857dead')Dead();
        if(e.Name=='ca857motion')Motion();
        if(e.Name=='ca857view' && Camera!=null)CA857Camera(Camera).Side=e.Args[0];
        if(e.Name=='ca857pose' && User!=null && User.PilotBody!=null)
            Console.Printf("CA857 POSE pose=%d frame=%d",User.PilotBody.Pose,User.PilotBody.ModelFrame);
        if(e.Name=='ca857benchstart'){Measuring=true;PreviousTic=0;TicIntervals.Clear();Console.Printf("CA857 BEGIN");}
        if(e.Name=='ca857benchend')
        {
            Measuring=false;Console.Printf("CA857 END");
            for(int index=0;index<TicIntervals.Size();index++)Console.Printf("CA857 TIC %.6f",TicIntervals[index]);
            Check(TicIntervals.Size()>=699,"recorded native tic interval window");
        }
        if(e.Name=='ca857done')Console.Printf("CA836 EDGE_RESULT checks=%d failures=%d result=%s",Checks,Failures,Failures==0?"PASS":"FAIL");
    }
}
class CA857Camera : Actor
{
    Actor Subject;int Side;
    override void Tick()
    {
        Super.Tick();if(Subject==null)return;
        double yaw=Subject.Angle+Side*90;
        SetOrigin(Subject.Pos+(Cos(yaw)*110,Sin(yaw)*110,Subject.Height*.55),false);
        Angle=AngleTo(Subject);Pitch=0;
    }
    Default { +NOBLOCKMAP +NOINTERACTION +NOGRAVITY }
}
class CA857Witness : Inventory
{
    int Ids[4],Wear[4];double Weights[4];
    Default { Inventory.MaxAmount 1; Inventory.InterHubAmount 1; +INVENTORY.UNDROPPABLE -INVENTORY.INVBAR }
}
