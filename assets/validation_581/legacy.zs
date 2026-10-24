class CA413Checks : EventHandler
{
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!='ca413_legacy' || e.Player<0 || e.Player>=MAXPLAYERS)return;
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        Console.Printf("CA413 LEGACY playable=%d health=%d",u.CharacterCreationComplete,u.health);
        if(!u.CharacterCreationComplete || u.health<=0)Console.Printf("CA413 FAIL legacy character");
    }
}
