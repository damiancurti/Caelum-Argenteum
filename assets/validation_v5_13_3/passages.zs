class CA440PassageLedger : Inventory
{
    int Phase,Started;
    CaelumTarotFalseWall Wall;
    CaelumTarotCursedPassage Left,Right,Untouched;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440Probe : StaticEventHandler
{
    bool Entered,Reloaded;
    void Check(bool ok,String label){Console.Printf("CA440G %s %s",ok?"PASS":"FAIL",label);}
    void Prepare(CaelumPlayer user)
    {
        let record=user.GetPersistentCharacterState(false);
        for(int card=0;card<78;card++)
        {record.TarotOwned[card]=true;record.TarotSelected[card]=false;record.TarotActive[card]=false;record.TarotRemaining[card]=0;}
        record.TarotOrderCount=0;record.TarotLoadoutRevision=1;record.TarotPowerRevision=2;
        record.TarotCooldownTics=record.TarotEffectTics=0;
        user.ApplyCharacterProfile();user.CurrentAnima=user.DerivedStats.MaximumAnima;
    }
    override void WorldTick()
    {
        if(level.time<105)return;
        let user=CaelumPlayer(players[0].mo);let other=CaelumPlayer(players[1].mo);
        if(!CaelumWorldClockTicker.Ready(user) || !CaelumWorldClockTicker.Ready(other))return;
        let ledger=CA440PassageLedger(user.FindInventory('CA440PassageLedger'));
        if(!Entered){Entered=true;Reloaded=ledger!=null;}
        if(ledger==null)
        {
            Prepare(user);Prepare(other);
            ledger=CA440PassageLedger(user.GiveInventoryType('CA440PassageLedger'));
            ledger.Wall=CaelumTarotFalseWall(Actor.Spawn('CaelumTarotFalseWall',(0,0,0),NO_REPLACE));
            ledger.Left=CaelumTarotCursedPassage(Actor.Spawn('CaelumTarotCursedPassage',(-32,200,0),NO_REPLACE));
            ledger.Right=CaelumTarotCursedPassage(Actor.Spawn('CaelumTarotCursedPassage',(32,200,0),NO_REPLACE));
            ledger.Untouched=CaelumTarotCursedPassage(Actor.Spawn('CaelumTarotCursedPassage',(400,200,0),NO_REPLACE));
            ledger.Left.args[0]=ledger.Right.args[0]=440;
            ledger.Wall.args[1]=ledger.Right.args[1]=1;ledger.Left.args[1]=-1;
            ledger.Wall.Angle=ledger.Left.Angle=ledger.Right.Angle=0;
            user.SetOrigin((0,-40,0),false);user.Angle=90;user.Pitch=0;
            other.SetOrigin((-700,-700,0),false);ledger.Phase=1;ledger.Started=level.time;return;
        }
        if(ledger.Phase==1 && level.time-ledger.Started>2)
        {
            let record=user.GetPersistentCharacterState(false);let panel=new("CaelumTargetInfo");
            panel.Refresh(user);
            Check(panel.Subject==ledger.Wall && panel.Title==CaelumTargetInfo.L("CA_TAROT_UNMARKED_WALL") && panel.Actions=="","native aim keeps an unequipped false wall anonymous");
            Check(!CaelumTarotFalseWall.Revealed(user),"owning Priestess does not grant its passive");
            CaelumTarotService.Select(user,2);panel.Refresh(user);
            Check(panel.Subject==ledger.Wall && panel.Title==CaelumTargetInfo.L("CA_TAROT_FALSE_WALL") && panel.Actions!="","equipped Priestess reveals only the aimed authored wall");
            Check(!CaelumTarotFalseWall.Revealed(other),"another player does not inherit private equipment knowledge");
            CaelumTarotService.Select(user,2);
            Check(ledger.Wall.Used(user) && ledger.Wall.DoorRequested,"identification is not an extra key requirement for a discovered wall");
            Check(!ledger.Left.CanOpenPassage(user),"owning Hierophant does not purify a curse");
            user.SetOrigin((0,160,0),false);user.Angle=90;
            Check(!ledger.Left.RequestDoorGroup(user) && !ledger.Left.Purified && !ledger.Right.Purified,"unqualified use preserves every cursed leaf");
            CaelumTarotService.Select(user,5);
            ledger.Right.RuloArenaLocked=true;
            Check(!ledger.Left.RequestDoorGroup(user) && !ledger.Left.Purified && !ledger.Right.Purified,"scene-locked peer prevents partial purification");
            ledger.Right.RuloArenaLocked=false;ledger.Right.args[3]=1;
            Check(!ledger.Left.RequestDoorGroup(user) && !ledger.Left.Purified && !ledger.Right.Purified,"missing key is checked before purifying any leaf");
            ledger.Right.args[3]=0;
            double anima=user.CurrentAnima;int cooldown=record.TarotCooldownTics;
            Check(ledger.Left.RequestDoorGroup(user) && ledger.Left.Purified && ledger.Right.Purified,"qualified use purifies and opens the entire permitted group");
            Check(user.CurrentAnima==anima && record.TarotCooldownTics==cooldown,"passive purification does not charge a Tarot sequence");
            Check(!ledger.Untouched.Purified,"unrelated passages retain their curse");
            CaelumTarotService.Select(user,5);
            Check(ledger.Right.RequestDoorGroup(user),"purification persists after unequipping Hierophant");
            Check(ledger.Left.CanOpenPassage(other),"the opened world passage is shared with other characters");
            let ordinary=CaelumSlidingDoorLeaf(Actor.Spawn('CaelumSlidingDoorLeaf',(600,200,0),NO_REPLACE));
            Check(ordinary.CanOpenPassage(user),"ordinary doors retain their existing permission rules");ordinary.Destroy();
            user.SetOrigin((0,-40,0),false);user.Angle=90;
            ledger.Phase=2;user.PersistCharacterState();other.PersistCharacterState();
            Console.Printf("CA440G RESULT capture");return;
        }
        if(ledger.Phase==2 && Reloaded)
        {
            Check(ledger.Left.PassageRevision==CaelumMajorArcanaData.PASSAGE_REVISION && ledger.Left.Purified && ledger.Right.Purified,"common save preserves both purified leaves and revision");
            Check(!ledger.Untouched.Purified,"common save does not purify untouched passages");
            Check(!CaelumTarotFalseWall.Revealed(user) && !CaelumTarotFalseWall.Revealed(other),"loading does not equip cards or leak secret identification");
            user.SetOrigin((0,160,0),false);
            Check(ledger.Left.RequestDoorGroup(user),"recovered purified passage opens without recasting");
            Check(ledger.Left.Peers()==ledger.Right.Peers(),"recovered native door group retains one shared permission transaction");
            ledger.Phase=3;Console.Printf("CA440G RESULT reload");
        }
    }
}
