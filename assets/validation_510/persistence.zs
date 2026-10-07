// Identical baseline/current save fixtures, except the explicit thermal seed.
class CA130Persistence : StaticEventHandler
{
    bool Loaded,Reopened;
    int ObservationTics;
    override void WorldLoaded(WorldEvent e)
    {
        Loaded=e.IsSaveGame;Reopened=e.IsReopen;ObservationTics=0;
        Console.Printf("CA130 SAVE LOAD map=%s save=%d reopen=%d tic=%d",level.MapName,Loaded,Reopened,level.time);
    }
    override void WorldTick()
    {
        let user=CaelumPlayer(players[0].mo);if(user==null)return;
        ObservationTics++;
        if(!Loaded && !Reopened && level.time==1 && !user.CharacterCreationComplete)
        {user.InitializeDirectMapCharacter();user.PersistCharacterState();}
        if(level.time==1 && !Loaded && !Reopened)
        {
            let marker=Actor.Spawn("CaelumClimateRegion",(0,0,0),NO_REPLACE);
            marker.args[0]=1;marker.args[1]=5;
        }
        if(!Loaded && !Reopened && level.MapName=="QA130A" && level.time==44)
        {
            let item=CaelumEquipmentItem(Actor.Spawn("CaelumWeaponPickup",user.Pos,NO_REPLACE));
            item.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;item.ItemType=CaelumConstants.WEAPON_TYPE_SWORD;
            item.ArmorSlot=-1;item.Tier=1;item.EquipmentSize=user.WeaponModel.Size;
            item.SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT;
            item.UnitWeight=user.WeaponModel.GetWeightFor(item.ItemType,item.Tier,item.EquipmentSize);
            item.Durability=123;item.PickupDataInitialized=true;item.Equipped=true;item.AttachToOwner(user);
            user.EnsureEquipmentItemId(item);user.ActivateExactEquippedWeapon(item);user.EnsureWeaponFamilySelectors();
            let record=user.GetPersistentCharacterState(false);record.EnsureQuestStateInitialized();
            record.QuestObjectiveProgress[0]=7;record.QuestRewardClaimed[0]=true;
            user.PersistCharacterState();
            // THERMAL_SEED
        }
        if(ObservationTics==2 || ObservationTics==35 || ObservationTics==60)
        {
            let record=user.GetPersistentCharacterState(false);
            Console.Printf("CA130 SAVE VALUES map=%s tic=%d hp=%d air=%.9f hunger=%.9f thirst=%.9f sleep=%.9f nextid=%d weaponid=%d",
                level.MapName,level.time,user.health,user.CurrentAir,user.CurrentHunger,user.CurrentThirst,user.CurrentSleep,
                record!=null ? record.NextEquipmentItemId : 0,user.ActiveWeaponItemId);
            Console.Printf("CA130 SAVE QUEST progress=%d reward=%d",record.QuestObjectiveProgress[0],record.QuestRewardClaimed[0]);
            // THERMAL_CHECK
            Console.Printf("CA130 SAVE COMPLETE");
        }
    }
}
