class CA440CollectLedger : Inventory
{
    int Phase,Started;
    CaelumLuxuryBedItem Bed;
    CaelumWardrobe Wardrobe;
    CaelumStashChest Ordinary;
    CaelumWaterContainer Bottle;
    CaelumChestCargo Cargo;
    double Weight;
    int Slots;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440Probe : StaticEventHandler
{
    bool Entered,Reloaded;
    void Check(bool okay,String label){Console.Printf("CA440COLLECT %s %s",okay?"PASS":"FAIL",label);}
    override void WorldTick()
    {
        if(level.time<105)return;
        let user=CaelumPlayer(players[0].mo),other=CaelumPlayer(players[1].mo);
        if(!CaelumWorldClockTicker.Ready(user) || !CaelumWorldClockTicker.Ready(other))return;
        let ledger=CA440CollectLedger(user.FindInventory('CA440CollectLedger'));
        if(!Entered){Entered=true;Reloaded=ledger!=null;}
        if(ledger==null)
        {
            user.SetOrigin((0,0,0),false);other.SetOrigin((800,0,0),false);
            user.player.cheats|=CF_GODMODE;other.player.cheats|=CF_GODMODE;
            let record=user.GetPersistentCharacterState(false);
            for(int card=0;card<78;card++)
            {record.TarotOwned[card]=true;record.TarotSelected[card]=false;record.TarotActive[card]=false;record.TarotRemaining[card]=0;}
            record.TarotOrderCount=0;record.TarotLoadoutRevision=1;record.TarotPowerRevision=2;
            record.TarotCooldownTics=record.TarotEffectTics=0;
            user.ApplyCharacterProfile();CaelumInventoryService.GrantMagicBoxFromPalomo(user,false);
            CaelumTarotService.Select(user,17);CaelumTarotSequence.ApplyCard(user,record,17,6000);
            ledger=CA440CollectLedger(user.GiveInventoryType('CA440CollectLedger'));
            ledger.Bed=CaelumLuxuryBedItem(Actor.Spawn('CaelumLuxuryBedItem',user.Pos,NO_REPLACE));ledger.Bed.AttachToOwner(user);
            let release=CaelumTarotStar.View(user);release.Placing=true;release.Point=(160,0,0);
            Check(ledger.Bed.Place(user),"fixture uses native physical bed placement");release.Placing=false;
            ledger.Wardrobe=CaelumWardrobe(Actor.Spawn('CaelumWardrobe',(-128,0,0),NO_REPLACE));
            ledger.Ordinary=CaelumStashChest(Actor.Spawn('CaelumStashChest',(0,-200,0),NO_REPLACE));ledger.Ordinary.args[4]=3;
            ledger.Phase=1;ledger.Started=level.time;return;
        }
        if(!Reloaded && ledger.Phase==1 && level.time-ledger.Started>35)
        {
            user.SetOrigin((80,0,0),false);user.Angle=0;
            Check(ledger.Bed.Carry(user),"heavy placed bed can enter the Box directly");
            Check(ledger.Bed.InMagicBox && ledger.Bed.Owner==user && ledger.Bed.Body.bInvisible,"collection parks the original bed with one boxed item");
            user.SetOrigin((-64,0,0),false);user.Angle=180;
            ledger.Wardrobe.GrantLawfulTitle(user);
            ledger.Bottle=CaelumWaterContainer(Actor.Spawn('CaelumCanteenLarge',ledger.Wardrobe.Pos,NO_REPLACE));
            ledger.Bottle.EnsureWaterQuality();ledger.Bottle.WaterLiters=1;ledger.Bottle.AttachToOwner(ledger.Wardrobe);
            user.RefreshCarriedInventorySummary();ledger.Slots=user.CountNativeMagicBoxSlots();ledger.Weight=user.HUDMagicBoxRawContentWeight;
            Check(CaelumInventoryService.CarryStorageChest(user,ledger.Wardrobe),"placed wardrobe uses its real storage carrier");
            ledger.Cargo=ledger.Wardrobe.Cargo;
            Check(ledger.Cargo!=null && ledger.Cargo.InMagicBox && ledger.Cargo.Chest==ledger.Wardrobe,"heavy storage furniture enters Box without recreating its chest");
            if(ledger.Cargo==null){ledger.Phase=-1;return;}
            user.RefreshCarriedInventorySummary();
            Check(user.CountNativeMagicBoxSlots()==ledger.Slots+1,"stored wardrobe uses exactly one Box slot");
            Check(Abs(user.HUDMagicBoxRawContentWeight-ledger.Weight-ledger.Cargo.CarriedWeight(user))<0.001,"raw weight includes wardrobe and actual contents once");
            Check(ledger.Bottle.Owner==ledger.Wardrobe && ledger.Bottle.WaterLiters==1,"collection preserves original filled bottle");
            Check(!ledger.Wardrobe.CanStore(user),"Boxed furniture cannot be opened as an exposed chest");
            Check(!CaelumContainerRules.Allowed(user,ledger.Cargo,true),"storage carrier cannot nest inside another chest");
            user.SetOrigin((0,-120,0),false);user.Angle=270;
            Check(!CaelumInventoryService.CarryStorageChest(user,ledger.Ordinary),"ordinary heavy chest retains its no-Box rule");
            Check(ledger.Ordinary.Cargo==null && !ledger.Ordinary.bInvisible,"refused ordinary chest stays intact in the world");
            ledger.Phase=2;Console.Printf("CA440COLLECT RESULT capture");
        }
        if(Reloaded && ledger.Phase==2)
        {
            Check(ledger.Bed.InMagicBox && ledger.Bed.Body!=null && ledger.Bed.Body.bInvisible,"native save restores original boxed bed");
            Check(ledger.Cargo!=null && ledger.Cargo.InMagicBox && ledger.Cargo.Chest==ledger.Wardrobe,"native save restores boxed wardrobe state");
            Check(ledger.Bottle.Owner==ledger.Wardrobe && ledger.Bottle.WaterLiters==1,"native save preserves stored liquid and identity");
            user.SetOrigin((0,0,0),false);user.RefreshCarriedInventorySummary();
            ledger.Weight=user.HUDMagicBoxRawContentWeight;ledger.Slots=user.CountNativeMagicBoxSlots();
            Check(CaelumTarotStar.RequestDrop(user,ledger.Cargo),"Drop requests collision-safe placement without a personal-weight prerequisite");
            ledger.Phase=3;ledger.Started=level.time;
        }
        if(Reloaded && ledger.Phase==3 && level.time-ledger.Started>200)
        {
            Check(ledger.Wardrobe.Cargo==null && ledger.Wardrobe.bSolid && !ledger.Wardrobe.bInvisible,"original wardrobe returns to world geometry");
            Check(ledger.Bottle.Owner==ledger.Wardrobe && ledger.Bottle.WaterLiters==1,"release preserves original contents");
            user.RefreshCarriedInventorySummary();
            Check(user.CountNativeMagicBoxSlots()==ledger.Slots-1,"released wardrobe frees exactly one slot");
            Check(Abs(user.HUDMagicBoxRawContentWeight-(ledger.Weight-ledger.Wardrobe.TotalStorageWeight(user)))<0.001,"release removes complete wardrobe weight exactly once");
            Check(CaelumTarotStar.Count(user)==1 && ledger.Bed.InMagicBox,"unrelated giant bed remains boxed");
            ledger.Phase=4;Console.Printf("CA440COLLECT RESULT reload");
        }
    }
}
