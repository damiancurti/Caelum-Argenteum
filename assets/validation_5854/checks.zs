class CA410ReviewChecks : EventHandler
{
    int Passed,Failed;
    void Check(bool ok,String label){if(ok)Passed++;else Failed++;Console.Printf("CA410V %s %s",ok?"PASS":"FAIL",label);}
    bool Near(double a,double b){return Abs(a-b)<.00001;}
    bool LargeWall(CaelumPlayer u,CaelumDecorItem item)
    {
        for(int i=0;i<level.Lines.Size();i++)
        {
            let line=level.Lines[i];if(line.special!=0 || line.frontsector==null)continue;
            vector2 edge=line.v2.p-line.v1.p;double length=edge.Length();if(length<1)continue;
            vector2 tangent=edge/length;
            for(int part=1;part<=3;part++)for(int sign=-1;sign<=1;sign+=2)
            {
                vector2 normal=(-tangent.Y,tangent.X)*sign,center=line.v1.p+edge*(part/4.0);
                vector2 xy=center+normal*48;
                u.SetOrigin((xy.X,xy.Y,line.frontsector.floorplane.ZatPoint(xy)),false);u.FindFloorCeiling();
                u.SetOrigin((xy.X,xy.Y,u.FloorZ),false);u.FindFloorCeiling();
                u.Angle=VectorAngle(-normal.X,-normal.Y);u.Pitch=0;u.Vel=(0,0,0);
                if(u.TestMobjLocation() && item.Place(u))return true;
            }
        }
        return false;
    }
    void Profile(CaelumPlayer u)
    {let setup=new('CA410WaterFurnitureChecks');setup.Profile(u);}
    void Water(CaelumPlayer u)
    {
        Profile(u);let helper=new('CA410WaterFurnitureChecks');helper.Find();
        let source=helper.Fountain;Check(source!=null,"real mansion fountain exists");if(source==null)return;
        helper.Position(u,source);source.SyncWater(u);
        Name kinds[]={'CaelumBottleSmall','CaelumBottleNormal','CaelumBottleLarge','CaelumCanteenSmall','CaelumCanteenNormal','CaelumCanteenLarge'};
        for(int k=0;k<6;k++)
        {
            let bottle=CaelumWaterContainer(Actor.Spawn(kinds[k]));bottle.AttachToOwner(u);
            bottle.WaterLiters=0;u.InvSel=bottle;double before=source.Reserve.WaterLiters;
            Check(CaelumQuickUse.Available(u,bottle),"empty selected container usable at full hydration");
            Check(u.UseInventory(bottle) && Near(bottle.WaterLiters,bottle.GetCapacityLiters()),"native item-use fills exact capacity");
            Check(Near(before-source.Reserve.WaterLiters,bottle.WaterLiters),"source spends actual transferred volume");
            Check(!u.UseInventory(bottle) && Near(bottle.WaterLiters,bottle.GetCapacityLiters()),"full container does not fall back to drinking");
            bottle.EmptyWater(u);let selector=new('CA410RestChecks');selector.Select(u,bottle);
            CaelumWaterQuality.InventoryAction(u,false);
            Check(Near(bottle.WaterLiters,bottle.GetCapacityLiters()),"existing inventory refill action still works");
            u.Angle+=180;u.CurrentThirst=50;double filled=bottle.WaterLiters;
            Check(u.UseInventory(bottle) && bottle.WaterLiters<filled,"away from source same action drinks");
            u.CurrentThirst=100;helper.Position(u,source);
        }
    }
    void Decor(CaelumPlayer u)
    {
        Profile(u);let h=new('CA410DecorChecks');h.Profile(u);
        let item=CaelumDecorItem(Actor.Spawn('CaelumLargePaintingItem'));item.AttachToOwner(u);
        Console.Printf("CA410V DEBUG item owner=%d amount=%d kind=%d authority=%d frozen=%d height=%.3f view=%.3f",item.Owner==u,item.Amount,item.Kind(),CaelumPlayerAuthority.CanMutate(u),u.isFrozen(),u.Height,u.ViewHeight);
        Check(LargeWall(u,item),"museum painting fits actual mansion wall");
        Check(item.Decoration!=null && !item.Decoration.bSolid && Near(item.Decoration.Height,49.92),"large painting has its full wall envelope");
        if(item.Decoration!=null)
        {
            h.Face(u,item.Decoration);let original=item.Decoration;
            Check(item.Carry(u),"large painting can be packed with real ownership");
            Check(LargeWall(u,item) && item.Decoration==original,"same large painting redeploys without duplication");
        }
        let record=u.GetPersistentCharacterState(true);int old=CaelumRestFurnitureData.FIRST_RECIPE+13;
        record.RecipeBookVersion=24;record.KnownCraftingRecipe[old]=true;record.EnsureRecipeBookInitialized();
        Check(record.KnownCraftingRecipe[old] && !record.KnownCraftingRecipe[old+1] && record.RecipeBookVersion==25,"migration preserves statue knowledge and appends unknown large recipe");
        Check(CaelumRestFurnitureData.COUNT==15 && CaelumDecorData.ItemClass(2)=='CaelumLargePaintingItem',"new catalogue entry is appended, never renumbered");
        let vendor=CaelumCityMerchant(Actor.Spawn('CaelumCityMerchant'));vendor.Category=0;vendor.RestFurnitureRevision=0;
        vendor.EnsureStock(u);int amount=vendor.Products.Size();
        Console.Printf("CA410V DEBUG merchant revision=%d products=%d enum=%d",vendor.RestFurnitureRevision,amount,vendor.EnumeratingStock);
        Check(CaelumRestFurnitureCatalogue.Has(vendor,CaelumShopProduct.SIMPLE,14),"large painting available through normal Provisions catalogue");
        CaelumRestFurnitureCatalogue.Ensure(vendor,u);Check(vendor.Products.Size()==amount,"catalogue migration is idempotent");
        h.Reject(u);Check(h.Failed==0,"existing overlap and obstruction protections still pass");
    }
    void Gallery(CaelumPlayer u,int page)
    {
        Profile(u);
        if(page==0)
        {
            let cot=Actor.Spawn('CaelumRestBed',(-85,0,0));let luxury=Actor.Spawn('CaelumLuxuryBed',(85,0,0));
            cot.Angle=0;luxury.Angle=0;
            u.SetOrigin((0,-155,0),false);u.Angle=90;u.Pitch=12;
            Check(cot!=null && luxury!=null,"both beds visibly present in one gallery");
        }
        else
        {
            let small=Actor.Spawn('CaelumLandscapePainting',(-85,400,35));small.Angle=270;
            let large=Actor.Spawn('CaelumLargeLandscapePainting',(55,400,25));large.Angle=270;
            large.A_SetSize(CaelumDecorData.Radius(2),CaelumDecorData.Height(2),false);
            let statue=Actor.Spawn('CaelumOrnamentalStatue',(-30,350,0));
            u.SetOrigin((0,240,0),false);u.Angle=90;u.Pitch=3;
            Check(small!=null && large!=null && statue!=null,"small and museum paintings plus ornamental statue present together");
        }
        u.FindFloorCeiling();u.Vel=(0,0,0);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=="ca410review_water")Water(u);
        else if(e.Name=="ca410review_decor")Decor(u);
        else if(e.Name=="ca410review_gallery")Gallery(u,e.Args[0]);
        else return;
        Console.Printf("CA410V RESULT passed=%d failed=%d",Passed,Failed);
    }
}
