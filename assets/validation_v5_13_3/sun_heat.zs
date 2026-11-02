class CA440HeatLedger : Inventory
{
    int Phase,Started;
    CaelumTarotHeatRock Rock;
    CaelumTarotRock Neutral;
    CaelumThermalFireSource Standard;
    CaelumTarotRockHeat OriginalHeat;
    CaelumHazardRockVisual OriginalVisual;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440Probe : StaticEventHandler
{
    bool Entered,Reloaded;
    void Check(bool okay,String label){Console.Printf("CA440HEAT %s %s",okay?"PASS":"FAIL",label);}
    int Registered(CaelumThermalFireSource heat)
    {
        let world=CaelumThermalWorld.Get();int found=0;
        for(int i=0;i<world.FireSources.Size();i++)if(world.FireSources[i]==heat)found++;
        return found;
    }
    override void WorldTick()
    {
        if(level.time<105)return;
        let user=CaelumPlayer(players[0].mo),other=CaelumPlayer(players[1].mo);
        if(!CaelumWorldClockTicker.Ready(user) || !CaelumWorldClockTicker.Ready(other))return;
        let ledger=CA440HeatLedger(user.FindInventory('CA440HeatLedger'));
        if(!Entered){Entered=true;Reloaded=ledger!=null;}
        let record=user.GetPersistentCharacterState(false);
        if(ledger==null)
        {
            user.SetOrigin((0,0,0),false);other.SetOrigin((800,0,0),false);
            user.Angle=0;user.Pitch=0;
            for(int card=0;card<78;card++)
            {record.TarotOwned[card]=true;record.TarotSelected[card]=false;record.TarotActive[card]=false;record.TarotRemaining[card]=0;}
            record.TarotOrderCount=0;record.TarotLoadoutRevision=1;record.TarotPowerRevision=2;
            record.TarotCooldownTics=record.TarotEffectTics=0;
            user.ApplyCharacterProfile();user.CurrentAnima=user.DerivedStats.MaximumAnima;
            CaelumInventoryService.GrantMagicBoxFromPalomo(user,false);
            CaelumTarotService.Select(user,17);CaelumTarotService.Select(user,19);
            CaelumTarotSequence.ApplyCard(user,record,17,6000);
            CaelumTarotSequence.ApplyCard(user,record,19,6000);
            ledger=CA440HeatLedger(user.GiveInventoryType('CA440HeatLedger'));
            ledger.Rock=CaelumTarotHeatRock(Actor.Spawn('CaelumTarotHeatRock',(96,0,0),NO_REPLACE));
            ledger.Neutral=CaelumTarotRock(Actor.Spawn('CaelumTarotRock',(96,96,0),NO_REPLACE));
            ledger.Phase=1;ledger.Started=level.time;return;
        }
        if(!Reloaded && ledger.Phase==1 && level.time-ledger.Started>35)
        {
            Check(ledger.Rock.Heat!=null && ledger.Rock.Visual!=null,"native lifecycle initializes components before sampling");
            if(ledger.Rock.Heat==null || ledger.Rock.Visual==null){ledger.Phase=-1;return;}
            ledger.OriginalHeat=ledger.Rock.Heat;ledger.OriginalVisual=ledger.Rock.Visual;
            Check(ledger.Rock.Heat!=null && Registered(ledger.Rock.Heat)==1,"hot rock registers one typed thermal source");
            Check(ledger.Neutral.Heat==null && ledger.Neutral.Visual!=null,"ordinary rock gains visual without invented heat");
            Check(ledger.Rock.Heat.Watts()==8000,"source emits exactly approved eight kilowatts");
            Check(Abs(ledger.Rock.Heat.EmissionRadiusMeters()-0.6)<0.00001,"spherical source radius is six tenths meter");
            Check((ledger.Rock.Heat.EmissionCenter()-(ledger.Rock.Pos+(0,0,19.2))).Length()<0.001,"heat originates at physical sphere center");
            Check(Abs(ledger.Rock.PhysicalMass()-2261.9467106)<0.001,"physical mass and volume unchanged");
            ledger.Standard=CaelumThermalFireSource(Actor.Spawn('CaelumThermalFireSource',(-96,0,0),NO_REPLACE));
            ledger.Standard.args[0]=1;ledger.Standard.args[1]=16;ledger.Standard.args[2]=32;
            Check(ledger.Standard.EmissionCenter()==(-96,0,16) && ledger.Standard.EmissionRadiusMeters()==0.5,"ordinary fire keeps its prior geometry");
            Check(ledger.Standard.Watts()==CaelumThermalData.FireWatts(1),"ordinary fire keeps prior power");
            ledger.Standard.Destroy();
            let thermal=CaelumThermalBody.Get(user,true);
            Check(CaelumThermalFire.Absorbed(user,thermal,ledger.Rock.Heat)>0,"native body receives exposed radiant heat");
            Check(ledger.Rock.Visual.master==ledger.Rock && !ledger.Rock.Visual.bInvisible,"owned boulder model follows actual rock");
            Check(Abs(ledger.Rock.Visual.Scale.X-0.4)<0.00001,"owned model scales to approved diameter");
            ledger.Rock.SetOrigin((128,32,0),false);ledger.Rock.UpdateComponents();
            Check(ledger.Rock.Heat.EmissionCenter()==(128,32,19.2),"moving body moves heat center without creating another source");
            Check(CaelumSunCargo.Capture(user,ledger.Rock),"Sun and Star capture hot original");
            Check(ledger.Rock.Heat.Watts()==0 && CaelumThermalFire.Absorbed(user,thermal,ledger.Rock.Heat)==0,"containment immediately blocks thermal emission");
            Check(ledger.Rock.Visual.bInvisible,"contained visual disappears in same operation");
            Check(Registered(ledger.Rock.Heat)==1,"containment retains one dormant source for persistence");
            ledger.Phase=2;Console.Printf("CA440HEAT RESULT capture");
        }
        if(Reloaded && ledger.Phase==2)
        {
            Check(CaelumSunCargo.View(user).Body==ledger.Rock && ledger.Rock.Contained,"common save retains contained original");
            Check(ledger.Rock.Heat==ledger.OriginalHeat && ledger.Rock.Visual==ledger.OriginalVisual,"recovery retains exact component identities");
            Check(Registered(ledger.Rock.Heat)==1 && ledger.Rock.Heat.Watts()==0,"recovery neither duplicates nor reignites source");
            Check(ledger.Rock.Visual.bInvisible,"recovered contained model remains hidden");
            CaelumSunCargo.View(user).Released((96,0,0));
            Check(ledger.Rock.Heat.Watts()==8000 && !ledger.Rock.Visual.bInvisible,"release restores original heat and visible model");
            ledger.Phase=3;ledger.Started=level.time;
        }
        if(Reloaded && ledger.Phase==3 && level.time-ledger.Started>35)
        {
            Check(CaelumThermalFire.Absorbed(user,CaelumThermalBody.Get(user,true),ledger.Rock.Heat)>0,"released source reaches real thermal adapter");
            ledger.Rock.UpdateComponents();ledger.Rock.UpdateComponents();
            Check(Registered(ledger.Rock.Heat)==1,"idempotent preparation cannot multiply emissions");
            ledger.Rock.Destroy();
            Check(Registered(ledger.OriginalHeat)==0,"destroyed body unregisters its heat source");
            Check(ledger.OriginalVisual==null || ledger.OriginalVisual.bDestroyed,"destroyed body leaves no orphan visual");
            ledger.Phase=4;Console.Printf("CA440HEAT RESULT reload");
        }
    }
}
