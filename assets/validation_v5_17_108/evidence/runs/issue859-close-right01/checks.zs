// Escenario aislado: equipa objetos reales; no forma parte del PK3 del juego.
class CA259Session : EventHandler
{
    CaelumEquipmentItem TestItem;
    int Choice,Tier,LucidityChoice;
    bool Pinned,Manual;
    double FixedLucidity;
    override void UiTick()
    { if(!Pinned && Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close(); }
    int Kind()
    {
        static const int kinds[]={1,18,19,17,0,2,14,15,16};
        return kinds[Clamp(Choice,0,8)];
    }
    void Equip(CaelumPlayer user)
    {
        if(TestItem!=null && TestItem.Owner==user)
        {
            user.EquipmentSelectionItemId=TestItem.ItemId;
            user.RefreshEquipmentSelectionPreview();user.UnequipSelectedNativeEquipment();
            TestItem.Destroy();TestItem=null;
        }
        let model=new("CaelumWeaponModel");model.InitializeDefaults();
        TestItem=CaelumEquipmentItem(Actor.Spawn("CaelumWeaponPickup",user.Pos,NO_REPLACE));
        TestItem.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;TestItem.ItemType=Kind();
        TestItem.Tier=Tier;TestItem.EquipmentSize=CaelumEquipmentRules.GetDefaultSizeForCharacterTier(user.CharacterProfile.GetSizeTier());
        TestItem.EssenceType=CaelumConstants.ESSENCE_FIRE;
        TestItem.Durability=model.GetMaximumDurabilityFor(Kind(),Tier,TestItem.EquipmentSize);
        TestItem.UnitWeight=model.GetWeightFor(Kind(),Tier,TestItem.EquipmentSize);
        TestItem.PickupDataInitialized=true;TestItem.AcquisitionResolved=true;
        TestItem.WeaponDurabilityRevision=CaelumAttackRules.DURABILITY_REVISION;
        TestItem.AttachToOwner(user);user.EnsureEquipmentItemId(TestItem);
        user.EquipmentSelectionKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;
        user.EquipmentSelectionItemId=TestItem.ItemId;
        user.EquipmentSelectionWeaponType=Kind();user.EquipmentSelectionTier=Tier;
        user.EquipmentSelectionSize=TestItem.EquipmentSize;
        user.EquipmentSelectionWeaponEssenceType=CaelumConstants.ESSENCE_FIRE;
        user.RefreshEquipmentSelectionPreview();user.EquipSelectedNativeEquipment();
        Console.Printf("CA259 EQUIP action=%d compatible=%d id=%d selected=%d itemtier=%d modeltier=%d equipped=%d",
            user.LastEquipmentAction,user.EquipmentSelectionSizeCompatible,TestItem.ItemId,user.EquipmentSelectionItemId,
            TestItem.Tier,user.WeaponModel.Tier,TestItem.Equipped);
        user.SelectNativeWeaponConfiguration(Kind(),CaelumConstants.ESSENCE_FIRE,Tier);
        if(!TestItem.Equipped || user.WeaponModel.Tier!=Tier || user.WeaponModel.WeaponType!=Kind())
            Console.Printf("CA259 FAIL native equipment selection");
        user.EquipmentMenuOpen=false;
    }
    void Show(CaelumPlayer user)
    {
        static const String names[]={"CA_WEAPON_TYPE_STAFF","CA_WEAPON_TYPE_BOOK","CA_WEAPON_TYPE_STATUETTE",
            "CA_WEAPON_TYPE_BELL","CA_WEAPON_TYPE_SWORD","CA_WEAPON_TYPE_CARBINE","CA_WEAPON_TYPE_SHOTGUN",
            "CA_WEAPON_TYPE_LONGBOW","CA_WEAPON_TYPE_CROSSBOW"};
        String text=String.Format("#259 | %s T%d | Lucidez %.1f%% | F6 Lucidez / F7 tier / F8 arma",
            StringTable.Localize(names[Choice],false),Tier,FixedLucidity);
        CaelumNotifications.Notify(user,text);Console.Printf("CA259 SESSION %s",text);
    }
    override void WorldTick()
    {
        let user=CaelumPlayer(players[0].mo);
        if(!Pinned || user==null)return;
        user.CurrentLucidity=FixedLucidity;user.UpdateLucidityState();
        if(Manual)
        {
            // Recursos y stun fijos sólo para comparar trayectorias sin esperas.
            user.CurrentAir=100000;user.CurrentAnima=100000;user.LucidityPhysicalStunRemaining=0;
            user.SetRangedMagazineCount(Kind(),user.GetRangedMagazineCapacity(Kind()));
        }
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let user=CaelumPlayer(players[e.Player].mo);if(user==null)return;
        if(e.Name=="c259_seed" || e.Name=="c259_manual")
        {
            user.CreationWizardOpen=false;user.CharacterCreationComplete=true;user.ApplyCharacterProfile();
            user.Attributes.Dexterity=0;user.Attributes.Insight=0;user.Attributes.Strength=100;
            user.DerivedStats.Recalculate(user.Attributes,user.CharacterProfile);
            user.player.ConversationNPC=null;user.player.ConversationPC=null;
            user.CurrentAir=100000;user.CurrentAnima=100000;
            Manual=e.Name=="c259_manual";Pinned=true;Choice=0;Tier=Manual?1:3;
            FixedLucidity=Manual?100:9.999;user.CurrentLucidity=FixedLucidity;
            Equip(user);user.UpdateLucidityState();user.PersistCharacterState();
            if(Manual)
            {
                user.bInvulnerable=true;
                let dummy=Actor.Spawn("CaelumTrainingDummy",user.Pos+(256,0,0),NO_REPLACE);
                if(dummy!=null){dummy.bInvulnerable=true;dummy.health=1000000;user.Angle=user.AngleTo(dummy);}
                Show(user);
            }
            Console.Printf("CA259 DONE failures=%d seeded-tier=%d item-tier=%d equipped=%d",
                user.WeaponModel.Tier==Tier && TestItem.Equipped?0:1,user.WeaponModel.Tier,TestItem.Tier,TestItem.Equipped);
        }
        if(e.Name=="c259_verify" || e.Name=="c259_verify_old")
        {
            bool legacy=e.Name=="c259_verify_old";
            bool ok=TestItem!=null && TestItem.Owner==user && TestItem.Tier==3 && TestItem.Equipped
                && user.WeaponModel.Tier==3 && user.WeaponModel.WeaponType==CaelumConstants.WEAPON_TYPE_STAFF
                && Abs(user.CurrentLucidity-FixedLucidity)<=CaelumConstants.MAXIMUM_LUCIDITY/CaelumConstants.LUCIDITY_FULL_RECOVERY_SECONDS/TICRATE+0.00001
                && Abs(user.LucidityAccuracyMultiplier-(legacy?0.5:1.0))<0.00001
                && Abs(user.WeaponModel.GetMaximumSpreadFor(CaelumConstants.WEAPON_TYPE_STAFF)-(legacy?20:30))<0.00001;
            Console.Printf("CA259 %s save inventory-tier=%d model-tier=%d lucidity=%.4f multiplier=%.2f spread=%.1f",
                ok?"PASS":"FAIL",TestItem!=null?TestItem.Tier:-1,user.WeaponModel.Tier,user.CurrentLucidity,
                user.LucidityAccuracyMultiplier,user.WeaponModel.GetMaximumSpreadFor(CaelumConstants.WEAPON_TYPE_STAFF));
            Console.Printf("CA259 DONE failures=%d",ok?0:1);
        }
        if(!Manual)return;
        if(e.Name=="c259_lucidity")
        {
            static const double values[]={100,50,49.9,10,9.9};
            LucidityChoice=(LucidityChoice+1)%5;FixedLucidity=values[LucidityChoice];Show(user);
        }
        if(e.Name=="c259_tier"){Tier=Tier%3+1;Equip(user);Show(user);}
        if(e.Name=="c259_weapon"){Choice=(Choice+1)%9;Equip(user);Show(user);}
    }
}

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
    bool SeenPoses[24];int LastPose;
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
    void Setup()
    {
        User=CaelumDomingoPilotPlayer(players[0].mo);
        Check(User!=null,"existing opt-in native player");if(User==null)return;
        User.CharacterCreationComplete=true;User.CreationWizardOpen=false;
        User.CharacterProfile.Race=CaelumConstants.RACE_HUMAN;User.CharacterProfile.Sex=CaelumConstants.SEX_MALE;
        User.ApplyCharacterProfile();User.bInvulnerable=true;
        let session=new('CA259Session');session.Choice=4;session.Tier=1;session.Equip(User);
        let shield=CaelumEquipmentItem(Actor.Spawn('CaelumShieldPickup',User.Pos,NO_REPLACE));
        shield.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_SHIELD;shield.ItemType=CaelumConstants.SHIELD_TYPE_BUCKLER;shield.Tier=1;
        shield.EquipmentSize=User.WeaponModel.Size;
        shield.Durability=User.ShieldModel.GetMaximumDurabilityFor(shield.ItemType,shield.Tier,shield.EquipmentSize);
        shield.UnitWeight=User.ShieldModel.GetWeightFor(shield.ItemType,shield.Tier,shield.EquipmentSize);
        shield.PickupDataInitialized=true;shield.AcquisitionResolved=true;shield.AttachToOwner(User);User.EnsureEquipmentItemId(shield);
        Select(shield);User.EquipSelectedNativeEquipment();
        Check(shield.Equipped && User.ShieldModel.Equipped,"native sword/shield fixture equipped");
        for(int slot=0;slot<CaelumConstants.ARMOR_SLOT_COUNT;slot++)
        {
            let armor=User.FindNativeEquipmentItemById(User.EquippedArmorItemId[slot]);
            if(armor!=null){Armor=armor;Select(armor);User.UnequipSelectedNativeEquipment();}
            Check(User.ArmorModel.ArmorType[slot]==CaelumConstants.ARMOR_TYPE_BASE_CLOTHING,"unsupported armor removed through native equipment operation");
        }
        User.EquipmentMenuOpen=false;User.PersistCharacterState();User.GetPersistentCharacterState(true).ProfileCommitted=true;
    }

