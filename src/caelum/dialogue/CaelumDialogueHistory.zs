// El servidor conserva claves estables; repetir sólo lee texto, sin responder
// de nuevo al nodo USDF ni ejecutar sus acciones, pagos o recompensas.
class CaelumDialogueHistory : StaticEventHandler
{
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="ca_dialogue_seen" || e.Player<0 || e.Player>=MAXPLAYERS
            || !playeringame[e.Player] || e.Args[0]<0 || e.Args[0]>=CaelumDialogueHistoryData.COUNT)return;
        let user=CaelumPlayer(players[e.Player].mo);
        if(user==null || user.player.ConversationNPC==null || !user.HasActiveConversation())return;
        let r=user.GetPersistentCharacterState(true);
        String key=String.Format("%s",user.player.ConversationNPC.GetClassName()).."|"..CaelumDialogueHistoryData.Key(e.Args[0]);
        if(r.SeenDialogueKeys.Find(key)==r.SeenDialogueKeys.Size())r.SeenDialogueKeys.Push(key);
        r.DialogueHistoryRevision=CaelumDialogueHistoryData.REVISION;
    }
}

class CaelumHistoryConversationMenu : ConversationMenu
{
    override void FormatSpeakerMessage()
    {
        String text=CaelumInputHints.Resolve(StringTable.Localize(mCurNode.Dialogue));
        if(text=="")text=".";
        mDialogueLines=displayFont.BreakLines(text,SpeechWidth);
    }
    bool ReplyHeld;
    int ArmedReply, ArmedPage, ReplyRevision;
    override bool MouseEvent(int type,int x,int y)
    {
        if(demoplayback)return false;
        Super.MouseEvent(MOUSE_Move,x,y);
        if(type==MOUSE_Click && !ReplyHeld)
        {ReplyHeld=true;ArmedReply=SelectedNativeReply();ArmedPage=ReplyRevision;}
        else if(type==MOUSE_Release)
        {
            bool activate=ReplyHeld && ArmedReply!=-1 && ArmedReply==SelectedNativeReply() && ArmedPage==ReplyRevision;
            ReplyHeld=false;
            if(activate)return MenuEvent(MKEY_Enter,true);
        }
        return true;
    }
    override void OnReturn(){ReplyHeld=false;}
    Array<int> ReplyMap;
    bool Replaying;
    int PageOffset, NextOffset;
    // Números negativos reservados al menú; nunca llegan a SendConversationReply.
    const REPEAT = -10;
    const MORE = -11;
    const HISTORY_BACK = -12;
    const ARCHIVE_ITEM = 10000;
    const CONTENT_LINES = 5;

    CaelumPersistentCharacterState History()
    {
        let user=mPlayer==null?null:mPlayer.mo;
        return user==null?null:CaelumPersistentCharacterState(user.FindInventory("CaelumPersistentCharacterState"));
    }

    String SpeakerKey()
    { return mPlayer==null || mPlayer.ConversationNPC==null?"":String.Format("%s",mPlayer.ConversationNPC.GetClassName()); }

    bool Seen(int id)
    {
        let r=History();
        return id>=0 && r!=null && r.SeenDialogueKeys.Find(SpeakerKey().."|"..CaelumDialogueHistoryData.Key(id))<r.SeenDialogueKeys.Size();
    }

    bool HasHistory()
    {
        for(int i=0;i<CaelumDialogueHistoryData.COUNT;i++)if(Seen(i))return true;
        return false;
    }

    int SelectedNativeReply()
    { return mSelection<0 || mSelection>=ReplyMap.Size()?-1:ReplyMap[mSelection]; }

    void AppendReply(String text,int nativeIndex)
    {
        let lines=displayFont.BreakLines(CaelumInputHints.Resolve(text),ReplyWidth);
        mResponses.Push(mResponseLines.Size());ReplyMap.Push(nativeIndex);
        for(int i=0;i<lines.Count();i++)mResponseLines.Push(lines.StringAt(i));
        lines.Destroy();
    }

