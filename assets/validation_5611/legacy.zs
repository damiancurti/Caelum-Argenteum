// El mismo estado se guarda con 5.5.8a y se carga con ambos motores de juego.
class CA385LegacyMark : Inventory
{
    CaelumCityMerchant Vendor;
    Inventory Ammo;
    CaelumEnvironmentProp Node,Finite;
    int Stock,Wallet,Quota,CalendarId;
    double Capacity,Remaining,Carry,Stamp;
    Default { +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE Inventory.MaxAmount 1; }
}
class CA385Legacy : CA377Checks
{
    void Snapshot(CaelumPlayer u)
    {
        Prepare(u);Money(u);let clock=CaelumWorldClock.Get(u,true);
        CaelumCalendarState.Get(u,true).EnsureCampaign(clock);
        let v=Vendor(u,2);v.StockInitialized=false;v.Revision=0;v.EnsureStock(u);v.ShopIdentity=3385;v.WalletCopper=37;
        let ammo=v.FindInventory("CaelumArrowAmmo");ammo.Amount-=5;
        let node=CaelumEnvironmentProp(Actor.Spawn("CaelumTreeCityTipa",(320,320,0),NO_REPLACE));
        node.EnsureResourceState();node.SyncResourceClock();
        double extracted=node.TryExtractResource(u,node.GetRequiredHarvestDamageType(),100.5);
        let finite=CaelumEnvironmentProp(Actor.Spawn("CaelumTutorialGoldVein",(-320,320,0),NO_REPLACE));
        finite.EnsureResourceState();finite.ResourceRemainingUnits=17;finite.ResourceYieldCarry=0.25;
        let r=u.GetPersistentCharacterState(true);r.MainM00SupplyIssued[CaelumConstants.MATERIAL_WOOD]=19;
        let m=CA385LegacyMark(Actor.Spawn("CA385LegacyMark",u.Pos,NO_REPLACE));m.AttachToOwner(u);
        m.Vendor=v;m.Ammo=ammo;m.Stock=ammo.Amount;m.Wallet=v.WalletCopper;m.Quota=19;
        m.Node=node;m.Finite=finite;m.Capacity=node.GetResourceCapacityUnits();m.Remaining=node.ResourceRemainingUnits;
        m.Carry=node.ResourceYieldCarry;m.Stamp=node.ResourceClockStamp;m.CalendarId=node.ResourceCalendarId;
        u.PersistCharacterState();
        Check(extracted>0 && m.Carry>0 && m.CalendarId>0,"legacy snapshot has extracted fractional node and recovery calendar");
        Check(m.Stock>0 && m.Stock<1000,"legacy merchant saved depleted with finite wallet");
    }
    void Original(CaelumPlayer u)
    {
        let m=CA385LegacyMark(u.FindInventory("CA385LegacyMark"));Check(m!=null,"legacy marker survives rollback");if(m==null)return;
        Check(m.Ammo.Owner==m.Vendor && m.Ammo.Amount==m.Stock && m.Vendor.WalletCopper==37,"original package and save retain stock and wallet");
        Check(m.Node.ResourceYieldCarry==m.Carry && m.Node.ResourceCalendarId==m.CalendarId,"original node fraction and agenda identity retained");
        Check(m.Finite.ResourceRemainingUnits==17 && u.GetPersistentCharacterState(false).MainM00SupplyIssued[CaelumConstants.MATERIAL_WOOD]==19,"finite salvage and tutorial quota remain depleted");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[0].mo);if(u==null)return;
        if(e.Name=="ca385_legacy_save")Snapshot(u);
        if(e.Name=="ca385_rollback")Original(u);
        if(e.Name=="ca385_legacy_save" || e.Name=="ca385_rollback")Console.Printf("CA385 LEGACY passed=%d failed=%d",Passed,Failed);
    }
}
