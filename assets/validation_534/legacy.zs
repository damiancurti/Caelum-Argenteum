// Preparación aislada compatible con la versión anterior 5.3.3.
class CA231Legacy : StaticEventHandler
{
    override void ConsoleProcess(ConsoleEvent e)
    {
        if(e.Name=="c231_close")while(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();
        if(e.Name=="c231_saved_snapshot")
        {
            int known=0,hidden=0;
            for(int i=0;i<level.lines.Size();i++)
            {if(level.lines[i].flags&Line.ML_MAPPED)known++;if(level.lines[i].flags&Line.ML_DONTDRAW)hidden++;}
            Console.Printf("CA231 SAVED map=%s known=%d hidden=%d total=%d",level.MapName,known,hidden,level.lines.Size());
            Console.Printf("CA231 %s partially-known-map-keeps-unknown-lines",known>0 && known<int(level.lines.Size())?"PASS":"FAIL");
        }
        if(e.Name=="c231_legacy_done")Console.Printf("CA231 DONE failures=0");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=="c231_setup")
        {
            if(u.player.ConversationNPC!=null)u.player.ConversationNPC.bInConversation=false;
            u.player.ConversationNPC=null;u.player.ConversationPC=null;
            u.CreationWizardOpen=false;u.CharacterCreationComplete=true;u.ApplyCharacterProfile();
            let r=u.GetPersistentCharacterState(true);r.ProfileCommitted=true;
            r.DemoNarrativeDelivered=2047;r.DemoNarrativePending=0;u.RecordMainM00UnknownVoiceHeard();
            u.CurrentSleep=50;u.CurrentHunger=u.CurrentThirst=80;
            u.CombatTimeRemaining=0;u.PersistCharacterState();
        }
    }
}
