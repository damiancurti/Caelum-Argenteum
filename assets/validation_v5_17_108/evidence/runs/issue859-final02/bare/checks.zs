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
        double yaw=Subject.Angle+Side*45;double distance=Detail!=0?75:130;double height=Detail!=0?.47:.48;
        SetOrigin(Subject.Pos+(Cos(yaw)*distance,Sin(yaw)*distance,(Subject.health<=0?35:Subject.Height*height)),false);
        Angle=AngleTo(Subject);Pitch=Subject.health<=0?10:0;
    }
    Default { +NOBLOCKMAP +NOINTERACTION +NOGRAVITY }
}
class CA857Witness : Inventory
{
    int Ids[4],Wear[4];double Weights[4];
    Default { Inventory.MaxAmount 1; Inventory.InterHubAmount 1; +INVENTORY.UNDROPPABLE -INVENTORY.INVBAR }
}
