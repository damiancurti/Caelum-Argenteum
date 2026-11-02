// Native capture/release and two-peer save recovery, isolated from campaign art.
class CA440SunBlock : Actor
{
    Default {Radius 200;Height 100;+SOLID +NOGRAVITY}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440SunLedger : Inventory
{
    int Phase,Started;
    CaelumTarotRock Rock,Second;
    CA440SunBlock Blocker;
    double RawBefore;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440Probe : StaticEventHandler
{
    bool Entered,Reloaded;
    void Check(bool okay,String label){Console.Printf("CA440SUN %s %s",okay?"PASS":"FAIL",label);}
    override void WorldTick()
    {
        if(level.time<105)return;
        let user=CaelumPlayer(players[0].mo),other=CaelumPlayer(players[1].mo);
        if(!CaelumWorldClockTicker.Ready(user) || !CaelumWorldClockTicker.Ready(other))return;
        let ledger=CA440SunLedger(user.FindInventory('CA440SunLedger'));
        if(!Entered){Entered=true;Reloaded=ledger!=null;}
        let record=user.GetPersistentCharacterState(false);
        if(ledger==null)
        {
            user.SetOrigin((0,0,0),false);other.SetOrigin((800,0,0),false);
            for(int card=0;card<78;card++)
            {record.TarotOwned[card]=true;record.TarotSelected[card]=false;record.TarotActive[card]=false;record.TarotRemaining[card]=0;}
            record.TarotOrderCount=0;record.TarotLoadoutRevision=1;record.TarotPowerRevision=2;
            record.TarotCooldownTics=record.TarotEffectTics=0;
            user.ApplyCharacterProfile();user.CurrentAnima=user.DerivedStats.MaximumAnima;
            CaelumInventoryService.GrantMagicBoxFromPalomo(user,false);
            ledger=CA440SunLedger(user.GiveInventoryType('CA440SunLedger'));
            ledger.Rock=CaelumTarotRock(Actor.Spawn('CaelumTarotRock',(96,0,0),NO_REPLACE));
            ledger.Second=CaelumTarotRock(Actor.Spawn('CaelumTarotRock',(96,80,0),NO_REPLACE));
            CaelumTarotSequence.ApplyCard(user,record,19,6000);
            Check(!CaelumSunCargo.Capture(user,ledger.Rock),"Sun alone cannot bypass Star giant requirement");
            CaelumTarotService.Select(user,17);CaelumTarotService.Select(user,19);
            CaelumTarotSequence.ApplyCard(user,record,17,6000);
            user.RefreshCarriedInventorySummary();ledger.RawBefore=user.HUDMagicBoxRawContentWeight;
            double oldRadius=user.Radius,oldHeight=user.Height;
            user.A_SetSize(8,56);
            Check(CaelumSunCargo.Giant(user,ledger.Rock),"small collision cylinder classifies same rock as giant");
            user.A_SetSize(32,96);
            Check(!CaelumSunCargo.Giant(user,ledger.Rock),"large collision cylinder does not classify same rock as giant");
            user.A_SetSize(oldRadius,oldHeight);
            Check(Abs(ledger.Rock.PhysicalMass()-2261.9467106)<0.001,"physical mass uses approved volume and density");
            int slots=user.CountNativeMagicBoxSlots();
            Console.Printf("CA440SUN TRACE valid=%d visible=%d star=%d sun=%d box=%d slot=%d weight=%d interrupted=%d menu=%d",
                CaelumTarotService.ValidUser(user),CaelumMajorTargets.Visible(user,ledger.Rock),CaelumTarotLoadout.Passive(record,17),
                CaelumTarotService.IsActive(record,19),user.MagicBoxOwned,user.HasNativeMagicBoxSlotAvailable(),
                user.CanAddRawWeightToMagicBox(ledger.Rock.PhysicalMass()),CaelumRacialAbilityRules.Interrupted(user),CaelumRacialAbilityRules.MenuBlocked(user));
            Check(CaelumSunCargo.Capture(user,ledger.Rock),"active Sun captures original rock with Star");
            let cargo=CaelumSunCargo.View(user);
            Check(cargo!=null && cargo.Body==ledger.Rock && ledger.Rock.Cargo!=null && ledger.Rock.Cargo.Owner==user,"capture preserves actor and owner identity");
            if(cargo==null || cargo.Body==null){ledger.Phase=-1;return;}
            Check(ledger.Rock.Contained && !ledger.Rock.bSolid && !ledger.Rock.bShootable && ledger.Rock.bInvisible,"contained rock stops physical world interaction");
            Check(CaelumContaminationStorage.IsShielded(ledger.Rock) && !CaelumContaminationObject.Eligible(ledger.Rock),"contained rock cannot resume environmental exposure on load");
            Check(user.CountNativeMagicBoxSlots()==slots+1,"giant occupies exactly one Box slot");
            Check(Abs(user.HUDMagicBoxRawContentWeight-ledger.RawBefore-ledger.Rock.PhysicalMass())<0.001,"raw Box mass includes contained sphere");
            Check(user.HUDMagicBoxReducedContentWeight==0,"Star active removes content weight but keeps Box tare");
            Check(!CaelumSunCargo.Capture(user,ledger.Second),"one-giant limit rejects second rock");
            ledger.Blocker=CA440SunBlock(Actor.Spawn('CA440SunBlock',user.Pos,NO_REPLACE));
            CaelumTarotService.Select(user,17);
            Check(!record.TarotSelected[17] && CaelumSunCargo.View(user).Pending,"Star removal queues giant release without discarding other contents");
            Check(!CaelumTarotJustice.PrepareTravel(),"central map travel waits for blocked rock release");
            ledger.Phase=1;ledger.Started=level.time;return;
        }
        if(!Reloaded && ledger.Phase==1 && level.time-ledger.Started>100)
        {
            Check(CaelumSunCargo.View(user).Body==ledger.Rock && ledger.Rock.Contained,"blocked retries retain original contained body");
            Check(ledger.Blocker.health>0,"safe release never telefrags blocking actor");
            Check(CaelumSunCargo.View(other)==null,"another peer does not acquire cargo");
            ledger.Phase=2;Console.Printf("CA440SUN RESULT capture");
        }
        if(Reloaded && ledger.Phase==2)
        {
            Check(CaelumSunCargo.View(user).Body==ledger.Rock && ledger.Rock.Contained,"common save restores original contained actor reference");
            Check(CaelumSunCargo.View(user).Pending && !record.TarotSelected[17],"recovery preserves pending release and unequipped Star");
            Check(!CaelumTarotJustice.PrepareTravel(),"recovery does not bypass blocked travel");
            ledger.Blocker.Destroy();ledger.Phase=3;ledger.Started=level.time;
        }
        if(Reloaded && ledger.Phase==3 && level.time-ledger.Started>130)
        {
            Check(!CaelumSunCargo.Occupied(user) && !ledger.Rock.Contained,"free space completes original release");
            Check(ledger.Rock.bSolid && ledger.Rock.bShootable && !ledger.Rock.bInvisible,"release restores collision visibility and damage flags");
            Check(user.Distance3D(ledger.Rock)<=CaelumMajorArcanaData.SUN_RELEASE_MU,"released rock is within approved four meters");
            Check(ledger.Rock.Cargo==null && ledger.Rock.health>0,"released body survives without stale ownership");
            Check(CaelumTarotJustice.PrepareTravel(),"resolved cargo allows central travel");
            Check(Abs(user.HUDMagicBoxRawContentWeight-ledger.RawBefore)<0.001,"release removes exact cargo weight");
            CaelumTarotService.Select(user,17);
            CaelumTarotSequence.ApplyCard(user,record,17,6000);
            CaelumTarotSequence.ApplyCard(user,record,19,2);
            Check(CaelumSunCargo.Capture(user,ledger.Rock),"released original can be captured again");
            CaelumTarotSequence.Advance(user,record,2);
            Check(CaelumSunCargo.View(user).Pending,"shared Tarot expiry initiates safe release");
            ledger.Phase=4;ledger.Started=level.time;
        }
        if(Reloaded && ledger.Phase==4 && level.time-ledger.Started>130)
        {
            Check(!ledger.Rock.Contained && !CaelumSunCargo.Occupied(user),"expired Sun releases the same rock without another activation");
            Check(!CaelumContaminationStorage.IsShielded(ledger.Rock) && CaelumContaminationObject.Eligible(ledger.Rock),"released rock returns to physical contamination pipeline");
            CaelumTarotSequence.ApplyCard(user,record,19,6000);
            Check(CaelumSunCargo.Capture(user,ledger.Rock),"orphan test captures original body");
            let cargo=CaelumSunCargo.View(user);if(cargo!=null)cargo.Destroy();
            Check(ledger.Rock.Cargo!=null && ledger.Rock.Cargo.Owner==null && ledger.Rock.Cargo.Pending,"destroyed owner link preserves a world-owned pending release");
            ledger.Phase=5;ledger.Started=level.time;
        }
        if(Reloaded && ledger.Phase==5 && level.time-ledger.Started>130)
        {
            Check(!ledger.Rock.Contained && ledger.Rock.Cargo==null && ledger.Rock.health>0,"orphaned cargo safely releases without losing or cloning the rock");
            ledger.Phase=6;Console.Printf("CA440SUN RESULT reload");
        }
    }
}
