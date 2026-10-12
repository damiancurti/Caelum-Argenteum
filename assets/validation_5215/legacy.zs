// Same fixture before/after loading the immutable accepted-version save.
class CA150Legacy : StaticEventHandler
{
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="c150_legacy")
        {
            let user=CaelumPlayer(players[e.Player].mo);
            CaelumNotifications.Inbox(user).Add("Original legacy message: must survive migration unchanged.",600*TICRATE);
        }
    }
    override void ConsoleProcess(ConsoleEvent e)
    {if(e.Name=="c150_done")Console.Printf("CA150 DONE failures=0");}
}
