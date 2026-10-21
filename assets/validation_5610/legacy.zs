// El mismo fixture carga en 5.5.8a y en la versión revisada.
class CA383LegacyMark : Inventory
{
    CaelumCityMerchant Library,Clothing;
    CaelumEquipmentItem OldItem;
    int LibraryCount,ClothingCount,Identity,Wear,Size,Wallet;
    Default { +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE Inventory.MaxAmount 1; }
}
class CA383Legacy : CA377Checks
{
    int Items(Actor owner)
    {int n=0;for(Inventory i=owner.Inv;i!=null;i=i.Inv)n++;return n;}
    void Snapshot(CaelumPlayer u)
    {
        Prepare(u);Money(u);
        let a=CaelumCityMerchant.Find(34),b=CaelumCityMerchant.Find(35);
        Check(a!=null && b!=null && a.Category==4 && b.Category==5,"real legacy city has original repeated shops");
        a.EnsureStock(u);b.EnsureStock(u);
        let item=CaelumEquipmentItem(a.Inv);item.Durability=17;
        a.RemoveInventory(item);item.AttachToOwner(u);u.EnsureEquipmentItemId(item);u.RemoveInventory(item);item.AttachToOwner(a);
        // Retirar otra pieza deja una tienda previamente agotada parcialmente.
        b.Inv.Destroy();a.WalletCopper=37;b.WalletCopper=51;
        let m=CA383LegacyMark(Actor.Spawn("CA383LegacyMark",u.Pos,NO_REPLACE));m.AttachToOwner(u);
        m.Library=a;m.Clothing=b;m.OldItem=item;m.LibraryCount=Items(a);m.ClothingCount=Items(b);
        m.Identity=item.ItemId;m.Wear=item.Durability;m.Size=item.EquipmentSize;m.Wallet=a.WalletCopper;
        u.PersistCharacterState();Check(m.LibraryCount>0 && m.ClothingCount>0,"legacy snapshot includes exact worn item and depleted initialized stock");
    }
    void Original(CaelumPlayer u)
    {
        let m=CA383LegacyMark(u.FindInventory("CA383LegacyMark"));Check(m!=null,"legacy marker survives");if(m==null)return;
        Check(m.Library.Category==4 && m.Clothing.Category==5,"original runtime retains original categories");
        Check(Items(m.Library)==m.LibraryCount && Items(m.Clothing)==m.ClothingCount,"original stock remains depleted");
        Check(m.OldItem.Owner==m.Library && m.OldItem.ItemId==m.Identity && m.OldItem.Durability==m.Wear,"original exact item survives rollback");
        Check(m.Library.WalletCopper==37 && m.Clothing.WalletCopper==51,"original wallets unchanged");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[0].mo);if(u==null)return;
        if(e.Name=="ca383_legacy_save")Snapshot(u);
        if(e.Name=="ca383_rollback")Original(u);
        if(e.Name=="ca383_legacy_save" || e.Name=="ca383_rollback")Console.Printf("CA383 LEGACY passed=%d failed=%d",Passed,Failed);
    }
}
