// Escena aislada: valores de prueba, nunca datos de balance distribuidos.
class CA479Body : CaelumCombatActor
{
    bool Live;
    override void Tick() { if(Live)Super.Tick(); Vel=(0,0,0); }
    Default { Radius 16; Height 64; Health 1000; Speed 10; +SOLID +SHOOTABLE +ISMONSTER +NOGRAVITY }
    States { Spawn: RUID A -1; Stop; }
}
class CA479Gameplay : EventHandler
{
    int Passed,Failed;
    CA479Body SavedBody;
    int SavedAt,SavedMaximum;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA479 %s %s",ok?"PASS":"FAIL",label);}
    bool Near(double a,double b){return Abs(a-b)<0.000001;}
    CA479Body Body(vector3 point)
    {
        let body=CA479Body(Actor.Spawn("CA479Body",point,NO_REPLACE));
        body.CombatMaximumHealth=1000;body.health=1000;body.CombatBaseSpeed=10;
        body.CombatToughness=0;body.CombatAgility=0;body.CombatPatience=0;
        body.CombatArmor=null;body.UpdateCombatHealthEffects();return body;
    }
    void Clear(Actor body)
    {let effect=CaelumSupportMagic.Status(body);if(effect!=null)effect.Destroy();}
    void Advance(CaelumSupportStatus effect,int tics)
    {for(int i=0;i<tics;i++)effect.Tick();}
    void Checks(CaelumPlayer user)
    {
        user.CreationWizardOpen=false;user.CharacterCreationComplete=true;
        user.Attributes.Charisma=0;user.Attributes.Empathy=0;
        user.CurrentHunger=100;user.CurrentThirst=100;user.CurrentSleep=100;
        user.SetOrigin((-128,0,0),false);user.Angle=0;user.Pitch=0;
        let enemy=Body((64,0,0));let ally=Body((64,96,0));ally.bFriendly=true;
        Check(CaelumSupportMagic.Eligible(user,enemy,0),"enemy accepts curse");
        Check(!CaelumSupportMagic.Eligible(user,enemy,1),"enemy rejects benefit");
        Check(CaelumSupportMagic.Eligible(user,ally,1),"ally accepts benefit");
        Check(!CaelumSupportMagic.Eligible(user,ally,0),"ally rejects curse");
        Check(CaelumSupportMagic.Eligible(user,user,2) && !CaelumSupportMagic.Eligible(user,user,3),"self polarity");
        Check(CaelumSupportMagic.Apply(user,enemy,0),"native status attaches");
        let effect=CaelumSupportMagic.Status(enemy);Advance(effect,35);
        Check(enemy.health==990 && !effect.AnyActive,"one second curse health and expiry");
        Check(CaelumSupportMagic.Factor(enemy)==1,"book leaves secondary factor neutral");
        Clear(enemy);enemy.CombatMaximumHealth=73;enemy.health=73;
        CaelumSupportMagic.Apply(user,enemy,0);effect=CaelumSupportMagic.Status(enemy);Advance(effect,35);
        Check(enemy.health==73 && Near(effect.HealthFraction[0],0.73),"native fractional health retained");
        CaelumSupportMagic.Apply(user,enemy,0);Advance(effect,35);
        Check(enemy.health==72 && Near(effect.HealthFraction[0],0.46),"fraction carries across applications");
        Clear(enemy);enemy.CombatMaximumHealth=1000;enemy.health=500;
        user.Attributes.Charisma=100;CaelumSupportMagic.Apply(user,enemy,0);
        effect=CaelumSupportMagic.Status(enemy);Advance(effect,35);enemy.CombatMaximumHealth=2000;Advance(effect,35);
        Check(enemy.health==380,"native health uses changing maximum");
        Check(Near(effect.Effects[0].RemainingSeconds,2),"native scaled duration advances");
        Clear(enemy);enemy.CombatMaximumHealth=1000;enemy.health=1000;
        user.Attributes.Charisma=0;CaelumSupportMagic.Apply(user,enemy,0);CaelumSupportMagic.Apply(user,enemy,3);
        effect=CaelumSupportMagic.Status(enemy);
        Check(effect.Effects[0]!=effect.Effects[3] && Near(effect.Factor(3),1.01),"book and effigy separate stacks");
        effect.Apply(3,ally,100);
        Check(effect.Effects[3].IntensityPercent==5 && effect.Effects[3].RemainingSeconds==4 && effect.Effects[0].IntensityPercent==1,"casters share only same implement stack");
        effect.Apply(2,ally,100);
        Check(Near(CaelumSupportMagic.Factor(enemy),1.04/1.05),"opposite modifiers coexist");
        double baseSpeed=enemy.CombatBaseSpeed;enemy.UpdateCombatHealthEffects();double currentSpeed=enemy.Speed;
        enemy.UpdateCombatHealthEffects();
        Check(Near(enemy.Speed,currentSpeed) && enemy.CombatBaseSpeed==baseSpeed,"movement recalculation does not drift");
        effect.Effects[2].Advance(10,1000);effect.Effects[3].Advance(10,1000);enemy.UpdateCombatHealthEffects();
        Check(Near(enemy.Speed/currentSpeed,1.05/1.04),"movement cache observes expiry");
        Clear(enemy);enemy.health=1000;
        CaelumSupportMagic.Apply(user,enemy,3);effect=CaelumSupportMagic.Status(enemy);
        for(int i=1;i<100;i++)effect.Apply(3,user,0);
        enemy.DamageMobj(null,user,100,'CaelumElementalDOT',DMG_FORCED|DMG_NO_ARMOR,0);
        Check(enemy.health==800,"native received damage uses inverse curse factor");
        Clear(enemy);Clear(user);enemy.health=1000;
        CaelumSupportMagic.Apply(user,user,2);let benefit=CaelumSupportMagic.Status(user);
        for(int i=1;i<100;i++)benefit.Apply(2,user,0);
        enemy.DamageMobj(null,user,100,'CaelumElementalDOT',DMG_FORCED|DMG_NO_ARMOR,0);
        Check(enemy.health==800,"native dealt damage uses benefit factor");
        Clear(user);enemy.health=1000;
        let seal=CaelumEquipmentItem(Actor.Spawn("CaelumSealPickup",enemy.Pos,NO_REPLACE));seal.AttachToOwner(enemy);
        seal.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_SEAL;seal.ItemType=CaelumConstants.SEAL_QUINTESSENCE;
        seal.PickupDataInitialized=true;seal.Equipped=true;
        CaelumSupportMagic.Apply(user,enemy,3);effect=CaelumSupportMagic.Status(enemy);
        Check(Near(effect.Factor(3),1.0085) && effect.Effects[3].RemainingSeconds==1,"seal reduces secondary intensity without duration");
        Clear(enemy);CaelumSupportMagic.Apply(user,enemy,0);effect=CaelumSupportMagic.Status(enemy);Advance(effect,35);
        Check(enemy.health==992 && Near(effect.HealthFraction[0],0.5),"seal reduces health intensity exactly once");
        effect.Apply(2,user,100);
        Check(Near(effect.Factor(2),1.04),"seal never reduces benefit");seal.Destroy();
        Clear(enemy);Clear(ally);ally.health=500;
        CaelumSupportMagic.Apply(user,ally,1);CaelumSupportMagic.Apply(user,ally,2);
        effect=CaelumSupportMagic.Status(ally);Advance(effect,35);
        Check(ally.health==520,"censer and statuette health contributions sum");
        Clear(ally);ally.health=999;CaelumSupportMagic.Apply(user,ally,1);effect=CaelumSupportMagic.Status(ally);Advance(effect,35);
        Check(ally.health==1000 && effect.HealthFraction[1]==0,"healing caps at current maximum");
        Clear(enemy);Clear(ally);
        int affected=CaelumSupportMagic.ApplyArea(user,(64,0,32),0,128);
        Check(affected==1 && CaelumSupportMagic.Status(enemy)!=null && CaelumSupportMagic.Status(ally)==null,"local area filters teams");
        Clear(enemy);enemy.SetOrigin((320,0,0),false);
        Check(CaelumSupportMagic.ApplyArea(user,(64,0,32),0,128)==0,"area range excludes distant actor");
        enemy.SetOrigin((64,0,0),false);user.Pitch=VectorAngle(192,user.ViewHeight-32);
        Check(CaelumSupportMagic.Release(user,CaelumConstants.WEAPON_TYPE_EFFIGY,false),"native aim applies single curse");
        Check(!CaelumSupportMagic.Release(user,CaelumConstants.WEAPON_TYPE_EFFIGY,true),"curse secondary inert");
        Check(CaelumSupportMagic.Release(user,CaelumConstants.WEAPON_TYPE_SUPPORT_STATUETTE,true),"native secondary self benefit");
        Clear(user);Clear(enemy);
        for(int role=0;role<4;role++)
        {
            int type=CaelumConstants.WEAPON_TYPE_SUPPORT_BOOK+role;
            int recipe=CaelumSupportImplementData.FIRST_RECIPE+role;
            Check(user.GetWeaponFamilyForType(type)==0 && user.GetNativeWeaponSelectorClass(type,4,1)!='',String.Format("support native slot role %d",role));
            Check(CaelumCraftingRules.GetUnifiedEssenceWeaponType(recipe)==type && CaelumCraftingRules.GetUnifiedEssenceType(recipe)==4,String.Format("recipe identity role %d",role));
            Check(CaelumSupportImplementData.ValidEssence(type,4) && !CaelumSupportImplementData.ValidEssence(type,0),String.Format("support essence restriction role %d",role));
            double weight=user.WeaponModel.GetWeightFor(type,1,CaelumConstants.EQUIPMENT_SIZE_M);
            Check(Near(weight,role==0?6:role==1?5:8),String.Format("approved mass role %d",role));
            double price=Ceil(1.5*CaelumEconomyRules.GetEquipmentBaseValueFor(CaelumConstants.EQUIPMENT_KIND_WEAPON,type,0,1,4,weight));
            Check(price==(role==0?741094:role==1?668335:971250),String.Format("derived purchase price role %d actual %.0f",role,price));
            let quote=new("CaelumRecipeQuote");quote.Build(user,recipe,1,CaelumConstants.EQUIPMENT_SIZE_M);
            Check(quote.ManufactureSeconds>0 && quote.CompleteManufactureSeconds>quote.ManufactureSeconds,String.Format("manufacturing tree role %d",role));
        }
        for(int role=0;role<4;role++)
        {
            int type=role==0?CaelumConstants.WEAPON_TYPE_STAFF:CaelumConstants.WEAPON_TYPE_BELL+role-1;
            Check(user.GetNativeWeaponSelectorClass(type,4,1)=='' && CaelumRecipeLearning.Slot(36+role*5,1)<0,String.Format("retired offensive quintessence role %d",role));
        }
        let vendor=CaelumCityMerchant(Actor.Spawn("CaelumCityMerchant",(192,192,0),NO_REPLACE));vendor.Category=5;
        vendor.EnsureStock(user);int products=vendor.Products.Size();int wallet=vendor.WalletCopper;
        CaelumSupportCatalogue.Ensure(vendor,user);
        Check(vendor.Products.Size()==products && vendor.WalletCopper==wallet,"shop migration idempotent preserves wallet");
        int supports=0,retired=0;for(int i=0;i<vendor.Products.Size();i++)
        {let p=vendor.Products[i];if(p.Kind==CaelumShopProduct.EQUIPMENT && CaelumSupportImplementData.IsSupport(p.ItemType))supports++;if(CaelumSupportCatalogue.Retired(p))retired++;}
        Check(supports==20 && retired==0,"magic shop stocks all support sizes without offensive quintessence");
        let old=CaelumEquipmentItem(Actor.Spawn("CaelumWeaponPickup",user.Pos,NO_REPLACE));
        old.ItemType=18;old.EssenceType=4;old.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;
        old.PickupDataInitialized=true;old.ItemId=9001;old.Equipped=true;old.AttachToOwner(user);
        user.ActiveWeaponItemId=9001;user.WeaponModel.WeaponType=18;user.WeaponModel.EssenceType=4;user.WeaponModel.Equipped=true;
        Check(!old.MigrateSupportImplement() && user.FindNativeEquipmentItemById(9001)==null && user.ActiveWeaponItemId==0,"retire active quintessence item and active identity");
        let kept=CaelumEquipmentItem(Actor.Spawn("CaelumWeaponPickup",user.Pos,NO_REPLACE));
        kept.ItemType=18;kept.EssenceType=0;kept.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;
        kept.PickupDataInitialized=true;kept.ItemId=9002;kept.Tier=3;kept.Durability=123;kept.AttachToOwner(user);
        Check(kept.MigrateSupportImplement() && kept.MigrateSupportImplement() && kept.ItemId==9002 && kept.Tier==3 && kept.Durability==123 && kept.ItemType==18,"legacy scepter preserves ID tier wear and migration is idempotent");
        kept.Destroy();
        vendor.SupportCatalogueRevision=0;vendor.WalletCopper=42;
        CaelumShopProduct preserved=null;
        for(int i=vendor.Products.Size()-1;i>=0;i--)
        {
            let p=vendor.Products[i];
            if(p.Kind==CaelumShopProduct.EQUIPMENT && CaelumSupportImplementData.IsSupport(p.ItemType))
            {if(p.Stock!=null)p.Stock.Destroy();vendor.Products.Delete(i);}
            else if(p.Kind==CaelumShopProduct.EQUIPMENT){preserved=p;p.NextDue=12345;if(p.Stock!=null)p.Stock.Amount=3;}
        }
        CaelumSupportCatalogue.Ensure(vendor,user);
        Check(vendor.Products.Size()==products && vendor.WalletCopper==42 && preserved!=null && preserved.Stock.Amount==3,"old shop appends new products preserving existing stock and money");
        vendor.Destroy();enemy.Destroy();ally.Destroy();
        Console.Printf("CA479 RESULT gameplay passed=%d failed=%d",Passed,Failed);
    }
    override void NetworkProcess(ConsoleEvent event)
    {
        if(level.MapName!="CSUP479")return;
        let user=CaelumPlayer(players[event.Player].mo);if(user==null)return;
        if(event.Name=="ca479_gameplay")Checks(user);
        if(event.Name=="ca479_tickseed")
        {
            SavedBody=Body((128,0,0));SavedBody.Live=true;SavedBody.CombatToughness=0;
            user.Attributes.Charisma=100;CaelumSupportMagic.Apply(user,SavedBody,0);
            SavedAt=level.time;SavedMaximum=SavedBody.CombatMaximumHealth;
            Console.Printf("CA479 RESULT live save prepared tic=%d maximum=%d",SavedAt,SavedMaximum);
        }
        if(event.Name=="ca479_tickcheck")
        {
            Check(SavedBody!=null,"live receiver reference survives load");
            let effect=CaelumSupportMagic.Status(SavedBody);
            Check(effect!=null && effect.Sources[0]==user,"native receiver inventory and caster serialized");
            if(effect!=null)
            {
                double expected=Max(0,4-(level.time-SavedAt)/double(TICRATE));
                Check(Abs(effect.Effects[0].RemainingSeconds-expected)<=1.01/TICRATE,"native tick duration matches world elapsed time");
                Check(SavedBody.health<SavedMaximum,"native ticks deliver curse health");
                Console.Printf("CA479 STATE live tic=%d elapsed=%d health=%d remaining=%.9f fraction=%.9f",level.time,level.time-SavedAt,SavedBody.health,effect.Effects[0].RemainingSeconds,effect.HealthFraction[0]);
            }
            Console.Printf("CA479 RESULT live passed=%d failed=%d",Passed,Failed);
        }
    }
}
