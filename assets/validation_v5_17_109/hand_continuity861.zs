// Baseline-compatible saved fixture fields; native gameplay remains authoritative.
class CA861HandProbe : EventHandler
{
    CaelumDomingoPilotPlayer User,DeadUser;
    int Checks,Failures,GloveId,GloveType,GloveWear;
    double GloveWeight;
    bool Seeded;
    void Check(bool okay,String label)
    {Checks++;if(!okay)Failures++;Console.Printf("CA836 EDGE %s hands861: %s",okay?"PASS":"FAIL",label);}
    void Select(CaelumEquipmentItem item)
    {User.EquipmentSelectionKind=item.EquipmentKind;User.EquipmentSelectionItemId=item.ItemId;User.RefreshEquipmentSelectionPreview();}
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
            if(armor!=null){Select(armor);User.UnequipSelectedNativeEquipment();}
            Check(User.ArmorModel.ArmorType[slot]==CaelumConstants.ARMOR_TYPE_BASE_CLOTHING,"unsupported armor removed through native equipment operation");
        }
        User.EquipmentMenuOpen=false;User.PersistCharacterState();User.GetPersistentCharacterState(true).ProfileCommitted=true;
    }


    void Seed()
    {
        Setup();if(User==null)return;
        User.CharacterProfile.Sex=SEX861;User.ApplyCharacterProfile();
        let previous=CaelumClothing.Equipped(User,CaelumConstants.ARMOR_SLOT_HANDS);
        if(previous!=null){Select(previous);User.UnequipSelectedNativeEquipment();}
        if(GLOVE861>=0)
        {
            int size=CaelumEquipmentRules.GetDefaultSizeForCharacterTier(User.CharacterProfile.GetSizeTier());
            let item=CaelumClothing.Create(User,GLOVE861,size);item.AttachToOwner(User);User.EnsureEquipmentItemId(item);
            Select(item);User.EquipSelectedNativeEquipment();
            GloveId=item.ItemId;GloveType=item.ItemType;GloveWear=item.Durability;GloveWeight=item.UnitWeight;
        }
        User.EquipmentMenuOpen=false;User.PersistCharacterState();Seeded=true;Loaded();
    }
    void Witness()
    {
        let witness=CA861HandWitness(User.FindInventory('CA861HandWitness'));
        if(witness==null && Seeded)
        {
            witness=CA861HandWitness(Actor.Spawn('CA861HandWitness',User.Pos,NO_REPLACE));witness.AttachToOwner(User);
            witness.Identity=GloveId;witness.Kind=GloveType;witness.Wear=GloveWear;witness.Weight=GloveWeight;
        }
        else if(witness!=null && !Seeded)
        {
            GloveId=witness.Identity;GloveType=witness.Kind;GloveWear=witness.Wear;GloveWeight=witness.Weight;Seeded=true;
        }
    }
    void Loaded()
    {
        User=CaelumDomingoPilotPlayer(players[0].mo);
        if(User!=null)Witness();
        Check(User!=null && Seeded,"actual player and saved fixture survive");if(User==null)return;
        let item=CaelumClothing.Equipped(User,CaelumConstants.ARMOR_SLOT_HANDS);
        Check(GloveId==0?item==null:item!=null && item.Owner==User && item.ItemId==GloveId
            && item.ItemType==GloveType && item.Durability==GloveWear && item.UnitWeight==GloveWeight,"native saved glove identity and data remain intact");
        bool wanted=EXPECTED861 && GloveId>0;
        Check(CaelumAppearanceHands.HasGloves(User)==wanted,"current build selects its documented glove scope");
        int expected=wanted?(User.CharacterProfile.Sex==1?36:-1):User.CharacterProfile.Sex==1?18:0;
        Check(CaelumAppearanceHands.Variant(User)==expected,"saved sex and actual glove choose the expected existing art");
        CaelumAppearance.Apply(User);Check(User.AppearanceHasGloves==wanted,"world and preview flag share actual selection");
        // CACHE861
    }
    void Dead()
    {
        User=DeadUser!=null?DeadUser:CaelumDomingoPilotPlayer(players[0].mo);
        Check(User!=null && User.health<=0,"native player remains dead");if(User==null)return;
        Check(User.AppearanceDeathProfile!=null && User.AppearanceDeathGloves==(DEATH_SNAPSHOT861 && GloveId>0),"death snapshot retains the actual pre-death glove selection");
        CaelumAppearance.Apply(User);Check(User.AppearanceHasGloves==User.AppearanceDeathGloves,"corpse uses saved appearance after equipment cleanup");
    }
    void Pose(int expected)
    {
        bool attacking=User.AttackAnimationDurationTics>0
            && level.time-User.AttackAnimationStartTic<User.AttackAnimationDurationTics
            && User.AttackAnimationItemId==User.ActiveWeaponItemId;
        Check(expected==1?attacking:!attacking,"capture agrees with native attack timer");
        Check(User.CombatBlockModeActive==(expected==2),"capture agrees with native block mode");
        let hand=User.player.FindPSprite(52);
        if(expected==2)
        {
            Check(hand==null,"native frontal shield guard clears the sword hand layer");
            let shield=User.player.FindPSprite(CaelumFirstPersonShield.BODY_LAYER);
            let left=User.player.FindPSprite(CaelumFirstPersonShield.HAND_LAYER);
            Check(shield!=null && shield.CurState==CaelumFirstPersonShield.Pose("Buckler","Hold"),"native guard renders the actual buckler hold");
            Check(left!=null && left.CurState==CaelumAppearanceHands.Resolve(User,"Shield_Hold",CaelumFirstPersonShield.Pose("Hand","Hold")),"native guard left hand uses actual current glove selection");
            Check(User.HasActiveBlockSource(),"native guard retains its actual shield");
        }
        else Check(hand!=null && hand.CurState==CaelumAppearanceHands.Hand(User,0),"rendered sword hand uses actual current glove selection");
        Console.Printf("CA861 POSE tic=%d expected=%d attack=%d block=%d variant=%d",level.time,expected,attacking,User.CombatBlockModeActive,CaelumAppearanceHands.Variant(User));
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=='ca861seed')Seed();
        if(e.Name=='ca861loaded')Loaded();
        if(e.Name=='ca861pose')Pose(e.Args[0]);
        if(e.Name=='ca861kill')
        {DeadUser=User;User.bInvulnerable=false;User.DamageMobj(User,User,10000000,'CaelumPhysicalTest',DMG_FORCED,0);}
        if(e.Name=='ca861dead')Dead();
        if(e.Name=='ca861done')Console.Printf("CA836 EDGE_RESULT checks=%d failures=%d result=%s",Checks,Failures,Failures==0?"PASS":"FAIL");
    }
}
class CA861HandWitness : Inventory
{
    int Identity,Kind,Wear;double Weight;
    Default { Inventory.MaxAmount 1; Inventory.InterHubAmount 1; +INVENTORY.UNDROPPABLE -INVENTORY.INVBAR }
}
