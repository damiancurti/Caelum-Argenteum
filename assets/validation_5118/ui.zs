class CA164Ui : StaticEventHandler
{
    int Age;
    ui bool Advanced;
    ui int MenuAge;
    override void WorldLoaded(WorldEvent e){Age=0;}
    override void UiTick()
    {
        let menu=ConversationMenu(Menu.GetCurrentMenu());
        if(menu==null || menu.mCurNode==null || Advanced)return;
        MenuAge++;if(MenuAge<10)return;
        int mode=CVar.FindCVar('ca164_stage').GetInt();
        if((mode==9 && (menu.mCurNode.UserData=="caella_magic_status" || menu.mCurNode.UserData=="caella_magic_return_gate"))
            || (mode==11 && menu.mCurNode.UserData=="loadout_root"))
        {
            ConversationMenu.SendConversationReply(menu.mCurNode.ThisNodeNum,mode==11?1:0);
            menu.Close();Advanced=mode==11;MenuAge=0;
            Console.Printf("CA164 PASS native reply navigation mode=%d",mode);
        }
    }
    override void WorldTick()
    {
        Age++;let u=CaelumPlayer(players[0].mo);if(u==null || !u.CharacterCreationComplete)return;
        int mode=CVar.FindCVar('ca164_stage').GetInt();
        if(Age!=40)return;
        if(mode==8 || mode==11)
        {
            let p=CA164Route.Palomo(u);CA164Route.EndTalk(u);
            CaelumMainM00Loadout.Refresh(u);CaelumMainM00RonnieTrial.Sync(u);
            Level.ExecuteSpecial(CaelumConstants.GZDOOM_THING_SET_CONVERSATION_SPECIAL,p,null,false,0,CaelumMainM00Loadout.CONVERSATION);
            CA164Route.Check(p.StartConversation(u,true,true),"native optional loadout menu opens");
        }
        if(mode==9)
        {
            let p=CA164Route.Talk(u,"CaelumCaella");CA164Route.EndTalk(u);
            let r=u.GetPersistentCharacterState(true);r.QuestState[0]=CaelumConstants.QUEST_STATE_ACTIVE;
            r.QuestStage[0]=CaelumConstants.MAIN_M00_STATE_CAELLA_ACTIVE;
            r.MainM00Flag[CaelumConstants.MAIN_M00_FLAG_CAELLA_COMPLETE]=false;
            r.MainM00Flag[CaelumConstants.MAIN_M00_FLAG_MAGIC_PRIMARY_USED]=false;
            r.MainM00Flag[CaelumConstants.MAIN_M00_FLAG_MAGIC_SECONDARY_USED]=false;
            r.MainM00Flag[CaelumConstants.MAIN_M00_FLAG_MAGIC_ANIMA_SPENT]=false;
            r.MainM00Flag[CaelumConstants.MAIN_M00_FLAG_MAGIC_ANIMA_RECOVERED]=false;
            r.MainM00RuneSequenceIndex=0;
            CaelumMainM00MagicTrial.Sync(u);
            CA164Route.Check(CaelumMainM00SocialDialogue.Open(u,CaelumAnchoredResident(p)),"native Caella practice dialogue opens");
        }
        if(mode==10)
        {
            let p=CA164Route.Talk(u,"CaelumArgento");CA164Route.EndTalk(u);
            let r=u.GetPersistentCharacterState(true);r.QuestState[0]=CaelumConstants.QUEST_STATE_ACTIVE;
            r.QuestStage[0]=CaelumConstants.MAIN_M00_STATE_ARGENTO_ACTIVE;
            r.MainM00Flag[CaelumConstants.MAIN_M00_FLAG_ARGENTO_COMPLETE]=false;
            for(int i=0;i<3;i++)r.MainM00Flag[CaelumConstants.MAIN_M00_FLAG_RULO_CONVINCED+i]=false;
            CaelumMainM00SocialDialogue.Sync(u);
            CA164Route.Check(CaelumMainM00SocialDialogue.Open(u,CaelumAnchoredResident(p)),"native Argento gift dialogue opens");
        }
    }
}
