// Fixture compatible con 5.7.0 y el esquema nuevo; cantidades sólo diagnósticas.
class CA405LegacyMark : Inventory
{
    CaelumCityMerchant Vendor;
    int Wallet,ProductCount,Stock;
    double Due;
    Default { +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE Inventory.MaxAmount 1; }
}
class CA405Legacy : StaticEventHandler
{
    bool Measuring,Finished;
    int MeasureTic;
    ui bool Flushed;
    ui double LastFrame;
    ui Array<double> FrameMS;
    override void WorldTick()
    {
        if(Measuring && !Finished && level.time-MeasureTic>=350)
        {Finished=true;Console.Printf("CA405 PERF END tic=%d ms=%.6f",level.time,MSTimeF());}
    }
    override void RenderOverlay(RenderEvent e)
    {
        double now=MSTimeF();
        if(Measuring && !Finished){if(LastFrame>0)FrameMS.Push(now-LastFrame);LastFrame=now;}
        if(Finished && !Flushed){Flushed=true;for(int i=0;i<FrameMS.Size();i++)Console.Printf("CA405 FRAME %.6f",FrameMS[i]);Console.Printf("CA405 FRAMES_END count=%d",FrameMS.Size());}
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=="ca405_perf")
        {
            u.bInvulnerable=true;u.DebugAttributesAt100=true;u.ApplyCharacterProfile();u.CreationWizardOpen=false;
            Vector3 pos=level.MapName=="MAP01"?(-1904,832,0):(-30320,320,0);
            let sector=level.PointInSector(pos.XY);pos.Z=sector.FloorPlane.ZatPoint(pos.XY);u.SetOrigin(pos,false);
            u.Angle=0;u.Pitch=20;Measuring=true;MeasureTic=level.time;
            Console.Printf("CA405 PERF BEGIN tic=%d ms=%.6f",level.time,MSTimeF());
            Console.Printf("CA405 LEGACY presentation measurement started");
        }
        else if(e.Name=="ca405_legacy_save")
        {
            u.bInvulnerable=true;u.DebugAttributesAt100=true;u.ApplyCharacterProfile();u.CreationWizardOpen=false;
            let r=u.GetPersistentCharacterState(true);r.MainM00SupplyIssued[79]=17;r.MainM00SupplyLimit[80]=23;
            let mark=CA405LegacyMark(u.GiveInventoryType("CA405LegacyMark"));
            let v=CaelumCityMerchant(Actor.Spawn("CaelumCityMerchant",u.Pos+(48,0,0),NO_REPLACE));
            v.Category=0;v.EnsureStock(u);v.WalletCopper=12345;
            mark.Vendor=v;mark.Wallet=v.WalletCopper;mark.ProductCount=v.Products.Size();
            v.Products[0].Stock.Amount=321;mark.Stock=321;mark.Due=v.RestockNextDue;
            u.CurrentThirst=100;u.PersistCharacterState();
            Console.Printf("CA405 LEGACY prepared old material array and provision vendor");
        }
        else if(e.Name=="ca405_legacy_verify")
        {
            let r=u.GetPersistentCharacterState(true);let mark=CA405LegacyMark(u.FindInventory("CA405LegacyMark"));
            bool ok=r.MainM00SupplyIssued[79]==17 && r.MainM00SupplyLimit[80]==23 && mark!=null
                && mark.Vendor.WalletCopper==12345 && mark.Vendor.Products.Size()==mark.ProductCount
                && mark.Vendor.Products[0].Stock.Amount==321;
            Console.Printf("CA405 %s untouched baseline save rolls back",ok?"PASS":"FAIL");
            Console.Printf("CA405 LEGACY failed=%d",ok?0:1);
        }
    }
}
