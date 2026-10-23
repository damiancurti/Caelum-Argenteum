// Compatible con el runtime anterior: sólo usa identidades y API ya existentes.
class CA479Legacy : EventHandler
{
    int Passed,Failed;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA479 %s %s",ok?"PASS":"FAIL",label);}
    CaelumEquipmentItem Piece(CaelumPlayer user,int id,int type,int essence,int tier,bool boxed=false)
    {
        let item=CaelumEquipmentItem(Actor.Spawn("CaelumWeaponPickup",(160,96,0),NO_REPLACE));
        item.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;item.ItemType=type;
        item.EssenceType=essence;item.Tier=tier;item.EquipmentSize=CaelumConstants.EQUIPMENT_SIZE_M;
        item.PickupDataInitialized=true;item.ItemId=id;item.Durability=1234;item.WeaponDurabilityRevision=1;
        item.UnitWeight=user.WeaponModel.GetWeightFor(type,tier,item.EquipmentSize);
        item.InMagicBox=boxed;item.Equipped=!boxed;item.AttachToOwner(user);return item;
    }
    override void NetworkProcess(ConsoleEvent event)
    {
        if(level.MapName!="CSUP479")return;
        let user=CaelumPlayer(players[event.Player].mo);if(user==null)return;
        if(event.Name=="ca479_oldseed")
        {
            user.CreationWizardOpen=false;user.CharacterCreationComplete=true;
            CaelumInventoryService.GrantMagicBoxFromPalomo(user,false);
            let book=Piece(user,97001,18,0,2);Piece(user,97002,19,1,3,true);
            Piece(user,97003,1,4,1,true);
            user.EnsureWeaponFamilySelectors();CaelumInventoryService.ActivateExactEquippedWeapon(user,book);
            let record=user.GetPersistentCharacterState(true);
            record.RecipeRereadings[CaelumRecipeLearning.Slot(42,2)]=2;
            record.RecipePractice[CaelumRecipeLearning.Slot(42,2)]=3;
            user.PersistCharacterState();
            Check(user.FindNativeEquipmentItemById(97003)!=null,"old runtime retains offensive quintessence baseline");
            Console.Printf("CA479 RESULT old save prepared");
        }
        if(event.Name=="ca479_migrated")
        {
            let book=user.FindNativeEquipmentItemById(97001);let statue=user.FindNativeEquipmentItemById(97002);
            if(statue!=null)Console.Printf("CA479 PERSIST orb type=%d essence=%d tier=%d wear=%d box=%d",statue.ItemType,statue.EssenceType,statue.Tier,statue.Durability,statue.InMagicBox);
            Check(book!=null && book.ItemType==18 && book.EssenceType==0 && book.Tier==2 && book.Durability==1234,"old offensive book preserves identity tier wear and element");
            Check(statue!=null && statue.ItemType==19 && statue.EssenceType==1 && statue.Tier==3 && statue.Durability==1234 && statue.InMagicBox,"old offensive statuette and Box placement survive");
            Check(user.FindNativeEquipmentItemById(97003)==null,"old offensive quintessence is retired from Box");
            Check(CaelumDisplayNames.GetWeaponKey(18)=="CA_WEAPON_TYPE_SCEPTER" && CaelumDisplayNames.GetWeaponKey(19)=="CA_WEAPON_TYPE_ORB","loaded legacy identities use new offensive names");
            let record=user.GetPersistentCharacterState(false);
            Check(record!=null && record.RecipeRereadings[CaelumRecipeLearning.Slot(42,2)]==2 && record.RecipePractice[CaelumRecipeLearning.Slot(42,2)]==3,"legacy recipe learning indices survive");
            Check(CaelumRecipeLearning.Slot(169,1)>=0 && CaelumRecipeLearning.Slot(36,1)<0,"new recipe appended and retired slot disabled");
            Console.Printf("CA479 RESULT legacy load passed=%d failed=%d",Passed,Failed);
        }
        if(event.Name=="ca479_oldrollback")
        {
            let statue=user.FindNativeEquipmentItemById(97002);
            if(statue!=null)Console.Printf("CA479 PERSIST baseline statue type=%d essence=%d tier=%d wear=%d box=%d",statue.ItemType,statue.EssenceType,statue.Tier,statue.Durability,statue.InMagicBox);
            Check(user.FindNativeEquipmentItemById(97003)!=null,"original saved file retains retired item for rollback");
            Console.Printf("CA479 RESULT legacy rollback passed=%d failed=%d",Passed,Failed);
        }
    }
}
