class CA440StarBlock : Actor
{
    Default {Radius 400;Height 200;+SOLID +NOGRAVITY}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440StarLedger : Inventory
{
    int Phase,Started;
    CaelumLuxuryBedItem Bed;
    CaelumBasicChairItem Chair;
    CaelumLuxuryDiningSetItem Table;
    CaelumTarotHeatRock Rock;
    CA440StarBlock Blocker;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440Probe : StaticEventHandler
{
    bool Entered,Reloaded;
    void Check(bool okay,String label){Console.Printf("CA440STAR %s %s",okay?"PASS":"FAIL",label);}
    override void WorldTick()
    {
        if(level.time<105)return;
        let user=CaelumPlayer(players[0].mo),other=CaelumPlayer(players[1].mo);
        if(!CaelumWorldClockTicker.Ready(user) || !CaelumWorldClockTicker.Ready(other))return;
        let ledger=CA440StarLedger(user.FindInventory('CA440StarLedger'));
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
            ledger=CA440StarLedger(user.GiveInventoryType('CA440StarLedger'));
            ledger.Bed=CaelumLuxuryBedItem(Actor.Spawn('CaelumLuxuryBedItem',user.Pos,NO_REPLACE));ledger.Bed.AttachToOwner(user);
            ledger.Chair=CaelumBasicChairItem(Actor.Spawn('CaelumBasicChairItem',user.Pos,NO_REPLACE));ledger.Chair.AttachToOwner(user);
            ledger.Table=CaelumLuxuryDiningSetItem(Actor.Spawn('CaelumLuxuryDiningSetItem',(700,500,0),NO_REPLACE));
            ledger.Rock=CaelumTarotHeatRock(Actor.Spawn('CaelumTarotHeatRock',(500,0,0),NO_REPLACE));
            ledger.Phase=1;ledger.Started=level.time;return;
        }
        if(!Reloaded && ledger.Phase==1 && level.time-ledger.Started>35)
        {
            Check(CaelumTarotStar.Giant(user,ledger.Bed) && !CaelumTarotStar.Giant(user,ledger.Chair),"native furniture uses exterior dimensions, not its mass");
            double radius=user.Radius,height=user.Height;
            double boundary=CaelumTarotStar.FurnitureVolume(ledger.Bed)*(CaelumPhysicsUnits.MAP_UNITS_PER_METER**3)/(2*CaelumThermalData.CIRCLE_PI*radius*radius);
            user.A_SetSize(radius,boundary+0.001,false);Check(!CaelumTarotStar.Giant(user,ledger.Bed),"below twice-body boundary is ordinary");
            user.A_SetSize(radius,boundary-0.001,false);Check(CaelumTarotStar.Giant(user,ledger.Bed),"above twice-body boundary is giant");user.A_SetSize(radius,height,false);
            Check(!CaelumTarotStar.CanBox(user,ledger.Bed),"giant furniture requires equipped Star");
            CaelumStorageFurnitureInventory.ToggleBox(user,ledger.Bed);
            Check(!ledger.Bed.InMagicBox,"inventory route cannot bypass missing Star");
            Check(CaelumTarotStar.CanBox(user,ledger.Chair),"ordinary furniture keeps existing permission");
            CaelumTarotService.Select(user,17);CaelumTarotService.Select(user,19);
            CaelumTarotSequence.ApplyCard(user,user.GetPersistentCharacterState(false),17,6000);
            CaelumTarotSequence.ApplyCard(user,user.GetPersistentCharacterState(false),19,6000);
            Check(CaelumTarotStar.CanBox(user,ledger.Bed) && !CaelumTarotStar.CanBox(user,ledger.Bed,2),"one giant allowed, batch of two refused before transfer");
            CaelumStorageFurnitureInventory.ToggleBox(user,ledger.Bed);
            Check(ledger.Bed.InMagicBox && CaelumTarotStar.Count(user)==1,"one original bed occupies giant allowance");
            ledger.Table.AttachToOwner(user);
            CaelumStorageFurnitureInventory.ToggleBox(user,ledger.Table);
            Check(!ledger.Table.InMagicBox && !CaelumTarotStar.CanBox(user,ledger.Table),"second giant table is refused");
            Check(!CaelumSunCargo.Capture(user,ledger.Rock),"Sun rock and furniture share the same giant allowance");
            Check(CaelumTarotStar.Count(other)==0,"peer does not share the owner's Box allowance");
            ledger.Blocker=CA440StarBlock(Actor.Spawn('CA440StarBlock',user.Pos,NO_REPLACE));
            Check(CaelumTarotService.Select(user,17),"Star can be unequipped with its giant-drop exception");
            let cargo=CaelumTarotStar.View(user);
            Check(cargo!=null && cargo.Pending.Size()==1 && cargo.Pending[0]==ledger.Bed,"deselection queues original furniture, not a copy");
            Check(!CaelumTarotStar.PrepareTravel(),"blocked release prevents departure");
            ledger.Phase=2;Console.Printf("CA440STAR RESULT capture");
        }
        if(Reloaded && ledger.Phase==2)
        {
            let cargo=CaelumTarotStar.View(user);
            Check(cargo!=null && cargo.Pending.Size()==1 && cargo.Pending[0]==ledger.Bed,"save restores original pending furniture");
            Check(ledger.Bed.InMagicBox && ledger.Bed.Owner==user,"blocked release loses no item");
            ledger.Blocker.Destroy();ledger.Phase=3;ledger.Started=level.time;
        }
        if(Reloaded && ledger.Phase==3 && level.time-ledger.Started>200)
        {
            let cargo=CaelumTarotStar.View(user);
            Check(cargo.Pending.Size()==0 && !ledger.Bed.InMagicBox,"clearing geometry completes automatic drop");
            Check(ledger.Bed.Body!=null && ledger.Bed.Owner==ledger.Bed.Body && ledger.Bed.Body.PackedItem==ledger.Bed,"drop preserves inventory identity and physical bed");
            Check(ledger.Bed.Body!=null && ledger.Bed.Body.bSolid && !ledger.Bed.Body.bInvisible,"released bed renders with normal collision");
            Check(CaelumTarotStar.Count(user)==0 && CaelumTarotStar.PrepareTravel(),"release frees allowance and travel");
            // Simular una partida anterior con un mueble gigante ya guardado.
            ledger.Table.InMagicBox=true;cargo.Revision=0;CaelumTarotStar.Changed(user);CaelumTarotStar.Changed(user);
            Check(cargo.Pending.Size()==1 && cargo.Pending[0]==ledger.Table,"legacy excess is queued idempotently without deleting items");
            ledger.Phase=4;ledger.Started=level.time;
        }
        if(Reloaded && ledger.Phase==4 && level.time-ledger.Started>250)
        {
            Check(ledger.Table.Table!=null && ledger.Table.Owner==ledger.Table.Table,"large dining set releases even when wider than rock search radius");
            Check(CaelumTarotStar.View(user).Pending.Size()==0,"legacy queue drains without repeated furniture creation");
            ledger.Phase=5;Console.Printf("CA440STAR RESULT reload");
        }
    }
}
