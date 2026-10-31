// El guardado ocurre después de toda la transacción y no se repite al cargar.
class CA434ProfileProbe : StaticEventHandler
{
    int Stage,BaseSerial;
    bool Reload;
    ui bool Logged;
    override void UiTick()
    {
        if(Stage==2 && !Logged)
        {
            Logged=true;Console.Printf("CA434 DEBUG ready=%d paused=%d menu=%d console=%d up=%d action=%d",CaelumNarrativeCheckpoint.Ready(),paused,menuactive,ConsoleState,c_up,gameaction);
            for(int i=0;i<2;i++){let user=CaelumPlayer(players[i].mo);Console.Printf("CA434 DEBUG slot=%d complete=%d wizard=%d crafting=%d npc=%p",i,user.CharacterCreationComplete,user.CreationWizardOpen,user.CraftingTaskCompleting,user.player.ConversationNPC);}
        }
    }
    void Check(bool value,String label){Console.Printf("CA434 %s %s",value?"PASS":"FAIL",label);}
    override void WorldLoaded(WorldEvent e){Reload=e.IsSaveGame;}
    override void WorldTick()
    {
        if(Stage==9 || level.time<105)return;
        let a=CaelumPlayer(players[0].mo);let b=CaelumPlayer(players[1].mo);
        if(!CaelumWorldClockTicker.Ready(a) || !CaelumWorldClockTicker.Ready(b))return;
        let r=b.GetPersistentCharacterState(false);
        if(Reload)
        {
            Check(r.NarrativeCheckpoint!=null,"checkpoint state restored");
            Check(r.NarrativeCheckpoint.Queued==r.NarrativeCheckpoint.Serial,"loaded transaction already dispatched");
            Check(r.PrisonerRewardClaimed[0],"reward receipt restored");
            let coins=b.FindInventory('CaelumCopperCoin');Check(coins!=null && coins.Amount==777,"complete reward wallet restored");
            Check(r.MainM00SealChoice==2,"irreversible choice restored");
            int before=r.NarrativeCheckpoint.Serial;b.PersistCharacterState();
            Check(r.NarrativeCheckpoint.Serial==before,"persisting unchanged state does not repeat checkpoint");
            Stage=9;Console.Printf("CA434 RESULT narrative reload peer=%d",consoleplayer);return;
        }
        if(Stage==0)
        {
            b.PersistCharacterState();BaseSerial=r.NarrativeCheckpoint.Serial;
            Check(r.NarrativeCheckpoint.Revision==1,"legacy/new baseline initialized");
            b.CraftingTaskCompleting=true;
            r.PrisonerRewardClaimed[0]=true;let coins=b.GiveInventoryType('CaelumCopperCoin');coins.Amount=777;
            // El diálogo automático del rescate no forma parte de esta prueba.
            r.DemoNarrativeDelivered|=CaelumDemoNarrative.ObservedEvents(r);r.DemoNarrativePending=0;
            b.PersistCharacterState();
            Check(r.NarrativeCheckpoint.Serial==BaseSerial+1,"reward transaction requests checkpoint");
            Check(!CaelumNarrativeCheckpoint.Ready(),"busy transaction defers all peers");
            Stage=1;
        }
        if(Stage==1 && level.time>=140)
        {
            Check(r.NarrativeCheckpoint.Queued<r.NarrativeCheckpoint.Serial,"pending checkpoint survives busy state");
            b.CraftingTaskCompleting=false;Stage=2;
        }
        if(Stage==2 && level.time>=210)
        {
            Check(r.NarrativeCheckpoint.Queued==r.NarrativeCheckpoint.Serial,"host queues reward save for every peer");
            int before=r.NarrativeCheckpoint.Serial;b.PersistCharacterState();
            Check(r.NarrativeCheckpoint.Serial==before,"same transaction is idempotent");
            r.MainM00SealChoice=2;b.PersistCharacterState();
            Check(r.NarrativeCheckpoint.Serial==before+1,"irreversible choice requests next checkpoint");
            Stage=3;
        }
        if(Stage==3 && level.time>=280)
        {
            Check(r.NarrativeCheckpoint.Queued==r.NarrativeCheckpoint.Serial,"second transaction dispatched");
            Check(CaelumSaveRules.ACTIVE_INTERVAL_SECONDS==300,"five-active-minute autosave interval preserved");
            Stage=9;Console.Printf("CA434 RESULT narrative peer=%d",consoleplayer);
        }
    }
}
