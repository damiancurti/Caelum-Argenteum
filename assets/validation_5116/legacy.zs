// This exact fixture compiles against both accepted 5.1.15 and current source.
class CA163Legacy : EventHandler
{
    int Id,Passed,Failed,Checked;
    void Check(String label,bool ok)
    {if(ok)Passed++;else Failed++;Console.Printf("CA163 %s %s",ok?"PASS":"FAIL",label);}
    override void WorldTick()
    {
        let u=CaelumPlayer(players[0].mo);
        if(level.time==1)u.InitializeDirectMapCharacter();
        let r=u.GetPersistentCharacterState(true);
        if(level.time==20)
        {
            let item=CaelumEquipmentItem(Actor.Spawn("CaelumWeaponPickup",u.Pos,NO_REPLACE));
            item.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;item.ItemType=CaelumConstants.WEAPON_TYPE_STAFF;
            item.Tier=2;item.EquipmentSize=1;item.Durability=2345;item.EssenceType=CaelumConstants.ESSENCE_WATER;
            item.UnitWeight=u.WeaponModel.GetWeightFor(item.ItemType,2,1);item.PickupDataInitialized=true;
            item.WeaponDurabilityRevision=CaelumAttackRules.DURABILITY_REVISION;
            item.AttachToOwner(u);u.EnsureEquipmentItemId(item);Id=item.ItemId;
            u.LearnCraftingRecipe(131);u.LearnCraftingRecipe(132);u.LearnCraftingRecipe(33);u.PersistCharacterState();
            Console.Printf("CA163 BASELINE recipe_revision=%d wand_id=%d durability=%d tier=%d essence=%d",r.RecipeBookVersion,Id,item.Durability,item.Tier,item.EssenceType);
        }
        int requested=CVar.FindCVar('ca163_stage').GetInt();
        if(requested<12 || Checked==requested)return;
        Checked=requested;Passed=0;Failed=0;
        let old=u.FindNativeEquipmentItemById(Id);
        r.EnsureRecipeBookInitialized();
        Check("old save migrates recipe book to revision 7",r.RecipeBookVersion==7);
        Check("old Pickaxe and wand recipes remain learned",r.KnowsCraftingRecipe(131) && r.KnowsCraftingRecipe(33));
        Check("bolas recipe remains locked until learned",!r.KnowsCraftingRecipe(133));
        Check("old elemental wand retains tier size essence durability and identity",old!=null && old.ItemType==CaelumConstants.WEAPON_TYPE_STAFF
            && old.Tier==2 && old.EquipmentSize==1 && old.EssenceType==CaelumConstants.ESSENCE_WATER && old.Durability==2345);
        int copies=0,tools=0;
        for(Inventory i=u.Inv;i!=null;i=i.Inv)
        {let item=CaelumEquipmentItem(i);if(item!=null && item.EquipmentKind==CaelumConstants.EQUIPMENT_KIND_WEAPON){if(item.ItemId==Id)copies++;if(item.ItemType==22)tools++;}}
        Check("load creates neither duplicate wand nor unsolicited tool",copies==1 && tools==0);
        r.EnsureRecipeBookInitialized();u.PersistCharacterState();
        Check("migration is idempotent",r.RecipeBookVersion==7 && r.KnowsCraftingRecipe(131) && old.Durability==2345);
        Console.Printf("CA163 RESULT passed=%d failed=%d",Passed,Failed);
    }
}
