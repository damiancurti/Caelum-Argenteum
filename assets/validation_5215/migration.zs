class CA150Migration : StaticEventHandler
{
    override void ConsoleProcess(ConsoleEvent e)
    {
        if(e.Name!="c150_migration")return;
        let user=CaelumPlayer(players[consoleplayer].mo);
        let inbox=CaelumNotificationInbox(user.FindInventory("CaelumNotificationInbox"));
        bool ok=inbox!=null && inbox.HistoryRevision==1 && inbox.HistoryCount==1 && inbox.Count==1
            && inbox.HistoryText[0]=="Original legacy message: must survive migration unchanged." && inbox.Text[0]==inbox.HistoryText[0];
        Console.Printf("CA150 %s legacy history migration is additive and idempotent",ok?"PASS":"FAIL");
        Console.Printf("CA150 DONE failures=%d",ok?0:1);
    }
}
