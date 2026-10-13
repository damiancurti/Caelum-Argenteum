// Native rest regression fixture; never part of the production package.
class CA219Contract : StaticEventHandler
{
    int Failures;
    int BagId;
    double StartingSleep;
    CaelumPlayer User;
    CaelumSleepingBag Bag;
    void Check(bool ok,String label)
    {if(!ok)Failures++;Console.Printf("CA219 %s %s",ok?"PASS":"FAIL",label);}
    void CloseDialogue()
    {
        if(User.player.ConversationNPC!=null)User.player.ConversationNPC.bInConversation=false;
        User.player.ConversationNPC=null;User.player.ConversationPC=null;
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        User=CaelumPlayer(players[e.Player].mo);if(User==null)return;
        if(e.Name=="c219_prepare")
        {
            CloseDialogue();User.CreationWizardOpen=false;User.CharacterCreationComplete=true;
            User.ApplyCharacterProfile();User.GetPersistentCharacterState(true).ProfileCommitted=true;
            User.CombatTimeRemaining=0;User.CurrentHunger=90;User.CurrentThirst=90;User.CurrentSleep=30;
            User.Vel=(0,0,0);User.SetOrigin(CaelumMazeLayout.ArrivalChairPosition()+(128,128,0),false);
            User.Angle=0;User.Pitch=0;
            Bag=CaelumSleepingBag(User.FindInventory("CaelumSleepingBag"));
            if(Bag==null)Bag=CaelumSleepingBag(User.GiveInventoryType("CaelumSleepingBag"));
            Bag.InMagicBox=false;User.UpdateSurvivalStates();
        }
        if(e.Name=="c219_open")
        {
            Check(Bag.AvailableTo(User),"owned bag available outside Box");
            Check(CaelumRestBag.HasRoom(User),"existing dry arrival position fits bag");
            Check(!CaelumWorldCatalogue.IsLimboMap(level.MapName),"MAP02 keeps exterior time scale");
            Check(CaelumRestState.BlockReason(User)=="","ordinary sleep has no map restriction");
            Check(Bag.Open(User),"owned sleeping bag opens native dialogue");
        }
        if(e.Name=="c219_choose")
        {
            let guide=CaelumRestGuide(User.player.ConversationNPC);
            Check(guide!=null && guide.UsesBag,"dialogue retains bag ownership");
            let reply=CaelumRestSleep5Action(Actor.Spawn("CaelumRestSleep5Action"));
            reply.Owner=User;Check(reply.Use(false),"native five-minute reply queues sleep");
            reply.Owner=null;reply.Destroy();CloseDialogue();
        }
        if(e.Name=="c219_baseline")
        {
            Check(CaelumRestState.IsSleeping(User),"normal bag sleep works in baseline");
            Check(CaelumRestState.ResourceFactor(User)==3,"bag keeps existing comfort factor");
            Check(!CaelumTimeAdvanceState.InSafeZone(User),"arrival-side dry floor lies outside marked zones");
            Check(CaelumTimeAdvanceState.BlockReason(User)=="CA_FAST_ZONE","baseline rejects acceleration because of safe-zone marker");
            Check(!CaelumTimeAdvanceState.Toggle(User),"baseline cannot accelerate sleeping bag here");
        }
        if(e.Name=="c219_done")Console.Printf("CA219 DONE failures=%d",Failures);
    }
}
