class CA440CargoBlock : Actor
{
    Default {Radius 200;Height 100;+SOLID +NOGRAVITY}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440CargoLedger : Inventory
{
    int Phase,Started,Entries;
    CaelumTarotHeatRock Rock;
    CA440CargoBlock Blocker;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440Probe : StaticEventHandler
{
    bool Entered,Reloaded;
    ui bool Shown;
    void Check(bool okay,String label){Console.Printf("CA440CARGO %s %s",okay?"PASS":"FAIL",label);}
    void Select(CaelumPlayer user,Inventory item)
    {
        user.FormalInventoryFilter=0;
        for(int i=0;i<user.CountFormalInventoryEntries();i++)if(user.GetFormalInventoryEntryAt(i)==item)
        {user.FormalInventorySelectionIndex=i;break;}
        user.RefreshFormalInventorySnapshot();
    }
    override void UiTick()
    {
        if(consoleplayer!=0 || gamestate!=GS_LEVEL || Shown)return;
        let user=CaelumPlayer(players[0].mo);
        let ledger=user!=null?CA440CargoLedger(user.FindInventory('CA440CargoLedger')):null;
        if(ledger==null || ledger.Phase!=2 || Reloaded)return;
        let openState=CVar.GetCVar("ca_journal_open",players[0]);
        let page=CVar.GetCVar("ca_journal_page",players[0]);
        if(openState!=null)openState.SetBool(true);
        if(page!=null)page.SetInt(0);Shown=true;
    }
    override void WorldTick()
    {
        if(level.time<105)return;
        let user=CaelumPlayer(players[0].mo),other=CaelumPlayer(players[1].mo);
        if(!CaelumWorldClockTicker.Ready(user) || !CaelumWorldClockTicker.Ready(other))return;
        let ledger=CA440CargoLedger(user.FindInventory('CA440CargoLedger'));
        if(!Entered){Entered=true;Reloaded=ledger!=null;}
        if(ledger==null)
        {
            user.SetOrigin((0,0,0),false);other.SetOrigin((800,0,0),false);
            let record=user.GetPersistentCharacterState(false);
            for(int card=0;card<78;card++)
            {record.TarotOwned[card]=true;record.TarotSelected[card]=false;record.TarotActive[card]=false;record.TarotRemaining[card]=0;}
            record.TarotOrderCount=0;record.TarotLoadoutRevision=1;record.TarotPowerRevision=2;
            record.TarotCooldownTics=record.TarotEffectTics=0;
            user.ApplyCharacterProfile();CaelumInventoryService.GrantMagicBoxFromPalomo(user,false);
            CaelumTarotService.Select(user,17);CaelumTarotService.Select(user,19);
            CaelumTarotSequence.ApplyCard(user,record,17,6000);CaelumTarotSequence.ApplyCard(user,record,19,6000);
            ledger=CA440CargoLedger(user.GiveInventoryType('CA440CargoLedger'));
            user.FormalInventoryFilter=0;ledger.Entries=user.CountFormalInventoryEntries();
            ledger.Rock=CaelumTarotHeatRock(Actor.Spawn('CaelumTarotHeatRock',(96,0,0),NO_REPLACE));
            ledger.Phase=1;ledger.Started=level.time;return;
        }
        if(!Reloaded && ledger.Phase==1 && level.time-ledger.Started>35)
        {
            Check(CaelumSunCargo.Capture(user,ledger.Rock),"capture installs original cargo");
            let cargo=CaelumSunCargo.View(user);if(cargo==null || cargo.Body==null){ledger.Phase=-1;return;}
            Select(user,cargo);int row=user.FormalInventorySelectionIndex-user.FormalInventoryVisibleStart;
            Check(user.CountFormalInventoryEntries()==ledger.Entries+1,"one contained object adds one inventory row");
            Check(user.FormalInventoryRowKind[row]==CaelumConstants.EQUIPMENT_KIND_CONTAINER
                && user.FormalInventoryRowType[row]==CaelumMajorArcanaData.SUN_HEAT_DISPLAY,"snapshot identifies hot rock without chest substitution");
            Check(user.FormalInventoryRowInMagicBox[row] && user.FormalInventoryRowAmount[row]==1,"row reports one boxed original");
            Check(Abs(user.FormalInventoryRowWeight[row]-ledger.Rock.PhysicalMass())<0.00001,"row reports exact raw sphere mass");
            Check(cargo.CreateTossable()==null,"carrier cannot create a duplicate pickup");
            ledger.Blocker=CA440CargoBlock(Actor.Spawn('CA440CargoBlock',user.Pos,NO_REPLACE));
            CaelumInventoryService.ActivateFormalInventorySelection(user);
            Check(cargo.Pending && cargo.Body==ledger.Rock,"Use requests safe release instead of opening a chest");
            CaelumInventoryService.ToggleFormalInventoryStorage(user);
            Check(cargo.Pending && ledger.Rock.Contained,"Move cannot bypass blocked geometry or attach rock to body");
            CaelumInventoryService.DropFormalInventorySelection(user);
            Check(cargo.Body==ledger.Rock && ledger.Blocker.health>0,"Drop retains original without telefrag or item loss");
            Check(CaelumSunCargo.View(other)==null,"peer inventory does not inherit owner's cargo");
            ledger.Phase=2;Console.Printf("CA440CARGO RESULT capture");
        }
        if(Reloaded && ledger.Phase==2)
        {
            let cargo=CaelumSunCargo.View(user);Select(user,cargo);
            Check(cargo!=null && cargo.Pending && cargo.Body==ledger.Rock,"recovery retains pending command and original identity");
            Check(user.CountFormalInventoryEntries()==ledger.Entries+1,"recovery shows exactly one cargo row");
            ledger.Blocker.Destroy();ledger.Phase=3;ledger.Started=level.time;
        }
        if(Reloaded && ledger.Phase==3 && level.time-ledger.Started>175)
        {
            user.RefreshFormalInventorySnapshot();
            Check(!CaelumSunCargo.Occupied(user) && !ledger.Rock.Contained,"free space completes saved release request");
            Check(user.CountFormalInventoryEntries()==ledger.Entries,"empty metadata leaves no ghost inventory row");
            Check(ledger.Rock.Heat.Watts()==8000 && !ledger.Rock.Visual.bInvisible,"released original resumes owned visual and source");
            ledger.Phase=4;Console.Printf("CA440CARGO RESULT reload");
        }
    }
}
