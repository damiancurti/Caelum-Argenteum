class CA440WaterLedger : Inventory
{
    int Phase,Started;
    CaelumWaterContainer Bottle,Boxed,Stored;
    CaelumStashChest Chest;
    CaelumCistern Cistern;
    CaelumConnectedWaterMap Connected;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440Probe : StaticEventHandler
{
    bool Entered,Reloaded;
    void Check(bool okay,String label){Console.Printf("CA440H %s %s",okay?"PASS":"FAIL",label);}
    CaelumWaterContainer Bottle(Actor owner)
    {
        let item=CaelumWaterContainer(Actor.Spawn('CaelumCanteenSmall',(0,0,0),NO_REPLACE));
        item.Amount=1;item.AttachToOwner(owner);item.WaterLiters=1;item.WaterQuality=7;
        item.EnsureWaterQuality();item.WaterTemperatureC=41;item.WaterTemperatureRevision=1;return item;
    }
    override void WorldTick()
    {
        if(level.time<105)return;
        let user=CaelumPlayer(players[0].mo),other=CaelumPlayer(players[1].mo);
        if(!CaelumWorldClockTicker.Ready(user) || !CaelumWorldClockTicker.Ready(other))return;
        let ledger=CA440WaterLedger(user.FindInventory('CA440WaterLedger'));
        if(!Entered){Entered=true;Reloaded=ledger!=null;}
        if(ledger==null)
        {
            ledger=CA440WaterLedger(user.GiveInventoryType('CA440WaterLedger'));
            let record=user.GetPersistentCharacterState(false);
            for(int i=0;i<78;i++){record.TarotOwned[i]=true;record.TarotSelected[i]=false;record.TarotActive[i]=false;record.TarotRemaining[i]=0;}
            record.TarotOrderCount=0;record.TarotLoadoutRevision=1;record.TarotPowerRevision=2;
            record.TarotCooldownTics=record.TarotEffectTics=0;
            user.ApplyCharacterProfile();user.GrantMagicBoxFromPalomo(false);user.CurrentAnima=user.DerivedStats.MaximumAnima;
            user.SetOrigin((0,0,0),false);other.SetOrigin((-60,0,0),false);
            ledger.Chest=CaelumStashChest(Actor.Spawn('CaelumStashChest',(60,0,0),NO_REPLACE));
            ledger.Chest.ChestOpen=false;
            ledger.Bottle=Bottle(user);ledger.Boxed=Bottle(user);ledger.Boxed.InMagicBox=true;ledger.Stored=Bottle(ledger.Chest);
            ledger.Cistern=CaelumCistern(Actor.Spawn('CaelumCistern',(30,60,0),NO_REPLACE));
            ledger.Cistern.SyncWater(user);ledger.Cistern.Reserve.WaterLiters=500;ledger.Cistern.Reserve.WaterQuality=5;
            ledger.Started=level.time;ledger.Phase=1;return;
        }
        if(ledger.Phase==1 && level.time-ledger.Started>2)
        {
            CaelumContaminationStorage.Set(user,80);CaelumContaminationStorage.Set(other,70);
            CaelumContaminationStorage.Set(ledger.Bottle,60);CaelumContaminationStorage.Set(ledger.Boxed,23);
            let record=user.GetPersistentCharacterState(false);
            CaelumTarotService.Select(user,5);CaelumTarotService.Select(user,9);
            double anima=user.CurrentAnima,temperature=ledger.Bottle.WaterTemperatureC;
            Check(CaelumTarotService.Activate(user),"native Tarot service activates Hierophant");
            Check(Abs(user.CurrentAnima-anima+1000)<0.01 && !record.TarotActive[5],"purification pays once and remains instantaneous with Hermit");
            Check(CaelumContaminationStorage.Value(user)==0 && CaelumContaminationStorage.Value(other)==0,"purification clears caster and nearby player");
            Check(ledger.Bottle.WaterQuality==2 && CaelumContaminationStorage.Value(ledger.Bottle)==0,"carried vessel loses biological and chemical flags while retaining salt");
            Check(ledger.Bottle.WaterLiters==1 && ledger.Bottle.WaterTemperatureC==temperature,"purification preserves water quantity and temperature");
            Check(ledger.Boxed.WaterQuality==7 && CaelumContaminationStorage.Value(ledger.Boxed)==23,"Box protects water and exterior contamination");
            Check(ledger.Stored.WaterQuality==7,"closed chest protects the contained vessel");
            Check(ledger.Cistern.Reserve.WaterQuality==0 && ledger.Cistern.Reserve.WaterLiters==500,"whole contained cistern is purified without refilling");
            ledger.Chest.ChestOpen=true;
            CaelumTarotContamination.Pulse(user,(0,0,28),0,1,true);
            Check(ledger.Stored.WaterQuality==2,"open chest exposes its vessel to purification");
            ledger.Bottle.WaterQuality=7;
            double r=(ledger.Bottle.GetCapacityLiters()/1000*3/(4*CaelumWaterThermalData.PI))**(1.0/3.0)*32;
            CaelumTarotContamination.Pulse(user,(128-r/2,0,user.Height/2),0,1,true);
            Check(ledger.Bottle.WaterQuality==7,"a vessel crossing the pulse boundary keeps all water quality flags");
            record.TarotSelected[9]=false;record.TarotSelected[13]=true;record.TarotOrderCount=2;
            record.TarotOrder[0]=13;record.TarotOrder[1]=5;
            let snapshot=new('CaelumTarotGroundAim');snapshot.RangeMultiplier=1;
            CaelumTarotSequence.Apply(user,record,other,snapshot);
            Check(CaelumContaminationStorage.Value(user)==0 && CaelumContaminationStorage.Value(other)==0,"ordered Death then Hierophant ends with clean bodies");
            record.TarotOrder[0]=5;record.TarotOrder[1]=13;
            CaelumTarotSequence.Apply(user,record,other,snapshot);
            Check(CaelumContaminationStorage.Value(user)==100 && CaelumContaminationStorage.Value(other)==100 && ledger.Bottle.WaterQuality==2,"reversed order contaminates bodies while Death preserves water quality");
            CaelumContaminationStorage.Set(user,0);CaelumContaminationStorage.Set(other,0);
            ledger.Phase=10;Level.ChangeLevel("CTW440",0,CHANGELEVEL_NOINTERMISSION);return;
        }
        if(ledger.Phase==10 && level.MapName=="CTW440")
        {
            user.SetOrigin((0,0,0),false);other.SetOrigin((16,16,0),false);
            Check(CaelumWaterQuality.Volume(level.Sectors[1],level.Sectors[0])==7,"legacy static water starts with authored quality");
            CaelumTarotContamination.Pulse(user,(0,0,28),0,1,true);
            Check(CaelumWaterQuality.Volume(level.Sectors[1],level.Sectors[0])==2,"whole small map volume is purified while retaining salt");
            let registry=CaelumTarotWaterMap.Get();int count=registry.GeometrySectorCount;
            Check(registry.Revision==1 && count==level.Sectors.Size(),"water geometry is indexed once into a revisioned map controller");
            user.SetOrigin((1024,0,0),false);
            CaelumTarotContamination.Pulse(user,(1024,0,28),0,1,true);
            Check(CaelumWaterQuality.Volume(level.Sectors[3],level.Sectors[2])==5,"oversized pool retains its full quality");
            user.SetOrigin((1568,0,0),false);
            CaelumTarotContamination.Pulse(user,(1568,0,28),0,1,true);
            Check(CaelumWaterQuality.Volume(level.Sectors[6],level.Sectors[4])==5 && CaelumWaterQuality.Volume(level.Sectors[6],level.Sectors[5])==5,"shared model extending outside the pulse is not partially purified");
            Check(registry.GeometrySectorCount==count && registry.GeometryReady,"later pulses reuse the geometry index");
            user.SetOrigin((0,0,0),false);
            ledger.Connected=CaelumConnectedWaterMap(Actor.Spawn('CaelumConnectedWaterMap',(0,0,0),NO_REPLACE));
            ledger.Connected.Revision=CaelumConnectedWaterData.REVISION;
            ledger.Connected.Models[0]=level.Sectors[1];ledger.Connected.Models[1]=level.Sectors[3];
            ledger.Connected.Water=new('CaelumConnectedWaterState');ledger.Connected.Water.Initialize();
            ledger.Connected.Water.QualityA=7;ledger.Connected.Water.QualityB=5;
            ledger.Connected.ClockReady=true;ledger.Connected.Stamp=CaelumContaminationSurfaces.Now(user);
            CaelumWorldClockTicker(StaticEventHandler.Find('CaelumWorldClockTicker')).WaterMap=ledger.Connected;
            CaelumTarotContamination.Pulse(user,(0,0,28),0,1,true);
            Check(ledger.Connected.Water.QualityA==2 && ledger.Connected.Water.QualityB==5,"connected reservoir uses its mutable state and leaves the distant basin unchanged");
            ledger.Connected.Water.QualityA|=CaelumWaterQuality.BIOLOGICAL;
            Check(CaelumWaterQuality.Volume(level.Sectors[1],level.Sectors[0])==3,"later connected-water contamination is not masked by permanent immunity");
            CaelumWorldClockTicker(StaticEventHandler.Find('CaelumWorldClockTicker')).WaterMap=null;
            ledger.Phase=3;user.PersistCharacterState();Console.Printf("CA440H RESULT capture");return;
        }
        if(ledger.Phase==3 && Reloaded)
        {
            Check(CaelumWaterQuality.Volume(level.Sectors[1],level.Sectors[0])==2,"recovery restores purified static map water without changing original metadata");
            Check(CaelumWaterQuality.Metadata(level.Sectors[1])==7,"authored map metadata remains reversible");
            Check(CaelumWaterQuality.Volume(level.Sectors[3],level.Sectors[2])==5 && CaelumWaterQuality.Volume(level.Sectors[6],level.Sectors[4])==5,"recovery keeps excluded larger and shared volumes contaminated");
            Check(ledger.Connected!=null && ledger.Connected.Water.QualityA==3 && ledger.Connected.Water.QualityB==5,"mutable reservoir state survives without replaying purification");
            Check(ledger.Boxed.WaterQuality==7 && ledger.Boxed.InMagicBox,"shielded vessel remains contaminated after recovery");
            Check(user.GetPersistentCharacterState(false).TarotCooldownTics>0 && !user.GetPersistentCharacterState(false).TarotActive[5],"recovery keeps payment and no repeating pulse");
            ledger.Phase=4;Console.Printf("CA440H RESULT reload");
        }
    }
}
