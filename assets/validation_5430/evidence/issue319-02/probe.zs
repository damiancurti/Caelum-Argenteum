// Isolated #319 native inventory input and identity checks.
class CA319Probe : CA282Probe
{
    CaelumSleepingBag Bag;
    void Seed()
    {
        Setup();Input();
        User.PersistCharacterState();CaelumWorldClock.Get(User,true);
        Bag=CaelumSleepingBag(User.FindInventory('CaelumSleepingBag'));
        if(Bag==null)Bag=CaelumSleepingBag(User.GiveInventoryType('CaelumSleepingBag'));
        Bag.args[0]=319;Bag.InMagicBox=false;
        User.InvSel=Bag;User.OnNativeInventoryChanged();
        Check(Bag.bInvBar && User.InvSel==Bag && Bag.Icon.IsValid(),"carried bag selected with existing icon");
    }
    void Identity()
    {
        User=CaelumPlayer(players[consoleplayer].mo);
        Bag=CaelumSleepingBag(User.FindInventory('CaelumSleepingBag'));
        int count=0;for(Inventory i=User.Inv;i!=null;i=i.Inv)if(i is 'CaelumSleepingBag')count++;
        Check(Bag!=null && count==1 && Bag.Amount==1 && Bag.args[0]==319,"one original bag retained");
        Check(User.InvSel==Bag && Bag.bInvBar,"saved or travelled bag selection retained");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        Super.NetworkProcess(e);
        if(e.Name=="c319_seed")Seed();
        if(e.Name=="c319_manual"){Seed();Manual=true;}
        if(e.Name=="c319_next")Check(User.InvSel!=Bag && CaelumQuickUse.Eligible(User,User.InvSel),"native next reaches consumable");
        if(e.Name=="c319_prev")Check(User.InvSel==Bag,"native previous returns to bag");
        if(e.Name=="c319_open")Manual=true;
        if(e.Name=="c319_opened")
        {
            int count=0;CaelumRestGuide guide;let it=ThinkerIterator.Create('CaelumRestGuide');
            while((guide=CaelumRestGuide(it.Next()))!=null)
                if(guide.Subject==User){count++;Check(guide.UsesBag && guide.Bag==Bag,"rest guide holds exact selected bag");}
            Check(count==1 && User.HasActiveConversation(),"repeated native invuse opens one rest interaction");
            Check(Bag.Owner==User && Bag.Amount==1,"native invuse never consumes bag");
        }
        if(e.Name=="c319_close")Manual=false;
        if(e.Name=="c319_storage")
        {
            User.EquipmentSelectionKind=CaelumConstants.EQUIPMENT_KIND_KEY_ITEM;
            User.EquipmentSelectionSpecialType=CaelumConstants.KEY_ITEM_SLEEPING_BAG;
            User.ToggleSelectedMagicBox();CaelumQuickUse.Reconcile(User);
            Check(Bag.InMagicBox && !Bag.bInvBar && User.InvSel!=Bag,"actual Box storage excludes bag");
            Check(!User.UseInventory(Bag) && Bag.Amount==1,"boxed bag cannot open or be consumed");
            User.ToggleSelectedMagicBox();CaelumQuickUse.Reconcile(User);
            Check(!Bag.InMagicBox && Bag.bInvBar,"Box retrieval restores eligibility");
            User.InvSel=Bag;
        }
        if(e.Name=="c319_block")
        {
            User.CombatTimeRemaining=10;
            Check(!User.UseInventory(Bag) && Bag.Amount==1,"combat blocks opening without consuming bag");
            User.CombatTimeRemaining=0;User.SetOrigin((500,0,0),false);User.Vel=(0,0,0);
            Check(!Bag.BeginRest(User,5) && Bag.Amount==1,"wall blocks deployment without consuming bag");
            User.SetOrigin((0,0,0),false);User.Vel=(0,0,0);
        }
        if(e.Name=="c319_rest")
        {
            Console.Printf("CA319 REST reason=%s room=%d onground=%d velocity=%s",CaelumRestState.BlockReason(User),CaelumRestBag.HasRoom(User),User.player.onground,String.Format("%s",User.Vel));
            Check(Bag.BeginRest(User,5),"ordinary rest deploys exact bag");
            let rest=CaelumRestState.Get(User);
            let mat=rest==null?null:CaelumRestBag(rest.Furniture);
            Check(mat!=null && mat.Bag==Bag,"deployed mat references owned bag");
            CaelumRestState.Cancel(User);
            Check(Bag.Owner==User && Bag.Amount==1,"standing retains original bag");
        }
        if(e.Name=="c319_identity")Identity();
        if(e.Name=="c319_drop")
        {
            User.EquipmentSelectionKind=CaelumConstants.EQUIPMENT_KIND_KEY_ITEM;
            User.EquipmentSelectionSpecialType=CaelumConstants.KEY_ITEM_SLEEPING_BAG;
            User.DropSelectedNativeInventoryItem();CaelumQuickUse.Reconcile(User);
            Check(!CaelumQuickUse.Eligible(User,Bag) && User.InvSel!=Bag,"drop removes native selection");
            CaelumSleepingBag ground;let it=ThinkerIterator.Create('CaelumSleepingBag');
            while((ground=CaelumSleepingBag(it.Next()))!=null)if(ground.Owner==null && !ground.bDestroyed)break;
            Actor receiver=User;
            Check(ground!=null && ground.CallTryPickup(receiver),"normal pickup restores bag");
            Bag=CaelumSleepingBag(User.FindInventory('CaelumSleepingBag'));User.InvSel=Bag;Identity();
        }
    }
}
