// Guardado e interacción aislados: compatible también con el paquete anterior.
class CA261Session : EventHandler
{
    Array<CaelumEquipmentItem> Seals;
    int Choice;
    bool Ready;
    override void UiTick(){if(!Ready && Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    void Select(CaelumPlayer user)
    {
        let old=user.GetEquippedSeal();
        if(old!=null)
        {
            user.EquipmentSelectionKind=CaelumConstants.EQUIPMENT_KIND_SEAL;
            user.EquipmentSelectionItemId=old.ItemId;
            user.RefreshEquipmentSelectionPreview();user.UnequipSelectedNativeEquipment();
        }
        if(Choice<5)
        {
            let seal=Seals[Choice];
            user.EquipmentSelectionKind=CaelumConstants.EQUIPMENT_KIND_SEAL;
            user.EquipmentSelectionItemId=seal.ItemId;
            user.EquipmentSelectionSealType=seal.ItemType;
            user.EquipmentSelectionTier=seal.Tier;
            user.RefreshEquipmentSelectionPreview();user.EquipSelectedNativeEquipment();
            if(user.GetEquippedSeal()!=seal)Console.Printf("CA261 FAIL native seal equip");
        }
        else if(user.GetEquippedSeal()!=null)Console.Printf("CA261 FAIL native seal removal");
        user.EquipmentMenuOpen=false;user.SyncHUDActiveWeaponState();
        Console.Printf("CA261 SESSION selection=%d equipped=%d",Choice,user.GetEquippedSeal()!=null);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let user=CaelumPlayer(players[e.Player].mo);if(user==null)return;
        if(e.Name=="c261_seed")
        {
            user.CreationWizardOpen=false;user.CharacterCreationComplete=true;user.ApplyCharacterProfile();
            for(int i=0;i<5;i++)
            {
                let seal=CaelumEquipmentItem(Actor.Spawn("CaelumSealPickup",user.Pos,NO_REPLACE));
                seal.PickupDataInitialized=true;seal.AcquisitionResolved=true;
                seal.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_SEAL;seal.ItemType=i;seal.Tier=i%3+1;
                seal.EquipmentSize=CaelumConstants.EQUIPMENT_SIZE_M;
                seal.AttachToOwner(user);user.EnsureEquipmentItemId(seal);Seals.Push(seal);
            }
            Ready=true;Choice=0;Select(user);user.PersistCharacterState();
            user.ElementalStatus.ApplyDamageOverTime(CaelumConstants.ELEMENTAL_EFFECT_BURN,1000,1,1,null,user);
            Console.Printf("CA261 DONE failures=0 session seeded");
        }
        if(e.Name=="c261_cycle" && Ready){Choice=(Choice+1)%6;Select(user);}
        if(e.Name=="c261_details" && Ready)user.EquipmentMenuOpen=true;
        if(e.Name=="c261_verify" || e.Name=="c261_verify_old" || e.Name=="c261_travel_verify")
        {
            bool legacy=e.Name=="c261_verify_old";
            bool inventory=Ready && Seals.Size()==5 && user.GetEquippedSeal()==Seals[0]
                && Seals[0].Owner==user && Seals[0].Equipped;
            if(e.Name=="c261_travel_verify")
            {
                int count=0;
                for(Inventory item=user.Inv;item!=null;item=item.Inv)
                    if(item is "CaelumEquipmentItem" && CaelumEquipmentItem(item).EquipmentKind==CaelumConstants.EQUIPMENT_KIND_SEAL)count++;
                inventory=count==5 && user.GetEquippedSeal()!=null && user.GetEquippedSeal().ItemType==0;
            }
            user.bInvulnerable=false;user.health=100000;user.player.health=user.health;
            user.ApplyNativeHealthDamage(null,null,1000,'Fire',DMG_NO_ARMOR,0);
            bool dose=user.ElementalStatus.BurnRemaining>0 && user.ElementalStatus.BurnRemaining<1000
                && user.ElementalStatus.BurnDamagePerSecond==1;
            bool ok=inventory && dose && user.health==100000-(legacy?1000:500);
            Console.Printf("CA261 %s inventory=%d dose=%d HP=%d burn=%.4f fraction=%.4f",
                ok?"PASS":"FAIL",inventory,dose,user.health,user.ElementalStatus.BurnRemaining,user.ElementalStatus.HealthFraction[0]);
            Console.Printf("CA261 DONE failures=%d",ok?0:1);
        }
    }
}
