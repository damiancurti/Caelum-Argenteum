// Prueba aislada: registro nativo y apertura de conversaciones sin cambiar sus árboles.
class CA185Native : StaticEventHandler
{
    int Failures;
    static const int Ids[] = {43300,43200,43310,43311,43312,43313,43315,43316,43317,43318,43319,43320,43321,43322,43323,43410,43411,43412,43413,43510,43511,43512,43513,43514,43515,43516,43414,43415,43420,43421,43422,43423,43424,43425,43426,43427,43620,43621,43480,43481,43482,43483,43484,43485,43486,43487,43488,43489,43490,43630,43631,43632,43633};
    void Check(bool ok, String label)
    {
        if (!ok) Failures++;
        Console.Printf("CA185 %s %s",ok?"PASS":"FAIL",label);
    }
    override void WorldTick()
    {
        let u=CaelumPlayer(players[0].mo); if(u==null)return;
        let r=u.GetPersistentCharacterState(true);
        r.DemoNarrativeDelivered=2047;r.DemoNarrativePending=0;u.bInvulnerable=true;
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayerAuthority.FromNetworkPlayer(e.Player);if(u==null)return;
        if(e.Name=="ca185_ids")
        {
            for(int i=0;i<Ids.Size();i++)
            {
                let actor=Actor.Spawn("CaelumPalomo",u.Pos+(0,128,0),NO_REPLACE);
                bool assigned=Level.ExecuteSpecial(CaelumConstants.GZDOOM_THING_SET_CONVERSATION_SPECIAL,actor,null,false,0,Ids[i]);
                Check(assigned && actor.HasConversation(),String.Format("native conversation ID %d",Ids[i]));
                actor.Destroy();
            }
        }
        if(e.Name=="ca185_open")
        {
            static const String Classes[]={"CaelumPalomo","CaelumArgento","CaelumRulo","CaelumRonnie","CaelumCaella","CaelumPrisonerUnitario","CaelumPrisonerFederal","CaelumPrisonerBestia","CaelumPrisonerTarot"};
            static const int Conversations[]={43630,43310,43311,43312,43313,43420,43421,43422,43423};
            int index=e.Args[0];if(index<0 || index>=Classes.Size())return;
            if(u.player.ConversationNPC!=null)u.player.ConversationNPC.bInConversation=false;u.player.ConversationNPC=null;
            let it=ThinkerIterator.Create(Classes[index]);let npc=Actor(it.Next());
            if(npc==null)npc=Actor.Spawn(Classes[index],u.Pos+(0,64,0),NO_REPLACE);
            if(index==0){let p=CaelumPalomo(npc);p.DepartureStarted=true;p.DepartureDone=true;p.NarrativeRevealRequired=true;}
            let r=u.GetPersistentCharacterState(true);r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_PALOMO_MET);
            CaelumMainM00Loadout.Refresh(u);
            u.SetOrigin(npc.Pos+(0,-64,0),false);u.Vel=(0,0,0);u.Angle=90;
            Level.ExecuteSpecial(CaelumConstants.GZDOOM_THING_SET_CONVERSATION_SPECIAL,npc,null,false,0,Conversations[index]);
            Check(npc.StartConversation(u,false,false),String.Format("opened %s",Classes[index]));
        }
        if(e.Name=="ca185_done")Console.Printf("CA185 DONE failures=%d",Failures);
    }
}
