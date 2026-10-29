class CA502DiningChecks : CA410DiningChecks
{
    CaelumDiningTable Table()
    {let it=ThinkerIterator.Create('CaelumDiningTable');CaelumDiningTable t;while((t=CaelumDiningTable(it.Next()))!=null)if(t.Blocks[1]!=null)return t;return null;}
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name!="ca502d_legacyseed" && e.Name!="ca502d_legacyload")return;
        Profile(u);let t=Table();Check(t!=null,"original table exists");if(t==null)return;
        if(e.Name=="ca502d_legacyseed")
        {
            CaelumContaminationStorage.Set(t,30);
            CaelumContaminationStorage.Set(t.Blocks[0],80);
            CaelumContaminationStorage.Set(t.Blocks[1],60);
        }
        Check(Near(CaelumContaminationStorage.Value(t),30),"original table independent value");
        Check(Near(CaelumContaminationStorage.Value(t.Blocks[0]),80),"original first proxy value");
        Check(Near(CaelumContaminationStorage.Value(t.Blocks[1]),60),"original second proxy value");
        Result();
    }
}
