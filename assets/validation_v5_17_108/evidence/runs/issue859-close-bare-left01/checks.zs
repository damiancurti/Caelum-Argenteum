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
case 0: return (5.499998,26.799995,82.300011);
case 1: return (5.273566,26.799995,82.271461);
case 2: return (5.091894,26.799995,82.249435);
case 3: return (4.991024,26.799995,82.237534);
case 4: return (4.991024,26.799995,82.237534);
case 5: return (5.091894,26.799995,82.249435);
case 6: return (5.273566,26.799995,82.271461);
case 7: return (5.499998,26.799995,82.300011);
case 8: return (5.726272,26.799995,82.329773);
case 9: return (5.907600,26.799995,82.354500);
case 10: return (6.008191,26.799995,82.368553);
case 11: return (6.008191,26.799995,82.368553);
case 12: return (5.907600,26.799995,82.354500);
case 13: return (5.726272,26.799995,82.329773);
case 14: return (19.247112,26.799990,82.395088);
case 15: return (21.961121,26.799990,85.354332);
case 16: return (23.049726,26.799994,86.628960);
case 17: return (21.961121,26.799990,85.354332);
case 18: return (19.247112,26.799990,82.395088);
case 19: return (16.421183,26.799988,82.438316);
case 20: return (15.220790,26.799992,82.509163);
case 21: return (16.421183,26.799988,82.438316);
case 22: return (32.952854,26.799992,93.275307);
case 23: return (36.779587,26.799992,106.208313);
case 24: return (38.084763,26.799995,115.918945);
case 25: return (38.246750,26.799994,119.469223);
case 26: return (38.084763,26.799995,115.918945);
case 27: return (36.779587,26.799992,106.208313);
case 28: return (32.952854,26.799992,93.275307);
case 29: return (26.874992,26.799988,89.285690);
case 30: return (21.148468,26.799992,87.297852);
case 31: return (18.815874,26.799994,86.814270);
case 32: return (21.148468,26.799992,87.297852);
case 33: return (26.874992,26.799988,89.285690);
case 34: return (5.499998,26.799995,82.300011);
case 35: return (14.016714,25.561592,83.289902);
case 36: return (21.742813,23.121353,84.867203);
case 37: return (28.189152,19.959471,86.794403);
case 38: return (33.113216,16.682995,88.760948);
case 39: return (36.494362,13.878645,90.446320);
case 40: return (38.439674,12.006857,91.578255);
case 41: return (39.071087,11.351377,91.976509);
case 42: return (38.439674,12.006857,91.578255);
case 43: return (36.494362,13.878645,90.446320);
case 44: return (33.113216,16.682995,88.760948);
case 45: return (28.189152,19.959471,86.794403);
case 46: return (21.742813,23.121353,84.867203);
case 47: return (14.016714,25.561592,83.289902);
case 48: return (5.499998,26.799995,82.300011);
case 49: return (12.982927,25.789551,83.130348);
case 50: return (19.916168,23.821190,84.429092);
case 51: return (25.942661,21.192184,86.049538);
case 52: return (30.847076,18.296898,87.793304);
case 53: return (34.557789,15.547794,89.442131);
case 54: return (37.109978,13.308990,90.790070);
case 55: return (38.588474,11.854646,91.670639);
case 56: return (39.071087,11.351377,91.976509);
case 57: return (38.588474,11.854646,91.670639);
case 58: return (37.109978,13.308990,90.790070);
case 59: return (34.557789,15.547794,89.442131);
case 60: return (30.847076,18.296898,87.793304);
case 61: return (25.942661,21.192184,86.049538);
case 62: return (19.916168,23.821190,84.429092);
case 63: return (12.982927,25.789551,83.130348);
case 64: return (5.499998,26.799995,82.300011);
case 65: return (6.935556,26.799995,82.737907);
case 66: return (8.282381,26.799995,83.219704);
case 67: return (9.409018,26.799995,83.665215);
case 68: return (10.099401,26.799995,83.939568);
case 69: return (10.114721,26.799995,83.900322);
case 70: return (9.294463,26.799995,83.506569);
case 71: return (7.663325,26.799995,82.891701);
case 72: return (5.499998,26.799995,82.300011);
case 73: return (5.605480,27.283178,82.414154);
case 74: return (5.690921,27.765886,82.532135);
case 75: return (5.800059,28.248102,82.643791);
case 76: return (5.971200,28.729771,82.725624);
case 77: return (6.233805,29.210842,82.743416);
case 78: return (6.606542,29.691290,82.655540);
case 79: return (7.095972,30.171072,82.416679);
case 80: return (7.696952,30.650122,81.981354);
case 81: return (8.393648,31.128431,81.307220);
case 82: return (9.161551,31.605938,80.357460);
case 83: return (9.969566,32.082600,79.102509);
case 84: return (10.782623,32.558388,77.521118);
case 85: return (11.563648,33.033241,75.600258);
case 86: return (12.275626,33.507141,73.335060);
case 87: return (12.882952,33.980042,70.727951);
case 88: return (13.352510,34.451874,67.787788);
case 89: return (13.654237,34.922634,64.528709);
case 90: return (13.761415,35.392265,60.969292);
case 91: return (13.650650,35.860714,57.131523);
case 92: return (13.301758,36.327957,53.039875);
case 93: return (12.697355,36.793961,48.720753);
case 94: return (11.822502,37.258648,44.201881);
case 95: return (10.664585,37.722012,39.511665);
case 96: return (9.212728,38.184010,34.678989);
case 97: return (7.457787,38.644566,29.732784);
case 98: return (5.392080,39.103699,24.701885);
case 99: return (3.009183,39.561317,19.614904);
case 100: return (0.303981,40.017399,14.500010);
case 101: return (0.303981,40.017399,14.500010);
case 102: return (3.960243,39.378456,21.956242);
case 103: return (6.993468,38.736519,29.309490);
case 104: return (9.419995,38.091713,36.453693);
case 105: return (11.260113,37.444157,43.286728);
case 106: return (12.540640,36.793961,49.713661);
case 107: return (13.298082,36.141209,55.649998);
case 108: return (13.581416,35.486046,61.024651);
case 109: return (13.453219,34.828583,65.783241);
case 110: return (12.989224,34.168896,69.890915);
case 111: return (12.275626,33.507141,73.335060);
case 112: return (11.403738,32.843418,76.127266);
case 113: return (10.463132,32.177837,78.303375);
case 114: return (9.533701,31.510498,79.921638);
case 115: return (8.678068,30.841545,81.058197);
case 116: return (7.935468,30.171072,81.800011);
case 117: return (7.318387,29.499187,82.236389);
case 118: return (6.812460,28.826031,82.449593);
case 119: return (6.379555,28.151705,82.506317);
case 120: return (5.963943,27.476311,82.450706);
case 121: return (5.499998,26.799995,82.300011);
case 122: return (39.134789,26.799994,75.990181);
case 123: return (39.044064,26.799994,75.782959);
case 124: return (38.970520,26.799994,75.617149);
case 125: return (38.929413,26.799994,75.525269);
case 126: return (38.929413,26.799994,75.525269);
case 127: return (38.970520,26.799994,75.617149);
case 128: return (39.044064,26.799994,75.782959);
case 129: return (39.134789,26.799994,75.990181);
case 130: return (39.224407,26.799994,76.197861);
case 131: return (39.295464,26.799994,76.364754);
case 132: return (39.334606,26.799994,76.457504);
case 133: return (39.334606,26.799994,76.457504);
case 134: return (39.295464,26.799994,76.364754);
case 135: return (39.224407,26.799994,76.197861);
case 136: return (-0.303982,40.017399,25.499985);
case 137: return (-0.275400,40.017399,25.289478);
case 138: return (-0.253260,40.017399,25.120575);
case 139: return (-0.241293,40.017399,25.026791);
case 140: return (-0.241293,40.017399,25.026791);
case 141: return (-0.253260,40.017399,25.120575);
case 142: return (-0.275400,40.017399,25.289478);
case 143: return (-0.303982,40.017399,25.499985);
case 144: return (-0.333704,40.017399,25.710333);
case 145: return (-0.358328,40.017399,25.878895);
case 146: return (-0.372319,40.017399,25.972397);
case 147: return (-0.372319,40.017399,25.972397);
case 148: return (-0.358328,40.017399,25.878895);
case 149: return (-0.333704,40.017399,25.710333);
case 150: return (-3.404056,26.799995,39.892609);
case 151: return (5.499998,26.799995,82.300011);
case 152: return (9.665455,26.799994,79.857391);
case 153: return (13.837744,26.799992,77.852318);
case 154: return (18.027121,26.799994,76.334114);
case 155: return (22.161640,26.799994,75.335014);
case 156: return (26.102232,26.799992,74.833069);
case 157: return (29.690779,26.799988,74.737785);
case 158: return (32.806293,26.799988,74.911827);
case 159: return (35.399227,26.799990,75.220604);
case 160: return (37.489456,26.799992,75.582153);
case 161: return (39.134789,26.799994,75.990181);
case 162: return (39.134789,26.799994,75.990181);
case 163: return (37.189476,26.799992,75.045860);
case 164: return (34.827820,26.799990,74.404579);
case 165: return (32.154064,26.799988,74.156990);
case 166: return (29.241608,26.799988,74.314575);
case 167: return (26.102232,26.799992,74.833069);
case 168: return (22.688810,26.799994,75.657089);
case 169: return (18.930008,26.799994,76.763542);
case 170: return (14.780847,26.799992,78.184853);
case 171: return (10.266832,26.799994,80.000526);
case 172: return (5.499998,26.799995,82.300011);
case 173: return (5.499998,26.799995,82.300011);
case 174: return (0.739314,28.151705,84.203011);
case 175: return (-3.750596,29.499187,84.067543);
case 176: return (-7.615348,30.841545,82.027374);
case 177: return (-10.607587,32.177837,78.241875);
case 178: return (-12.561592,33.507141,72.839752);
case 179: return (-13.330260,34.828583,65.903534);
case 180: return (-12.727167,36.141209,57.508083);
case 181: return (-10.513812,37.444157,47.788998);
case 182: return (-6.438961,38.736519,36.996571);
case 183: return (-0.303982,40.017399,25.499985);
case 184: return (-0.303982,40.017399,25.499985);
case 185: return (-6.451140,38.736519,36.414658);
case 186: return (-10.683611,37.444157,46.852829);
case 187: return (-13.045414,36.141209,56.601974);
case 188: return (-13.615116,34.828583,65.377090);
case 189: return (-12.561592,33.507141,72.839752);
case 190: return (-10.166987,32.177837,78.659622);
case 191: return (-6.800357,30.841545,82.586082);
case 192: return (-2.853504,29.499187,84.493408);
case 193: return (1.330636,28.151705,84.376648);
case 194: return (5.499998,26.799995,82.300011);
case 195: return (5.499998,26.799995,82.300011);
case 196: return (5.553535,26.799995,82.260742);
case 197: return (5.709959,26.799992,82.146286);
case 198: return (5.962867,26.799994,81.962021);
case 199: return (6.305812,26.799992,81.713768);
case 200: return (6.732254,26.799995,81.407593);
case 201: return (7.235526,26.799994,81.049789);
case 202: return (7.808981,26.799994,80.646790);
case 203: return (8.445822,26.799992,80.205002);
case 204: return (9.139227,26.799992,79.730789);
case 205: return (9.882307,26.799992,79.230415);
case 206: return (10.668139,26.799995,78.709892);
case 207: return (11.489810,26.799992,78.175034);
case 208: return (12.340396,26.799992,77.631332);
case 209: return (13.212977,26.799992,77.083916);
case 210: return (14.100779,26.799994,76.537628);
case 211: return (14.997046,26.799992,75.996826);
case 212: return (15.895204,26.799994,75.465538);
case 213: return (16.788797,26.799992,74.947372);
case 214: return (17.671637,26.799994,74.445534);
case 215: return (18.537651,26.799994,73.962776);
case 216: return (19.381092,26.799994,73.501633);
case 217: return (20.196426,26.799992,73.064125);
case 218: return (20.978401,26.799994,72.652069);
case 219: return (21.722006,26.799992,72.267006);
case 220: return (22.422535,26.799992,71.910187);
case 221: return (23.075480,26.799992,71.582748);
case 222: return (23.676586,26.799994,71.285576);
case 223: return (24.221794,26.799992,71.019608);
case 224: return (24.707109,26.799990,70.785599);
case 225: return (25.128736,26.799986,70.584435);
case 226: return (25.482830,26.799988,70.416977);
case 227: return (25.765507,26.799986,70.284279);
case 228: return (25.972786,26.799994,70.187492);
case 229: return (26.100485,26.799990,70.128113);
case 230: return (26.144104,26.799990,70.107857);
case 231: return (26.144104,26.799990,70.107857);
case 232: return (26.100485,26.799990,70.128113);
case 233: return (25.972786,26.799994,70.187492);
case 234: return (25.765507,26.799986,70.284279);
case 235: return (25.482830,26.799988,70.416977);
case 236: return (25.128736,26.799986,70.584435);
case 237: return (24.707109,26.799990,70.785599);
case 238: return (24.221794,26.799992,71.019608);
case 239: return (23.676586,26.799994,71.285576);
case 240: return (23.075480,26.799992,71.582748);
case 241: return (22.422535,26.799992,71.910187);
case 242: return (21.722006,26.799992,72.267006);
case 243: return (20.978401,26.799994,72.652069);
case 244: return (20.196426,26.799992,73.064125);
case 245: return (19.381092,26.799994,73.501633);
case 246: return (18.537651,26.799994,73.962776);
case 247: return (17.671637,26.799994,74.445534);
case 248: return (16.788797,26.799992,74.947372);
case 249: return (15.895204,26.799994,75.465538);
case 250: return (14.997046,26.799992,75.996826);
case 251: return (14.100779,26.799994,76.537628);
case 252: return (13.212977,26.799992,77.083916);
case 253: return (12.340396,26.799992,77.631332);
case 254: return (11.489810,26.799992,78.175034);
case 255: return (10.668139,26.799995,78.709892);
case 256: return (9.882307,26.799992,79.230415);
case 257: return (9.139227,26.799992,79.730789);
case 258: return (8.445822,26.799992,80.205002);
case 259: return (7.808981,26.799994,80.646790);
case 260: return (7.235526,26.799994,81.049789);
case 261: return (6.732254,26.799995,81.407593);
case 262: return (6.305812,26.799992,81.713768);
case 263: return (5.962867,26.799994,81.962021);
case 264: return (5.709959,26.799992,82.146286);
case 265: return (5.553535,26.799995,82.260742);
case 266: return (5.499998,26.799995,82.300011);
case 267: return (26.144104,26.799990,70.107857);
case 268: return (46.207348,26.799999,138.129700);
case 269: return (46.276291,26.799999,137.884583);
case 270: return (46.330643,26.799999,137.687744);
case 271: return (46.360447,26.799999,137.578400);
case 272: return (46.360447,26.799999,137.578400);
case 273: return (46.330643,26.799999,137.687744);
case 274: return (46.276291,26.799999,137.884583);
case 275: return (46.207348,26.799999,138.129700);
case 276: return (46.137108,26.799999,138.374451);
case 277: return (46.079826,26.799999,138.570450);
case 278: return (46.047688,26.799999,138.679123);
case 279: return (46.047688,26.799999,138.679123);
case 280: return (46.079826,26.799999,138.570450);
case 281: return (46.137108,26.799999,138.374451);
case 282: return (46.207348,26.799999,132.129700);
case 283: return (46.319046,26.799999,133.144241);
case 284: return (46.364311,26.799999,133.564209);
case 285: return (46.319046,26.799999,133.144241);
case 286: return (46.207348,26.799999,132.129700);
case 287: return (46.092190,26.799999,133.942596);
case 288: return (46.043495,26.799999,134.693237);
case 289: return (46.092190,26.799999,133.942596);
case 290: return (46.207348,26.799999,124.129692);
case 291: return (46.286686,26.800001,127.847183);
case 292: return (46.343670,26.799999,130.568268);
case 293: return (46.364311,26.799999,131.564209);
case 294: return (46.343670,26.799999,130.568268);
case 295: return (46.286686,26.800001,127.847183);
case 296: return (46.207348,26.799999,124.129692);
case 297: return (46.126274,26.799999,128.411713);
case 298: return (46.065842,26.799999,131.546051);
case 299: return (46.043495,26.800001,132.693222);
case 300: return (46.065842,26.799999,131.546051);
case 301: return (46.126274,26.799999,128.411713);
case 302: return (46.207348,26.799999,138.129700);
case 303: return (46.219841,26.799999,138.066605);
case 304: return (46.256329,26.799999,137.882233);
case 305: return (46.315247,26.799999,137.583817);
case 306: return (46.394966,26.799999,137.178650);
case 307: return (46.493858,26.799999,136.673920);
case 308: return (46.610222,26.799999,136.076782);
case 309: return (46.742359,26.799999,135.394440);
case 310: return (46.888588,26.799999,134.634109);
case 311: return (47.047180,26.799999,133.802933);
case 312: return (47.216469,26.799999,132.908142);
case 313: return (47.394775,26.799999,131.956955);
case 314: return (47.580467,26.799999,130.956589);
case 315: return (47.771912,26.799997,129.914337);
case 316: return (47.967609,26.799999,128.837463);
case 317: return (48.165985,26.799999,127.733337);
case 318: return (48.365593,26.799999,126.609314);
case 319: return (48.565002,26.799999,125.472794);
case 320: return (48.762894,26.799997,124.331215);
case 321: return (48.957916,26.799999,123.192055);
case 322: return (49.148880,26.799999,122.062790);
case 323: return (49.334557,26.799999,120.951012);
case 324: return (49.513832,26.799999,119.864243);
case 325: return (49.685608,26.799999,118.810066);
case 326: return (49.848877,26.799999,117.796173);
case 327: return (50.002682,26.799999,116.830154);
case 328: return (50.146027,26.799999,115.919701);
case 329: return (50.278061,26.800001,115.072487);
case 330: return (50.397850,26.799999,114.296181);
case 331: return (50.504562,26.799999,113.598480);
case 332: return (50.597321,26.799999,112.987099);
case 333: return (50.675308,26.799999,112.469711);
case 334: return (50.737587,26.799999,112.054001);
case 335: return (50.783295,26.799999,111.747620);
case 336: return (50.811474,26.799999,111.558212);
case 337: return (50.821072,26.799999,111.493385);
case 338: return (50.821072,26.799999,111.493385);
case 339: return (50.811474,26.799999,111.558212);
case 340: return (50.783295,26.799999,111.747620);
case 341: return (50.737587,26.799999,112.054001);
case 342: return (50.675308,26.799999,112.469711);
case 343: return (50.597321,26.799999,112.987099);
case 344: return (50.504562,26.799999,113.598480);
case 345: return (50.397850,26.799999,114.296181);
case 346: return (50.278061,26.800001,115.072487);
case 347: return (50.146027,26.799999,115.919701);
case 348: return (50.002682,26.799999,116.830154);
case 349: return (49.848877,26.799999,117.796173);
case 350: return (49.685608,26.799999,118.810066);
case 351: return (49.513832,26.799999,119.864243);
case 352: return (49.334557,26.799999,120.951012);
case 353: return (49.148880,26.799999,122.062790);
case 354: return (48.957916,26.799999,123.192055);
case 355: return (48.762894,26.799997,124.331215);
case 356: return (48.565002,26.799999,125.472794);
case 357: return (48.365593,26.799999,126.609314);
case 358: return (48.165985,26.799999,127.733337);
case 359: return (47.967609,26.799999,128.837463);
case 360: return (47.771912,26.799997,129.914337);
case 361: return (47.580467,26.799999,130.956589);
case 362: return (47.394775,26.799999,131.956955);
case 363: return (47.216469,26.799999,132.908142);
case 364: return (47.047180,26.799999,133.802933);
case 365: return (46.888588,26.799999,134.634109);
case 366: return (46.742359,26.799999,135.394440);
case 367: return (46.610222,26.799999,136.076782);
case 368: return (46.493858,26.799999,136.673920);
case 369: return (46.394966,26.799999,137.178650);
case 370: return (46.315247,26.799999,137.583817);
case 371: return (46.256329,26.799999,137.882233);
case 372: return (46.219841,26.799999,138.066605);
case 373: return (46.207348,26.799999,138.129700);
case 374: return (50.821072,26.799999,111.493385);
} return (0,0,0);}}
