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
        types[2]=CaelumClothingData.GC;types[3]=CaelumClothingData.BS;
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
        Check(CaelumWardrobePilotBody(User.PilotBody).HandKind==1,"actual equipped hand kind matches requested grip case");
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
        // MD3 native model transforms compensate the level's vertical pixel stretch.
        local=(local.X*Subject.Scale.X,local.Y*Subject.Scale.X,local.Z*Subject.Scale.Y/level.pixelstretch);
        double angle=Subject.Angle,yaw=angle+Side*45,distance=20;
        Vector3 anchor=Subject.Pos+(local.X*Cos(angle)-local.Y*Sin(angle),local.X*Sin(angle)+local.Y*Cos(angle),local.Z);
        SetOrigin(anchor+(Cos(yaw)*distance,Sin(yaw)*distance,3),false);
        Angle=yaw+180;Pitch=atan2(3,distance);
    }
    Default { CameraHeight 0; +NOBLOCKMAP +NOINTERACTION +NOGRAVITY }
}
class CA857Witness : Inventory
{
    int Ids[4],Wear[4];double Weights[4];
    Default { Inventory.MaxAmount 1; Inventory.InterHubAmount 1; +INVENTORY.UNDROPPABLE -INVENTORY.INVBAR }
}

class CA859GripCameraData : Object { static clearscope Vector3 Point(int ordinal) { switch(ordinal) {
case 0: return (10.550743,-25.625059,88.594315);
case 1: return (10.357614,-25.625059,88.538910);
case 2: return (10.202526,-25.625059,88.495201);
case 3: return (10.116380,-25.625059,88.471230);
case 4: return (10.116380,-25.625059,88.471230);
case 5: return (10.202526,-25.625059,88.495201);
case 6: return (10.357614,-25.625059,88.538910);
case 7: return (10.550743,-25.625059,88.594315);
case 8: return (10.743582,-25.625059,88.650757);
case 9: return (10.897995,-25.625059,88.696754);
case 10: return (10.983609,-25.625059,88.722557);
case 11: return (10.983609,-25.625059,88.722557);
case 12: return (10.897995,-25.625059,88.696754);
case 13: return (10.743582,-25.625059,88.650757);
case 14: return (20.474030,-25.625055,90.371490);
case 15: return (17.740854,-25.625055,89.984268);
case 16: return (16.560425,-25.625057,89.888863);
case 17: return (17.740854,-25.625055,89.984268);
case 18: return (20.474030,-25.625055,90.371490);
case 19: return (23.028120,-25.625055,93.795807);
case 20: return (24.029736,-25.625055,95.271240);
case 21: return (23.028120,-25.625055,93.795807);
case 22: return (28.410280,-25.625055,99.945641);
case 23: return (24.077682,-25.625055,96.638603);
case 24: return (19.660959,-25.625057,94.884148);
case 25: return (17.804840,-25.625055,94.431404);
case 26: return (19.660959,-25.625057,94.884148);
case 27: return (24.077682,-25.625055,96.638603);
case 28: return (28.410280,-25.625055,99.945641);
case 29: return (30.647644,-25.625055,111.780128);
case 30: return (30.955561,-25.625059,120.442368);
case 31: return (30.797678,-25.625057,123.562599);
case 32: return (30.955561,-25.625059,120.442368);
case 33: return (30.647644,-25.625055,111.780128);
case 34: return (10.550743,-25.625059,88.594315);
case 35: return (27.849218,-28.458807,99.634178);
case 36: return (36.415989,-33.068974,117.569717);
case 37: return (35.606483,-36.536430,136.242035);
case 38: return (28.927933,-37.461960,151.047272);
case 39: return (20.973993,-36.439335,160.467896);
case 40: return (15.110777,-34.978336,165.237442);
case 41: return (13.005167,-34.338535,166.637924);
case 42: return (15.110777,-34.978336,165.237442);
case 43: return (20.973993,-36.439335,160.467896);
case 44: return (28.927933,-37.461960,151.047272);
case 45: return (35.606483,-36.536430,136.242035);
case 46: return (36.415989,-33.068974,117.569717);
case 47: return (27.849218,-28.458807,99.634178);
case 48: return (10.550743,-25.625059,88.594315);
case 49: return (26.092154,-27.944633,97.756607);
case 50: return (35.218452,-31.922430,112.779381);
case 51: return (36.844032,-35.507500,129.510132);
case 52: return (32.702785,-37.317787,144.294067);
case 53: return (25.874676,-37.231209,155.203186);
case 54: return (19.220631,-36.055214,162.043106);
case 55: return (14.623468,-34.835358,165.574844);
case 56: return (13.005167,-34.338535,166.637924);
case 57: return (14.623468,-34.835358,165.574844);
case 58: return (19.220631,-36.055214,162.043106);
case 59: return (25.874676,-37.231209,155.203186);
case 60: return (32.702785,-37.317787,144.294067);
case 61: return (36.844032,-35.507500,129.510132);
case 62: return (35.218452,-31.922430,112.779381);
case 63: return (26.092154,-27.944633,97.756607);
case 64: return (10.550743,-25.625059,88.594315);
case 65: return (11.523671,-25.625059,89.377007);
case 66: return (12.433942,-25.625059,90.140175);
case 67: return (13.216773,-25.625059,90.780632);
case 68: return (13.731124,-25.625059,91.146439);
case 69: return (13.798976,-25.625059,91.080475);
case 70: return (13.275702,-25.625059,90.526398);
case 71: return (12.136055,-25.625059,89.609062);
case 72: return (10.550743,-25.625059,88.594315);
case 73: return (11.357638,-26.049444,88.062096);
case 74: return (12.058191,-26.473461,87.461250);
case 75: return (12.685979,-26.897097,86.799240);
case 76: return (13.273610,-27.320307,86.071815);
case 77: return (13.849497,-27.743040,85.264442);
case 78: return (14.435575,-28.165281,84.354439);
case 79: return (15.045495,-28.586983,83.313614);
case 80: return (15.684173,-29.008102,82.111084);
case 81: return (16.347893,-29.428616,80.716156);
case 82: return (17.025391,-29.848475,79.100471);
case 83: return (17.699066,-30.267649,77.239861);
case 84: return (18.346830,-30.686106,75.115685);
case 85: return (18.943502,-31.103786,72.715187);
case 86: return (19.462538,-31.520691,70.031868);
case 87: return (19.877052,-31.936758,67.065109);
case 88: return (20.160872,-32.351944,63.819786);
case 89: return (20.289207,-32.766243,60.305462);
case 90: return (20.238892,-33.179600,56.535889);
case 91: return (19.988670,-33.591961,52.528164);
case 92: return (19.519247,-34.003326,48.301979);
case 93: return (18.813028,-34.413635,43.879116);
case 94: return (17.854048,-34.822853,39.282932);
case 95: return (16.627998,-35.230961,34.537640);
case 96: return (15.121819,-35.637917,29.668137);
case 97: return (13.323810,-36.043659,24.699516);
case 98: return (11.223485,-36.448193,19.656912);
case 99: return (8.811488,-36.851460,14.565282);
case 100: return (6.079719,-37.253414,9.449265);
case 101: return (6.079719,-37.253414,9.449265);
case 102: return (9.735432,-36.690304,16.864111);
case 103: return (12.779057,-36.124672,24.189520);
case 104: return (15.238910,-35.556610,31.332911);
case 105: return (17.146130,-34.986233,38.205166);
case 106: return (18.536203,-34.413635,44.724052);
case 107: return (19.450882,-33.838898,50.817692);
case 108: return (19.939890,-33.262146,56.427605);
case 109: return (20.061024,-32.683464,61.511932);
case 110: return (19.879034,-32.102936,66.047585);
case 111: return (19.462538,-31.520691,70.031868);
case 112: return (18.879089,-30.936811,73.482910);
case 113: return (18.189232,-30.351402,76.437859);
case 114: return (17.440340,-29.764555,78.949234);
case 115: return (16.661528,-29.176382,81.078995);
case 116: return (15.860703,-28.586983,82.890877);
case 117: return (15.024531,-27.996447,84.442291);
case 118: return (14.121409,-27.404890,85.776512);
case 119: return (13.107147,-26.812407,86.917046);
case 120: return (11.932463,-26.219090,87.864105);
case 121: return (10.550743,-25.625059,88.594315);
case 122: return (34.947536,-25.625055,82.889099);
case 123: return (34.893436,-25.625055,82.703995);
case 124: return (34.849361,-25.625055,82.555763);
case 125: return (34.824631,-25.625055,82.473572);
case 126: return (34.824631,-25.625055,82.473572);
case 127: return (34.849361,-25.625055,82.555763);
case 128: return (34.893436,-25.625055,82.703995);
case 129: return (34.947536,-25.625055,82.889099);
case 130: return (35.000641,-25.625055,83.074493);
case 131: return (35.042522,-25.625055,83.223373);
case 132: return (35.065475,-25.625055,83.306061);
case 133: return (35.065475,-25.625055,83.306061);
case 134: return (35.042522,-25.625055,83.223373);
case 135: return (35.000641,-25.625055,83.074493);
case 136: return (-6.079729,-37.253414,30.550728);
case 137: return (-6.024272,-37.253414,30.370770);
case 138: return (-5.980495,-37.253414,30.226255);
case 139: return (-5.956468,-37.253414,30.145967);
case 140: return (-5.956468,-37.253414,30.145967);
case 141: return (-5.980495,-37.253414,30.226255);
case 142: return (-6.024272,-37.253414,30.370770);
case 143: return (-6.079729,-37.253414,30.550728);
case 144: return (-6.136128,-37.253414,30.730391);
case 145: return (-6.182050,-37.253414,30.874239);
case 146: return (-6.207794,-37.253414,30.953997);
case 147: return (-6.207794,-37.253414,30.953997);
case 148: return (-6.182050,-37.253414,30.874239);
case 149: return (-6.136128,-37.253414,30.730391);
case 150: return (3.636798,-25.625059,43.836533);
case 151: return (10.550743,-25.625059,88.594315);
case 152: return (13.960647,-25.625057,86.689629);
case 153: return (17.300663,-25.625059,85.141792);
case 154: return (20.575863,-25.625055,83.991272);
case 155: return (23.723089,-25.625057,83.252716);
case 156: return (26.629290,-25.625055,82.886047);
case 157: return (29.174662,-25.625055,82.791473);
case 158: return (31.277334,-25.625051,82.835884);
case 159: return (32.915974,-25.625051,82.899254);
case 160: return (34.121437,-25.625053,82.915947);
case 161: return (34.947536,-25.625055,82.889099);
case 162: return (34.947536,-25.625055,82.889099);
case 163: return (33.927128,-25.625053,82.427269);
case 164: return (32.523663,-25.625051,82.138847);
case 165: return (30.809649,-25.625051,82.114433);
case 166: return (28.841202,-25.625055,82.374840);
case 167: return (26.629290,-25.625055,82.886047);
case 168: return (24.136379,-25.625057,83.596413);
case 169: return (21.300138,-25.625055,84.477867);
case 170: return (18.073446,-25.625059,85.552834);
case 171: return (14.463455,-25.625057,86.893745);
case 172: return (10.550743,-25.625059,88.594315);
case 173: return (10.550743,-25.625059,88.594315);
case 174: return (4.798358,-26.812407,91.148453);
case 175: return (-0.783712,-27.996447,91.513878);
case 176: return (-5.831458,-29.176382,89.808998);
case 177: return (-10.071727,-30.351402,86.171936);
case 178: return (-13.294407,-31.520691,80.715393);
case 179: return (-15.297083,-32.683464,73.521866);
case 180: return (-15.841352,-33.838898,64.685127);
case 181: return (-14.652912,-34.986233,54.371948);
case 182: return (-11.465237,-36.124672,42.863728);
case 183: return (-6.079729,-37.253414,30.550728);
case 184: return (-6.079729,-37.253414,30.550728);
case 185: return (-11.392644,-36.124672,42.353390);
case 186: return (-14.668621,-34.986233,53.530182);
case 187: return (-15.991979,-33.838898,63.849449);
case 188: return (-15.472318,-32.683464,73.022881);
case 189: return (-13.294407,-31.520691,80.715393);
case 190: return (-9.745081,-30.351402,86.596558);
case 191: return (-5.197761,-29.176382,90.407066);
case 192: return (-0.060445,-27.996447,92.006691);
case 193: return (5.289514,-26.812407,91.379677);
case 194: return (10.550743,-25.625059,88.594315);
case 195: return (10.550743,-25.625059,88.594315);
case 196: return (10.595567,-25.625059,88.562012);
case 197: return (10.726473,-25.625059,88.467918);
case 198: return (10.937917,-25.625059,88.316322);
case 199: return (11.224241,-25.625059,88.111992);
case 200: return (11.579644,-25.625059,87.859810);
case 201: return (11.998178,-25.625059,87.564812);
case 202: return (12.473870,-25.625059,87.232155);
case 203: return (13.000642,-25.625059,86.866982);
case 204: return (13.572395,-25.625059,86.474335);
case 205: return (14.183013,-25.625059,86.059196);
case 206: return (14.826390,-25.625059,85.626343);
case 207: return (15.496473,-25.625057,85.180382);
case 208: return (16.187284,-25.625059,84.725670);
case 209: return (16.892912,-25.625057,84.266281);
case 210: return (17.607643,-25.625057,83.806053);
case 211: return (18.325867,-25.625059,83.348503);
case 212: return (19.042208,-25.625057,82.896858);
case 213: return (19.751492,-25.625057,82.454094);
case 214: return (20.448797,-25.625053,82.022827);
case 215: return (21.129465,-25.625053,81.605476);
case 216: return (21.789125,-25.625053,81.204208);
case 217: return (22.423677,-25.625053,80.820900);
case 218: return (23.029306,-25.625053,80.457329);
case 219: return (23.602474,-25.625053,80.115067);
case 220: return (24.139936,-25.625053,79.795547);
case 221: return (24.638651,-25.625051,79.500107);
case 222: return (25.095823,-25.625055,79.230019);
case 223: return (25.508812,-25.625053,78.986519);
case 224: return (25.875103,-25.625053,78.770828);
case 225: return (26.192251,-25.625053,78.584251);
case 226: return (26.457838,-25.625053,78.428070);
case 227: return (26.669338,-25.625053,78.303711);
case 228: return (26.824148,-25.625053,78.212669);
case 229: return (26.919388,-25.625053,78.156662);
case 230: return (26.951893,-25.625053,78.137527);
case 231: return (26.951893,-25.625053,78.137527);
case 232: return (26.919388,-25.625053,78.156662);
case 233: return (26.824148,-25.625053,78.212669);
case 234: return (26.669338,-25.625053,78.303711);
case 235: return (26.457838,-25.625053,78.428070);
case 236: return (26.192251,-25.625053,78.584251);
case 237: return (25.875103,-25.625053,78.770828);
case 238: return (25.508812,-25.625053,78.986519);
case 239: return (25.095823,-25.625055,79.230019);
case 240: return (24.638651,-25.625051,79.500107);
case 241: return (24.139936,-25.625053,79.795547);
case 242: return (23.602474,-25.625053,80.115067);
case 243: return (23.029306,-25.625053,80.457329);
case 244: return (22.423677,-25.625053,80.820900);
case 245: return (21.789125,-25.625053,81.204208);
case 246: return (21.129465,-25.625053,81.605476);
case 247: return (20.448797,-25.625053,82.022827);
case 248: return (19.751492,-25.625057,82.454094);
case 249: return (19.042208,-25.625057,82.896858);
case 250: return (18.325867,-25.625059,83.348503);
case 251: return (17.607643,-25.625057,83.806053);
case 252: return (16.892912,-25.625057,84.266281);
case 253: return (16.187284,-25.625059,84.725670);
case 254: return (15.496473,-25.625057,85.180382);
case 255: return (14.826390,-25.625059,85.626343);
case 256: return (14.183013,-25.625059,86.059196);
case 257: return (13.572395,-25.625059,86.474335);
case 258: return (13.000642,-25.625059,86.866982);
case 259: return (12.473870,-25.625059,87.232155);
case 260: return (11.998178,-25.625059,87.564812);
case 261: return (11.579644,-25.625059,87.859810);
case 262: return (11.224241,-25.625059,88.111992);
case 263: return (10.937917,-25.625059,88.316322);
case 264: return (10.726473,-25.625059,88.467918);
case 265: return (10.595567,-25.625059,88.562012);
case 266: return (10.550743,-25.625059,88.594315);
case 267: return (26.951893,-25.625053,78.137527);
case 268: return (10.550743,-25.625059,88.594315);
case 269: return (10.357614,-25.625059,88.538910);
case 270: return (10.202526,-25.625059,88.495201);
case 271: return (10.116380,-25.625059,88.471230);
case 272: return (10.116380,-25.625059,88.471230);
case 273: return (10.202526,-25.625059,88.495201);
case 274: return (10.357614,-25.625059,88.538910);
case 275: return (10.550743,-25.625059,88.594315);
case 276: return (10.743582,-25.625059,88.650757);
case 277: return (10.897995,-25.625059,88.696754);
case 278: return (10.983609,-25.625059,88.722557);
case 279: return (10.983609,-25.625059,88.722557);
case 280: return (10.897995,-25.625059,88.696754);
case 281: return (10.743582,-25.625059,88.650757);
case 282: return (20.474030,-25.625055,90.371490);
case 283: return (17.740854,-25.625055,89.984268);
case 284: return (16.560425,-25.625057,89.888863);
case 285: return (17.740854,-25.625055,89.984268);
case 286: return (20.474030,-25.625055,90.371490);
case 287: return (23.028120,-25.625055,93.795807);
case 288: return (24.029736,-25.625055,95.271240);
case 289: return (23.028120,-25.625055,93.795807);
case 290: return (28.410280,-25.625055,99.945641);
case 291: return (24.077682,-25.625055,96.638603);
case 292: return (19.660959,-25.625057,94.884148);
case 293: return (17.804840,-25.625055,94.431404);
case 294: return (19.660959,-25.625057,94.884148);
case 295: return (24.077682,-25.625055,96.638603);
case 296: return (28.410280,-25.625055,99.945641);
case 297: return (30.647644,-25.625055,111.780128);
case 298: return (30.955561,-25.625059,120.442368);
case 299: return (30.797678,-25.625057,123.562599);
case 300: return (30.955561,-25.625059,120.442368);
case 301: return (30.647644,-25.625055,111.780128);
case 302: return (10.550743,-25.625059,88.594315);
case 303: return (10.595567,-25.625059,88.562012);
case 304: return (10.726473,-25.625059,88.467918);
case 305: return (10.937917,-25.625059,88.316322);
case 306: return (11.224241,-25.625059,88.111992);
case 307: return (11.579644,-25.625059,87.859810);
case 308: return (11.998178,-25.625059,87.564812);
case 309: return (12.473870,-25.625059,87.232155);
case 310: return (13.000642,-25.625059,86.866982);
case 311: return (13.572395,-25.625059,86.474335);
case 312: return (14.183013,-25.625059,86.059196);
case 313: return (14.826390,-25.625059,85.626343);
case 314: return (15.496473,-25.625057,85.180382);
case 315: return (16.187284,-25.625059,84.725670);
case 316: return (16.892912,-25.625057,84.266281);
case 317: return (17.607643,-25.625057,83.806053);
case 318: return (18.325867,-25.625059,83.348503);
case 319: return (19.042208,-25.625057,82.896858);
case 320: return (19.751492,-25.625057,82.454094);
case 321: return (20.448797,-25.625053,82.022827);
case 322: return (21.129465,-25.625053,81.605476);
case 323: return (21.789125,-25.625053,81.204208);
case 324: return (22.423677,-25.625053,80.820900);
case 325: return (23.029306,-25.625053,80.457329);
case 326: return (23.602474,-25.625053,80.115067);
case 327: return (24.139936,-25.625053,79.795547);
case 328: return (24.638651,-25.625051,79.500107);
case 329: return (25.095823,-25.625055,79.230019);
case 330: return (25.508812,-25.625053,78.986519);
case 331: return (25.875103,-25.625053,78.770828);
case 332: return (26.192251,-25.625053,78.584251);
case 333: return (26.457838,-25.625053,78.428070);
case 334: return (26.669338,-25.625053,78.303711);
case 335: return (26.824148,-25.625053,78.212669);
case 336: return (26.919388,-25.625053,78.156662);
case 337: return (26.951893,-25.625053,78.137527);
case 338: return (26.951893,-25.625053,78.137527);
case 339: return (26.919388,-25.625053,78.156662);
case 340: return (26.824148,-25.625053,78.212669);
case 341: return (26.669338,-25.625053,78.303711);
case 342: return (26.457838,-25.625053,78.428070);
case 343: return (26.192251,-25.625053,78.584251);
case 344: return (25.875103,-25.625053,78.770828);
case 345: return (25.508812,-25.625053,78.986519);
case 346: return (25.095823,-25.625055,79.230019);
case 347: return (24.638651,-25.625051,79.500107);
case 348: return (24.139936,-25.625053,79.795547);
case 349: return (23.602474,-25.625053,80.115067);
case 350: return (23.029306,-25.625053,80.457329);
case 351: return (22.423677,-25.625053,80.820900);
case 352: return (21.789125,-25.625053,81.204208);
case 353: return (21.129465,-25.625053,81.605476);
case 354: return (20.448797,-25.625053,82.022827);
case 355: return (19.751492,-25.625057,82.454094);
case 356: return (19.042208,-25.625057,82.896858);
case 357: return (18.325867,-25.625059,83.348503);
case 358: return (17.607643,-25.625057,83.806053);
case 359: return (16.892912,-25.625057,84.266281);
case 360: return (16.187284,-25.625059,84.725670);
case 361: return (15.496473,-25.625057,85.180382);
case 362: return (14.826390,-25.625059,85.626343);
case 363: return (14.183013,-25.625059,86.059196);
case 364: return (13.572395,-25.625059,86.474335);
case 365: return (13.000642,-25.625059,86.866982);
case 366: return (12.473870,-25.625059,87.232155);
case 367: return (11.998178,-25.625059,87.564812);
case 368: return (11.579644,-25.625059,87.859810);
case 369: return (11.224241,-25.625059,88.111992);
case 370: return (10.937917,-25.625059,88.316322);
case 371: return (10.726473,-25.625059,88.467918);
case 372: return (10.595567,-25.625059,88.562012);
case 373: return (10.550743,-25.625059,88.594315);
case 374: return (26.951893,-25.625053,78.137527);
} return (0,0,0);}}
