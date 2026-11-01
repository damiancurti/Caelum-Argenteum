class CA440DirtyLedger : Inventory
{
    int Phase,Started;
    CaelumTarotDirtyRock Rock,Second;
    CaelumTarotRock Item,Outside;
    CaelumTarotExampleSpirit Resident;
    CaelumContaminationTile Shared;
    double CapturedContamination;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440Probe : StaticEventHandler
{
    bool Entered,Reloaded;
    void Check(bool okay,String label){Console.Printf("CA440DIRTY %s %s",okay?"PASS":"FAIL",label);}
    override void WorldTick()
    {
        if(level.time<105)return;
        let user=CaelumPlayer(players[0].mo),other=CaelumPlayer(players[1].mo);
        if(!CaelumWorldClockTicker.Ready(user) || !CaelumWorldClockTicker.Ready(other))return;
        let ledger=CA440DirtyLedger(user.FindInventory('CA440DirtyLedger'));
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
            CaelumTarotService.Select(user,17);CaelumTarotService.Select(user,19);
            CaelumTarotSequence.ApplyCard(user,record,17,6000);CaelumTarotSequence.ApplyCard(user,record,19,6000);
            ledger=CA440DirtyLedger(user.GiveInventoryType('CA440DirtyLedger'));
            ledger.Rock=CaelumTarotDirtyRock(Actor.Spawn('CaelumTarotDirtyRock',(96,0,0),NO_REPLACE));
            ledger.Second=CaelumTarotDirtyRock(Actor.Spawn('CaelumTarotDirtyRock',(96,64,0),NO_REPLACE));
            ledger.Item=CaelumTarotRock(Actor.Spawn('CaelumTarotRock',(0,64,0),NO_REPLACE));
            ledger.Resident=CaelumTarotExampleSpirit(Actor.Spawn('CaelumTarotExampleSpirit',(32,32,0),NO_REPLACE));
            ledger.Outside=CaelumTarotRock(Actor.Spawn('CaelumTarotRock',(1050,0,0),NO_REPLACE));
            ledger.Phase=1;ledger.Started=level.time;return;
        }
        if(!Reloaded && ledger.Phase==1 && level.time-ledger.Started>70)
        {
            Check(ledger.Rock.FieldRevision==1 && ledger.Rock.FieldActive,"native lifecycle starts revisioned pollution field");
            Check(ledger.Rock.Tiles.Size()>0 && ledger.Rock.Sheet!=null,"local geometry supplies exposed surface tiles");
            double reference=CaelumContaminationEnvironment.ReferenceAt(user);
            Check(reference==CaelumMajorArcanaData.ROCK_FIXED_REFERENCE,"nearby player samples declared environmental source");
            Check(CaelumContaminationRules.Ambient(reference,-40,0,80,true)==100,"cold dry weather and rain cannot scale down fixed source");
            Check(CaelumContaminationEnvironment.ReferenceAt(other)==CaelumContaminationEnvironment.BaseReferenceAt(other),"distant peer keeps its own environment");
            Check(CaelumContaminationStorage.Value(ledger.Item)>0,"native object exposure accumulates contamination without a direct pulse");
            let node=CaelumContaminationStorage.Get(ledger.Item).Exposure;
            Check(node!=null && node.HistoryReference==reference,"object history records fixed source for elapsed time");
            Check(CaelumContaminationStorage.Value(ledger.Resident)>0,"native NPC body receives environmental exposure");
            ledger.Rock.RefreshField(true);
            Check(ledger.Rock.Recipients.Find(ledger.Resident)<ledger.Rock.Recipients.Size(),"periodic refresh retains NPC interval until its next native sample");
            for(int i=0;i<ledger.Rock.Tiles.Size();i++)if(ledger.Second.Tiles.Find(ledger.Rock.Tiles[i])<ledger.Second.Tiles.Size())
            {ledger.Shared=ledger.Rock.Tiles[i];break;}
            Check(ledger.Shared!=null && ledger.Shared.RockSources==2,"overlapping fields share one tile with two source references");
            if(ledger.Shared==null){ledger.Phase=-1;return;}
            let copy=ledger.Shared.Copy();
            Check(copy.RockSources==2 && copy.EffectiveReference()==reference && copy.RockTouched,"forecast copy retains local source without reusing pristine climate cohort");
            let cache=new('CaelumContaminationMap');cache.Epoch=0;cache.PristineReady=true;cache.PristineTic=level.time;
            copy.Profile=CaelumWeatherRules.PROFILE_LIMBO;copy.RockSources=0;copy.Reference=15;
            copy.Concentration=75;copy.Stamp=60;cache.Pristine.Push(copy);
            let fresh=copy.Copy();fresh.RockTouched=false;fresh.Concentration=0;fresh.Stamp=0;
            let expected=fresh.Copy();expected.Sync(60,0,new('CaelumWeatherSample'),new('CaelumWeatherSample'));
            cache.Sync(fresh,60);
            Check(Abs(fresh.Concentration-expected.Concentration)<0.00001 && fresh.Concentration!=75,"source-touched cached tile cannot contaminate unrelated pristine surface");
            ledger.Second.Destroy();
            Check(ledger.Shared.RockSources==1 && CaelumContaminationEnvironment.ReferenceAt(user)==reference,"removing one source preserves overlapping emission");
            Check(CaelumSunCargo.Capture(user,ledger.Rock),"Sun captures original contamination source");
            Check(!ledger.Rock.FieldActive && ledger.Rock.Tiles.Size()==0 && ledger.Shared.RockSources==0,"capture closes and removes only its surface field");
            Check(CaelumContaminationEnvironment.ReferenceAt(user)==CaelumContaminationEnvironment.BaseReferenceAt(user),"contained source no longer contaminates surrounding air");
            Check(node.HistoryReference!=reference && node.HistoryAmbient==node.Ambient,"capture reopens object interval under ordinary environment");
            ledger.CapturedContamination=CaelumContaminationStorage.Value(ledger.Item);
            Check(ledger.CapturedContamination>0,"capture does not clean contamination already acquired");
            int fields=ledger.Shared.RockSources;ledger.Rock.UpdateComponents();
            Check(ledger.Shared.RockSources==fields && !ledger.Rock.FieldActive,"contained preparation cannot reactivate field");
            ledger.Phase=2;Console.Printf("CA440DIRTY RESULT capture");
        }
        if(Reloaded && ledger.Phase==2)
        {
            Check(CaelumSunCargo.View(user).Body==ledger.Rock && ledger.Rock.Contained,"common save retains original contained source");
            Check(!ledger.Rock.FieldActive && ledger.Shared.RockSources==0,"recovery does not reconstruct a contained pollution field");
            Check(CaelumContaminationStorage.Value(ledger.Item)>=ledger.CapturedContamination,"recovery preserves existing contamination");
            CaelumSunCargo.View(user).Released((96,0,0));
            Check(ledger.Rock.FieldActive && ledger.Rock.Tiles.Size()>0,"release reopens field around actual original body");
            ledger.Rock.RefreshField(true);ledger.Rock.RefreshField(true);
            bool single=true;for(int i=0;i<ledger.Rock.Tiles.Size();i++)if(ledger.Rock.Tiles[i].RockSources!=1)single=false;
            Check(single,"repeated refresh does not accumulate source counts");
            ledger.Rock.SetOrigin((960,0,0),false);ledger.Rock.UpdateComponents();
            Check(ledger.Shared.RockSources==0,"moving source closes old surface exposure");
            Check(CaelumContaminationEnvironment.ReferenceAt(user)==CaelumContaminationEnvironment.BaseReferenceAt(user),"old location does not retain current environmental source");
            Check(!ledger.Rock.Affects(ledger.Outside),"native perimeter wall blocks pollution within four meters");
            other.SetOrigin((900,0,0),false);
            Check(ledger.Rock.Affects(other),"same-side nearby receiver remains exposed");
            ledger.Phase=3;ledger.Started=level.time;
        }
        if(Reloaded && ledger.Phase==3 && level.time-ledger.Started>70)
        {
            let tile=ledger.Rock.Tiles.Size()>0?ledger.Rock.Tiles[0]:null;
            Check(tile!=null && tile.Concentration>0,"real world time contaminates newly exposed surfaces");
            ledger.Rock.Destroy();
            Check(tile!=null && tile.RockSources==0,"destruction closes the final field without leaving a surface source");
            Check(CaelumContaminationWorld.Get().RockSources.Size()==0,"destroyed sources leave no registry entries");
            ledger.Phase=4;Console.Printf("CA440DIRTY RESULT reload");
        }
    }
}
