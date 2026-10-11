class CA172Flow : StaticEventHandler
{
    int Age;
    bool Loaded;
    ui int Step, WaitTicks;
    static void Check(bool ok,String label){Console.Printf("CA172 %s %s",ok?"PASS":"FAIL",label);}
    static ui void UCheck(bool ok,String label){Console.Printf("CA172 %s %s",ok?"PASS":"FAIL",label);}
    override void WorldLoaded(WorldEvent e)
    {
        Age=0;let u=CaelumPlayer(players[0].mo);
        let r=u==null?null:u.GetPersistentCharacterState(false);
        Loaded=e.IsSaveGame && r!=null && r.SeenDialogueKeys.Size()>0;
        if(e.IsSaveGame && !Loaded)Check(r!=null && r.DialogueHistoryRevision==0,"legacy schema defaults to empty without resetting profile");
    }
    void Open(CaelumPlayer u,int conversation,String actorClass="CaelumPalomo")
    {
        if(u.player.ConversationNPC!=null)u.player.ConversationNPC.bInConversation=false;
        u.player.ConversationNPC=null;
        let npc=Actor(ThinkerIterator.Create(actorClass).Next());
        if(npc==null)npc=Actor.Spawn(actorClass,u.Pos+(0,80,0),NO_REPLACE);
        let p=CaelumPalomo(npc);
        if(p!=null){p.DepartureStarted=true;p.DepartureDone=true;p.NarrativeRevealRequired=true;}
        u.SetOrigin(npc.Pos+(0,-72,0),false);u.Vel=(0,0,0);u.Angle=90;u.Pitch=0;
        Level.ExecuteSpecial(CaelumConstants.GZDOOM_THING_SET_CONVERSATION_SPECIAL,npc,null,false,0,conversation);
        Check(npc.StartConversation(u,true,true),"native conversation opens");
    }
    override void WorldTick()
    {
        Age++;if(Age!=100)return;
        let u=CaelumPlayer(players[0].mo);if(u==null)return;
        let r=u.GetPersistentCharacterState(true);r.DemoNarrativeDelivered=2047;r.DemoNarrativePending=0;
        if(Loaded)Check(r.SeenDialogueKeys.Size()==1 && r.DialogueHistoryRevision==1,"save load retains stable history");
        else Check(r.SeenDialogueKeys.Size()==0,"fresh or old save starts with empty history");
        Open(u,43316);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[0].mo);if(u==null)return;
        if(e.Name=="ca172_reopen")Open(u,43316);
        if(e.Name=="ca172_guard")Open(u,43631,"CaelumPortDefender");
    }
    ui int Find(CaelumHistoryConversationMenu m,int original)
    {for(int i=0;i<m.ReplyMap.Size();i++)if(m.ReplyMap[i]==original)return i;return -1;}
    ui void Select(CaelumHistoryConversationMenu m,int original)
    {m.mSelection=Find(m,original);UCheck(m.mSelection>=0,"requested visible selection exists");m.MenuEvent(Menu.MKEY_Enter,false);}
    override void UiTick()
    {
        if(Age<110)return;
        let m=CaelumHistoryConversationMenu(Menu.GetCurrentMenu());
        if(m==null || m.mCurNode==null)return;
        WaitTicks++;if(WaitTicks<12)return;WaitTicks=0;
        if(Loaded && Step==0)
        {UCheck(Find(m,2)<0 && Find(m,m.REPEAT)>=0,"loaded conversation filters read information");Step=10;return;}
        if(Step==0)
        {UCheck(Find(m,2)>=0,"unseen information initially visible");Select(m,2);Step++;return;}
        if(Step==1)
        {UCheck(m.mCurNode.UserData=="palomo_final_idea","native reply reaches intended answer");Select(m,0);Step++;return;}
        if(Step==2)
        {
            UCheck(Find(m,2)<0 && Find(m,0)>=0,"seen information hidden but gift offer remains");
            UCheck(Find(m,m.REPEAT)==m.ReplyMap.Size()-1,"repeat option is at the bottom");
            Select(m,m.REPEAT);Step++;return;
        }
        if(Step==3)
        {UCheck(m.Replaying && m.ReplyMap[0]>=m.ARCHIVE_ITEM,"archive lists seen topic");Select(m,m.ReplyMap[0]);Step++;return;}
        if(Step==4)
        {
            UCheck(m.History().SeenDialogueKeys.Size()==1,"replay records no duplicate history");
            UCheck(!CaelumPlayer(m.mPlayer.mo).MagicBoxOwned,"replay triggers no Box reward");
            m.MenuEvent(Menu.MKEY_Back,false);Step++;return;
        }
        if(Step==5)
        {UCheck(!m.Replaying && Find(m,2)<0,"Back restores filtered conversation");m.MenuEvent(Menu.MKEY_Back,false);EventHandler.SendNetworkEvent("ca172_reopen");Step++;return;}
        if(Step==6)
        {UCheck(Find(m,2)<0,"reopening retains history");Select(m,m.MORE);Step++;return;}
        if(Step==7)
        {UCheck(Find(m,6)>=0 && Find(m,2)<0,"pagination keeps native index of last action");Select(m,6);Step++;return;}
        if(Step==8)
        {UCheck(m.mCurNode.Dialogue=="$CA_DEMO_PALOMO_LESSONS","paginated action opens correct native page");m.MenuEvent(Menu.MKEY_Back,false);EventHandler.SendNetworkEvent("ca172_reopen");Step++;return;}
        if(Step==9){Console.Printf("CA172 FLOW_DONE");Step=99;return;}
        if(Step==10)
        {m.MenuEvent(Menu.MKEY_Back,false);EventHandler.SendNetworkEvent("ca172_guard");Step++;return;}
        if(Step==11)
        {UCheck(!m.HasHistory(),"different NPC has independent history");Select(m,0);Step++;return;}
        if(Step==12)
        {UCheck(m.mCurNode.UserData=="guard_captain_first_answer" && m.HasHistory(),"shared base menu records guard information");Select(m,m.REPEAT);Step++;return;}
        if(Step==13)
        {UCheck(m.ReplyMap.Size()==2,"guard archive contains only its own topic");Console.Printf("CA172 RELOAD_DONE");Step=99;}
    }
}

