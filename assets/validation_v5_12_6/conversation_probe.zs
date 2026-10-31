// Comprobar los campos nativos realmente serializados, sin diálogo automático.
class CA434ProfileProbe : StaticEventHandler
{
    int Stage;
    Actor Speaker;
    ui int SavedStage;
    override void UiTick()
    {
        if((Stage==1 || Stage==2) && Stage!=SavedStage && consoleplayer==0)
        {
            SavedStage=Stage;let manager=SavegameManager.GetManager();manager.ReadSaveStrings();
            manager.InsertNewSaveNode();manager.DoSave(0,"CA434 conversation boundary");manager.RemoveNewSaveNode();
        }
    }
    void Check(bool okay,String label){Console.Printf("CA434 %s %s",okay?"PASS":"FAIL",label);}
    override void WorldTick()
    {
        if(Stage==3 || level.time<105)return;
        let user=CaelumPlayer(players[0].mo);
        if(!CaelumWorldClockTicker.Ready(user))return;
        if(Stage==0)
        {
            Speaker=Actor.Spawn('CaelumPalomo',user.Pos+(100,0,0),NO_REPLACE);
            Check(Speaker!=null,"real speaker actor created");if(Speaker==null){Stage=3;return;}
            Speaker.bInConversation=true;user.player.ConversationNPC=Speaker;user.player.ConversationPC=user;
            Check(user.HasActiveConversation(),"native active dialogue visible to player");Stage=1;
        }
        if(Stage==1 && level.time>=210)
        {
            Speaker.bInConversation=false;
            Check(user.player.ConversationNPC==Speaker,"native speaker reference can remain after dialogue");
            Check(!user.HasActiveConversation(),"stale reference is not an active dialogue");Stage=2;
        }
        if(Stage==2 && level.time>=315)
        {Check(!Speaker.bInConversation,"speaker remains inactive");Stage=3;Console.Printf("CA434 RESULT conversation peer=%d",consoleplayer);}
    }
}
