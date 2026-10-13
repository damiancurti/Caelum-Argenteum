// Native input-path probe; packaged only in the isolated test addon.
class CA227Probe : StaticEventHandler
{
    CaelumPlayer User;
    int Failures;
    CaelumDiningTable FixtureTable;
    CaelumCanteenLarge FixtureCanteen;
    Actor Hazard;
    CaelumConsumableItem ReserveFood;
    CaelumCanteenLarge ReserveWater;
    bool UseBag, Boxed;
    void Check(bool ok,String text)
    {if(!ok)Failures++;Console.Printf("CA227 %s %s",ok?"PASS":"FAIL",text);}
    override void ConsoleProcess(ConsoleEvent e)
    {
        if(e.Name=="c227_close_intro" && Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();
        let menu=CaelumLiveMenu(Menu.GetCurrentMenu());
        if(e.Name=="c227_key" || e.Name=="c227_click")
        {
            if(menu==null){Console.Printf("CA227 FAIL missing native menu");return;}
            Console.Printf("CA227 INPUT context=%d allowed=%d",menu.Context,CaelumLiveMenu.InputAllowed());
            if(e.Name=="c227_key")
            {
                int character=e.Args[0];String key=String.Format("%c",character);
                menu.Key(InputEvent.Type_KeyDown,CaelumMenuPointer.KeyScan(character),character,key);
                menu.Key(InputEvent.Type_KeyUp,CaelumMenuPointer.KeyScan(character),character,key);
            }
            else
            {
                Vector2 point=(32+(e.Args[0]-1)*96+40,152);
                menu.PointerInput(Menu.MOUSE_Click,point);
                menu.PointerInput(Menu.MOUSE_Release,point);
            }
        }
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        User=CaelumPlayer(players[e.Player].mo);if(User==null)return;
        if(e.Name=="ca_time_fast" || e.Name=="ca_table_eat" || e.Name=="ca_table_drink")
            Console.Printf("CA227 EVENT %s",e.Name);
        if(e.Name=="c227_prepare")
        {
            if(User.player.ConversationNPC!=null)User.player.ConversationNPC.bInConversation=false;
            User.player.ConversationNPC=null;User.player.ConversationPC=null;
            User.CreationWizardOpen=false;User.CharacterCreationComplete=true;
            User.ApplyCharacterProfile();User.GetPersistentCharacterState(true).ProfileCommitted=true;
            User.CombatTimeRemaining=0;User.CurrentHunger=40;User.CurrentThirst=40;User.CurrentSleep=30;
            User.Vel=(0,0,0);User.SetOrigin(CaelumMazeLayout.ArrivalChairPosition()+(128,128,0),false);
            User.UpdateSurvivalStates();
            if(User.FindInventory("CaelumSleepingBag")==null)User.GiveInventoryType("CaelumSleepingBag");
        }
        if(e.Name=="c227_bag")
        {
            let bag=CaelumSleepingBag(User.FindInventory("CaelumSleepingBag"));
            Console.Printf("CA227 BEGIN bag=%d",bag.BeginRest(User,480));
        }
        if(e.Name=="c227_authored_prepare")
        {
            FixtureTable=CaelumDiningWorld.Find(105);
            Check(FixtureTable!=null && FixtureTable.Chairs[0]!=null,"authored mansion table and chair exist");
            if(FixtureTable!=null && FixtureTable.Chairs[0]!=null)
            {
                User.SetOrigin(FixtureTable.Chairs[0].Pos+(0,48,0),false);User.Vel=(0,0,0);
                User.CurrentHunger=40;User.CurrentThirst=40;
            }
        }
        if(e.Name=="c227_authored_sit")
        {
            let chair=FixtureTable.Chairs[0];
            Check(CaelumRestState.Begin(User,chair.RestMode(),0,chair),"authored mansion chair accepts seated wait");
            Check(FixtureTable.CanDine(User),"authored stocked mansion table can serve player");
        }
        if(e.Name=="c227_table")
        {
            CaelumRestState.Cancel(User);User.CurrentHunger=40;User.CurrentThirst=40;
            let table=CaelumDiningTable(Actor.Spawn("CaelumDiningTable",User.Pos+(150,0,0)));
            let food=CaelumConsumableItem(Actor.Spawn("CaelumFoodRation",table.Pos));
            food.Amount=1;food.AttachToOwner(table);table.Items[0]=food;
            let canteen=CaelumCanteenLarge(Actor.Spawn("CaelumCanteenLarge",table.Pos));
            canteen.WaterLiters=3;canteen.AttachToOwner(table);table.Items[1]=canteen;table.RefreshDisplays();
            FixtureTable=table;FixtureCanteen=canteen;
            let chair=CaelumRestFurniture(Actor.Spawn("CaelumRestChair",User.Pos));
            chair.Angle=180;chair.DiningTable=table;
            Console.Printf("CA227 BEGIN chair=%d",CaelumRestState.Begin(User,chair.RestMode(),480,chair));
            Console.Printf("CA227 TABLE reachable=%d",table.CanDine(User));
        }
        if(e.Name=="c227_hazard")
        {
            let oldChair=CaelumRestState.Get(User).Furniture;
            CaelumRestState.Cancel(User);User.CurrentSleep=30;
            if(oldChair!=null)oldChair.Destroy();
            if(FixtureTable!=null)FixtureTable.Destroy();
            let foodPower=User.FindInventory("CaelumHungerRegeneration");if(foodPower!=null)foodPower.Destroy();
            let waterPower=User.FindInventory("CaelumThirstRegeneration");if(waterPower!=null)waterPower.Destroy();
            User.SetOrigin(CaelumMazeLayout.ArrivalChairPosition()+(128,128,0),false);User.Vel=(0,0,0);
            Check(CaelumSleepingBag(User.FindInventory("CaelumSleepingBag")).BeginRest(User,480),"bag sleep prepared for rejection");
            Hazard=Actor.Spawn("CA227Hazard",User.Pos+(300,0,100));
        }
        if(e.Name=="c227_portable_prepare")
        {
            UseBag=e.Args[0]!=0;Boxed=e.Args[1]!=0;
            CaelumRestState.Cancel(User);User.CurrentHunger=40;User.CurrentThirst=40;User.CurrentSleep=30;
            ReserveFood=CaelumConsumableItem(Actor.Spawn("CaelumFoodRation"));
            ReserveFood.Amount=3;ReserveFood.InMagicBox=Boxed;ReserveFood.AttachToOwner(User);
            ReserveWater=CaelumCanteenLarge(Actor.Spawn("CaelumCanteenLarge"));
            ReserveWater.WaterLiters=3;ReserveWater.InMagicBox=Boxed;ReserveWater.AttachToOwner(User);
            User.MagicBoxOwned=true;User.GetPersistentCharacterState(true).MagicBoxOwned=true;
            User.SetOrigin(UseBag?CaelumMazeLayout.ArrivalChairPosition()+(128,128,0):CaelumRestFurnitureTrial.Find(1).Pos+(40,0,0),false);
            User.Vel=(0,0,0);
        }
        if(e.Name=="c227_portable_start")
        {
            let chair=CaelumRestFurnitureTrial.Find(1);
            Check(UseBag?CaelumSleepingBag(User.FindInventory("CaelumSleepingBag")).BeginRest(User,480)
                :CaelumRestState.Begin(User,chair.RestMode(),480,chair),"authored chair or owned bag accepts rest");
            Check(CaelumDiningTable.Nearby(User)==null,"portable test has no serving table");
        }
        if(e.Name=="c227_portable_check")
        {
            let rest=CaelumRestState.Get(User);
            Check(rest.AutoEating && rest.AutoDrinking,"both meal channels enabled without a table");
            Check(ReserveFood.Amount==2 && ReserveFood.InMagicBox==Boxed,"one owned ration spent and storage preserved");
            Check(ReserveWater.WaterLiters<3 && ReserveWater.WaterLiters>0 && ReserveWater.InMagicBox==Boxed,"owned water spent and container storage preserved");
            Check(User.FindInventory("CaelumHungerRegeneration")!=null && User.FindInventory("CaelumThirstRegeneration")!=null,"both native recovery effects run");
            Check(rest.DiningTable==null && CaelumDiningSession.CanServe(User),"meal session retains real portable support");
        }
        if(e.Name=="c227_portable_repeat")
        {
            User.FindInventory("CaelumHungerRegeneration").Destroy();User.FindInventory("CaelumThirstRegeneration").Destroy();
            double water=ReserveWater.WaterLiters;
            CaelumDiningSession.Advance(User);
            Check(ReserveFood.Amount==1 && ReserveWater.WaterLiters<water,"automatic next portions consume finite supplies");
        }
        if(e.Name=="c227_portable_stop")
        {
            let rest=CaelumRestState.Get(User);
            Check(!rest.AutoEating && !rest.AutoDrinking,"F and G stop both channels");
            Check(ReserveFood.Amount==1,"stopping never consumes another ration");
            CaelumRestState.Cancel(User);
            Check(!CaelumDiningSession.Toggle(User,false) && !CaelumDiningSession.Toggle(User,true),"standing cannot start automatic serving");
        }
        if(e.Name=="c227_resume")
        {
            ReserveFood=CaelumConsumableItem(User.FindInventory("CaelumFoodRation"));
            ReserveWater=CaelumCanteenLarge(User.FindInventory("CaelumCanteenLarge"));Boxed=true;
            Check(CaelumRestState.IsSleeping(User) && CaelumDiningSession.CanServe(User),"saved bag support resumes");
        }
        if(e.Name=="c227_portable_guards")
        {
            let rest=CaelumRestState.Get(User);
            User.FindInventory("CaelumHungerRegeneration").Destroy();User.FindInventory("CaelumThirstRegeneration").Destroy();
            ReserveWater.WaterLiters=0;
            CaelumDiningSession.Advance(User);
            Check(ReserveFood==null && !rest.AutoDrinking,"last ration is consumed and empty water stops serving");
            User.FindInventory("CaelumHungerRegeneration").Destroy();
            CaelumDiningSession.Advance(User);
            Check(!rest.AutoEating,"exhausted food stops without replacement");
            Check(!CaelumDiningSession.Toggle(User,false) && !CaelumDiningSession.Toggle(User,true),"empty supplies reject serving");
            Check(ReserveWater.Owner==User && ReserveWater.InMagicBox==Boxed,"empty canteen retains identity and storage");
        }
        if(e.Name=="c227_expect")
        {
            let rest=CaelumRestState.Get(User);let fast=CaelumTimeAdvanceState.Get(User);
            Check(rest!=null && rest.Status==CaelumRestRules.STATUS_ACTIVE,"input preserves rest");
            if(e.Args[0]==1)Check(fast!=null && fast.Active && fast.SimulatedTics>=104,"T dispatch accelerates actual simulation");
            if(e.Args[0]==2)Check(fast!=null && !fast.Active,"click dispatch returns to normal speed");
            if(e.Args[0]==3)
            {
                Check(rest.AutoEating && User.FindInventory("CaelumHungerRegeneration")!=null,"F dispatch starts real food effect");
                Check(FixtureTable.Items[0]==null,"one finite portion consumed");
            }
            if(e.Args[0]==4)
            {
                Check(rest.AutoDrinking && User.FindInventory("CaelumThirstRegeneration")!=null,"drink click starts real water effect");
                Check(FixtureCanteen.Owner==FixtureTable && FixtureCanteen.WaterLiters<3 && FixtureCanteen.WaterLiters>0,"canteen persists with less water");
            }
            if(e.Args[0]==5)
            {
                Check(!fast.Active && fast.LastReason=="CA_FAST_UNSAFE","nearby hazard blocks speed with existing rule");
                let inbox=CaelumNotifications.Inbox(User);
                Check(inbox.Count>0 && inbox.Text[inbox.Count-1]==StringTable.Localize("CA_FAST_UNSAFE",false),"rejection reaches visible feedback mailbox");
            }
            if(e.Args[0]==6)
            {
                Check(!rest.AutoEating && !rest.AutoDrinking,"no reserve means no automatic consumption");
                let inbox=CaelumNotifications.Inbox(User);
                Check(inbox.Count>0 && inbox.Text[inbox.Count-1]==StringTable.Localize("CA_TABLE_CANNOT_EAT",false),"empty-reserve dining key reports restriction");
            }
            if(e.Args[0]==7)
            {
                Check(rest.AutoEating && User.FindInventory("CaelumHungerRegeneration")!=null,"authored table F supplies food");
                Check(rest.AutoDrinking && User.FindInventory("CaelumThirstRegeneration")!=null,"authored table G supplies drink");
            }
        }
        if(e.Name=="c227_done")Console.Printf("CA227 DONE failures=%d",Failures);
        if(e.Name=="c227_report")
        {
            let rest=CaelumRestState.Get(User);let fast=CaelumTimeAdvanceState.Get(User);
            Console.Printf("CA227 STATE rest=%d mode=%d fast=%d extra=%d eat=%d drink=%d reason=%s",rest.Status,rest.Mode,fast!=null && fast.Active,fast==null?0:fast.SimulatedTics,rest.AutoEating,rest.AutoDrinking,fast==null?"":fast.LastReason);
        }
    }
}

class CA227Hazard : Actor
{
    Default {Radius 0;Height 0;+MISSILE +NOGRAVITY +NOBLOCKMAP RenderStyle "None";}
    States {Spawn:TNT1 A -1;Stop;}
}
