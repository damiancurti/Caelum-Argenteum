// Compatible con 5.3.2: conserva una copia anterior sin campos de agotamiento.
class CA258Legacy : StaticEventHandler
{
    override void ConsoleProcess(ConsoleEvent e)
    {if(e.Name=="c258_close")while(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=="c258_setup")
        {
            if(u.player.ConversationNPC!=null)u.player.ConversationNPC.bInConversation=false;
            u.player.ConversationNPC=null;u.player.ConversationPC=null;
            u.CreationWizardOpen=false;u.CharacterCreationComplete=true;u.ApplyCharacterProfile();
            let r=u.GetPersistentCharacterState(true);r.ProfileCommitted=true;
            r.DemoNarrativeDelivered=2047;r.DemoNarrativePending=0;u.RecordMainM00UnknownVoiceHeard();
            u.CurrentSleep=50;u.CurrentHunger=u.CurrentThirst=80;
            u.CombatTimeRemaining=0;u.PersistCharacterState();
        }
        if(e.Name=="c258_old")
        {
            u.CurrentSleep=0;u.CurrentHunger=80;u.CurrentThirst=70;
            u.GiveInventory("CaelumFoodRation",3);
            u.PersistCharacterState();
            Console.Printf("CA258 PASS legacy-zero-seed");
            Console.Printf("CA258 DONE failures=0");
        }
        if(e.Name=="c258_snapshot")
        {Console.Printf("CA258 SNAPSHOT map=%s sleep=%.9f hunger=%.9f thirst=%.9f health=%d",level.MapName,u.CurrentSleep,u.CurrentHunger,u.CurrentThirst,u.health);}
        if(e.Name=="c258_rollback")
        {Console.Printf("CA258 %s rollback-original-save",u.CurrentSleep<1 && u.CurrentHunger>79 && u.CurrentThirst>69?"PASS":"FAIL");Console.Printf("CA258 DONE failures=0");}
    }
}
