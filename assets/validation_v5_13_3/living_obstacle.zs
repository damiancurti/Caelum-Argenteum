class CA440ObstacleLedger : Inventory
{
    int Phase,Started;
    CaelumTarotLivingObstacle Marked,Far;
    CaelumTreePlainsEspinillo Ordinary;
    CaelumContaminationState Dirt;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440Probe : StaticEventHandler
{
    bool Entered,Reloaded;
    void Check(bool okay,String label){Console.Printf("CA440O %s %s",okay?"PASS":"FAIL",label);}
    override void WorldTick()
    {
        let user=CaelumPlayer(players[0].mo),other=CaelumPlayer(players[1].mo);
        if(!CaelumWorldClockTicker.Ready(user) || !CaelumWorldClockTicker.Ready(other))return;
        let ledger=CA440ObstacleLedger(user.FindInventory('CA440ObstacleLedger'));
        if(!Entered){Entered=true;Reloaded=ledger!=null;}
        if(ledger==null)
        {
            ledger=CA440ObstacleLedger(user.GiveInventoryType('CA440ObstacleLedger'));
            let record=user.GetPersistentCharacterState(false);
            for(int i=0;i<78;i++){record.TarotSelected[i]=false;record.TarotActive[i]=false;record.TarotRemaining[i]=0;}
            record.TarotOwned[13]=true;record.TarotOrderCount=0;record.TarotLoadoutRevision=1;
            record.TarotPowerRevision=2;record.TarotCooldownTics=record.TarotEffectTics=0;
            other.GetPersistentCharacterState(false).TarotSelected[13]=false;
            user.ApplyCharacterProfile();user.SetOrigin((-60,0,0),false);other.SetOrigin((-60,-100,0),false);
            user.Angle=0;user.Pitch=0;
            ledger.Marked=CaelumTarotLivingObstacle(Actor.Spawn('CaelumTarotLivingObstacle',(0,0,0),NO_REPLACE));
            ledger.Far=CaelumTarotLivingObstacle(Actor.Spawn('CaelumTarotLivingObstacle',(400,0,0),NO_REPLACE));
            ledger.Ordinary=CaelumTreePlainsEspinillo(Actor.Spawn('CaelumTreePlainsEspinillo',(0,200,0),NO_REPLACE));
            ledger.Dirt=CaelumContaminationStorage.Get(ledger.Marked,true);
            ledger.Started=level.time;ledger.Phase=1;return;
        }
        if(ledger.Phase==1 && level.time-ledger.Started>2)
        {
            let record=user.GetPersistentCharacterState(false);
            Check(!ledger.Marked.DestroyByTarot(user),"owning Death without equipping it cannot destroy an obstacle");
            record.TarotActive[13]=true;
            Check(!ledger.Marked.DestroyByTarot(user),"an active flag alone does not grant the passive");
            record.TarotActive[13]=false;CaelumTarotService.Select(user,13);
            Check(!ledger.Marked.DestroyByTarot(other),"equipped permission is not shared with another player");
            Check(!ledger.Far.DestroyByTarot(user),"interaction cannot destroy a distant marked obstacle");
            double anima=user.CurrentAnima;
            Check(user.TryPushMovablePropInFront(),"ordinary native Use trace invokes the equipped Death passive");
            Check(ledger.Marked==null || ledger.Marked.bDestroyed,"marked obstacle leaves the world through native destruction");
            Check(ledger.Dirt.Concentration==100,"the exact obstacle record is contaminated before destruction");
            Check(user.CurrentAnima==anima && record.TarotCooldownTics==0,"passive destruction does not charge an active sequence");
            user.SetOrigin((-60,200,0),false);user.TryPushMovablePropInFront();
            Check(ledger.Ordinary!=null && !ledger.Ordinary.bDestroyed && ledger.Ordinary.bSolid,"ordinary vegetation keeps its collision and harvesting identity");
            CaelumTarotService.Select(user,13);user.SetOrigin((340,0,0),false);
            Check(!ledger.Far.DestroyByTarot(user),"unequipping immediately removes permission");
            ledger.Phase=2;user.PersistCharacterState();Console.Printf("CA440O RESULT capture");return;
        }
        if(ledger.Phase==2 && Reloaded)
        {
            Check(ledger.Marked==null,"save recovery does not recreate the destroyed obstacle");
            Check(ledger.Far!=null && !ledger.Far.bDestroyed && ledger.Ordinary!=null && !ledger.Ordinary.bDestroyed,"save recovery preserves untouched marked and ordinary trees");
            Check(ledger.Dirt.Concentration==100 && !user.GetPersistentCharacterState(false).TarotSelected[13],"recovery preserves contamination evidence and the unequipped loadout");
            ledger.Phase=3;Console.Printf("CA440O RESULT reload");
        }
    }
}
