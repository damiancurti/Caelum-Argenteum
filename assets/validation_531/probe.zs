// Isolated #256 fixture. Does not ship in src or alter player saves in place.
class CA256Probe : StaticEventHandler
{
    int Failures;
    void Check(bool condition, String name)
    {
        Console.Printf("CA256 %s %s", condition ? "PASS" : "FAIL", name);
        if (!condition) Failures++;
    }
    override void ConsoleProcess(ConsoleEvent e)
    {
        if (e.Name == "c256_metrics")
        {
            let font=Font.GetFont("CaelumSmall");
            Console.Printf("CA256 METRICS height=%d resistance=%.1f thermal=%.1f",
                font.GetHeight(), font.StringWidth(String.Format(StringTable.Localize("CA_CHARACTER_RESIST_FIRE",false),100.0)),
                font.StringWidth(StringTable.Localize("CA_CHARACTER_THERMAL",false)));
        }
    }
    void Equip(CaelumPlayer user,int type,int tier)
    {
        let record=user.GetPersistentCharacterState(true);
        let item=CaelumEquipmentItem(Actor.Spawn("CaelumEquipmentItem"));
        item.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;
        item.ItemType=type;item.Tier=tier;
        item.EquipmentSize=CaelumEquipmentRules.GetDefaultSizeForCharacterTier(user.CharacterProfile.GetSizeTier());
        item.Durability=100000;item.ItemId=record.NextEquipmentItemId++;
        item.AcquisitionResolved=true;item.PickupDataInitialized=true;user.AddInventory(item);
        user.ApplyFormalInventorySelection(item);user.EquipSelectedNativeEquipment();user.ActivateExactEquippedWeapon(item);
        user.RefreshCarriedInventorySummary();
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let user=CaelumPlayer(players[e.Player].mo);
        if(user==null)return;
        if(e.Name=="c256_weapon")
        {
            int mode=e.Args[0];
            if(mode==0)
            {
                let item=user.FindNativeEquipmentItemById(user.ActiveWeaponItemId);
                if(item!=null){user.ApplyFormalInventorySelection(item);user.UnequipSelectedNativeEquipment();}
                user.EnsureUnarmedFallback();
                user.player.PendingWeapon=Weapon(user.FindInventory("CaelumUnarmedWeapon"));
            }
            else Equip(user,mode==1 ? CaelumConstants.WEAPON_TYPE_SWORD
                : mode==2 ? CaelumConstants.WEAPON_TYPE_CARBINE
                : mode==3 ? CaelumConstants.WEAPON_TYPE_STAFF
                : mode==4 ? CaelumConstants.WEAPON_TYPE_UTILITY_STAFF : CaelumConstants.WEAPON_TYPE_BOLAS, mode==2 ? 3 : 1);
        }
        if(e.Name=="c256_chance")
        {
            int mode=e.Args[0];
            bool physical=mode<=2, magical=mode==3 || mode==4;
            Check(user.HUDPhysicalCriticalApplies==physical && user.HUDMagicalCriticalApplies==magical,"attack-category");
            double expected=0;
            if(mode>=1 && mode<=3)
                expected=Clamp(((mode==2 ? 15.0 : 8.0)+Max(0.0,
                    (magical ? user.DerivedStats.MagicalCriticalChance : user.DerivedStats.PhysicalCriticalChance)
                        -CaelumConstants.BASE_CRITICAL_CHANCE_PERCENT))
                    *user.CrouchCriticalChanceMultiplier*CaelumPersonalityRules.Critical(user),0.0,100.0);
            Check(Abs((magical ? user.HUDMagicalCriticalChance : user.HUDPhysicalCriticalChance)-expected)<0.000001,"effective-critical");
            Console.Printf("CA256 CHANCE mode=%d weapon=%d physical=%.6f magical=%.6f evasion=%.6f stance=%.1f resistance=%.6f",
                mode,user.HUDActiveWeaponType,user.HUDPhysicalCriticalChance,user.HUDMagicalCriticalChance,
                Clamp(user.EffectiveEvasionChance,0.0,100.0),user.CrouchCriticalChanceMultiplier,100*(1-user.HUDMagicalDamageFactor));
        }
        if(e.Name=="c256_state")
        {
            int mode=e.Args[0];
            user.CurrentHunger=user.CurrentThirst=user.CurrentSleep=mode==0 ? 100 : mode==1 ? 30 : 5;
            user.UpdateSurvivalStates();
            let thermal=user.GetPersistentCharacterState(true).ThermalState;
            if(thermal!=null)
            {
                thermal.Exposure=mode==0 ? 0 : (mode==3 ? -1 : 1)*CaelumThermalRules.Threshold(2,thermal.Toughness)*1.1;
                thermal.Severity=CaelumThermalRules.Severity(thermal.Exposure,thermal.Toughness);
            }
        }
        if(e.Name=="c256_notices")
        {
            let inbox=CaelumNotifications.Inbox(user);
            int before=inbox.HistoryCount;
            for(int i=0;i<100;i++)CaelumNotifications.Survival(user);
            Check(inbox.SurvivalRevision==1 && inbox.HistoryCount==before,"unchanged-states-do-not-repeat");
            // Read each localized category and recovery from the bounded inbox.
            Console.Printf("CA256 INBOX revision=%d count=%d history=%d states=%d,%d,%d,%d",
                inbox.SurvivalRevision,inbox.Count,inbox.HistoryCount,
                inbox.SurvivalStates[0],inbox.SurvivalStates[1],inbox.SurvivalStates[2],inbox.SurvivalStates[3]);
            for(int i=0;i<inbox.HistoryCount;i++)Console.Printf("CA256 NOTICE %s",inbox.HistoryText[i]);
            int categories[4];
            for(int i=0;i<inbox.Count;i++)
                if(inbox.SurvivalCategory[i]>0)
                {
                    categories[inbox.SurvivalCategory[i]-1]++;
                    Console.Printf("CA256 VISIBLE %s",inbox.Text[i]);
                }
            Check(categories[0]<=1 && categories[1]<=1 && categories[2]<=1 && categories[3]<=1,"one-live-notice-per-resource");
        }
        if(e.Name=="c256_resistance")
        {
            // Controlled asymmetric armor tests the author's mean, not one region.
            int oldType[4],oldTier[4],oldDurability[4];
            for(int slot=0;slot<4;slot++)
            {
                oldType[slot]=user.ArmorModel.ArmorType[slot];oldTier[slot]=user.ArmorModel.Tier[slot];
                oldDurability[slot]=user.ArmorModel.Durability[slot];
                user.ArmorModel.ArmorType[slot]=slot<2 ? CaelumConstants.ARMOR_TYPE_MAGIC : CaelumConstants.ARMOR_TYPE_BASE_CLOTHING;
                user.ArmorModel.Tier[slot]=1;user.ArmorModel.Durability[slot]=slot==0 ? 100 : 0;
            }
            double expected=CaelumArmorRules.InnateDefense(user.CharacterProfile.Race,true)
                +30.0*CaelumPersonalityRules.Absorption(user,true)/4;
            CaelumPlayerPresentation.SyncHUDActiveWeaponState(user);
            Check(Abs(100*(1-user.HUDMagicalDamageFactor)-expected)<0.000001,"mean-four-regions-broken-piece-excluded");
            double before=user.HUDMagicalDamageFactor,oldToughness=user.Attributes.Toughness;
            user.Attributes.Toughness+=100;
            CaelumPlayerPresentation.SyncHUDActiveWeaponState(user);
            Check(Abs(user.HUDMagicalDamageFactor-before)<0.000001,"toughness-does-not-enter-resistance");
            user.Attributes.Toughness=oldToughness;
            for(int slot=0;slot<4;slot++)
            {user.ArmorModel.ArmorType[slot]=oldType[slot];user.ArmorModel.Tier[slot]=oldTier[slot];user.ArmorModel.Durability[slot]=oldDurability[slot];}
            CaelumPlayerPresentation.SyncHUDActiveWeaponState(user);
        }
        if(e.Name=="c256_done")Console.Printf("CA256 DONE failures=%d",Failures);
    }
}
