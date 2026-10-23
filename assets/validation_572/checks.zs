// Las posiciones, cantidades y saltos de esta sala no forman parte de campaña.
class CA405Mark : Inventory
{
    CaelumLandSource Source;
    CaelumCityMerchant Vendor;
    double Remaining,Carry,Due;
    int Wallet;
    Default { +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE Inventory.MaxAmount 1; }
}
class CA405Checks : StaticEventHandler
{
    int Passed,Failed;
    CaelumLandSource UseHive;
    CaelumLandSource CutPlant;
    bool GalleryReady;
    override void WorldLoaded(WorldEvent e)
    {GalleryReady=false;UseHive=null;CutPlant=null;}
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA405 %s %s",ok?"PASS":"FAIL",label);}
    void Result(){Console.Printf("CA405 RESULT passed=%d failed=%d",Passed,Failed);}
    void Prepare(CaelumPlayer u)
    {
        u.bInvulnerable=true;u.DebugAttributesAt100=true;u.ApplyCharacterProfile();
        u.CancelCraftingTask();u.ClosePalomoMerchant();u.CloseCraftingStationSession();
        u.CreationWizardOpen=false;u.GrantMagicBoxFromPalomo(false);
        u.CurrentThirst=100;u.CurrentHunger=100;u.CurrentSleep=100;
        u.CurrentAir=u.DerivedStats.MaximumAir;u.CurrentAnima=u.DerivedStats.MaximumAnima;
        u.health=u.CaelumMaximumHealth;u.player.health=u.health;
        let clock=CaelumWorldClock.Get(u,true);CaelumCalendarState.Get(u,true).EnsureCampaign(clock);
    }
    Name SourceName(int index)
    {
        switch(index){case 0:return 'CaelumSourceYerbaMate';case 1:return 'CaelumSourceMarcela';
        case 2:return 'CaelumSourceIrupeFlower';case 3:return 'CaelumSourceCypellaFlower';
        case 4:return 'CaelumSourceSugarcane';case 5:return 'CaelumSourceCotton';default:return 'CaelumSourceHoney';}
    }
    CaelumLandSource Source(int index,Vector3 pos)
    {let source=CaelumLandSource(Actor.Spawn(SourceName(index),pos,NO_REPLACE));if(source!=null)source.EnsureResourceState();return source;}
    int Ground(int material)
    {
        int total=0;let it=ThinkerIterator.Create("CaelumMaterialPickup");CaelumMaterialPickup item;
        while((item=CaelumMaterialPickup(it.Next()))!=null)
            if(item.Owner==null && item.GetSpecialType()==material)total+=item.Amount;
        return total;
    }
    CaelumShopProduct Imported(CaelumCityMerchant v,int material)
    {for(int i=0;i<v.Products.Size();i++)if(v.Products[i].ImportedMaterial && v.Products[i].ItemType==material)return v.Products[i];return null;}
    CaelumCityMerchant Vendor(CaelumPlayer u,int category)
    {
        let v=CaelumCityMerchant(Actor.Spawn("CaelumCityMerchant",u.Pos+(48,0,0),NO_REPLACE));
        v.Category=category;v.TradesClothing=category==7;v.WalletCopper=200000;v.EnsureStock(u);return v;
    }
    void Suite(CaelumPlayer u)
    {
        Prepare(u);
        for(int i=0;i<7;i++)
        {
            let source=Source(i,(300+i*100,400,0));int material=CaelumLandResourceData.Material(i);
            double cap=CaelumLandResourceData.Capacity(i);int ground=Ground(material);
            Check(source!=null && source.ResourceRemainingUnits==cap,String.Format("profile %d authored capacity",i));
            Check(source.TryExtractResource(u,CaelumConstants.CATALOGUE_DAMAGE_PIERCING,100,-1)==0,"piercing cannot harvest plant or hive");
            if(i==6)
            {
                Check(source.TryExtractResource(u,CaelumConstants.CATALOGUE_DAMAGE_SLASHING,100,-1)==0,"hive cannot be harvested by slashing");
                for(int n=0;n<10;n++)Check(source.CollectHoney(u),"hive interaction releases fifty grams");
                Check(!source.CollectHoney(u) && source.ResourceRemainingUnits==0 && Ground(material)-ground==500,"hive exhausted exactly once at 500 grams");
            }
            else
            {
                double removed=source.TryExtractResource(u,CaelumConstants.CATALOGUE_DAMAGE_SLASHING,1,-1);
                Check(removed==0.75 && source.ResourceYieldCarry==0.75 && Ground(material)==ground,"fractional strike held until whole gram");
                source.TryExtractResource(u,CaelumConstants.CATALOGUE_DAMAGE_SLASHING,1,-1);
                Check(source.ResourceYieldCarry==0.5 && Ground(material)==ground+1,"next strike yields one gram without losing carry");
                source.TryExtractResource(u,CaelumConstants.CATALOGUE_DAMAGE_SLASHING,100000,-1);
                Check(source.ResourceRemainingUnits==0 && source.ResourceYieldCarry==0 && Ground(material)-ground==int(cap),"exhaustion conserves exact authored reserve");
                Check(source.TryExtractResource(u,CaelumConstants.CATALOGUE_DAMAGE_SLASHING,100,-1)==0,"exhausted node cannot duplicate output");
            }
        }
        for(int i=81;i<=86;i++)
        {
            let item=u.CreateDetachedMaterialStack(i,1,37);item.AttachToOwner(u);
            Check(item.GetSpecialType()==i && item.GetUnitWeight()==0.001 && item.Amount==37,"new material has gram unit and exact identity");
            Check(CaelumEconomyRules.GetMaterialUnitBaseValue(i,1)==CaelumLandResourceData.Price(i),"approved material price used by shared economy");
            let dropped=CaelumMaterialPickup(item.CreateTossable(11));
            Check(dropped!=null && dropped.Amount==11 && dropped.GetSpecialType()==i && item.Amount==26,"native split/drop preserves amount and identity");
            if(dropped!=null)dropped.Destroy();
            item.InMagicBox=true;Check(item.InMagicBox && item.Amount==26,"Box retains new material units");
        }
        let decor=CaelumLandSource(Actor.Spawn("CaelumSourceHoneyDecoration",(1200,400,0),NO_REPLACE));
        Check(!decor.CollectHoney(u) && !decor.IsNaturalResource(),"decorative hive rejects interaction");
        Result();
    }
    bool Select(CaelumPlayer u,Inventory item,bool sell=false)
    {
        u.PalomoMerchantMode=sell?CaelumConstants.PALOMO_MERCHANT_MODE_SELL:CaelumConstants.PALOMO_MERCHANT_MODE_BUY;
        u.PalomoMerchantQuantityIndex=0;u.CityTrade.Refresh(u);
        for(int i=0;i<u.CityTrade.Rows.Size();i++)if(u.CityTrade.Rows[i]==item)
        {u.CityTrade.Selection=i;u.CityTrade.Refresh(u);return true;}return false;
    }
    void Trade(CaelumPlayer u)
    {
        Prepare(u);let coin=CaelumCurrencyItem(Actor.Spawn(CaelumEconomyRules.GetCurrencyClassName(5),u.Pos,NO_REPLACE));
        coin.Amount=1000;coin.AttachToOwner(u);u.OnNativeInventoryChanged();
        let provisions=Vendor(u,0);let clothing=Vendor(u,7);let weapons=Vendor(u,2);
        for(int i=0;i<4;i++)
        {
            int material=CaelumLandResourceData.ImportMaterial(i);let v=i==3?clothing:provisions;
            let p=Imported(v,material);int target=CaelumLandResourceData.ImportTarget(i);
            Check(p!=null && p.Stock.Amount==target && p.Stock.Owner==v,"import seeded with approved stock and category");
            int count=v.Products.Size(),wallet=v.WalletCopper;v.EnsureStock(u);v.EnsureStock(u);
            Check(v.Products.Size()==count && p.Stock.Amount==target && wallet==v.WalletCopper,"repeat initialization cannot add stock or money");
            p.Stock.Amount=0;CaelumShopRestock.Sync(v,u,true);
            double due=p.NextDue,period=p.UnitTics;
            Check(Abs(period-CaelumWorldClock.TicsPerDay()/(target*0.001))<0.00001,"import renews at one tenth percent per game day");
            let clock=CaelumWorldClock.Get(u);clock.AdvanceTics(int(Ceil(due-CaelumScheduleState.Now(u))));CaelumShopRestock.Sync(v,u);
            Check(p.Stock.Amount==1,"exact deadline releases a single gram, including fractional daily import");
            CaelumShopRestock.Sync(v,u);Check(p.Stock.Amount==1,"same timestamp cannot renew twice");
            clock.AdvanceTics(int(Ceil(period*target)));CaelumShopRestock.Sync(v,u);
            Check(p.Stock.Amount==target && p.NextDue<0 && v.WalletCopper==wallet,"long skip caps stock and preserves wallet");
        }
        let kit=weapons.Products[0];bool finite=true;
        for(int i=0;i<weapons.Products.Size();i++)
            if(weapons.Products[i].Kind==CaelumShopProduct.MATERIAL)finite=finite && !weapons.Products[i].ImportedMaterial && weapons.Products[i].Recipe<0;
        Check(finite,"existing prepared kits remain finite");
        let p=Imported(provisions,81);CaelumCityTradeSession.Open(u,provisions);Check(Select(u,p.Stock),"new ingredient is selectable in ordinary shop");
        int price=u.PalomoMerchantSelectedLotPrice,money=int(u.GetOwnedMoneyCopperValue()),wallet=provisions.WalletCopper,quantity=u.PalomoMerchantSelectedQuantity;
        u.ExecutePalomoMerchantTransaction();let bought=CaelumCityTradeSession.Stack(u,p.Stock);
        Check(bought!=null && bought.Amount==quantity && p.Stock.Amount==p.Target-quantity,"native shop transfers exact material quantity once");
        Check(int(u.GetOwnedMoneyCopperValue())==money-price && provisions.WalletCopper==wallet+price,"shared merchant margin charged exactly");
        if(bought!=null){Check(Select(u,bought,true),"new ingredient can be resold");u.ExecutePalomoMerchantTransaction();Check(p.Stock.Amount==p.Target,"resale restores material stock exactly");}
        u.ClosePalomoMerchant();Result();
    }
    void Save(CaelumPlayer u)
    {
        Prepare(u);let m=CA405Mark(u.GiveInventoryType("CA405Mark"));m.Source=Source(1,(300,400,0));
        m.Source.PlacementId=900;
        m.Source.TryExtractResource(u,CaelumConstants.CATALOGUE_DAMAGE_SLASHING,1,-1);
        m.Remaining=m.Source.ResourceRemainingUnits;m.Carry=m.Source.ResourceYieldCarry;
        m.Vendor=Vendor(u,0);m.Vendor.ShopIdentity=900;let p=Imported(m.Vendor,81);p.Stock.Amount=777;CaelumShopRestock.Sync(m.Vendor,u,true);
        m.Due=p.NextDue;m.Wallet=m.Vendor.WalletCopper;
        let item=u.CreateDetachedMaterialStack(84,1,17);item.InMagicBox=true;item.AttachToOwner(u);
        u.PersistCharacterState();Verify(u);
    }
    void Verify(CaelumPlayer u)
    {
        let m=CA405Mark(u.FindInventory("CA405Mark"));Check(m!=null,"saved checkpoint exists");if(m==null){Result();return;}
        if(level.MapName=="CARESRC")
        {
            // Referencias a actores de otro mapa no viajan en el inventario.
            // Recuperar los fixtures por ID prueba la autoridad guardada del hub.
            let si=ThinkerIterator.Create("CaelumLandSource");CaelumLandSource node;
            while((node=CaelumLandSource(si.Next()))!=null)if(node.PlacementId==900)m.Source=node;
            let vi=ThinkerIterator.Create("CaelumCityMerchant");CaelumCityMerchant vendor;
            while((vendor=CaelumCityMerchant(vi.Next()))!=null)if(vendor.ShopIdentity==900)m.Vendor=vendor;
            Check(m.Source!=null && Abs(m.Source.ResourceRemainingUnits-m.Remaining)<0.001 && m.Source.ResourceYieldCarry==m.Carry,"node amount and fractional carry survive save/hub");
            Check(m.Vendor!=null,"saved map-local vendor recovered by stable fixture ID");
            if(m.Vendor==null){Result();return;}
            let p=Imported(m.Vendor,81);m.Vendor.EnsureStock(u);
            Check(p.Stock.Amount==777 && p.NextDue==m.Due && m.Vendor.WalletCopper==m.Wallet,"import stock, queue and wallet survive without reset");
        }
        bool found=false;for(Inventory item=u.Inv;item!=null;item=item.Inv)
        {let material=CaelumMaterialPickup(item);if(material!=null && material.GetSpecialType()==84)found=material.Amount==17 && material.InMagicBox;}
        Check(found,"boxed material survives save and travel");Result();
    }
    void Upgrade(CaelumPlayer u)
    {
        let r=u.GetPersistentCharacterState(true);let m=CA405LegacyMark(u.FindInventory("CA405LegacyMark"));
        Check(r.MainM00SupplyIssued[79]==17 && r.MainM00SupplyLimit[80]==23,"old material indices survive real old-save migration");
        bool zero=true;for(int i=81;i<=86;i++)zero=zero && r.MainM00RepairSupply[i]==0 && r.MainM00SupplyLimit[i]==0 && r.MainM00SupplyIssued[i]==0 && r.MainM00MazeRepairUnits[i]==0 && r.MainM00StarterRequired[i]==0;
        Check(zero && r.LandMaterialSchemaRevision==1,"six new slots start empty with revisioned migration");
        r.EnsureLandMaterialSchema();Check(r.MainM00SupplyIssued[79]==17,"repeated migration preserves old data");
        Check(m!=null,"legacy merchant checkpoint exists");if(m!=null)
        {
            m.Vendor.EnsureStock(u);m.Vendor.EnsureStock(u);
            Check(m.Vendor.Products.Size()==m.ProductCount+3 && m.Vendor.Products[0].Stock.Amount==m.Stock
                && m.Vendor.WalletCopper==m.Wallet,"old merchant receives imports once without resetting prior stock or wallet");
            Check(Imported(m.Vendor,81).Stock.Amount==1000 && Imported(m.Vendor,83).Stock.Amount==20 && Imported(m.Vendor,85).Stock.Amount==10000,"old merchant exact approved imports");
        }
        Result();
    }
    void MapCheck(CaelumPlayer u,bool removed=false)
    {
        Prepare(u);int count=0,natural=0;bool floor=true;double herb=0,flower=0,honey=0;
        let it=ThinkerIterator.Create("CaelumLandSource");CaelumLandSource s;
        while((s=CaelumLandSource(it.Next()))!=null)
        {
            count++;if(s.IsNaturalResource())natural++;floor=floor && Abs(s.Pos.Z-s.FloorZ)<0.01;
            if(s.Profile()==1)herb+=s.ResourceRemainingUnits;
            if(s.Profile()==3)flower+=s.ResourceRemainingUnits;
            if(s.Profile()==6)honey+=s.ResourceRemainingUnits;
            Check(s.PlacementId>0 && (level.MapName!="MAP01" || s.TryExtractResource(u,CaelumConstants.CATALOGUE_DAMAGE_SLASHING,100,-1)==0),"placed source has persistent identity and tutorial restriction");
        }
        Check(count==(level.MapName=="MAP01"?4:7)-(removed?1:0),"exact approved source count, no respawn of removed issued node");
        Check(natural==(level.MapName=="MAP01"?0:count) && floor,"correct decoration/harvest policy and native floor placement");
        if(level.MapName=="MAP03" && !removed)Check(herb==200 && flower==20 && honey==500,"MAP03 approved total reserves");
        int rosters=0;let ri=ThinkerIterator.Create("CaelumLandSourceRoster");CaelumLandSourceRoster roster;
        while((roster=CaelumLandSourceRoster(ri.Next()))!=null){rosters++;Check(roster.Issued.Size()==(level.MapName=="MAP01"?4:7),"issued IDs retained independently of surviving sources");}
        Check(rosters==1,"one persistent map roster");Result();
    }
    void Gallery(CaelumPlayer u)
    {
        Prepare(u);if(!GalleryReady){GalleryReady=true;for(int i=0;i<7;i++)Source(i,(300,-300+i*100,0));
        Actor.Spawn("CaelumFiberBush",(300,400,0),NO_REPLACE);
        Actor.Spawn("CaelumMansionSceneryShrub",(300,500,0),NO_REPLACE);
        for(int i=81;i<=86;i++){let item=u.CreateDetachedMaterialStack(i,1,10);item.SetOrigin((180,-250+(i-81)*100,0),false);}}
        u.SetOrigin((-180,100,0),false);u.Angle=0;u.Pitch=0;Result();
    }
    void UseSetup(CaelumPlayer u)
    {Prepare(u);u.SetOrigin((0,0,0),false);u.Angle=0;u.Pitch=25;if(UseHive==null)UseHive=Source(6,(48,0,0));Result();}
    void Equip(CaelumPlayer u)
    {
        int kind=CaelumConstants.WEAPON_TYPE_SWORD;let item=CaelumEquipmentItem(Actor.Spawn("CaelumWeaponPickup",u.Pos,NO_REPLACE));
        item.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;item.ItemType=kind;item.Tier=1;
        item.EquipmentSize=CaelumConstants.EQUIPMENT_SIZE_M;
        item.Durability=u.WeaponModel.GetMaximumDurabilityFor(kind,1,item.EquipmentSize);
        item.UnitWeight=u.WeaponModel.GetWeightFor(kind,1,item.EquipmentSize);
        item.WeaponDurabilityRevision=CaelumAttackRules.DURABILITY_REVISION;
        item.PickupDataInitialized=true;item.AcquisitionResolved=true;item.Equipped=true;item.AttachToOwner(u);
        u.EnsureEquipmentItemId(item);u.ActivateExactEquippedWeapon(item);u.EnsureWeaponFamilySelectors();
        u.SelectNativeWeaponConfiguration(kind,0,1);u.OnNativeInventoryChanged();
    }
    void CutSetup(CaelumPlayer u)
    {Prepare(u);u.SetOrigin((0,700,0),false);u.Angle=0;u.Pitch=25;Equip(u);if(CutPlant==null)CutPlant=Source(1,(48,700,0));Result();}
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=="ca405_suite")Suite(u);
        else if(e.Name=="ca405_trade")Trade(u);
        else if(e.Name=="ca405_save")Save(u);
        else if(e.Name=="ca405_verify")Verify(u);
        else if(e.Name=="ca405_upgrade")Upgrade(u);
        else if(e.Name=="ca405_map")MapCheck(u);
        else if(e.Name=="ca405_map_removed")MapCheck(u,true);
        else if(e.Name=="ca405_remove"){let it=ThinkerIterator.Create("CaelumLandSource");let source=Actor(it.Next());if(source!=null)source.Destroy();}
        else if(e.Name=="ca405_gallery")Gallery(u);
        else if(e.Name=="ca405_angle"){u.SetOrigin((100,-700,0),false);u.Angle=80;u.Pitch=0;}
        else if(e.Name=="ca405_use_setup")UseSetup(u);
        else if(e.Name=="ca405_use_check"){Check(UseHive!=null && Abs(UseHive.ResourceRemainingUnits-450)<0.01,"native held Use collects once, not every tic");Result();}
        else if(e.Name=="ca405_cut_setup")CutSetup(u);
        else if(e.Name=="ca405_cut_check"){Check(CutPlant!=null && CutPlant.ResourceRemainingUnits<50 && Ground(82)>0,"native sword attack extracts plant material");Result();}
        else if(e.Name=="ca405_closeup"){u.SetOrigin((210,e.Args[0]==0?300:-200,0),false);u.Angle=0;u.Pitch=18;}
        else if(e.Name=="ca405_campaign")
        {
            Prepare(u);Equip(u);u.Angle=0;u.Pitch=20;
            Vector3 pos=level.MapName=="MAP03"?(-30320,320,0):(-1904,832,0);
            let sector=level.PointInSector(pos.XY);pos.Z=sector.FloorPlane.ZatPoint(pos.XY);u.SetOrigin(pos,false);Result();
        }
        else if(e.Name=="ca405_author")
        {
            if(level.MapName!="CARESRC"){Console.Printf("CA405: pulsa F1 para volver a la sala de pruebas.");return;}
            Prepare(u);
            if(e.Args[0]==0){Gallery(u);Console.Printf("CA405 READY: F1 modelos; F2 colmena (E recoger); F3 tienda; F4 planta; F5 MAP03; F6 MAP01. Materiales en suelo: acercarse.");}
            else if(e.Args[0]==1){UseSetup(u);Console.Printf("CA405 READY: mira la colmena y pulsa E. Cada pulsacion extrae 50 g.");}
            else if(e.Args[0]==3)CutSetup(u);
            else {let vendor=Vendor(u,0);CaelumCityTradeSession.Open(u,vendor);Result();}
        }
    }
}
