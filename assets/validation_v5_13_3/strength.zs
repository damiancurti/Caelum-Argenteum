class CA440LiftProp : CaelumMovableProp
{
    Default {Health 100;Radius 8;Height 16;Mass 20;}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440LiftBlock : Actor
{
    Default {Radius 16;Height 96;+SOLID}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440StrengthLedger : Inventory
{
    int Phase;
    CA440LiftProp Prop;
    double BaseLoad,Strength,Damage,Capacity;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440Probe : StaticEventHandler
{
    bool Entered,Reloaded;
    void Check(bool ok,String label){Console.Printf("CA440S %s %s",ok?"PASS":"FAIL",label);}
    void Aim(CaelumPlayer user,Actor body)
    {
        vector3 delta=body.Pos+(0,0,body.Height/2)-CaelumTelekinesisRules.Eye(user);
        user.Angle=VectorAngle(delta.X,delta.Y);user.Pitch=-VectorAngle(delta.XY.Length(),delta.Z);
    }
    override void WorldTick()
    {
        if(level.time<105)return;
        let user=CaelumPlayer(players[0].mo);let other=CaelumPlayer(players[1].mo);
        if(!CaelumWorldClockTicker.Ready(user) || !CaelumWorldClockTicker.Ready(other))return;
        let ledger=CA440StrengthLedger(user.FindInventory('CA440StrengthLedger'));
        if(!Entered){Entered=true;Reloaded=ledger!=null;}
        let record=user.GetPersistentCharacterState(false);
        if(ledger==null)
        {
            ledger=CA440StrengthLedger(user.GiveInventoryType('CA440StrengthLedger'));
            for(int card=0;card<78;card++)
            {record.TarotOwned[card]=true;record.TarotSelected[card]=false;record.TarotActive[card]=false;record.TarotRemaining[card]=0;}
            record.TarotOrderCount=0;record.TarotLoadoutRevision=1;record.TarotPowerRevision=2;
            record.TarotCooldownTics=record.TarotEffectTics=0;
            user.ApplyCharacterProfile();user.RefreshCarriedInventorySummary();user.CurrentAnima=user.DerivedStats.MaximumAnima;
            ledger.Strength=user.Attributes.Strength;ledger.Damage=user.DerivedStats.MeleeDamagePercent;
            ledger.Capacity=user.DerivedStats.CarryCapacity;ledger.BaseLoad=user.DerivedStats.CarriedWeight;
            user.SetOrigin((-256,0,0),false);other.SetOrigin((-600,-600,0),false);
            ledger.Prop=CA440LiftProp(Actor.Spawn('CA440LiftProp',(-208,0,0),NO_REPLACE));ledger.Prop.args[0]=1;
            Aim(user,ledger.Prop);
            Check(!CaelumTarotObjectMovement.Use(user,ledger.Prop),"unequipped Strength cannot lift scenery");
            CaelumTarotService.Select(user,11);
            Check(user.TryPushMovablePropInFront(),"native aimed Use lifts an eligible object");
            let held=CaelumTarotObjectMovement.View(user);
            Check(held!=null && held.Body==ledger.Prop && ledger.Prop.TarotLift==held && ledger.Prop.bNoGravity,"lift preserves exact object with reciprocal ownership");
            Check(Abs(user.DerivedStats.CarriedWeight-ledger.BaseLoad-20)<0.001,"lifted mass counts once toward real load");
            user.RefreshCarriedInventorySummary();
            Check(Abs(user.DerivedStats.CarriedWeight-ledger.BaseLoad-20)<0.001,"refresh does not accumulate lifted weight");
            Check(!CaelumTelekinesisRules.Eligible(other,ledger.Prop),"a held object cannot be captured by telekinesis");
            user.SetOrigin(user.Pos+(16,0,0),false);
            Check(held.Follow(user) && Abs(ledger.Prop.Pos.X-user.Pos.X-held.Distance)<0.01,"object follows its holder using native collision checks");
            Check(CaelumTarotObjectMovement.Use(user,null) && held.Body==null && !ledger.Prop.bNoGravity,"next Use releases and restores gravity");
            Check(Abs(user.DerivedStats.CarriedWeight-ledger.BaseLoad)<0.001,"release removes only the lifted mass");
            ledger.Prop.SetOrigin(user.Pos+(48,0,0),false);ledger.Prop.Mass=int(Ceil(ledger.Capacity*2));
            Check(CaelumTarotObjectMovement.Use(user,ledger.Prop) && held.Body==null,"normal lifting limit includes the existing load");
            double anima=user.CurrentAnima;
            Check(CaelumTarotService.Activate(user) && record.TarotRemaining[11]==2100,"Strength opens its existing sixty-second window");
            Check(Abs(user.CurrentAnima-(anima-1000))<0.01,"Strength charges the shared sequence exactly once");
            Check(user.Attributes.Strength==ledger.Strength && user.DerivedStats.MeleeDamagePercent==ledger.Damage
                && user.DerivedStats.CarryCapacity==ledger.Capacity,"active Strength does not change combat or ordinary inventory capacity");
            Check(Abs(CaelumTarotObjectMovement.Push(user)-user.DerivedStats.CalculateType1Percent(ledger.Strength*10)/100*user.DerivedStats.BaseMassMultiplier)<0.00001,"object push evaluates the native curve at Strength times ten");
            Check(CaelumTarotObjectMovement.Use(user,ledger.Prop) && held.Body==ledger.Prop,"active Strength permits heavier scenery within its derived limit");
            CaelumTarotService.Select(user,11);
            Check(held.Body==null && !ledger.Prop.bNoGravity,"unequipping removes lifting permission without waiting for expiry");
            CaelumTarotService.Select(user,11);ledger.Prop.Mass=20;ledger.Prop.SetOrigin(user.Pos+(48,0,0),false);
            CaelumTarotObjectMovement.Use(user,ledger.Prop);
            let obstacle=Actor.Spawn('CA440LiftBlock',ledger.Prop.Pos+(48,0,0),NO_REPLACE);
            user.SetOrigin(user.Pos+(80,0,0),false);
            Check(!held.Follow(user) && ledger.Prop.Pos.X<obstacle.Pos.X,"held object cannot jump through a solid obstacle");
            held.Release();obstacle.Destroy();
            ledger.Prop.SetOrigin(user.Pos+(48,0,0),false);ledger.Prop.args[0]=0;
            Check(!CaelumTarotObjectMovement.Use(user,ledger.Prop),"fixed or unconfigured objects remain excluded");
            ledger.Prop.args[0]=1;ledger.Prop.bNoGravity=true;
            CaelumTarotObjectMovement.Use(user,ledger.Prop);held.Release();
            Check(ledger.Prop.bNoGravity,"release preserves pre-existing gravity flags");ledger.Prop.bNoGravity=false;
            CaelumContaminationStorage.Set(ledger.Prop,75);
            CaelumTarotObjectMovement.Use(user,ledger.Prop);
            Check(CaelumContaminationStorage.Value(ledger.Prop)==75,"lifting does not clean the object");
            ledger.Phase=1;user.PersistCharacterState();Console.Printf("CA440S RESULT capture");return;
        }
        if(ledger.Phase==1 && Reloaded)
        {
            let held=CaelumTarotObjectMovement.View(user);
            Check(held!=null && held.Body==ledger.Prop && ledger.Prop.TarotLift==held && held.Holding,"common recovery preserves exact held object and reciprocal link");
            Check(Abs(user.DerivedStats.CarriedWeight-ledger.BaseLoad-20)<0.001,"recovery charges carried mass only once");
            Check(CaelumContaminationStorage.Value(ledger.Prop)>0,"recovery preserves object contamination");
            CaelumTarotService.Advance(user,record.TarotRemaining[11]);
            CaelumTarotObjectMovement.Guard(user);
            Check(held.Body==ledger.Prop,"normal-capacity object stays held after active window ends");
            ledger.Prop.Mass=int(Ceil(ledger.Capacity*2));user.RefreshCarriedInventorySummary();
            CaelumTarotObjectMovement.Guard(user);
            Check(held.Body==null && !held.Holding && !ledger.Prop.bNoGravity,"insufficient capacity releases the existing body safely");
            ledger.Phase=2;Console.Printf("CA440S RESULT reload");
        }
    }
}
