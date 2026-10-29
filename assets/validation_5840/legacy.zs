class CA410DiningLegacyProof : Inventory
{
    CaelumCityMerchant Vendor;CaelumLuxuryTable Table;CaelumWaterContainer Water;CaelumConsumableItem Food;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA410DiningLegacyChecks : EventHandler
{
    int Passed,Failed;
    void Check(bool b,String label){if(b)Passed++;else Failed++;Console.Printf("CA410DS %s %s",b?"PASS":"FAIL",label);}
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!='ca410ds_priorseed' && e.Name!='ca410ds_priorload')return;
        let u=CaelumPlayer(players[e.Player].mo);u.CharacterCreationComplete=true;u.CreationWizardOpen=false;u.bInvulnerable=true;
        u.GetPersistentCharacterState(true).ProfileCommitted=true;
        let r=u.GetPersistentCharacterState(true);let p=CA410DiningLegacyProof(u.FindInventory('CA410DiningLegacyProof'));
        if(e.Name=='ca410ds_priorseed')
        {
            p=CA410DiningLegacyProof(Actor.Spawn('CA410DiningLegacyProof'));p.AttachToOwner(u);
            p.Vendor=CaelumCityMerchant(Actor.Spawn('CaelumCityMerchant',(0,300,0)));p.Vendor.Category=0;
            p.Vendor.StockInitialized=true;p.Vendor.CatalogueRevision=1;p.Vendor.RestockRevision=1;CaelumRestFurnitureCatalogue.Ensure(p.Vendor,u);
            for(int k=0;k<8;k++){p.Vendor.Products[k].Stock.Amount=1;r.LearnCraftingRecipe(CaelumRestFurnitureData.FIRST_RECIPE+k,1);}
            p.Table=CaelumLuxuryTable(Actor.Spawn('CaelumLuxuryTable',(200,300,0)));
            p.Water=CaelumWaterContainer(Actor.Spawn('CaelumCanteenLarge'));p.Water.AttachToOwner(p.Table);p.Table.Items[0]=p.Water;
            p.Water.AddWater(.25,CaelumWaterQuality.BIOLOGICAL,61,true);
            p.Food=CaelumConsumableItem(Actor.Spawn('CaelumFoodRation'));p.Food.Amount=2;p.Food.AttachToOwner(p.Table);p.Table.Items[1]=p.Food;CaelumFoodInventory.Prepare(p.Food).Exposure=21;
            Check(r.RecipeBookVersion==22 && p.Vendor.RestFurnitureRevision==4 && p.Vendor.Products.Size()==8,"original runtime creates revision22 learning and revision4 stock");
        }
        else
        {
            Check(p!=null && p.Table!=null && p.Water!=null && p.Food!=null,"original save retains fixed table and actual contents");if(p==null)return;
            r.EnsureTierRecipeBook();CaelumRestFurnitureCatalogue.Ensure(p.Vendor,u);
            Check(r.RecipeBookVersion==CaelumConstants.CRAFTING_RECIPE_BOOK_VERSION,"save reaches current recipe schema");
            Check(p.Vendor.Products.Size()==CaelumRestFurnitureData.COUNT,"save appends only current catalogue");
            Check(p.Water.Owner==p.Table && Abs(p.Water.WaterLiters-.25)<.000001 && p.Water.WaterQuality==CaelumWaterQuality.BIOLOGICAL,"original bottle volume and quality preserved");
            Check(p.Food.Owner==p.Table && p.Food.Amount==2 && p.Food.FoodLots.OldestContamination()>=21,"original food lots preserved");
        }
        for(int k=0;k<8;k++)Check(r.KnowsCraftingRecipe(CaelumRestFurnitureData.FIRST_RECIPE+k,1) && p.Vendor.Products[k].Stock.Amount==1,"old learning and sold stock conserved");
        for(int k=8;k<CaelumRestFurnitureData.COUNT;k++)Check(!r.KnowsCraftingRecipe(CaelumRestFurnitureData.FIRST_RECIPE+k,1) && p.Vendor.Products[k].Stock.Amount==3,"new recipes unlearned and initial dining stock appended");
        Console.Printf("CA410DS RESULT passed=%d failed=%d",Passed,Failed);
    }
}
