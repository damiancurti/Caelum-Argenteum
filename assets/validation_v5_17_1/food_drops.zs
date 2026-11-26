// #647: objetos reales en una sala aislada; no altera reglas de inventario.
class CA647FoodCamera : Actor
{
    Default { CameraHeight 0; Height 0; Radius 0; +NOINTERACTION +NOGRAVITY }
    States { Spawn: TNT1 A -1; Stop; }
}

class CA647FoodEvents : EventHandler
{
    Array<CaelumConsumableItem> Drops;
    Array<CaelumConsumableItem> OwnedStacks;
    CA647FoodCamera Camera;
    int Failures;
    CaelumDiningTable Table;

    void Check(bool okay, String label)
    {
        if (!okay) Failures++;
        Console.Printf("CA647 %s %s", okay ? "PASS" : "FAIL", label);
    }

    void Verify()
    {
        Check(Drops.Size() == 6 && OwnedStacks.Size() == 6, "all six food types retained");
        for (int index = 0; index < Drops.Size(); index++)
        {
            let item = Drops[index];
            let owned = OwnedStacks[index];
            String label = String.Format("food %d", index);
            Check(item != null && owned != null, label .. " saved references");
            if (item == null || owned == null) continue;
            Check(item.Owner == null && owned.Owner == players[0].mo,
                label .. " world/inventory ownership");
            Check(item.Amount == 2 && owned.Amount == 3, label .. " split quantities");
            Check(item.GetClass() == owned.GetClass()
                && item.GetConsumableType() == owned.GetConsumableType(),
                label .. " food identity");
            Check(item.FoodLots != null && owned.FoodLots != null, label .. " native lot books");
            if(item.FoodLots != null && owned.FoodLots != null)
            {
                Check(item.FoodLots.Units()==2 && owned.FoodLots.Units()==3,
                    label .. " split lot quantities");
                Check(item.FoodLots.Lots.Size()==1 && owned.FoodLots.Lots.Size()==2,
                    label .. " split lot boundaries");
                Check(item.FoodLots.Lots[0].CreatedStamp==100 && owned.FoodLots.Lots[0].CreatedStamp==100
                    && owned.FoodLots.Lots[1].CreatedStamp==200, label .. " retained oldest-first chronology");
                Check(item.FoodLots.Contamination(0)>=10 && owned.FoodLots.Contamination(1)>=30,
                    label .. " no contamination rejuvenation");
            }
            Check(item.GetUnitWeight() == owned.GetUnitWeight(),
                label .. " unit weight");
            let defaults = GetDefaultByType(item.GetClass());
            Check(item.Radius == defaults.Radius && item.Height == defaults.Height
                && item.Scale == defaults.Scale, label .. " native collision and scale");
            Check(item.Icon == owned.Icon && item.sprite == defaults.SpawnState.sprite,
                label .. " original icon and state");
            Check(abs(item.Pos.Z - item.floorz) < 0.01, label .. " rests on floor");
        }
        Check(Table != null, "saved dining table");
        if(Table != null)
        for(int slot=0;slot<4;slot++)
        {
            let item=Table.Items[slot];let visual=Table.Displays[slot];
            Check(item != null && item.Owner==Table && item.Amount==1, "table retains real portion");
            Check(visual != null && visual.Item==item && visual.Table==Table, "table display retains authority");
            if(item != null && visual != null)
            {
                Check(visual.GetClass()==CaelumMealData.TableDisplay(item.GetConsumableType()), "correct prepared-meal display");
                Check(visual.Scale==GetDefaultByType(item.GetClass()).Scale*Table.ServingScale(), "native table serving scale");
                Check(abs(visual.Pos.Z-Table.Pos.Z-Table.SurfaceHeight())<0.01, "model rests on table surface");
            }
        }
        Console.Printf("CA647 COMPLETE failures=%d", Failures);
    }

