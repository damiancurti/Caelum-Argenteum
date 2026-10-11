// Native conversation UI and the MAP01 Bull's changed drop policy.
class CA183Dialogue : StaticEventHandler
{
    int Age;
    override void WorldTick()
    {
        let u=CaelumPlayer(players[0].mo);if(u==null)return;Age++;
        let r=u.GetPersistentCharacterState(true);r.DemoNarrativeDelivered=2047;r.DemoNarrativePending=0;
        if(Age==70){let b=CaelumMainM00RuloTrial.GetBull();if(b!=null)b.health=0;}
        if(Age==75)
        {
            Console.Printf("CA183 Bull feedback: %s",StringTable.Localize("CA_M01_RULO_BULL_WON",false));
            int leather=0;let it=ThinkerIterator.Create("CaelumMaterialPickup");CaelumMaterialPickup m;
            while((m=CaelumMaterialPickup(it.Next()))!=null)if(m.Owner==null && m.args[0]==CaelumConstants.MATERIAL_LEATHER)leather+=m.Amount;
            Console.Printf("CA183 %s MAP01 Bull drops no leather",leather==0?"PASS":"FAIL");
        }
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="ca183_dialogue")return;let u=CaelumPlayerAuthority.FromNetworkPlayer(e.Player);if(u==null)return;
        let r=u.GetPersistentCharacterState(true);r.QuestState[0]=CaelumConstants.QUEST_STATE_ACTIVE;r.QuestStage[0]=CaelumConstants.MAIN_M00_STATE_ARGENTO_ACTIVE;
        r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_PALOMO_MET);r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_PALOMO_UPSTAIRS_ENABLED);
        r.MainM00GoldRewardStarted=true;CaelumOnboarding.UpdateLessons(u);CaelumMainM00Loadout.Refresh(u);
        let it=ThinkerIterator.Create("CaelumPalomo");let p=CaelumPalomo(it.Next());
        if(u.player.ConversationNPC!=null)u.player.ConversationNPC.bInConversation=false;u.player.ConversationNPC=null;
        p.SetOrigin((500,120,264),false);p.DepartureStarted=true;p.DepartureDone=true;p.NarrativeRevealRequired=true;
        u.SetOrigin(p.Pos+(0,-64,0),false);u.Vel=(0,0,0);u.Angle=90;u.bInvulnerable=true;
        Level.ExecuteSpecial(CaelumConstants.GZDOOM_THING_SET_CONVERSATION_SPECIAL,p,null,false,0,e.Args[0]==0?43630:43316);
        bool opened=p.StartConversation(u,false,false);Console.Printf("CA183 %s native Palomo conversation %d",opened?"PASS":"FAIL",e.Args[0]);
        if(e.Args[0]==1)Console.Printf("CA183 DIALOGUE_DONE");
    }
    override void ConsoleProcess(ConsoleEvent e)
    {
        if(e.Name!="ca183_reply")return;let menu=Menu.GetCurrentMenu();if(menu==null)return;
        for(int i=0;i<e.Args[0];i++)menu.MenuEvent(Menu.MKEY_Down,false);menu.MenuEvent(Menu.MKEY_Enter,false);
    }
}
