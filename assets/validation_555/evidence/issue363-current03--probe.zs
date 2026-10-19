// #363: entrada User2 nativa; la fixture sólo prepara equipo y observa.
class CA363Probe : EventHandler
{
    CaelumPlayer User;
    CaelumEquipmentItem Seal,Item;
    Actor Effect;
    int Passed,Failed,Starts,Stops,LastSealId;
    bool Previous,Observing,Manual;
    double StartAdrenaline,CostSnapshot;

    void Check(bool ok,String label)
    {
        if(ok)Passed++;else Failed++;
        Console.Printf("CA363 %s %s",ok?"PASS":"FAIL",label);
    }
    override void UiTick()
    {
        if(!Manual && Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();
    }
    void Setup()
    {
        User=CaelumPlayer(players[consoleplayer].mo);
        User.InitializeDirectMapCharacter();User.CharacterCreationComplete=true;
        User.CreationWizardOpen=false;User.ApplyCharacterProfile();
        User.bInvulnerable=true;User.bNOTARGET=true;
        User.CurrentSleep=User.CurrentLucidity=100;
        User.CurrentHunger=User.CurrentThirst=75;
        for(Inventory i=User.Inv;i!=null;i=i.Inv)
            if(i is 'CaelumEquipmentItem')CaelumEquipmentItem(i).Equipped=false;
        Seal=CaelumEquipmentItem(Actor.Spawn("CaelumSealPickup",User.Pos,NO_REPLACE));
        Seal.PickupDataInitialized=Seal.AcquisitionResolved=true;
        Seal.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_SEAL;
        Seal.Tier=1;Seal.ItemType=CaelumConstants.SEAL_WATER;
        Seal.Equipped=true;Seal.AttachToOwner(User);User.EnsureEquipmentItemId(Seal);
        LastSealId=Seal.ItemId;Equip(-1);
    }
    void Equip(int kind)
    {
        Observing=false;User.StopSealChannel(false,false);
        User.CombatChannelCooldownRemaining=0;
        if(Item!=null)Item.Equipped=false;
        if(kind<0)
        {
            User.WeaponModel.Equipped=false;User.ActiveWeaponItemId=0;
            User.EnsureUnarmedFallback();
            User.player.PendingWeapon=Weapon(User.FindInventory('CaelumUnarmedWeapon'));
        }
        else
        {
            Item=CaelumEquipmentItem(Actor.Spawn("CaelumWeaponPickup",User.Pos,NO_REPLACE));
            Item.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;Item.ItemType=kind;
            Item.Tier=1;Item.EssenceType=CaelumConstants.ESSENCE_FIRE;
            Item.EquipmentSize=CaelumConstants.EQUIPMENT_SIZE_M;
            Item.Durability=User.WeaponModel.GetMaximumDurabilityFor(kind,1,Item.EquipmentSize);
            Item.UnitWeight=User.WeaponModel.GetWeightFor(kind,1,Item.EquipmentSize);
            Item.WeaponDurabilityRevision=CaelumAttackRules.DURABILITY_REVISION;
            Item.PickupDataInitialized=Item.AcquisitionResolved=Item.Equipped=true;
            Item.AttachToOwner(User);User.EnsureEquipmentItemId(Item);
            User.ActivateExactEquippedWeapon(Item);User.EnsureWeaponFamilySelectors();
            User.SelectNativeWeaponConfiguration(kind,Item.EssenceType,1);
        }
        User.OnNativeInventoryChanged();
        User.CurrentAdrenaline=User.DerivedStats.MaximumAdrenaline;
    }
    void Begin(int mode)
    {
        User.StopSealChannel(false,false);User.CombatChannelCooldownRemaining=0;
        Seal.Equipped=mode!=2;
        User.CurrentAdrenaline=mode==1?0:User.DerivedStats.MaximumAdrenaline;
        User.CombatTimeRemaining=100;
        Starts=Stops=0;Previous=false;Effect=null;
        StartAdrenaline=User.CurrentAdrenaline;Observing=true;
        Console.Printf("CA363 BEGIN weapon=%s mode=%d eligible=%d seal=%d",
            User.player.ReadyWeapon.GetClassName(),mode,User.CanStartSealChannel(),Seal.ItemId);
        Check(User.CanStartSealChannel()==(mode==0),"eligibility agrees with fixture resources and seal");
    }
    override void WorldTick()
    {
        if(!Observing || User==null)return;
        bool active=User.CombatChannelModeActive;
        if(active && !Previous){Starts++;Effect=User.CombatChannelEffectActor;}
        if(!active && Previous)Stops++;
        if(active && Effect!=User.CombatChannelEffectActor)Check(false,"no effect replacement during hold");
        Previous=active;
    }
    void Verify(int expected,int stopCount)
    {
        Console.Printf("CA363 OBSERVED starts=%d stops=%d active=%d adrenaline=%.9f initial=%.9f",
            Starts,Stops,User.CombatChannelModeActive,User.CurrentAdrenaline,StartAdrenaline);
        Check(Starts==expected && Stops==stopCount,"one transition per native press");
        Check(User.CombatChannelModeActive==(expected>stopCount),"channel follows native toggle contract");
        Check(Seal.ItemId==LastSealId && Seal.Owner==User,"exact seal identity retained");
        if(expected>stopCount)
        {
            Check(User.CombatChannelEffectActor==Effect && Effect!=null,"same channel effect retained");
            Check(User.CurrentAdrenaline<StartAdrenaline && User.CurrentAdrenaline>0,"held channel spends finite resources");
            Check(User.CombatChannelSealType==Seal.ItemType && User.CombatChannelSealTier==Seal.Tier,"equipped seal type and tier used");
        }
    }
    void Restored()
    {
        User=CaelumPlayer(players[consoleplayer].mo);
        Check(User.GetEquippedSeal()==Seal && Seal.ItemId==LastSealId,"save keeps exact equipped seal");
        Check(User.player.ReadyWeapon is 'CaelumUnarmedWeapon',"save keeps native unarmed selector");
        Check(User.health>0,"save resumes a live pawn");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="c363_setup")Setup();
        else if(e.Name=="c363_equip")Equip(e.Args[0]);
        else if(e.Name=="c363_begin")Begin(e.Args[0]);
        else if(e.Name=="c363_check")Verify(e.Args[0],e.Args[1]);
        else if(e.Name=="c363_empty"){User.CurrentAdrenaline=0;}
        else if(e.Name=="c363_cost")CostSnapshot=User.CurrentAdrenaline;
        else if(e.Name=="c363_paid")Check(Abs(CostSnapshot-User.CurrentAdrenaline
            -10*User.GetSealChannelAdrenalinePerTic(Seal.Tier))<0.000001,"ten native tics pay exactly ten shared channel costs");
        else if(e.Name=="c363_cooldown")
        {
            Verify(1,1);
            Check(User.CombatChannelCooldownRemaining>0 && !User.CanStartSealChannel(),"cooldown rejects a new native press");
        }
        else if(e.Name=="c363_restored")Restored();
        else if(e.Name=="c363_manual"){Manual=true;}
        else if(e.Name=="c363_done")Console.Printf("CA363 DONE passes=%d failures=%d",Passed,Failed);
    }
}
