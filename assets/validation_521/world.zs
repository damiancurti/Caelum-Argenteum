class CA177World : EventHandler
{
    int Age;
    static void Check(bool ok,String label){Console.Printf("CA177 %s %s",ok?"PASS":"FAIL",label);}
    override void WorldTick()
    {
        let u=CaelumPlayer(players[0].mo);if(u==null || !u.CharacterCreationComplete)return;Age++;
        let r=u.GetPersistentCharacterState(true);
        if(Age==1){r.DemoNarrativeDelivered=2047;r.DemoNarrativePending=0;r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_UNKNOWN_VOICE_HEARD);}
        if(Age!=120)return;
        if(level.MapName=="MAP01")
        {
            let it=ThinkerIterator.Create("CaelumDiningTable");CaelumDiningTable t,best;
            while((t=CaelumDiningTable(it.Next()))!=null)if(best==null || t.Pos.Z>best.Pos.Z)best=t;
            best.RestockMansion();int cans=0;
            for(int i=0;i<best.Capacity();i++)if(best.Items[i] is "CaelumCanteenLarge")cans++;
            Check(cans==best.ForecastDailyTarget(),"upper table displays existing large 5-liter canteens");
            u.SetOrigin(best.Chairs[0].Pos+(0,0,8),false);
            vector3 facing=best.Pos-u.Pos;u.Angle=atan2(facing.Y,facing.X);u.Pitch=20;u.Vel=(0,0,0);
        }
        else
        {
            let it=ThinkerIterator.Create("CaelumMazeChest");let chest=CaelumMazeChest(it.Next());
            u.SetOrigin(chest.Pos+(0,-80,0),false);u.Angle=90;u.Pitch=atan2(u.ViewHeight-chest.Height/2,80);u.Vel=(0,0,0);
            Check(chest.Used(u),"native MAP02 chest still opens");let preview=CaelumChestPreviewState.Get(u);
            Check(preview!=null && preview.Chest==chest && preview.TutorialChest==null && preview.Count>0,"shared preview retains the native maze source");
            chest.Collect(u);preview.Refresh();Check(chest.MaterialAllocated,"MAP02 collection still debits its own material stock");
            preview.Close();Check(!preview.IsOpen(),"shared close clears MAP02 preview");
            let table=CaelumDiningTable(Actor.Spawn("CaelumDiningTable",u.Pos+(300,0,0),NO_REPLACE));
            table.RestockMansion();int count=0;
            for(int i=0;i<table.Capacity();i++)if(table.Items[i]!=null)count++;
            Check(count==0 && table.ForecastDailyTarget()==0,"mansion refill creates no supplies on MAP02");
        }
        Console.Printf("CA177 WORLD_DONE");
    }
}
