// Prueba aislada: los objetos siguen usando su Inventory y Use de producción.
class CA282Probe : StaticEventHandler
{
    CaelumPlayer User;
    int Passed,Failed;
    bool Manual;
    CaelumConsumableItem Food,Life;
    void Check(bool ok,String label)
    {
        if(ok)Passed++;else Failed++;Console.Printf("CA282 %s %s",ok?"PASS":"FAIL",label);
        if(!ok && User!=null)
        {
            Console.Printf("CA282 selection=%s",User.InvSel==null?"none":String.Format("%s",User.InvSel.GetClassName()));
            for(Inventory i=User.Inv;i!=null;i=i.Inv)if(CaelumQuickUse.Eligible(User,i))
                Console.Printf("CA282 eligible=%s amount=%d",i.GetClassName(),i.Amount);
        }
    }
    override void UiTick()
    {
        if(!Manual && Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();
    }
    void Setup()
    {
        User=CaelumPlayer(players[consoleplayer].mo);
        User.CharacterCreationComplete=true;User.CreationWizardOpen=false;User.ApplyCharacterProfile();
        User.GrantMagicBoxFromPalomo(false);
        User.bInvulnerable=true;User.CurrentSleep=User.CurrentLucidity=100;
        User.CurrentHunger=User.CurrentThirst=50;User.Angle=User.Pitch=0;
        for(Inventory item=User.Inv;item!=null;)
        {Inventory next=item.Inv;if(item is "CaelumConsumableItem" || item is "CaelumCarbineAmmo")item.Destroy();item=next;}
        CaelumQuickUse.Reconcile(User);
    }
    CaelumConsumableItem Give(Name kind,int quantity)
    {
        let item=CaelumConsumableItem(Actor.Spawn(kind));item.AttachToOwner(User);item.Amount=quantity;
        return item;
    }
    void Input()
    {
        // Evitar la alimentación automática aprobada por debajo del 50 %.
        User.CurrentHunger=User.CurrentThirst=75;
        Food=Give('CaelumFoodRation',3);Life=Give('CaelumLifePotion',2);
        User.InvSel=Food;User.OnNativeInventoryChanged();
    }
    void Checks()
    {
        Check(User.InvSel==null,"empty selection");
        Input();Check(User.InvSel==Food,"existing native selection kept");
        Check(CaelumQuickUse.Eligible(User,Food),"personal stock eligible");
        Check(Food.Icon.IsValid(),"existing owned icon valid");
        Life.InMagicBox=true;CaelumQuickUse.Reconcile(User);
        Check(!Life.bInvBar && !CaelumQuickUse.Eligible(User,Life),"boxed stock excluded");
        Check(!User.UseInventory(Life) && Life.Amount==2,"boxed use rejected without consumption");
        let ammo=Inventory(Actor.Spawn('CaelumCarbineAmmo'));ammo.AttachToOwner(User);
        CaelumQuickUse.Reconcile(User);Check(!ammo.bInvBar,"ammunition excluded from Use");
        int before=Food.Amount;Check(User.UseInventory(Food),"existing consumable use");
        Check(Food.Amount==before-1,"one unit consumed");
        Check(User.FindInventory('CaelumHungerRegeneration')!=null,"existing regeneration created");
        Food.Amount=1;Check(User.UseInventory(Food),"last unit use");
        CaelumQuickUse.Reconcile(User);Check(User.InvSel==null,"no ghost after final unit");
        Life.InMagicBox=false;User.OnNativeInventoryChanged();
        Check(User.InvSel==Life && Life.bInvBar,"retrieval restores selection");
        Life.InMagicBox=true;User.OnNativeInventoryChanged();
        Check(User.InvSel==null,"storage removes selection");
        let water=CaelumWaterContainer(Give('CaelumCanteenNormal',1));water.WaterLiters=0.5;
        User.CurrentThirst=50;CaelumQuickUse.Reconcile(User);
        Check(User.InvSel==water && water.bInvBar,"individual water container selected");
        Check(User.UseInventory(water),"native use delegates to Drink");
        Check(water.Amount==1 && water.Owner==User && water.WaterLiters<0.5,"water used without consuming container");
        water.WaterLiters=0;Check(!User.UseInventory(water) && water.Amount==1,"empty container unavailable retained");
        water.WaterLiters=0.5;User.CurrentThirst=100;
        Check(!User.UseInventory(water) && water.WaterLiters==0.5,"sated Drink unchanged");
        water.InMagicBox=true;User.OnNativeInventoryChanged();
        Check(User.InvSel==null && !User.UseInventory(water),"boxed container inaccessible");
        water.InMagicBox=false;User.RemoveInventory(water);CaelumQuickUse.Reconcile(User);
        Check(User.InvSel==null && !User.UseInventory(water),"detached identity rejected");
        water.Destroy();Life.InMagicBox=false;CaelumQuickUse.Reconcile(User);
        Check(User.InvSel==Life && Life.Amount==2,"reconcile never grants stock");
        Life.Amount=0;CaelumQuickUse.Reconcile(User);Check(User.InvSel==null,"depleted retained stack hidden");
    }
    void Transfers()
    {
        Input();User.EquipmentSelectionKind=CaelumConstants.EQUIPMENT_KIND_CONSUMABLE;
        User.EquipmentSelectionConsumableType=Food.GetConsumableType();
        User.ToggleSelectedMagicBox();CaelumQuickUse.Reconcile(User);
        Check(Food.InMagicBox && User.InvSel==Life && Food.Amount==3,"actual Box storage removes selected stock");
        User.ToggleSelectedMagicBox();CaelumQuickUse.Reconcile(User);
        Check(!Food.InMagicBox && Food.bInvBar && Food.Amount==3,"actual Box retrieval preserves quantity");
        User.InvSel=Food;User.DropSelectedNativeInventoryItem();CaelumQuickUse.Reconcile(User);
        Check(!CaelumQuickUse.Eligible(User,Food) && User.InvSel==Life,"actual drop removes selection");
        let actors=ThinkerIterator.Create('CaelumFoodRation');CaelumConsumableItem dropped,candidate;
        while((candidate=CaelumConsumableItem(actors.Next()))!=null)if(candidate.Owner==null && !candidate.bDestroyed){dropped=candidate;break;}
        Check(dropped!=null && dropped.Amount==3,"drop preserves whole stack");
        Actor toucher=User;
        Check(dropped!=null && dropped.CallTryPickup(toucher),"actual pickup succeeds");
        Food=CaelumConsumableItem(User.FindInventory('CaelumFoodRation'));
        Check(Food!=null && Food.Amount==3 && Food.bInvBar,"pickup refreshes available stock");
        let water=CaelumWaterContainer(Give('CaelumCanteenNormal',1));water.WaterLiters=1.5;
        let bottle=CaelumWaterContainer(Give('CaelumBottleSmall',1));bottle.WaterLiters=0.25;
        User.InvSel=water;CaelumQuickUse.Reconcile(User);User.UseInventory(water);
        Check(water.WaterLiters<1.5 && bottle.WaterLiters==0.25,"separate container identity and contents");
        User.EquipmentSelectionConsumableType=water.GetConsumableType();
        User.DropSelectedNativeInventoryItem();CaelumQuickUse.Reconcile(User);
        Check(!CaelumQuickUse.Eligible(User,water) && User.InvSel!=water,"container drop clears exact selection");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="c282_setup")Setup();
        if(e.Name=="c282_checks")Checks();
        if(e.Name=="c282_transfers")Transfers();
        if(e.Name=="c282_input")Input();
        if(e.Name=="c282_manual")
        {
            Input();let water=CaelumWaterContainer(Give('CaelumCanteenNormal',1));water.WaterLiters=1.5;
            Give('CaelumAnimaPotion',2);Manual=true;CaelumQuickUse.Reconcile(User);
        }
        if(e.Name=="c282_next")Check(User.InvSel==Life,"native invnext");
        if(e.Name=="c282_prev")Check(User.InvSel==Food,"native invprev");
        if(e.Name=="c282_used")Check(Food.Amount==2 && Life.Amount==2,"native invuse consumes displayed item once");
        if(e.Name=="c282_single")
        {Life.Destroy();CaelumQuickUse.Reconcile(User);Check(User.InvSel==Food,"single item retained");}
        if(e.Name=="c282_single_check")Check(User.InvSel==Food && Food.Amount==2,"single item wraps without consumption");
        if(e.Name=="c282_empty_check")Check(User.InvSel==null && User.FindInventory('CaelumFoodRation')==null,"repeated use depletes once and empty commands are safe");
        if(e.Name=="c282_loaded")
        {
            User=CaelumPlayer(players[consoleplayer].mo);let food=User.FindInventory('CaelumFoodRation');
            Check(CaelumQuickUse.Eligible(User,User.InvSel),"loaded valid native selection");
            Check(User.InvSel==food && food.Amount==3,"loaded selection and stock preserved");
        }
        if(e.Name=="c282_legacy")
        {
            User=CaelumPlayer(players[consoleplayer].mo);
            let life=CaelumConsumableItem(User.FindInventory('CaelumLifePotion'));
            let water=CaelumWaterContainer(User.FindInventory('CaelumCanteenNormal'));
            let food=User.FindInventory('CaelumFoodRation');
            Check(CaelumQuickUse.Eligible(User,User.InvSel),"old invalid selection resolves to an owned usable item");
            Check(food!=null && food.Amount==3 && life!=null && life.Amount==2,"old stock preserved without consumption or duplication");
            Check(life!=null && life.InMagicBox && !life.bInvBar && User.InvSel!=life,"old boxed selection reconciled safely");
            Check(water!=null && water.bInvBar && water.Amount==1 && water.WaterLiters==1.5,"old container enabled without changing contents");
        }
        if(e.Name=="c282_done")Console.Printf("CA282 DONE passes=%d failures=%d",Passed,Failed);
    }
}
