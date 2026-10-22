// Fixture privado compatible con 5.7.4: no agrega objetos a la campaña.
class CA407Mark : Inventory
{
    CaelumCityMerchant Vendor,Library;
    CaelumShopProduct Existing;
    int Products,Books,Wallet,Stock,Input,Output;
    double Due,Seconds;
    Default { +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE Inventory.MaxAmount 1; }
}
class CA407Legacy : StaticEventHandler
{
    int Passed,Failed;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA407 %s %s",ok?"PASS":"FAIL",label);}
    void Result(){Console.Printf("CA407 RESULT passed=%d failed=%d",Passed,Failed);}
    void Prepare(CaelumPlayer u)
    {
        u.bInvulnerable=true;u.DebugAttributesAt100=true;u.ApplyCharacterProfile();u.CreationWizardOpen=false;
        u.CancelCraftingTask();u.ClosePalomoMerchant();u.CloseCraftingStationSession();
        u.GrantMagicBoxFromPalomo(false);u.CurrentThirst=100;u.CurrentHunger=100;u.CurrentSleep=100;
        u.CurrentAir=u.DerivedStats.MaximumAir;u.CurrentAnima=u.DerivedStats.MaximumAnima;
        let clock=CaelumWorldClock.Get(u,true);CaelumCalendarState.Get(u,true).EnsureCampaign(clock);
    }
    CaelumCityMerchant Vendor(CaelumPlayer u,int category)
    {
        let v=CaelumCityMerchant(Actor.Spawn('CaelumCityMerchant',u.Pos+(48,0,0),NO_REPLACE));
        v.Category=category;v.WalletCopper=12345;v.EnsureStock(u);return v;
    }
    CaelumShopProduct Imported(CaelumCityMerchant v,int material)
    {for(int i=0;i<v.Products.Size();i++)if(v.Products[i].ImportedMaterial && v.Products[i].ItemType==material)return v.Products[i];return null;}
    CaelumShopProduct Book(CaelumCityMerchant v,int recipe)
    {for(int i=0;i<v.Products.Size();i++)if(v.Products[i].Kind==CaelumShopProduct.BOOK && v.Products[i].Recipe==recipe)return v.Products[i];return null;}
    void LegacySave(CaelumPlayer u)
    {
        Prepare(u);let r=u.GetPersistentCharacterState(true);r.EnsureTierRecipeBook();
        r.MainM00SupplyIssued[86]=17;r.MainM00SupplyLimit[81]=23;
        r.LearnCraftingRecipe(166,1);r.LearnCraftingRecipe(167,1);
        r.RecipeRereadings[166*3]=7;r.RecipePractice[167*3]=123;
        CaelumRecipeLearning.Receive(u,166,1);
        let m=CA407Mark(u.GiveInventoryType('CA407Mark'));
        m.Vendor=Vendor(u,0);m.Library=Vendor(u,6);
        m.Existing=Imported(m.Vendor,81);m.Existing.Stock.Amount=777;
        CaelumShopRestock.Sync(m.Vendor,u,true);
        m.Products=m.Vendor.Products.Size();m.Books=m.Library.Products.Size();
        m.Wallet=m.Vendor.WalletCopper;m.Stock=777;m.Due=m.Existing.NextDue;
        Book(m.Library,166).Stock.Amount=7;CaelumShopRestock.Sync(m.Library,u,true);
        u.PersistCharacterState();LegacyVerify(u);
    }
    void LegacyVerify(CaelumPlayer u)
    {
        let m=CA407Mark(u.FindInventory('CA407Mark'));Check(m!=null,"baseline checkpoint survives");
        if(m==null){Result();return;}
        let r=u.GetPersistentCharacterState(true);
        Check(r.MainM00SupplyIssued[86]==17 && r.MainM00SupplyLimit[81]==23,"legacy material indices preserved");
        Check(r.KnowsCraftingRecipe(166,1) && r.KnowsCraftingRecipe(167,1)
            && r.RecipeRereadings[166*3]==7 && r.RecipePractice[167*3]==123,"legacy recipe knowledge and progress preserved");
        Check(m.Existing.Stock.Amount==777 && m.Existing.NextDue==m.Due && m.Vendor.WalletCopper==m.Wallet,"legacy import stock deadline and wallet preserved");
        Check(m.Vendor.Products.Size()==m.Products && m.Library.Products.Size()==m.Books,"original save has original catalogue");Result();
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=="ca407_legacy_save")LegacySave(u);
        if(e.Name=="ca407_rollback")LegacyVerify(u);
    }
}
