// Isolated native action regression on a protected llave-plata checkpoint.
class CA160Checks : StaticEventHandler
{
    int Elapsed,Passed,Failed;
    void Check(String label,bool ok)
    {if(ok)Passed++;else Failed++;Console.Printf("CA160 %s %s",ok?"PASS":"FAIL",label);}
    int Keys()
    {
        let it=ThinkerIterator.Create("CaelumSilverKey");int count=0;
        while(it.Next()!=null)count++;return count;
    }
    bool InvokeOffer(CaelumPlayer u)
    {
        let offer=Inventory(Actor.Spawn("CaelumM00TakeSilverKeyAction",u.Pos,NO_REPLACE));
        bool ok=offer.CallTryPickup(u);
        if(!ok)offer.Destroy();
        return ok;
    }
    override void WorldTick()
    {
        Elapsed++;if(Elapsed!=20)return;
        let u=CaelumPlayer(players[0].mo);if(u==null)return;
        let it=ThinkerIterator.Create("CaelumArgento");let keeper=CaelumArgento(it.Next());
        let key=keeper==null?null:CaelumWeightedKey(keeper.FindInventory("CaelumSilverKey"));
        Check("checkpoint ready with keeper-owned key",keeper!=null && key!=null && key.Owner==keeper && u.FindInventory("CaelumSilverKey")==null && CaelumMainM00SocialDialogue.CanReceiveSilverKey(u));
        if(key==null)return;
        int count=Keys();let r=u.GetPersistentCharacterState(false);
        Check("ordinary pickup rejects foreign-owned key",!u.PrepareNativeKeyPickup(key) && key.Owner==keeper);
        // Re-establish the native conversation context; invoke the same AUTOACTIVATE
        // Inventory action selected by CAPALOMO's GiveItem, not a direct key grant.
        u.player.ConversationNPC=null;
        Check("missing keeper rejects action",!InvokeOffer(u) && key.Owner==keeper);
        u.player.ConversationNPC=keeper;
        keeper.StoryAnchored=false;
        Check("unanchored keeper rejects action",!InvokeOffer(u) && key.Owner==keeper);
        keeper.StoryAnchored=true;
        r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RONNIE_COMPLETE,false);
        Check("unfinished tutorial rejects action",!InvokeOffer(u) && key.Owner==keeper);
        r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RONNIE_COMPLETE,true);
        double capacity=u.DerivedStats.CarryCapacity;
        u.DerivedStats.CarryCapacity=-1;
        Check("insufficient capacity rejects action",!InvokeOffer(u));
        Check("failed handoff restores identical key to keeper",key.Owner==keeper && keeper.FindInventory("CaelumSilverKey")==key && u.FindInventory("CaelumSilverKey")==null && Keys()==count);
        u.DerivedStats.CarryCapacity=capacity;
        u.RefreshCarriedInventorySummary();double weight=u.DerivedStats.CarriedWeight;
        Check("original character has room for key",u.CanAddWeightToPersonalInventory(key.GetCarriedWeight()));
        Check("silver lock unavailable before handoff",!u.CheckKeys(CaelumConstants.LOCK_CAELUM_SILVER,false,true));
        Check("native dialogue action succeeds on retry",InvokeOffer(u));
        Check("identical key transfers to player",key.Owner==u && u.FindInventory("CaelumSilverKey")==key && keeper.FindInventory("CaelumSilverKey")==null);
        Check("key adds its canonical carried weight",abs(u.DerivedStats.CarriedWeight-weight-key.GetCarriedWeight())<0.000001);
        Check("silver lock grants access",u.CheckKeys(CaelumConstants.LOCK_CAELUM_SILVER,false,true));
        Check("repeat action succeeds without duplication",InvokeOffer(u) && Keys()==count && key.Owner==u);
        Check("dialogue ownership token refreshed",u.FindInventory("CaelumM00SilverKeyHeldToken")!=null);
        Check("no repeatable action retained",u.FindInventory("CaelumM00TakeSilverKeyAction")==null);
        u.PersistCharacterState();Console.Printf("CA160 RESULT passed=%d failed=%d",Passed,Failed);
    }
}
