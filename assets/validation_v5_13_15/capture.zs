// +use recorre la interacción real. Sólo se automatiza la respuesta posterior.
class CA513CaptureReview : StaticEventHandler
{
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Player<0 || e.Player>=MAXPLAYERS)return;
        let p=CaelumPlayer(players[e.Player].mo);if(p==null)return;
        if(e.Name=='ca_review_capture')
        {
            let source=CaelumArcanaSources.Find(77);
            bool opened=source!=null && p.player.ConversationNPC==source && source.bInConversation;
            Console.Printf("CA513CAPTURE %s native Use opens essence player=%d",opened?"PASS":"FAIL",e.Player);
            bool begun=opened && CaelumMainM00FoolCapture.BeginCapture(p);
            Console.Printf("CA513CAPTURE %s capture response player=%d",begun?"PASS":"FAIL",e.Player);
            if(p.player.ConversationNPC!=null){p.player.ConversationNPC.bInConversation=false;p.player.ConversationNPC=null;}
        }
        if(e.Name=='ca_review_result')
        {
            let r=p.GetPersistentCharacterState(false);
            Console.Printf("CA513CAPTURE %s collection reaches 78 player=%d",
                r!=null && r.HasTarotCard(77) && CaelumTarotService.CountTarotCards(r)==78?"PASS":"FAIL",e.Player);
        }
    }
}
