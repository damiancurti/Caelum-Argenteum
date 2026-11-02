class CA440ExampleRuntimeLedger : Inventory
{
    int Phase,Started;
    CaelumTarotExampleRoom Room;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440LivingExampleLedger : Inventory
{
    int Phase;
    CaelumTarotExampleRoom Room;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440Probe : StaticEventHandler
{
    bool Entered,Reloaded;
    void Check(bool ok,String label){Console.Printf("CA440B %s %s",ok?"PASS":"FAIL",label);}
    override void WorldTick()
    {
        if(level.time<105)return;
        let user=CaelumPlayer(players[0].mo),other=CaelumPlayer(players[1].mo);
        if(!CaelumWorldClockTicker.Ready(user) || !CaelumWorldClockTicker.Ready(other))return;
        let ledger=CA440LivingExampleLedger(user.FindInventory('CA440LivingExampleLedger'));
        if(!Entered){Entered=true;Reloaded=ledger!=null;}
        if(ledger==null)
        {
            let previous=CA440ExampleRuntimeLedger(user.FindInventory('CA440ExampleRuntimeLedger'));
            let room=CaelumTarotExamples.Get();
            Check(previous!=null && previous.Room==room && room.Revision==2,"prior apparatus save upgrades its original controller to revision2");
            if(room==null)return;
            ledger=CA440LivingExampleLedger(user.GiveInventoryType('CA440LivingExampleLedger'));ledger.Room=room;
            Check(room.Wet && CaelumTarotCursedPassage(room.Doors[1]).Purified,"upgrade preserves Wheel state and purified passage");
            let tree=room.LivingObstacle;
            Check(tree!=null && tree.Pos==CaelumTarotExampleData.Living(),"living obstacle occupies the authored display position");
            if(tree==null)return;
            Check(tree.Radius==16 && tree.Height==106 && tree.Mass==2211,"example retains the existing espinillo physical profile");
            Check(tree.TestMobjLocation(),"native tree collision fits the display room");
            room.Prepare();Check(room.LivingObstacle==tree,"repeated preparation does not duplicate the live example");
            user.SetOrigin(tree.Pos+(0,-64,0),false);user.Angle=90;user.Pitch=0;
            other.SetOrigin(tree.Pos+(128,64,0),false);
            let record=user.GetPersistentCharacterState(false);record.TarotSelected[13]=false;
            Check(!user.TryPushMovablePropInFront() && !tree.bDestroyed,"mere ownership cannot destroy the example through native Use");
            let panel=new('CaelumTargetInfo');panel.Refresh(user);
            Check(panel.Subject==tree && panel.Actions==CaelumTargetInfo.L("CA_TAROT_LIVING_REQUIRES"),"aim panel explains the missing equipped passive");
            record.TarotSelected[13]=true;
            panel.Refresh(user);
            Check(panel.Subject==tree && panel.Actions==CaelumTargetInfo.L("CA_TAROT_LIVING_BREAK"),"aim panel exposes the bound Use action when equipped");
            int cooldown=record.TarotCooldownTics;double anima=user.CurrentAnima;
            Check(user.TryPushMovablePropInFront(),"equipped Death destroys the actual placed obstacle through native Use");
            Check(record.TarotCooldownTics==cooldown && user.CurrentAnima==anima,"passive interaction adds no payment or cooldown");
            room.Prepare();
            Check(room.LivingObstacle==null || room.LivingObstacle.bDestroyed,"preparation does not regenerate a destroyed example");
            ledger.Phase=1;Console.Printf("CA440B RESULT capture");return;
        }
        if(Reloaded && ledger.Phase==1)
        {
            let room=CaelumTarotExamples.Get();
            Check(room==ledger.Room && room.Revision==2,"common recovery preserves the upgraded controller");
            Check(room.LivingObstacle==null || room.LivingObstacle.bDestroyed,"destroyed example remains absent after recovery");
            room.Prepare();Check(room.LivingObstacle==null || room.LivingObstacle.bDestroyed,"recovery migration remains idempotent after destruction");
            Check(room.Wet && CaelumTarotCursedPassage(room.Doors[1]).Purified,"unrelated saved room results remain intact");
            ledger.Phase=2;Console.Printf("CA440B RESULT reload");
        }
    }
}