    override int FormatReplies(int activereply)
    {
        ReplyHeld=false;ReplyRevision++;
        mResponses.Clear();mResponseLines.Clear();ReplyMap.Clear();
        mShowGold=false;mSelection=0;NextOffset=0;
        int eligible=0,index=0;
        for(let reply=mCurNode.Children;reply!=null;reply=reply.Next)
        {
            int original=index++;
            if(Replaying || reply.ShouldSkipReply(mPlayer)
                || Seen(CaelumDialogueHistoryData.Find(mCurNode.Dialogue,reply.Reply)))continue;
            if(eligible++<PageOffset)continue;
            String text=StringTable.Localize(reply.Reply);
            if(reply.NeedsGold)
            {
                mShowGold=true;text.AppendFormat(" %s",StringTable.Localize("$TXT_TRADE"));
                text.Replace("%u",String.Format("%u",reply.PrintAmount));
            }
            let lines=displayFont.BreakLines(CaelumInputHints.Resolve(text),ReplyWidth);
            int count=lines.Count();lines.Destroy();
            if(mResponses.Size()>0 && mResponseLines.Size()+count>CONTENT_LINES)
            {NextOffset=eligible-1;break;}
            AppendReply(text,original);
            if(original==activereply)mSelection=mResponses.Size()-1;
        }
        if(Replaying)
        {
            for(int id=0;id<CaelumDialogueHistoryData.COUNT;id++)
            {
                if(!Seen(id))continue;
                if(eligible++<PageOffset)continue;
                String text=StringTable.Localize(CaelumDialogueHistoryData.Reply(id));
                let lines=displayFont.BreakLines(CaelumInputHints.Resolve(text),ReplyWidth);
                int count=lines.Count();lines.Destroy();
                if(mResponses.Size()>0 && mResponseLines.Size()+count>CONTENT_LINES)
                {NextOffset=eligible-1;break;}
                AppendReply(text,ARCHIVE_ITEM+id);
            }
        }
        if(NextOffset>0 || PageOffset>0)AppendReply(StringTable.Localize("CA_DIALOGUE_MORE",false),MORE);
        if(Replaying)AppendReply(StringTable.Localize("CA_DIALOGUE_RETURN",false),HISTORY_BACK);
        else
        {
            // El índice de despedida nativo es el total de hijos, no el total visible.
            index=0;for(let r=mCurNode.Children;r!=null;r=r.Next)index++;
            String bye=StringTable.Localize(mCurNode.Goodbye);
            if(bye.Length()==0)bye=StringTable.Localize("CA_DLG_M01_SOCIAL_LEAVE",false);
            AppendReply(bye,index);
            if(HasHistory())AppendReply(StringTable.Localize("CA_DIALOGUE_REPEAT",false),REPEAT);
        }
        mYpos=Min(140,192-int(mResponseLines.Size())*ReplyLineHeight);
        return mYpos;
    }

    void RestorePage()
    {
        FormatSpeakerMessage();FormatReplies(-1);
    }

    override bool MenuEvent(int key,bool fromcontroller)
    {
        ReplyHeld=false;
        if(demoplayback)return Super.MenuEvent(key,fromcontroller);
        if(key==MKEY_Back && Replaying)
        {Replaying=false;PageOffset=0;RestorePage();return true;}
        if(key==MKEY_Back)
        {SendConversationReply(-1,0);Close();return true;}
        if(key!=MKEY_Enter)return Super.MenuEvent(key,fromcontroller);
        int selected=SelectedNativeReply();
        if(selected==-1)return true;
        if(selected==REPEAT){Replaying=true;PageOffset=0;RestorePage();return true;}
        if(selected==HISTORY_BACK){Replaying=false;PageOffset=0;RestorePage();return true;}
        if(selected==MORE){PageOffset=NextOffset;RestorePage();return true;}
        if(selected>=ARCHIVE_ITEM)
        {
            String text=StringTable.Localize(CaelumDialogueHistoryData.Answer(selected-ARCHIVE_ITEM));
            let user=mPlayer==null?null:CaelumPlayer(mPlayer.mo);
            if(user!=null)text.Replace("%DEFENSE%",StringTable.Localize(CaelumJournalOverlay.GetRuloDefenseKey(user),false));
            mDialogueLines=displayFont.BreakLines(CaelumInputHints.Resolve(text),SpeechWidth);
            return true;
        }
        let reply=mCurNode.Children;
        for(int i=0;i<selected && reply!=null;i++)reply=reply.Next;
        if(reply!=null)
        {
            int id=CaelumDialogueHistoryData.Find(mCurNode.Dialogue,reply.Reply);
            if(id>=0)EventHandler.SendNetworkEvent("ca_dialogue_seen",id);
        }
        SendConversationReply(mCurNode.ThisNodeNum,selected);Close();return true;
    }
}
