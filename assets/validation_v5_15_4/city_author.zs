// Revisión manual de geometría real: sólo la ubicación inicial es de diagnóstico.
class CA515QuietPort : CaelumPortSiege replaces CaelumPortSiege { override void Tick(){} }
class CA515Author : EventHandler
{
    bool Ready;
    void Locate(CaelumPlayer user,bool west)
    {
        user.SetOrigin(west?(-30272,-14528,0):(-28544,-1024,0),false);
        user.Angle=west?90:180;user.Pitch=0;user.Vel=(0,0,0);
    }
    override void WorldTick()
    {
        if(Ready || level.time<110)return;
        for(int p=0;p<MAXPLAYERS;p++)if(playeringame[p])
        {
            let user=CaelumPlayer(players[p].mo);if(!CaelumWorldClockTicker.Ready(user))return;
            let record=user.GetPersistentCharacterState(false);
            record.FactionMember[0]=true;record.FactionReputation[0]=50;
            record.QuestState[CaelumConstants.QUEST_GUARD_CAPTAIN]=CaelumConstants.QUEST_STATE_COMPLETED;
            record.DemoNarrativeDelivered=(1<<CaelumDemoNarrative.EVENT_COUNT)-1;record.DemoNarrativePending=0;
            user.MagicBoxOwned=true;record.MagicBoxOwned=true;user.PersistCharacterState();Locate(user,false);
        }
        Ready=true;Console.Printf("CA515 AUTHOR READY city geometry");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let user=CaelumPlayerAuthority.FromNetworkPlayer(e.Player);if(user==null || !Ready)return;
        if(e.Name=="ca515_a")Locate(user,false);
        if(e.Name=="ca515_b")Locate(user,true);
        if(e.Name=="ca515_c")
        {
            double civil=CaelumCityWorld.SiegeCivilSeconds();int day=int(Floor(civil/86400));
            int tic=int((civil-double(day)*86400)*CaelumWorldClock.TicsPerHour()/3600);
            CaelumCalendarState.Get(user,true).SetAnchor(CaelumWorldClock.Get(user,true),day,tic,false);
            CaelumWorldClockTicker.Mirror(user);
        }
    }
}
