class CA437SoloLedger : Inventory
{
    int Phase;
    CaelumPlayer Body;
    CaelumPersistentCharacterState Record;
    Inventory Coin;
    vector3 Origin;
    double AnimaBefore;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA437ClockProbe : EventHandler
{
    bool Done;
    void Check(bool ok,String message){Console.Printf("CA437 %s %s",ok?"PASS":"FAIL",message);}
    override void WorldTick()
    {
        if(Done || level.time<35)return;
        let user=CaelumPlayer(players[0].mo);if(!CaelumWorldClockTicker.Ready(user))return;
        let ledger=CA437SoloLedger(user.FindInventory('CA437SoloLedger'));
        if(ledger==null)
        {
            if(user.player.ConversationNPC!=null)user.player.ConversationNPC.bInConversation=false;
            user.player.ConversationNPC=null;user.player.ConversationPC=null;
            ledger=CA437SoloLedger(user.GiveInventoryType('CA437SoloLedger'));
            ledger.Body=user;ledger.Record=user.GetPersistentCharacterState(false);ledger.Origin=user.Pos;
            ledger.Record.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_UNKNOWN_VOICE_HEARD);
            ledger.Record.TarotOwned[CaelumConstants.TAROT_THE_FOOL]=true;
            ledger.Record.TarotSelected[CaelumConstants.TAROT_THE_FOOL]=true;
            user.CurrentAnima=user.DerivedStats.MaximumAnima;ledger.AnimaBefore=user.CurrentAnima;
            ledger.Coin=user.GiveInventoryType('CaelumCopperCoin');
            Check(CaelumTarotService.Activate(user) && Abs(user.CurrentAnima-(ledger.AnimaBefore-CaelumConstants.TAROT_ACTIVATION_ANIMA))<0.01,
                "solo living Fool activation pays once and commits without waiting for another player");
            ledger.Phase=1;return;
        }
        if(level.MapName=="MAP01" && ledger.Phase==1)
        {
            Check(user==ledger.Body && user.health>0 && !CaelumSpirit.Active(user),"living solo visitor remains living on arrival");
            Check(ledger.Record.TarotCooldownTics>0 && user.FindInventory('CaelumTarotFlight')==null,"solo journey retains the ordinary cooldown without granting flight");
            Check(user.FindInventory('CaelumCopperCoin')==ledger.Coin,"solo visit preserves original material item");
            let speaker=CaelumPalomo(Actor.Spawn('CaelumPalomo',user.Pos+(48,0,0),NO_REPLACE));
            speaker.args[0]=1;speaker.MerchantAnchored=true;speaker.WanderEnabled=false;
            user.Angle=0;user.Pitch=0;
            Check(user.OpenPalomoDialogue(speaker),"living solo player can ask Palomo to return");
            user.GiveInventoryType('CaelumFoolReturnAction');
            speaker.bInConversation=false;user.player.ConversationNPC=null;user.player.ConversationPC=null;
            ledger.Phase=2;return;
        }
        if(level.MapName=="MAP03" && ledger.Phase==2)
        {
            Check(user==ledger.Body && user.health>0 && (user.Pos-ledger.Origin).Length()<0.1,"solo return preserves identity and individual departure point");
            Check(user.CurrentAnima>=ledger.AnimaBefore-CaelumConstants.TAROT_ACTIVATION_ANIMA,"solo return has no extra payment and preserves normal living regeneration");
            ledger.Record.TarotCooldownTics=0;user.CurrentAnima=ledger.AnimaBefore;
            user.health=user.player.health=0;user.Die(null,null,0,'None');ledger.Phase=3;return;
        }
        if(level.MapName=="MAP01" && ledger.Phase==3)
        {
            Check(user==ledger.Body && user.health<=0 && CaelumSpirit.Active(user),"native User3 permits the exceptional dead solo journey without resurrection");
            Check(Abs(user.CurrentAnima-(ledger.AnimaBefore-CaelumConstants.TAROT_ACTIVATION_ANIMA))<0.01,"native dead activation applies the usual payment");
            Check(user.FindInventory('CaelumCopperCoin')==ledger.Coin,"exceptional journey preserves the same material item");
            Done=true;ledger.Phase=4;Console.Printf("CA437 RESULT peer=%d solo",consoleplayer);
        }
    }
}
