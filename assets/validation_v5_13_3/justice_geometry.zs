class CA440JusticeLedger : Inventory
{
    int Phase,Visited;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440Probe : StaticEventHandler
{
    bool Entered,Reloaded;
    void Check(bool okay,String label){Console.Printf("CA440J %s %s",okay?"PASS":"FAIL",label);}
    String MapFor(int index)
    {
        switch(index){case 0:return "MAP01";case 1:return "MAP02";case 2:return "CABAIRES";
        case 3:return "CAH000";case 4:return "CAR00";case 5:return "CARING";
        case 6:return "CASEWER";case 7:return "TCOAST";case 8:return "JTCITY";}
        return "";
    }
    override void WorldTick()
    {
        if(level.time<4)return;
        let user=CaelumPlayer(players[0].mo),other=CaelumPlayer(players[1].mo);
        if(!CaelumWorldClockTicker.Ready(user) || !CaelumWorldClockTicker.Ready(other))return;
        let ledger=CA440JusticeLedger(user.FindInventory('CA440JusticeLedger'));
        if(!Entered){Entered=true;Reloaded=ledger!=null;}
        if(ledger==null)
        {
            if(level.time<105)return;
            ledger=CA440JusticeLedger(user.GiveInventoryType('CA440JusticeLedger'));
            Check(CaelumJusticeGeometry.Get()==null,"old geometry has no accidental Justice arena");
            ledger.Phase=1;Level.ChangeLevel(MapFor(0),0,CHANGELEVEL_NOINTERMISSION);return;
        }
        if(ledger.Phase>=1 && ledger.Phase<=9)
        {
            int index=ledger.Phase-1;if(level.MapName!=MapFor(index))return;
            String original=index==8?"MAP03":level.MapName;
            int sectorIndex=CaelumJusticeGeometry.SectorIndex(original);
            Sector sector;if(sectorIndex>=0 && sectorIndex<level.Sectors.Size())sector=level.Sectors[sectorIndex];
            Check(sector!=null && sector.GetUDMFInt("user_ca_tarot_justice")!=0,String.Format("%s appended sector exists",original));
            if(sector==null){ledger.Phase=99;return;}
            if(index!=8)Check(CaelumJusticeGeometry.Get()==sector,String.Format("%s direct metadata lookup",original));
            vector3 center=CaelumJusticeGeometry.Center(original);
            user.SetOrigin(center+(-64,0,0),false);other.SetOrigin(center+(64,0,0),false);
            Check(user.TestMobjLocation() && other.TestMobjLocation() && user.CurSector==sector && other.CurSector==sector,
                String.Format("%s two native player bodies fit",original));
            Check(sector.lines.Size()==4 && Abs(sector.floorplane.ZatPoint(center.XY))<0.01
                && Abs(sector.ceilingplane.ZatPoint(center.XY)-160)<0.01,String.Format("%s approved arena envelope",original));
            let shape=GetDefaultByType('CaelumZupayColossus');
            let probe=CaelumSummoningProbe(Actor.Spawn('CaelumSummoningProbe',center,NO_REPLACE));
            probe.A_SetSize(shape.Radius,shape.Height);
            bool fits=true;double reach=CaelumJusticeGeometry.WIDTH/2-shape.Radius-1;
            for(int x=-1;x<=1;x+=2)for(int y=-1;y<=1;y+=2)
            {
                probe.SetOrigin(center+(x*reach,y*reach,0),false);probe.FindFloorCeiling();
                fits=fits && probe.TestMobjLocation() && probe.CurSector==sector;
            }
            probe.Destroy();Check(fits,String.Format("%s large-creature corners stay inside walls",original));
            ledger.Visited|=1<<index;ledger.Phase++;
            if(ledger.Phase<=9){Level.ChangeLevel(MapFor(ledger.Phase-1),0,CHANGELEVEL_NOINTERMISSION);return;}
            user.PersistCharacterState();Console.Printf("CA440J RESULT capture");return;
        }
        if(ledger.Phase==10 && Reloaded)
        {
            Check(ledger.Visited==511,"common save preserves all nine native geometry checks");
            let sector=level.Sectors[CaelumJusticeGeometry.SectorIndex("MAP03")];
            Check(user.CurSector==sector && other.CurSector==sector && user.TestMobjLocation() && other.TestMobjLocation(),
                "common recovery preserves both bodies in the appended arena");
            Check(sector.GetUDMFInt("user_ca_tarot_justice")!=0,"new geometry metadata survives recovery");
            ledger.Phase=11;Console.Printf("CA440J RESULT reload");
        }
    }
}
