class CA440ExampleLedger : Inventory
{
    int Phase,Started;
    bool Legacy;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440Probe : StaticEventHandler
{
    bool Entered,Reloaded;
    void Check(bool ok,String label){Console.Printf("CA440X %s %s",ok?"PASS":"FAIL",label);}
    override void WorldTick()
    {
        if(level.time<105)return;
        let user=CaelumPlayer(players[0].mo);let other=CaelumPlayer(players[1].mo);
        if(!CaelumWorldClockTicker.Ready(user) || !CaelumWorldClockTicker.Ready(other))return;
        let ledger=CA440ExampleLedger(user.FindInventory('CA440ExampleLedger'));
        if(!Entered){Entered=true;Reloaded=ledger!=null;}
        if(ledger==null)
        {
            ledger=CA440ExampleLedger(user.GiveInventoryType('CA440ExampleLedger'));
            ledger.Phase=1;user.PersistCharacterState();other.PersistCharacterState();
            Level.ChangeLevel("MAP01",0,CHANGELEVEL_NOINTERMISSION);return;
        }
        if(ledger.Phase==1)
        {
            Check(level.MapName=="MAP01","real mansion loaded with all previous content");
            Check(CaelumJusticeGeometry.Get()!=null,"separate Justice arena still resolves its original sector");
            Check(CaelumCartographyCatalogueData.MatchesMansionGeometry(level.GetChecksum()),"authored cartography accepts the loaded mansion revision");
            ledger.Legacy=level.Sectors.Size()==CA440ExampleLayout.ORIGINAL_SECTORS;
            if(ledger.Legacy)
            {
                Check(level.Sectors.Size()==7750,"compatibility retains exact pre-example sector count");
                ledger.Phase=5;user.PersistCharacterState();Console.Printf("CA440X RESULT capture");return;
            }
            Check(level.Sectors.Size()==CA440ExampleLayout.ORIGINAL_SECTORS+10,"annex appends ten sectors without renumbering the mansion");
            vector3 origin=CA440ExampleLayout.Origin();
            double centers[4];centers[0]=384;centers[1]=960;centers[2]=1344;centers[3]=1920;
            for(int i=0;i<4;i++)
            {
                user.SetOrigin(origin+(centers[i],400,0),false);user.FindFloorCeiling();
                Check(user.TestMobjLocation() && user.CurSector==level.Sectors[CA440ExampleLayout.FIRST_ROOM+i],String.Format("room %d has native walkable floor and correct identity",i+1));
            }
            let shape=GetDefaultByType('CaelumZupayColossus');
            let probe=CaelumSummoningProbe(Actor.Spawn('CaelumSummoningProbe',origin+(384,400,0),NO_REPLACE));
            probe.A_SetSize(shape.Radius,shape.Height);probe.FindFloorCeiling();
            Check(probe.TestMobjLocation(),"display room admits the approved automaton collision envelope");probe.Destroy();
            user.SetOrigin(origin+(960,400,0),false);user.Angle=180;user.Pitch=0;
            FLineTraceData hit;vector3 eye=CaelumTelekinesisRules.Eye(user);
            bool wall=user.LineTrace(180,256,0,TRF_ABSPOSITION|TRF_THRUACTORS,eye.Z,eye.X,eye.Y,hit);
            Check(wall && hit.HitType==FLineTraceData.TRACE_HitWall,"full partition prevents walking around the secret doorway");
            user.SetOrigin(origin+(960,136,0),false);user.FindFloorCeiling();
            Check(user.TestMobjLocation() && Abs(user.ceilingz-120)<0.01,"64-wide authored doorway fits the real player with its lintel");
            user.SetOrigin(origin+(1856,400,0),false);other.SetOrigin(origin+(1984,400,0),false);
            ledger.Phase=2;ledger.Started=level.time;return;
        }
        if(ledger.Phase==2 && level.time-ledger.Started>3)
        {
            Check(user.waterlevel==0 && other.waterlevel==0,"dry Wheel room has no water above its floor");
            let model=level.Sectors[CA440ExampleLayout.WATER_CONTROL];
            model.MoveCeiling(64,model.ceilingplane.PointToDist((0,0),64),-1,1,false);
            level.Sectors[CA440ExampleLayout.WHEEL_ROOM].SetLightLevel(32);
            ledger.Phase=3;ledger.Started=level.time;return;
        }
        if(ledger.Phase==3 && level.time-ledger.Started>3)
        {
            Check(user.waterlevel>0 && other.waterlevel>0,"raising the native swimmable floor submerges both players");
            Check(Abs(level.Sectors[CA440ExampleLayout.WATER_CONTROL].CenterCeiling()-64)<0.01,"wet state reaches the approved two-metre depth");
            Check(level.Sectors[CA440ExampleLayout.WHEEL_ROOM].lightlevel==32,"native Wheel sector supports the approved dark state");
            ledger.Phase=4;user.PersistCharacterState();other.PersistCharacterState();Console.Printf("CA440X RESULT capture");return;
        }
        if(Reloaded && (ledger.Phase==4 || ledger.Phase==5))
        {
            Check(CaelumCartographyCatalogueData.MatchesMansionGeometry(level.GetChecksum()),"common recovery retains compatible authored cartography");
            if(ledger.Legacy)Check(level.Sectors.Size()==CA440ExampleLayout.ORIGINAL_SECTORS,"pre-example common save stays on its original geometry");
            else
            {
                Check(user.CurSector==level.Sectors[CA440ExampleLayout.WHEEL_ROOM] && other.CurSector==user.CurSector,"common recovery retains both bodies in the annex");
                Check(Abs(level.Sectors[CA440ExampleLayout.WATER_CONTROL].CenterCeiling()-64)<0.01 && user.CurSector.lightlevel==32,"native wet geometry and lighting persist without reset");
            }
            Check(CaelumJusticeGeometry.Get()!=null,"recovery preserves the existing Justice arena");
            ledger.Phase=6;Console.Printf("CA440X RESULT reload");
        }
    }
}
