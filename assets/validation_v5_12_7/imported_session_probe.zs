// La prueba usa el mismo mensaje nativo que Escape en ConversationMenu.
// No modifica el interlocutor, la misión ni el inventario para cerrar el diálogo.
class CA435ImportedSessionProbe : StaticEventHandler
{
    int Tics;
    bool Ready,Done,Conversation;
    Vector3 Start;
    ui bool Sent,Saved;
    override void WorldTick()
    {
        let user=CaelumPlayer(players[0].mo);
        if(!CaelumWorldClockTicker.Ready(user) || user.SessionIdentityPending)return;
        Conversation=user.HasActiveConversation();
        if(!Ready){Ready=true;Start=user.Pos;}
        Tics++;
        if(Tics==210)
        {
            Console.Printf("CA435IMPORT %s native conversation cancellation",user.HasActiveConversation()?"FAIL":"PASS");
            Console.Printf("CA435IMPORT %s imported living control",user.health>0 && !user.ProfileDeparted
                && user.bSolid && !user.bInvisible && (user.Pos-Start).Length()>0?"PASS":"FAIL");
            Done=true;
        }
    }
    override void UiTick()
    {
        if(!Ready || consoleplayer!=0)return;
        let user=CaelumPlayer(players[0].mo);
        if(!Sent && Conversation)
        {Sent=true;ConversationMenu.SendConversationReply(-1,0);}
        if(Done && !Saved)
        {
            Saved=true;let manager=SavegameManager.GetManager();manager.ReadSaveStrings();
            manager.InsertNewSaveNode();manager.DoSave(0,"CA435 imported session");manager.RemoveNewSaveNode();
        }
    }
}
