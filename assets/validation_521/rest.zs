class CA177Rest : EventHandler
{
    int Age, OriginalHealth;
    bool Loaded;
    CaelumRestBed Occupied;
    CaelumSleepingBag Bag;
    static void Check(bool ok,String label){Console.Printf("CA177 %s %s",ok?"PASS":"FAIL",label);}
    static int Beds(){int n=0;let it=ThinkerIterator.Create("CaelumRestBed");while(it.Next()!=null)n++;return n;}
    static int Bags(CaelumPlayer u){int n=0;for(Inventory i=u.Inv;i!=null;i=i.Inv)if(i is "CaelumSleepingBag")n++;return n;}
    override void WorldTick()
    {
        let u=CaelumPlayer(players[0].mo);if(u==null || !u.CharacterCreationComplete)return;
        let r=u.GetPersistentCharacterState(true);Age++;
        if(Age==1){r.DemoNarrativeDelivered=2047;r.DemoNarrativePending=0;r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_UNKNOWN_VOICE_HEARD);}
        if(Age==100 && !Loaded)
        {
            Console.Printf("CA177 BEDS initial=%d",Beds());
            if(CVar.FindCVar('ca177_stage').GetInt()==1)Check(Beds()==0,"fresh MAP02 has no fixed beds");
            u.GrantMagicBoxFromPalomo(false);r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_MAGIC_BOX_GRANTED);
            r.MainM00SupplyIssued[CaelumConstants.MATERIAL_RAW_COPPER]=123;
            OriginalHealth=u.health;
            if(CVar.FindCVar('ca177_stage').GetInt()==0)
            {
                Occupied=CaelumRestBed(CaelumRestFurnitureTrial.Find(2));
                Check(Occupied!=null,"baseline fixture has an arrival bed to migrate");
                if(Occupied!=null)
                {
                    u.SetOrigin(Occupied.Pos+(100,0,0),false);u.Vel=(0,0,0);u.CurrentSleep=50;
                    Check(CaelumRestState.Begin(u,CaelumRestRules.MODE_SLEEP,60,Occupied),"baseline save contains real occupied rest session");
                }
            }
        }
        if(Age==240)
        {
            Bag=CaelumSleepingBag(u.FindInventory("CaelumSleepingBag"));
            Check(Bag!=null && Bags(u)==1,"completed Palomo save receives one sleeping bag");
            Check(r.MainM00SupplyIssued[CaelumConstants.MATERIAL_RAW_COPPER]==123 && u.health==OriginalHealth,"portable-rest migration preserves material ledger and health");
            if(Loaded)
            {
                Check(Occupied!=null && Occupied.Occupant==u && Beds()==1,"only the occupied saved bed remains until standing");
                CaelumRestState.Cancel(u);
            }
        }
        if(Age==260)
        {
            Check(Beds()==0 && Bags(u)==1,"bed retirement finishes without duplicating the bag");
            if(Bag!=null)
            {
                Bag.InMagicBox=false;u.SetOrigin((-448,320,0),false);u.Vel=(0,0,0);u.CurrentSleep=50;
                Check(Bag.BeginRest(u,5),"Palomo bag deploys through native safe rest in MAP02");
            }
        }
        if(Age==290)
        {
            CaelumRestState.Cancel(u);
            Check(Bag!=null && Bag.Owner==u && Bags(u)==1,"standing folds the same sleeping bag instance");
            Console.Printf("CA177 REST_DONE");
        }
    }
}
class CA177RestObserver : StaticEventHandler
{
    override void WorldLoaded(WorldEvent e)
    {
        if(!e.IsSaveGame)return;
        let run=CA177Rest(EventHandler.Find("CA177Rest"));
        if(run!=null){run.Loaded=true;run.Age=200;Console.Printf("CA177 REST_LOADED");}
    }
}
