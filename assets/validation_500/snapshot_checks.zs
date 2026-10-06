// Pruebas aisladas de los contratos de proyección; no se empaquetan en src.
class CA116SnapshotChecks : EventHandler
{
    int Checks, Failures;
    bool Done;
    bool ReloadChecked;
    void Check(bool passed, String label)
    {
        Checks++;
        if (!passed) { Failures++; Console.Printf("CA116 FAIL %s", label); }
    }
    void Refresh(CaelumPlayer user)
    {
        user.RefreshSocialJournalSnapshot();
        user.SyncHUDActiveWeaponState();
        user.SyncHUDLoadState();
    }
    CaelumEquipmentItem Item(CaelumPlayer user, int kind, int type)
    {
        let item = CaelumEquipmentItem(Actor.Spawn("CaelumEquipmentItem", user.Pos));
        item.EquipmentKind=kind; item.ItemType=type; item.Tier=1;
        item.EquipmentSize=CaelumConstants.EQUIPMENT_SIZE_M;
        item.Durability=1; item.Equipped=true; item.PickupDataInitialized=true;
        item.AttachToOwner(user); user.EnsureEquipmentItemId(item);
        return item;
    }
    void Run(CaelumPlayer user)
    {
        let record=user.GetPersistentCharacterState(true);
        Refresh(user);
        Check(!user.HUDHasActiveWeapon, "fresh unarmed");
        Check(user.HUDRangedMagazineCount==0 && user.HUDRangedReserveCount==0, "unarmed ammunition hidden");
        Check(user.HUDCarriedWeight==user.DerivedStats.CarriedWeight && user.HUDLoadRatio==user.DerivedStats.LoadRatio, "load projection");
        let derived=user.DerivedStats; user.DerivedStats=null;
        user.SyncHUDLoadState(); user.RefreshSocialJournalSnapshot();
        Check(user.HUDCarriedWeight==0 && user.HUDCarryCapacity==0 && user.HUDLoadRatio==0, "missing derived stats");
        Check(user.MainM00LoadAirFactorSnapshot==1, "missing load air factor");
        user.DerivedStats=derived;

        record.EnsureQuestStateInitialized(); record.EnsureFactionStateInitialized();
        for(int i=0;i<CaelumConstants.FACTION_COUNT;i++)
        { record.FactionMember[i]=(i%2==0); record.FactionReputation[i]=i; }
        record.MainM00SwimLessonStarted=true; record.MainM00SwimLessonComplete=false;
        record.MainM00ArmorCrafted[0]=true; record.MainM00ArmorCrafted[1]=false;
        record.MainM00ArmorCrafted[2]=true; record.MainM00ArmorCrafted[3]=false;
        record.TarotOwned[CaelumConstants.TAROT_THE_FOOL]=true;
        record.TarotOwned[CaelumSewerMaze.CUPS_ACE]=true;
        CaelumTarotPowers.EnsureRevision(record);
        record.TarotSelected[CaelumConstants.TAROT_THE_FOOL]=true;
        record.TarotEffectTics=35; record.TarotCooldownTics=70;
        user.RefreshSocialJournalSnapshot();
        Check(user.MainM00ArmorPiecesSnapshot==2, "armor completion count");
        Check(user.MainM00SwimLessonStartedSnapshot && !user.MainM00SwimLessonCompleteSnapshot, "lesson facts");
        Check(user.TarotFoolOwnedSnapshot && user.TarotCupsAceOwnedSnapshot && user.TarotOwnedCountSnapshot==2, "owned Tarot projection");
        Check(user.TarotSelectedSnapshot[CaelumConstants.TAROT_THE_FOOL], "selected Tarot projection");
        for(int i=0;i<CaelumConstants.FACTION_COUNT;i++)
            Check(user.JournalFactionMember[i]==record.FactionMember[i] && user.JournalFactionReputation[i]==i, "faction row");
        for(int i=0;i<CaelumConstants.QUEST_DEFINED_COUNT;i++)
            Check(user.JournalQuestState[i]==CaelumQuestCatalogue.State(record,i), "quest catalogue projection");
        user.RefreshSocialJournalSnapshot();
        Check(record.TarotEffectTics==35 && record.TarotCooldownTics==70 && record.CountTarotCards()==2, "refresh never advances powers or grants cards");

        let weapon=Item(user,CaelumConstants.EQUIPMENT_KIND_WEAPON,CaelumConstants.WEAPON_TYPE_STANDARD_BOW);
        user.WeaponModel.WeaponType=weapon.ItemType; user.WeaponModel.Tier=weapon.Tier;
        user.WeaponModel.Size=weapon.EquipmentSize; user.WeaponModel.Durability=weapon.Durability;
        user.WeaponModel.Equipped=true; user.ActiveWeaponItemId=weapon.ItemId;
        user.player.ReadyWeapon=null; user.SyncHUDActiveWeaponState();
        Check(user.HUDHasActiveWeapon && user.HUDActiveWeaponIsRanged && user.HUDActiveWeaponItemId==weapon.ItemId, "exact ranged identity");
        Check(user.HUDRangedMagazineCount==user.GetRangedMagazineCount(weapon.ItemType) && user.HUDRangedReserveCount==user.GetEquippedRangedReserveCount(), "ranged counters");
        Check(user.HUDActiveWeaponNoticeRemaining==CaelumConstants.ACTIVE_WEAPON_NOTICE_SECONDS, "changed weapon notice");
        user.SyncHUDActiveWeaponState();
        Check(Abs(user.HUDActiveWeaponNoticeRemaining-(CaelumConstants.ACTIVE_WEAPON_NOTICE_SECONDS-1.0/TICRATE))<0.000001, "one refresh countdown");
        let duplicate=Item(user,weapon.EquipmentKind,weapon.ItemType);
        user.ActiveWeaponItemId=duplicate.ItemId; user.SyncHUDActiveWeaponState();
        Check(duplicate.ItemId!=weapon.ItemId && user.HUDActiveWeaponItemId==duplicate.ItemId && user.HUDActiveWeaponNoticeRemaining==CaelumConstants.ACTIVE_WEAPON_NOTICE_SECONDS, "identical type distinct item");
        user.WeaponModel.Durability=0; user.SyncHUDActiveWeaponState();
        Check(!user.HUDHasActiveWeapon && !user.HUDActiveWeaponIsRanged && user.HUDActiveWeaponItemId==0, "broken weapon clears HUD");
        user.WeaponModel.Durability=1;
        user.player.ReadyWeapon=Weapon(user.FindInventory("CaelumUnarmedWeapon"));
        user.SyncHUDActiveWeaponState();
        Check(!user.HUDHasActiveWeapon, "native fists override equipped model");
        let seal=Item(user,CaelumConstants.EQUIPMENT_KIND_SEAL,CaelumConstants.SEAL_FIRE);
        user.SyncHUDActiveWeaponState();
        Check(user.HUDHasEquippedSeal && user.HUDEquippedSealType==seal.ItemType && user.HUDEquippedSealTier==seal.Tier, "native equipped seal");
        seal.Equipped=false; user.SyncHUDActiveWeaponState();
        Check(!user.HUDHasEquippedSeal && user.HUDEquippedSealTier==0, "removed seal clears HUD");
        Console.Printf("CA116 CHECKS done=%d failures=%d", Checks, Failures);
    }
    override void WorldTick()
    {
        if(Done && !ReloadChecked && level.time>=40)
        {
            ReloadChecked=true;
            let loaded=CaelumPlayer(players[0].mo);
            Check(loaded!=null, "loaded player");
            if(loaded!=null)
            {
                let record=loaded.GetPersistentCharacterState(false);
                Check(record!=null && record.CountTarotCards()==2, "loaded card ownership");
                Refresh(loaded);
                Check(loaded.TarotOwnedCountSnapshot==2 && loaded.MainM00ArmorPiecesSnapshot==2, "loaded projections");
            }
            Console.Printf("CA116 RESUME done=%d failures=%d",Checks,Failures);
        }
        if(Done || level.time<3) return;
        let user=CaelumPlayer(players[0].mo);
        if(user==null || !user.CharacterCreationComplete) return;
        Done=true; Run(user);
    }
}

// El observador estático verifica la carga; no depende de recrear el handler guardado.
class CA116ReloadObserver : StaticEventHandler
{
    bool Pending;
    override void WorldLoaded(WorldEvent e) { Pending=e.IsSaveGame; }
    override void WorldTick()
    {
        if(!Pending) return;
        Pending=false;
        let user=CaelumPlayer(players[0].mo);
        int failures=0;
        if(user==null) failures++;
        else
        {
            let record=user.GetPersistentCharacterState(false);
            if(record==null || record.CountTarotCards()!=2) failures++;
            user.RefreshSocialJournalSnapshot(); user.SyncHUDLoadState(); user.SyncHUDActiveWeaponState();
            if(user.TarotOwnedCountSnapshot!=2 || user.MainM00ArmorPiecesSnapshot!=2) failures++;
        }
        Console.Printf("CA116 RELOAD checks=3 failures=%d",failures);
    }
}