    void Seed()
    {
        Setup();
        int types[4];types[0]=CaelumClothingData.HP;types[1]=CaelumClothingData.CS;
        types[2]=CaelumClothingData.GP;types[3]=CaelumClothingData.BS;
        int size=CaelumEquipmentRules.GetDefaultSizeForCharacterTier(User.CharacterProfile.GetSizeTier());
        for(int region=0;region<4;region++)
        {
            if(region==2)continue;
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
        let oldGloves=CaelumClothing.Equipped(User,2);
        if(oldGloves!=null){Select(oldGloves);User.UnequipSelectedNativeEquipment();}
        Check(CaelumClothing.Equipped(User,2)==null,"bare-hand case removes actual starting gloves");
        User.EquipmentMenuOpen=false;User.PersistCharacterState();Seeded=true;Snapshot();Refresh();
        Check(CaelumWardrobePilotBody(User.PilotBody).HandKind==-1,"actual equipped hand kind matches requested grip case");
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
        if(expectedCandidate)
        {
            let body=CaelumWardrobePilotBody(User.PilotBody);
            Check(body!=null && body.WardrobeRevision==1 && body.CacheReady && body.BindingsReady,"revision and transient cache reconstructed");
            Check(body!=null && body.HeadKind==4 && body.BodyKind==0 && body.HandKind==3 && body.FootKind==4,"equipped four-region appearance reconstructed");
            if(body!=null)for(int region=0;region<4;region++)Check(body.CachedPieces[region]==CaelumClothing.Equipped(User,region),"cache references actual restored inventory object");
        }
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
        let body=CaelumWardrobePilotBody(User.PilotBody);
        Check(body!=null && body.FrozenDeath && body.SnapshotReady && body.BindingsReady,"saved death snapshot restored and rebound");
        Check(body!=null && body.HeadKind==4 && body.BodyKind==0 && body.HandKind==3 && body.FootKind==4,"death outfit unchanged after native equipment cleanup");
    }
    override void WorldTick()
    {
        if(User!=null && User.PilotBody!=null)
        {
            SeenPoses[Clamp(User.PilotBody.Pose,0,23)]=true;
            if(LastPose!=User.PilotBody.Pose){LastPose=User.PilotBody.Pose;Console.Printf("CA859 TRANSITION tic=%d pose=%d frame=%d",level.time,LastPose,User.PilotBody.ModelFrame);}
        }
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
        Check(Candidate(),"candidate remains selected through native motion");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=='ca857seed')Seed();
        if(e.Name=='ca859detail' && Camera!=null)CA857Camera(Camera).Detail=e.Args[0];
        if(e.Name=='ca859snapshot' && User!=null && User.PilotBody!=null)
            Console.Printf("CA859 SNAPSHOT tic=%d pose=%d frame=%d speed=%.4f",level.time,User.PilotBody.Pose,User.PilotBody.ModelFrame,User.Vel.XY.Length());
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
    Actor Subject;int Side,Detail;
    override void Tick()
    {
        Super.Tick();if(Subject==null)return;
        let user=CaelumDomingoPilotPlayer(Subject);
        if(user==null || user.PilotBody==null)return;
        Vector3 local=CA859GripCameraData.Point(user.PilotBody.ModelFrame);
        local=(local.X*Subject.Scale.X,local.Y*Subject.Scale.X,local.Z*Subject.Scale.Y);
        double angle=Subject.Angle,yaw=angle+Side*45,distance=20;
        Vector3 anchor=Subject.Pos+(local.X*Cos(angle)-local.Y*Sin(angle),local.X*Sin(angle)+local.Y*Cos(angle),local.Z);
        SetOrigin(anchor+(Cos(yaw)*distance,Sin(yaw)*distance,3),false);
        Angle=yaw+180;Pitch=atan2(3,distance);
    }
    Default { +NOBLOCKMAP +NOINTERACTION +NOGRAVITY }
}
class CA857Witness : Inventory
{
    int Ids[4],Wear[4];double Weights[4];
    Default { Inventory.MaxAmount 1; Inventory.InterHubAmount 1; +INVENTORY.UNDROPPABLE -INVENTORY.INVBAR }
}

class CA859GripCameraData : Object { static clearscope Vector3 Point(int frame) {
static const double xs[]={10.550743,10.357614,10.202526,10.116380,10.116380,10.202526,10.357614,10.550743,10.743582,10.897995,10.983609,10.983609,10.897995,10.743582,20.474030,17.740854,16.560425,17.740854,20.474030,23.028120,24.029736,23.028120,28.410280,24.077682,19.660959,17.804840,19.660959,24.077682,28.410280,30.647644,30.955561,30.797678,30.955561,30.647644,10.550743,27.849218,36.415989,35.606483,28.927933,20.973993,15.110777,13.005167,15.110777,20.973993,28.927933,35.606483,36.415989,27.849218,10.550743,26.092154,35.218452,36.844032,32.702785,25.874676,19.220631,14.623468,13.005167,14.623468,19.220631,25.874676,32.702785,36.844032,35.218452,26.092154,10.550743,11.523671,12.433942,13.216773,13.731124,13.798976,13.275702,12.136055,10.550743,11.357638,12.058191,12.685979,13.273610,13.849497,14.435575,15.045495,15.684173,16.347893,17.025391,17.699066,18.346830,18.943502,19.462538,19.877052,20.160872,20.289207,20.238892,19.988670,19.519247,18.813028,17.854048,16.627998,15.121819,13.323810,11.223485,8.811488,6.079719,6.079719,9.735432,12.779057,15.238910,17.146130,18.536203,19.450882,19.939890,20.061024,19.879034,19.462538,18.879089,18.189232,17.440340,16.661528,15.860703,15.024531,14.121409,13.107147,11.932463,10.550743,34.947536,34.893436,34.849361,34.824631,34.824631,34.849361,34.893436,34.947536,35.000641,35.042522,35.065475,35.065475,35.042522,35.000641,-6.079729,-6.024272,-5.980495,-5.956468,-5.956468,-5.980495,-6.024272,-6.079729,-6.136128,-6.182050,-6.207794,-6.207794,-6.182050,-6.136128,3.636798,10.550743,13.960647,17.300663,20.575863,23.723089,26.629290,29.174662,31.277334,32.915974,34.121437,34.947536,34.947536,33.927128,32.523663,30.809649,28.841202,26.629290,24.136379,21.300138,18.073446,14.463455,10.550743,10.550743,4.798358,-0.783712,-5.831458,-10.071727,-13.294407,-15.297083,-15.841352,-14.652912,-11.465237,-6.079729,-6.079729,-11.392644,-14.668621,-15.991979,-15.472318,-13.294407,-9.745081,-5.197761,-0.060445,5.289514,10.550743,10.550743,10.595567,10.726473,10.937917,11.224241,11.579644,11.998178,12.473870,13.000642,13.572395,14.183013,14.826390,15.496473,16.187284,16.892912,17.607643,18.325867,19.042208,19.751492,20.448797,21.129465,21.789125,22.423677,23.029306,23.602474,24.139936,24.638651,25.095823,25.508812,25.875103,26.192251,26.457838,26.669338,26.824148,26.919388,26.951893,26.951893,26.919388,26.824148,26.669338,26.457838,26.192251,25.875103,25.508812,25.095823,24.638651,24.139936,23.602474,23.029306,22.423677,21.789125,21.129465,20.448797,19.751492,19.042208,18.325867,17.607643,16.892912,16.187284,15.496473,14.826390,14.183013,13.572395,13.000642,12.473870,11.998178,11.579644,11.224241,10.937917,10.726473,10.595567,10.550743,26.951893,10.550743,10.357614,10.202526,10.116380,10.116380,10.202526,10.357614,10.550743,10.743582,10.897995,10.983609,10.983609,10.897995,10.743582,20.474030,17.740854,16.560425,17.740854,20.474030,23.028120,24.029736,23.028120,28.410280,24.077682,19.660959,17.804840,19.660959,24.077682,28.410280,30.647644,30.955561,30.797678,30.955561,30.647644,10.550743,10.595567,10.726473,10.937917,11.224241,11.579644,11.998178,12.473870,13.000642,13.572395,14.183013,14.826390,15.496473,16.187284,16.892912,17.607643,18.325867,19.042208,19.751492,20.448797,21.129465,21.789125,22.423677,23.029306,23.602474,24.139936,24.638651,25.095823,25.508812,25.875103,26.192251,26.457838,26.669338,26.824148,26.919388,26.951893,26.951893,26.919388,26.824148,26.669338,26.457838,26.192251,25.875103,25.508812,25.095823,24.638651,24.139936,23.602474,23.029306,22.423677,21.789125,21.129465,20.448797,19.751492,19.042208,18.325867,17.607643,16.892912,16.187284,15.496473,14.826390,14.183013,13.572395,13.000642,12.473870,11.998178,11.579644,11.224241,10.937917,10.726473,10.595567,10.550743,26.951893};
static const double ys[]={-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625055,-25.625055,-25.625057,-25.625055,-25.625055,-25.625055,-25.625055,-25.625055,-25.625055,-25.625055,-25.625057,-25.625055,-25.625057,-25.625055,-25.625055,-25.625055,-25.625059,-25.625057,-25.625059,-25.625055,-25.625059,-28.458807,-33.068974,-36.536430,-37.461960,-36.439335,-34.978336,-34.338535,-34.978336,-36.439335,-37.461960,-36.536430,-33.068974,-28.458807,-25.625059,-27.944633,-31.922430,-35.507500,-37.317787,-37.231209,-36.055214,-34.835358,-34.338535,-34.835358,-36.055214,-37.231209,-37.317787,-35.507500,-31.922430,-27.944633,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-26.049444,-26.473461,-26.897097,-27.320307,-27.743040,-28.165281,-28.586983,-29.008102,-29.428616,-29.848475,-30.267649,-30.686106,-31.103786,-31.520691,-31.936758,-32.351944,-32.766243,-33.179600,-33.591961,-34.003326,-34.413635,-34.822853,-35.230961,-35.637917,-36.043659,-36.448193,-36.851460,-37.253414,-37.253414,-36.690304,-36.124672,-35.556610,-34.986233,-34.413635,-33.838898,-33.262146,-32.683464,-32.102936,-31.520691,-30.936811,-30.351402,-29.764555,-29.176382,-28.586983,-27.996447,-27.404890,-26.812407,-26.219090,-25.625059,-25.625055,-25.625055,-25.625055,-25.625055,-25.625055,-25.625055,-25.625055,-25.625055,-25.625055,-25.625055,-25.625055,-25.625055,-25.625055,-25.625055,-37.253414,-37.253414,-37.253414,-37.253414,-37.253414,-37.253414,-37.253414,-37.253414,-37.253414,-37.253414,-37.253414,-37.253414,-37.253414,-37.253414,-25.625059,-25.625059,-25.625057,-25.625059,-25.625055,-25.625057,-25.625055,-25.625055,-25.625051,-25.625051,-25.625053,-25.625055,-25.625055,-25.625053,-25.625051,-25.625051,-25.625055,-25.625055,-25.625057,-25.625055,-25.625059,-25.625057,-25.625059,-25.625059,-26.812407,-27.996447,-29.176382,-30.351402,-31.520691,-32.683464,-33.838898,-34.986233,-36.124672,-37.253414,-37.253414,-36.124672,-34.986233,-33.838898,-32.683464,-31.520691,-30.351402,-29.176382,-27.996447,-26.812407,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625057,-25.625059,-25.625057,-25.625057,-25.625059,-25.625057,-25.625057,-25.625053,-25.625053,-25.625053,-25.625053,-25.625053,-25.625053,-25.625053,-25.625051,-25.625055,-25.625053,-25.625053,-25.625053,-25.625053,-25.625053,-25.625053,-25.625053,-25.625053,-25.625053,-25.625053,-25.625053,-25.625053,-25.625053,-25.625053,-25.625053,-25.625053,-25.625055,-25.625051,-25.625053,-25.625053,-25.625053,-25.625053,-25.625053,-25.625053,-25.625053,-25.625057,-25.625057,-25.625059,-25.625057,-25.625057,-25.625059,-25.625057,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625053,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625055,-25.625055,-25.625057,-25.625055,-25.625055,-25.625055,-25.625055,-25.625055,-25.625055,-25.625055,-25.625057,-25.625055,-25.625057,-25.625055,-25.625055,-25.625055,-25.625059,-25.625057,-25.625059,-25.625055,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625057,-25.625059,-25.625057,-25.625057,-25.625059,-25.625057,-25.625057,-25.625053,-25.625053,-25.625053,-25.625053,-25.625053,-25.625053,-25.625053,-25.625051,-25.625055,-25.625053,-25.625053,-25.625053,-25.625053,-25.625053,-25.625053,-25.625053,-25.625053,-25.625053,-25.625053,-25.625053,-25.625053,-25.625053,-25.625053,-25.625053,-25.625053,-25.625055,-25.625051,-25.625053,-25.625053,-25.625053,-25.625053,-25.625053,-25.625053,-25.625053,-25.625057,-25.625057,-25.625059,-25.625057,-25.625057,-25.625059,-25.625057,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625059,-25.625053};
static const double zs[]={88.594315,88.538910,88.495201,88.471230,88.471230,88.495201,88.538910,88.594315,88.650757,88.696754,88.722557,88.722557,88.696754,88.650757,90.371490,89.984268,89.888863,89.984268,90.371490,93.795807,95.271240,93.795807,99.945641,96.638603,94.884148,94.431404,94.884148,96.638603,99.945641,111.780128,120.442368,123.562599,120.442368,111.780128,88.594315,99.634178,117.569717,136.242035,151.047272,160.467896,165.237442,166.637924,165.237442,160.467896,151.047272,136.242035,117.569717,99.634178,88.594315,97.756607,112.779381,129.510132,144.294067,155.203186,162.043106,165.574844,166.637924,165.574844,162.043106,155.203186,144.294067,129.510132,112.779381,97.756607,88.594315,89.377007,90.140175,90.780632,91.146439,91.080475,90.526398,89.609062,88.594315,88.062096,87.461250,86.799240,86.071815,85.264442,84.354439,83.313614,82.111084,80.716156,79.100471,77.239861,75.115685,72.715187,70.031868,67.065109,63.819786,60.305462,56.535889,52.528164,48.301979,43.879116,39.282932,34.537640,29.668137,24.699516,19.656912,14.565282,9.449265,9.449265,16.864111,24.189520,31.332911,38.205166,44.724052,50.817692,56.427605,61.511932,66.047585,70.031868,73.482910,76.437859,78.949234,81.078995,82.890877,84.442291,85.776512,86.917046,87.864105,88.594315,82.889099,82.703995,82.555763,82.473572,82.473572,82.555763,82.703995,82.889099,83.074493,83.223373,83.306061,83.306061,83.223373,83.074493,30.550728,30.370770,30.226255,30.145967,30.145967,30.226255,30.370770,30.550728,30.730391,30.874239,30.953997,30.953997,30.874239,30.730391,43.836533,88.594315,86.689629,85.141792,83.991272,83.252716,82.886047,82.791473,82.835884,82.899254,82.915947,82.889099,82.889099,82.427269,82.138847,82.114433,82.374840,82.886047,83.596413,84.477867,85.552834,86.893745,88.594315,88.594315,91.148453,91.513878,89.808998,86.171936,80.715393,73.521866,64.685127,54.371948,42.863728,30.550728,30.550728,42.353390,53.530182,63.849449,73.022881,80.715393,86.596558,90.407066,92.006691,91.379677,88.594315,88.594315,88.562012,88.467918,88.316322,88.111992,87.859810,87.564812,87.232155,86.866982,86.474335,86.059196,85.626343,85.180382,84.725670,84.266281,83.806053,83.348503,82.896858,82.454094,82.022827,81.605476,81.204208,80.820900,80.457329,80.115067,79.795547,79.500107,79.230019,78.986519,78.770828,78.584251,78.428070,78.303711,78.212669,78.156662,78.137527,78.137527,78.156662,78.212669,78.303711,78.428070,78.584251,78.770828,78.986519,79.230019,79.500107,79.795547,80.115067,80.457329,80.820900,81.204208,81.605476,82.022827,82.454094,82.896858,83.348503,83.806053,84.266281,84.725670,85.180382,85.626343,86.059196,86.474335,86.866982,87.232155,87.564812,87.859810,88.111992,88.316322,88.467918,88.562012,88.594315,78.137527,88.594315,88.538910,88.495201,88.471230,88.471230,88.495201,88.538910,88.594315,88.650757,88.696754,88.722557,88.722557,88.696754,88.650757,90.371490,89.984268,89.888863,89.984268,90.371490,93.795807,95.271240,93.795807,99.945641,96.638603,94.884148,94.431404,94.884148,96.638603,99.945641,111.780128,120.442368,123.562599,120.442368,111.780128,88.594315,88.562012,88.467918,88.316322,88.111992,87.859810,87.564812,87.232155,86.866982,86.474335,86.059196,85.626343,85.180382,84.725670,84.266281,83.806053,83.348503,82.896858,82.454094,82.022827,81.605476,81.204208,80.820900,80.457329,80.115067,79.795547,79.500107,79.230019,78.986519,78.770828,78.584251,78.428070,78.303711,78.212669,78.156662,78.137527,78.137527,78.156662,78.212669,78.303711,78.428070,78.584251,78.770828,78.986519,79.230019,79.500107,79.795547,80.115067,80.457329,80.820900,81.204208,81.605476,82.022827,82.454094,82.896858,83.348503,83.806053,84.266281,84.725670,85.180382,85.626343,86.059196,86.474335,86.866982,87.232155,87.564812,87.859810,88.111992,88.316322,88.467918,88.562012,88.594315,78.137527};
int i=Clamp(frame,0,374);return (xs[i],ys[i],zs[i]);}}
