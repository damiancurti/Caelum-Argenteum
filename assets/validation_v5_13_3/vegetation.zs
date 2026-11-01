class CA440VegetationLedger : Inventory
{
    int Phase,Started;
    CaelumTreeEnvironmentProp Tree;
    CaelumRockEnvironmentProp Rock;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440Probe : StaticEventHandler
{
    bool Entered,Reloaded;
    void Check(bool okay,String label){Console.Printf("CA440G %s %s",okay?"PASS":"FAIL",label);}
    override void WorldTick()
    {
        let user=CaelumPlayer(players[0].mo),other=CaelumPlayer(players[1].mo);
        if(!CaelumWorldClockTicker.Ready(user) || !CaelumWorldClockTicker.Ready(other))return;
        let ledger=CA440VegetationLedger(user.FindInventory('CA440VegetationLedger'));
        if(!Entered){Entered=true;Reloaded=ledger!=null;}
        if(ledger==null)
        {
            ledger=CA440VegetationLedger(user.GiveInventoryType('CA440VegetationLedger'));
            let record=user.GetPersistentCharacterState(false);
            for(int i=0;i<78;i++){record.TarotSelected[i]=false;record.TarotActive[i]=false;record.TarotRemaining[i]=0;}
            record.TarotOwned[3]=true;record.TarotOrderCount=0;record.TarotLoadoutRevision=1;
            record.TarotPowerRevision=2;record.TarotCooldownTics=record.TarotEffectTics=0;
            other.GetPersistentCharacterState(false).TarotSelected[3]=false;
            user.ApplyCharacterProfile();other.ApplyCharacterProfile();
            user.SetOrigin((-100,0,0),false);other.SetOrigin((-100,200,0),false);
            ledger.Tree=CaelumTreeEnvironmentProp(Actor.Spawn('CaelumTreePlainsEspinillo',(0,0,0),NO_REPLACE));
            ledger.Rock=CaelumRockEnvironmentProp(Actor.Spawn('CaelumRockGranite',(0,200,0),NO_REPLACE));
            ledger.Started=level.time;ledger.Phase=1;return;
        }
        if(ledger.Phase==1 && level.time-ledger.Started>2)
        {
            let record=user.GetPersistentCharacterState(false);
            Check(!user.DerivedStats.TarotVegetationPassage && !user.TryMove((0,0),0),"owning an unequipped Empress does not bypass a tree");
            Check(CaelumTarotService.Select(user,3) && user.DerivedStats.TarotVegetationPassage,"equipping recalculates the cached vegetation permission");
            Check(user.TryMove((0,0),0),"native movement crosses vegetation for its equipped owner");
            Check(ledger.Tree.bSolid && ledger.Tree.bShootable,"vegetation keeps its physical and harvesting flags");
            user.SetOrigin((100,0,0),false);
            other.SetOrigin((-100,0,0),false);
            Check(!other.TryMove((0,0),0),"another player without Empress still collides");
            other.SetOrigin((-100,200,0),false);
            user.SetOrigin((0,0,0),false);
            Check(CaelumTarotService.Select(user,3) && !user.DerivedStats.TarotVegetationPassage,"removing the card immediately restores collision policy");
            Check(user.TryMove((-4,0),0),"a player already inside can take an ordinary outward step after removal");
            Check(user.TryMove((-100,0),0),"a player already inside can finish leaving after removal");
            Check(!user.TryMove((0,0),0),"removed card cannot re-enter vegetation");
            record.TarotActive[3]=true;record.TarotRemaining[3]=2100;user.ApplyCharacterProfile();
            Check(!user.DerivedStats.TarotVegetationPassage && !user.TryMove((0,0),0),"an active World-dispatched Empress does not grant its passive");
            record.TarotActive[3]=false;record.TarotRemaining[3]=0;
            CaelumTarotService.Select(user,3);user.SetOrigin((-100,200,0),false);
            Check(!user.TryMove((0,200),0),"equipped Empress does not bypass stone");
            user.SetOrigin((-990,400,0),false);other.SetOrigin((-300,200,0),false);
            Check(!user.TryMove((-1024,400),0),"equipped Empress does not bypass map walls");
            user.SetOrigin((-100,0,0),false);
            Check(record.TarotEffectTics==0 && record.TarotCooldownTics==0,"vegetation passage requires no active sequence or cooldown");
            ledger.Phase=2;user.PersistCharacterState();Console.Printf("CA440G RESULT capture");return;
        }
        if(ledger.Phase==2 && Reloaded)
        {
            Check(user.DerivedStats.TarotVegetationPassage && user.GetPersistentCharacterState(false).TarotSelected[3],"common recovery preserves equipped vegetation permission");
            Check(ledger.Tree!=null && ledger.Tree.bSolid && user.TryMove((0,0),0),"recovered exact tree remains selectively traversable");
            user.SetOrigin((-100,0,0),false);other.SetOrigin((-100,200,0),false);
            Check(ledger.Tree.CanCollideWith(other,false),"recovery does not grant another player the passive");
            ledger.Phase=3;Console.Printf("CA440G RESULT reload");
        }
    }
}
