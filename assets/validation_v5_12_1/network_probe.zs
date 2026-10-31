// Fixture only: observe synchronized requests from independent native peers.
class CA435NetworkProbe : EventHandler
{
    int Received[MAXPLAYERS];
    int InvalidRequests;
    int TotalRequests;
    bool Complete;
    ui bool Sent;

    override void UiTick()
    {
        if (gamestate != GS_LEVEL || consoleplayer < 0) return;
        if (!Sent && level.time >= TICRATE && players[consoleplayer].mo)
        {
            Sent = true;
            SendNetworkEvent("ca435_native_probe", consoleplayer, 435, 1);
        }
    }

    override void NetworkProcess(ConsoleEvent e)
    {
        if (e.Name != "ca435_native_probe") return;
        if (e.Player < 0 || e.Player >= MAXPLAYERS || !playeringame[e.Player]
            || e.Args[0] != e.Player || e.Args[1] != 435 || e.Args[2] != 1)
        { InvalidRequests++; return; }
        Received[e.Player]++;
        TotalRequests++;
        Console.Printf("CA435 EVENT peer=%d sender=%d serial=%d", consoleplayer, e.Player, TotalRequests);
    }

    override void WorldTick()
    {
        if (Complete || level.time < TICRATE * 3) return;
        int participants = 0;
        for (int i = 0; i < MAXPLAYERS; i++)
        {
            if (!playeringame[i]) continue;
            participants++;
            if (Received[i] == 0) return;
        }
        Complete = true;
        bool valid = multiplayer && participants >= 2 && InvalidRequests == 0
            && TotalRequests == participants;
        for (int i = 0; i < MAXPLAYERS; i++)
        {
            if (!playeringame[i]) continue;
            let user = CaelumPlayer(players[i].mo);
            bool owned = user && user.player == players[i] && Received[i] == 1;
            valid = valid && owned;
            Console.Printf("CA435 %s player%d native body and event ownership", owned ? "PASS" : "FAIL", i);
        }
        Console.Printf("CA435 %s native peer synchronization", valid ? "PASS" : "FAIL");
        Console.Printf("CA435 RESULT peer=%d participants=%d requests=%d invalid=%d", consoleplayer, participants, TotalRequests, InvalidRequests);
    }
}
