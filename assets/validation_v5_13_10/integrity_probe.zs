class CA614SavedProbe : Actor
{
    int ExpectedReady,ExpectedKind,ExpectedTier;
    CaelumEquipmentItem Item;
    Default {+NOINTERACTION +NOGRAVITY}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA614MatchProbe : StaticEventHandler
{
    CA614SavedProbe Saved;
    int Stage;
    void Check(bool ok,String label){Console.Printf("CA614 %s %s",ok?"PASS":"FAIL",label);}
    override void WorldTick()
    {
        let m=CaelumStandaloneMatch.View();if(m==null || !m.Started)return;
        if(m.Hunt!=null)m.Hunt.Hunter.bDormant=true;
        let a=CaelumPlayer(players[0].mo);
        if(level.time==110)
        {
            Saved=CA614SavedProbe(Actor.Spawn('CA614SavedProbe'));
            Saved.Item=a.FindNativeEquipmentItemById(a.ActiveWeaponItemId);
            Saved.ExpectedTier=Saved.Item.Tier;CaelumLabyrinthPowerups.Improve(a,Saved.Item,true);
            // Incompatible actor retains the shared point; no inventory removed.
            Array<CaelumEquipmentItem> equipped;
            for(Inventory cur=a.Inv;cur!=null;cur=cur.Inv)
            {let item=CaelumEquipmentItem(cur);if(item!=null && item.Equipped){equipped.Push(item);item.Equipped=false;}}
            Check(!CaelumLabyrinthPowerups.Apply(a,2) && !CaelumLabyrinthPowerups.Apply(a,3) && !CaelumLabyrinthPowerups.Apply(a,5),"no compatible equipment refuses three equipment effects");
            for(int i=0;i<equipped.Size();i++)equipped[i].Equipped=true;
            let c=CaelumPlayer(players[2].mo);c.Attributes.Toughness=0;c.health=1;c.player.health=1;
            CaelumFoodIllness.Get(c).Contamination=100;
            Check(CaelumLabyrinthPowerups.Apply(c,0),"severe illness still permits collecting rest");
            Check(m.Hunt!=null?m.Hunt.Captive(2):c.health<=0,"normal disease during simulated rest causes death or capture");
            if(m.Hunt!=null)Check(!CaelumLabyrinthPowerups.Apply(c,1),"captive cannot collect powerups");
            let p=m.Powerups.Points[0];p.Kind=1;a.CurrentAnima=0;a.SetOrigin(p.Pos,false);a.Vel=(1,0,0);
        }
        if(level.time==115)
        {
            let p=m.Powerups.Points[0];Saved.ExpectedReady=p.ReadyAt;Saved.ExpectedKind=p.Kind;
            Check(p.ReadyAt>level.time && p.ReadyAt-level.time<=60*TICRATE,"native touch schedules full sixty seconds");
            a.SetOrigin(CaelumPowerupData.Point(1)+(0,-96,0),false);a.Vel=(0,0,0);Stage=1;
        }
        if(Stage==1 && level.time==Saved.ExpectedReady-1)
            Check(m.Powerups.Points[0].bInvisible,"point remains absent until final respawn tic");
        if(Stage==1 && level.time==Saved.ExpectedReady+2)
        {
            Check(m.Powerups.Points[0].ReadyAt==0 && !m.Powerups.Points[0].bInvisible,"point reappears after actual sixty active seconds");
            Check(Saved.Item.MatchAwakened && Saved.Item.Tier==Saved.ExpectedTier+1,"personal upgrade survives normal elapsed match time");
            m.Finished=true;m.Winner=0;Stage=2;
        }
        if(Stage==2 && level.time==Saved.ExpectedReady+8)
        {
            Check(!Saved.Item.MatchAwakened && Saved.Item.MatchPowerOwner==null && Saved.Item.Tier==Saved.ExpectedTier,"match completion restores original tier and removes awakening");
            Check(CaelumAwakening.Factor(Saved.Item)==1,"finished match has normal native equipment factor");
            Console.Printf("CA614 RESULT powerups");Stage=3;
        }
    }
}
