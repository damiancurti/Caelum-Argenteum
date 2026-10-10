class CA160Reload : StaticEventHandler
{
    int Elapsed,Passed,Failed;
    void Check(String label,bool ok)
    {if(ok)Passed++;else Failed++;Console.Printf("CA160 %s %s",ok?"PASS":"FAIL",label);}
    override void WorldTick()
    {
        Elapsed++;if(Elapsed!=20)return;
        let u=CaelumPlayer(players[0].mo);if(u==null)return;
        let it=ThinkerIterator.Create("CaelumArgento");let keeper=CaelumArgento(it.Next());
        let keys=ThinkerIterator.Create("CaelumSilverKey");int count=0;
        while(keys.Next()!=null)count++;
        let key=u.FindInventory("CaelumSilverKey");
        Check("reload preserves single player-owned key",count==1 && key!=null && key.Owner==u && keeper.FindInventory("CaelumSilverKey")==null);
        Check("reload preserves native silver-lock access",u.CheckKeys(CaelumConstants.LOCK_CAELUM_SILVER,false,true));
        Check("reload preserves tutorial readiness",CaelumMainM00SocialDialogue.CanReceiveSilverKey(u));
        u.player.ConversationNPC=keeper;
        Check("reload repeated handoff stays idempotent",CaelumMainM00SocialDialogue.GiveSilverKey(u) && u.FindInventory("CaelumSilverKey")==key && keeper.FindInventory("CaelumSilverKey")==null);
        Console.Printf("CA160 RESULT passed=%d failed=%d",Passed,Failed);
    }
}
