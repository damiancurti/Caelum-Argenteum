// #647: objetos reales en una sala aislada; no altera reglas de inventario.
class CA647ConsumableCamera : Actor
{
    Default { CameraHeight 0; Height 0; Radius 0; +NOINTERACTION +NOGRAVITY }
    States { Spawn: TNT1 A -1; Stop; }
}

class CA647ConsumableEvents : EventHandler
{
    Array<CaelumConsumableItem> Drops;
    Array<CaelumConsumableItem> OwnedStacks;
    CA647ConsumableCamera Camera;
    int Failures;

    void Check(bool okay, String label)
    {
        if (!okay) Failures++;
        Console.Printf("CA647 %s %s", okay ? "PASS" : "FAIL", label);
    }

    void Verify()
    {
        Check(Drops.Size() == 9 && OwnedStacks.Size() == 9, "all nine consumable types retained");
        for (int index = 0; index < Drops.Size(); index++)
        {
            let item = Drops[index];
            let owned = OwnedStacks[index];
            String label = String.Format("consumable %d", index);
            Check(item != null && owned != null, label .. " saved references");
            if (item == null || owned == null) continue;
            Check(item.Owner == null && owned.Owner == players[0].mo,
                label .. " world/inventory ownership");
            Check(item.Amount == 2 && owned.Amount == 3, label .. " split quantities");
            Check(item.GetClass() == owned.GetClass()
                && item.GetConsumableType() == owned.GetConsumableType(),
                label .. " consumable identity");
            Check(item.GetUnitWeight() == owned.GetUnitWeight(),
                label .. " unit weight");
            let defaults = GetDefaultByType(item.GetClass());
            Check(item.Radius == defaults.Radius && item.Height == defaults.Height
                && item.Scale == defaults.Scale, label .. " native collision and scale");
            Check(item.Icon == owned.Icon && item.sprite == defaults.SpawnState.sprite,
                label .. " original icon and state");
            Check(abs(item.Pos.Z - item.floorz) < 0.01, label .. " rests on floor");
        }
        Console.Printf("CA647 COMPLETE failures=%d", Failures);
    }

    override void NetworkProcess(ConsoleEvent e)
    {
        if (e.Name == "ca647_prepare")
        {
            static const class<CaelumConsumableItem> kinds[] = { 'CaelumLifePotion','CaelumLifePotionMedium','CaelumLifePotionLarge','CaelumAnimaPotion','CaelumAnimaPotionMedium','CaelumAnimaPotionLarge','CaelumEnergyDrink','CaelumEnergyDrinkMedium','CaelumEnergyDrinkLarge' };
            Actor user = players[0].mo;
            for (int index = 0; index < kinds.Size(); index++)
            {
                let incoming = CaelumConsumableItem(Actor.Spawn(kinds[index], (0,0,0), NO_REPLACE));
                incoming.Amount = 5;
                Check(incoming.CallTryPickup(user), String.Format("consumable %d native pickup", index));
                let owned = CaelumConsumableItem(user.FindInventory(kinds[index]));
                Check(owned != null && owned.Amount == 5, String.Format("consumable %d owned quantity", index));
                if (owned == null) continue;
                let dropped = CaelumConsumableItem(owned.CreateTossable(2));
                Check(dropped != null, String.Format("consumable %d native toss", index));
                if (dropped == null) continue;
                dropped.SetOrigin(((index % 3 - 1) * 55, (index / 3 - 1) * 55, 0), false);
                Drops.Push(dropped);
                OwnedStacks.Push(owned);
            }
            Camera = CA647ConsumableCamera(Actor.Spawn('CA647ConsumableCamera', (0,-180,180), NO_REPLACE));
            Camera.Angle = 90;
            Camera.Pitch = 43;
            players[0].camera = Camera;
            players[0].mo.bInvisible = true;
        }
        if (e.Name == "ca647_view")
        {
            if (e.Args[0] == 4) players[0].camera = players[0].mo;
            else players[0].camera = Camera;
            players[0].mo.bInvisible = e.Args[0] != 4;
            if (e.Args[0] == 0) { Camera.SetOrigin((0,-180,180), false); Camera.Angle=90; Camera.Pitch=43; }
            if (e.Args[0] == 1) { Camera.SetOrigin((0,-180,50), false); Camera.Angle=90; Camera.Pitch=10; }
            if (e.Args[0] == 2) { Camera.SetOrigin((180,0,60), false); Camera.Angle=180; Camera.Pitch=14; }
            if (e.Args[0] == 3) { Camera.SetOrigin((0,-95,40), false); Camera.Angle=90; Camera.Pitch=14; }
            if (e.Args[0] == 5) { Camera.SetOrigin((0,-40,40), false); Camera.Angle=90; Camera.Pitch=14; }
            if (e.Args[0] == 6) { Camera.SetOrigin((0,15,40), false); Camera.Angle=90; Camera.Pitch=14; }
            if (e.Args[0] == 7) { Camera.SetOrigin((0,180,60), false); Camera.Angle=270; Camera.Pitch=14; }
            Camera.ClearInterpolation();
        }
        if (e.Name == "ca647_verify") Verify();
        if (e.Name == "ca647_pickup")
        {
            Actor user = players[0].mo;
            for (int index = 0; index < Drops.Size(); index++)
            {
                Check(Drops[index].CallTryPickup(user), String.Format("consumable %d repickup", index));
                Check(OwnedStacks[index].Amount == 5 && OwnedStacks[index].Owner == user,
                    String.Format("consumable %d combined native stack", index));
            }
            Console.Printf("CA647 COMPLETE failures=%d", Failures);
        }
    }
}
