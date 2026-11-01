class CA440ExampleRuntimeLedger : Inventory
{
    int Phase,Started;
    CaelumTarotExampleRoom Room;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440Probe : StaticEventHandler
{
    bool Entered,Reloaded;
    void Check(bool ok,String label){Console.Printf("CA440Y %s %s",ok?"PASS":"FAIL",label);}
    void Prepare(CaelumPlayer user)
    {
        let record=user.GetPersistentCharacterState(false);
        record.EnsureQuestStateInitialized();
        record.MainM00Flag[CaelumConstants.MAIN_M00_FLAG_UNKNOWN_VOICE_HEARD]=true;
        record.QuestStage[CaelumConstants.QUEST_MAIN_M00_THE_FOOL]=CaelumConstants.MAIN_M00_STATE_MET_PALOMO;
        for(int card=0;card<78;card++)
        {record.TarotOwned[card]=true;record.TarotSelected[card]=false;record.TarotActive[card]=false;record.TarotRemaining[card]=0;}
        record.TarotOrderCount=0;record.TarotLoadoutRevision=1;record.TarotPowerRevision=2;
        record.TarotCooldownTics=record.TarotEffectTics=0;
        user.ApplyCharacterProfile();user.CurrentAnima=user.DerivedStats.MaximumAnima;
        user.PersistCharacterState();
    }
    override void WorldTick()
    {
        if(level.time<105)return;
        let user=CaelumPlayer(players[0].mo),other=CaelumPlayer(players[1].mo);
        if(!CaelumWorldClockTicker.Ready(user) || !CaelumWorldClockTicker.Ready(other))return;
        let ledger=CA440ExampleRuntimeLedger(user.FindInventory('CA440ExampleRuntimeLedger'));
        if(!Entered){Entered=true;Reloaded=ledger!=null;}
        if(ledger==null)
        {
            Prepare(user);Prepare(other);
            ledger=CA440ExampleRuntimeLedger(user.GiveInventoryType('CA440ExampleRuntimeLedger'));
            ledger.Phase=1;Level.ChangeLevel("MAP01",0,CHANGELEVEL_NOINTERMISSION);return;
        }
        if(ledger.Phase==1)
        {
            if(!CaelumTarotExampleData.Present())
            {
                Check(CaelumTarotExamples.Get()==null,"legacy mansion receives no new controller or misplaced fixtures");
                Check(!CaelumTarotExamples.Wheel(user,false),"legacy mansion safely skips the unavailable Wheel effect");
                ledger.Phase=9;Console.Printf("CA440Y RESULT capture");return;
            }
            let room=CaelumTarotExamples.Get();ledger.Room=room;
            Check(room!=null && room.Revision==1,"new mansion initializes its saved bounded controller");
            if(room==null)return;
            Check(room.Doors[0] is 'CaelumTarotFalseWall' && room.Doors[1] is 'CaelumTarotCursedPassage',"authored passives have real placed door targets");
            Check(!room.Wet && CaelumTarotExampleRoute(room.Doors[2]).OpenRoute()
                && !CaelumTarotExampleRoute(room.Doors[3]).OpenRoute(),"dry state opens only its intended route");
            user.SetOrigin(CaelumTarotExampleData.Portal(0)+(0,32,-0.5),false);
            vector3 origin=user.Pos;other.SetOrigin(CaelumTarotExampleData.Arrival(0),false);
            Check(!room.Portals[0].Used(user) && user.Pos==origin,"occupied portal destination is not telefragged or bypassed");
            other.SetOrigin(CaelumTarotExampleData.Controller()+(64,0,0),false);
            Check(room.Portals[0].Used(user) && user.Pos==CaelumTarotExampleData.Arrival(0),"mansion Use enters the annex without changing maps");
            Check(user.TestMobjLocation(),"native arrival point is clear in the authored corridor");
            user.SetOrigin(CaelumTarotExampleData.Portal(1)+(32,0,-0.5),false);
            Check(room.Portals[1].Used(user) && user.Pos==CaelumTarotExampleData.Arrival(1),"annex Use returns to the practice room");
            Check(user.TestMobjLocation(),"mansion return clears its real furnishings");
            Check(!CaelumTarotExamples.Wheel(user,false) && !room.Wet,"ordinary mansion rooms cannot be altered");
            user.SetOrigin(CaelumTarotExampleData.Door(1)+(0,-40,0),false);
            CaelumTarotService.Select(user,5);
            Check(room.Doors[1].Used(user) && CaelumTarotCursedPassage(room.Doors[1]).Purified,"placed cursed passage supports actual passive Use");
            CaelumTarotService.Select(user,5);
            user.SetOrigin(CaelumTarotExampleData.Controller()+(-64,0,0),false);
            CaelumTarotService.Select(user,10);let record=user.GetPersistentCharacterState(false);
            double anima=user.CurrentAnima;
            Check(CaelumTarotService.Activate(user) && room.Wet,"real equipped sequence toggles the Wheel room");
            Check(Abs(anima-user.CurrentAnima-1000)<0.01 && record.TarotCooldownTics==600*TICRATE,"Wheel uses one ordinary shared payment and cooldown");
            Check(!record.TarotActive[10] && record.TarotRemaining[10]==0,"instantaneous room change has no repeating timer");
            ledger.Phase=2;ledger.Started=level.time;return;
        }
        if(ledger.Phase==2 && level.time-ledger.Started>20)
        {
            let room=ledger.Room;
            Check(user.waterlevel>0 && other.waterlevel>0 && user.CurSector.lightlevel==32,"wet state uses native water and darkness for both players");
            Check(!CaelumTarotExampleRoute(room.Doors[2]).OpenRoute()
                && CaelumTarotExampleRoute(room.Doors[3]).OpenRoute(),"wet state swaps the two routes");
            Check(room.Doors[2].SlideProgress==0 && room.Doors[3].SlideProgress==64,"native leaf collisions match the selected routes");
            other.SetOrigin(room.Doors[3].ClosedPosition,false);
            Check(!CaelumTarotExamples.Wheel(user,false) && room.Wet,"a body in the closing doorway prevents the whole state change");
            other.SetOrigin(CaelumTarotExampleData.Controller()+(64,0,0),false);
            Check(CaelumTarotExamples.Wheel(user,false) && !room.Wet,"clearing the doorway permits the dry state");
            ledger.Phase=3;ledger.Started=level.time;return;
        }
        if(ledger.Phase==3 && level.time-ledger.Started>20)
        {
            let room=ledger.Room;let record=user.GetPersistentCharacterState(false);
            Check(user.waterlevel==0 && other.waterlevel==0 && user.CurSector.lightlevel==192,"dry state restores air and light without moving the players");
            CaelumTarotSequence.ApplyCard(user,record,10,4200,null,false);
            Check(room.Wet && !record.TarotActive[10],"Hermit duration still executes only one instantaneous room change");
            user.Angle=90;user.Pitch=0;ledger.Phase=4;user.PersistCharacterState();other.PersistCharacterState();
            Console.Printf("CA440Y RESULT capture");return;
        }
        if(ledger.Phase==4 && Reloaded)
        {
            let room=CaelumTarotExamples.Get();
            Check(room==ledger.Room && room.Wet,"common recovery rebinds the exact saved controller and state");
            Check(CaelumTarotCursedPassage(room.Doors[1]).Purified,"recovery preserves the purifying player's world result");
            Check(Abs(level.Sectors[CaelumTarotExampleData.WATER].CenterCeiling()-64)<0.01
                && level.Sectors[CaelumTarotExampleData.ROOM].lightlevel==32,"recovery retains native wet geometry and light");
            let iterator=ThinkerIterator.Create('CaelumTarotExampleRoom');
            Check(iterator.Next()==room && iterator.Next()==null,"restoration does not duplicate the controller or its fixtures");
            Check(room.Portals[0].Room==room && room.Portals[1].Room==room,"both saved access points retain ownership");
            ledger.Phase=5;Console.Printf("CA440Y RESULT reload");
        }
        if(ledger.Phase==9 && Reloaded)
        {Check(CaelumTarotExamples.Get()==null,"legacy recovery remains free of new apparatus");ledger.Phase=10;Console.Printf("CA440Y RESULT reload");}
    }
}