    override void NetworkProcess(ConsoleEvent e)
    {
        if (e.Name == "ca647_prepare")
        {
            static const class<CaelumConsumableItem> kinds[] = { ITEM_CLASSES };
            Actor user = players[0].mo;
            for (int index = 0; index < kinds.Size(); index++)
            {
                let incoming = CaelumConsumableItem(Actor.Spawn(kinds[index], (0,0,0), NO_REPLACE));
                incoming.Amount = 5;
                let lots=new('CaelumFoodLots');
                lots.Ensure(CaelumFoodInventory.Kind(incoming),0,0);
                lots.Add(3,10,100); lots.Add(2,30,200);
                incoming.FoodLots=lots;
                Check(incoming.CallTryPickup(user), String.Format("food %d native pickup", index));
                let owned = CaelumConsumableItem(user.FindInventory(kinds[index]));
                Check(owned != null && owned.Amount == 5, String.Format("food %d owned quantity", index));
                if (owned == null) continue;
                let dropped = CaelumConsumableItem(owned.CreateTossable(2));
                Check(dropped != null, String.Format("food %d native toss", index));
                if (dropped == null) continue;
                dropped.SetOrigin(((index % 3 - 1) * 55, (index / 3 - 1) * 55, 0), false);
                Drops.Push(dropped);
                OwnedStacks.Push(owned);
            }
            Table=CaelumDiningTable(Actor.Spawn('CaelumDiningTable',(0,110,0),NO_REPLACE));
            for(int slot=0;slot<4;slot++)
            {
                let meal=CaelumConsumableItem(Actor.Spawn(CaelumMealData.ItemClass(CaelumMealData.FIRST_CONSUMABLE+slot),Table.Pos,NO_REPLACE));
                meal.Amount=1;meal.AttachToOwner(Table);Table.Items[slot]=meal;
                CaelumFoodInventory.Reconcile(meal);
            }
            Table.RefreshDisplays();
            Camera = CA647FoodCamera(Actor.Spawn('CA647FoodCamera', (0,-180,180), NO_REPLACE));
            Camera.Angle = 90;
            Camera.Pitch = 43;
            players[0].camera = Camera;
            players[0].mo.bInvisible = true;
            let hud = CaelumHUDOverlay(EventHandler.Find('CaelumHUDOverlay'));
            if (hud != null) hud.HUDFont = null;
        }
        if (e.Name == "ca647_view")
        {
            if (e.Args[0] == 4) players[0].camera = players[0].mo;
            else players[0].camera = Camera;
            players[0].mo.bInvisible = e.Args[0] != 4;
            let hud = CaelumHUDOverlay(EventHandler.Find('CaelumHUDOverlay'));
            if (hud != null)
            {
                if (e.Args[0] == 4) hud.HUDFont = Font.GetFont("CaelumMono");
                else hud.HUDFont = null;
            }
            if (e.Args[0] == 0) { Camera.SetOrigin((0,-180,180), false); Camera.Angle=90; Camera.Pitch=43; }
            if (e.Args[0] == 1) { Camera.SetOrigin((0,-180,50), false); Camera.Angle=90; Camera.Pitch=10; }
            if (e.Args[0] == 2) { Camera.SetOrigin((180,0,60), false); Camera.Angle=180; Camera.Pitch=14; }
            if (e.Args[0] == 3) { Camera.SetOrigin((0,-108,35), false); Camera.Angle=90; Camera.Pitch=25; }
            if (e.Args[0] == 5) { Camera.SetOrigin((0,-53,35), false); Camera.Angle=90; Camera.Pitch=22; }
            if (e.Args[0] == 6) { Camera.SetOrigin((0,2,35), false); Camera.Angle=90; Camera.Pitch=22; }
            if (e.Args[0] == 7) { Camera.SetOrigin((0,180,60), false); Camera.Angle=270; Camera.Pitch=14; }
            if (e.Args[0] == 8) { Camera.SetOrigin((0,0,95), false); Camera.Angle=90; Camera.Pitch=30; }
            Camera.ClearInterpolation();
        }
        if (e.Name == "ca647_verify") Verify();
        if (e.Name == "ca647_pickup")
        {
            Actor user = players[0].mo;
            for (int index = 0; index < Drops.Size(); index++)
            {
                Check(Drops[index].CallTryPickup(user), String.Format("food %d repickup", index));
                let lots=OwnedStacks[index].FoodLots;
                Check(lots != null && lots.Units()==5, String.Format("food %d recovered lot units",index));
                if(lots != null)
                {
                    int oldUnits=0,newUnits=0;
                    for(int lot=0;lot<lots.Lots.Size();lot++)
                    {
                        if(lots.Lots[lot].CreatedStamp==100)oldUnits+=lots.Lots[lot].Units;
                        if(lots.Lots[lot].CreatedStamp==200)newUnits+=lots.Lots[lot].Units;
                    }
                    Check(oldUnits==3 && newUnits==2,String.Format("food %d retained lot chronology",index));
                }
                Check(OwnedStacks[index].Amount == 5 && OwnedStacks[index].Owner == user,
                    String.Format("food %d combined native stack", index));
            }
            Console.Printf("CA647 COMPLETE failures=%d", Failures);
        }
    }
}
