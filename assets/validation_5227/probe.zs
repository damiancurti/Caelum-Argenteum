// Isolated engine probe; never packaged with production assets.
class CA229Probe : StaticEventHandler
{
    int Failures;
    void Check(bool ok, String label)
    {
        if (!ok) Failures++;
        Console.Printf("CA229 %s %s", ok ? "PASS" : "FAIL", label);
    }
    bool Near(double a, double b) { return Abs(a-b) < 0.0000001; }
    override void NetworkProcess(ConsoleEvent e)
    {
        let user = CaelumPlayer(players[e.Player].mo);
        if (user == null) return;
        double tare = e.Args[0] / 1000.0;
        if (e.Name == "c229_prepare")
        {
            if (user.player.ConversationNPC != null)
                user.player.ConversationNPC.bInConversation = false;
            user.player.ConversationNPC = null;
            user.player.ConversationPC = null;
            user.CreationWizardOpen = false;
            user.CharacterCreationComplete = true;
            user.ApplyCharacterProfile();
            user.GetPersistentCharacterState(true).ProfileCommitted = true;
        }
        if (e.Name == "c229_check")
        {
            user.MagicBoxOwned = false;
            user.GetPersistentCharacterState(true).MagicBoxOwned = false;
            user.RefreshCarriedInventorySummary();
            double before = user.DerivedStats.CarriedWeight;
            Check(Near(user.HUDMagicBoxTotalWeight, 0)
                && Near(user.CalculateMagicBoxTotalWeight(10), 0), "unowned Box adds no weight");
            user.MagicBoxOwned = true;
            user.GetPersistentCharacterState(true).MagicBoxOwned = true;
            user.RefreshCarriedInventorySummary();
            Check(Near(user.HUDMagicBoxRawContentWeight, 0), "initial Box is empty");
            Check(Near(user.HUDMagicBoxTotalWeight, tare), "empty Box has requested tare");
            Check(Near(user.DerivedStats.CarriedWeight - before, tare), "carried load adds tare exactly once");
            let food = CaelumConsumableItem(Actor.Spawn("CaelumFoodRation"));
            food.Amount = 50;
            food.InMagicBox = true;
            food.AttachToOwner(user);
            for (int i = 0; i < 2; i++)
            {
                user.Attributes.Intelligence = i * 100;
                user.DerivedStats.Recalculate(user.Attributes, user.CharacterProfile);
                user.RefreshCarriedInventorySummary();
                Check(user.MagicBoxMaximumSlots == (i == 0 ? 30 : 100), "Intelligence retains capacity and divisor");
                Check(Near(user.HUDMagicBoxRawContentWeight, 10), "real stored ration stack weighs 10 kg");
                double reduced = i == 0 ? 0.333 : 0.100;
                Check(Near(user.HUDMagicBoxReducedContentWeight, reduced), "aggregate content reduction still truncates to grams");
                Check(Near(user.HUDMagicBoxTotalWeight, tare + reduced)
                    && Near(user.CalculateMagicBoxTotalWeight(10), tare + reduced), "HUD and shared Box total agree");
                Check(Near(user.DerivedStats.CarriedWeight - before, tare + reduced), "carried load includes reduced content once");
            }
            user.ApplyCharacterProfile();
            user.PersistCharacterState();
            Console.Printf("CA229 SAVE raw=%.3f reduced=%.3f total=%.3f load=%.3f",
                user.HUDMagicBoxRawContentWeight, user.HUDMagicBoxReducedContentWeight,
                user.HUDMagicBoxTotalWeight, user.DerivedStats.CarriedWeight);
        }
        if (e.Name == "c229_loaded")
        {
            // Observe normal post-load state before any forced refresh.
            Check(user.MagicBoxOwned, "saved ownership remains");
            Check(Near(user.HUDMagicBoxRawContentWeight, 10), "saved contents remain");
            double reduced = Floor(10.0 / user.MagicBoxMaximumSlots / 0.001 + 0.0000001) * 0.001;
            Check(Near(user.HUDMagicBoxTotalWeight, reduced + tare), "normal tick refreshes saved Box tare");
            double loadedWeight = user.DerivedStats.CarriedWeight;
            user.RefreshCarriedInventorySummary();
            Check(Near(user.DerivedStats.CarriedWeight, loadedWeight), "loaded carried load already matches refreshed load");
            Check(Near(user.HUDCarriedWeight, loadedWeight), "loaded HUD load agrees");
            Console.Printf("CA229 LOADED raw=%.3f reduced=%.3f total=%.3f load=%.3f",
                user.HUDMagicBoxRawContentWeight, user.HUDMagicBoxReducedContentWeight,
                user.HUDMagicBoxTotalWeight, user.DerivedStats.CarriedWeight);
        }
        if (e.Name == "c229_done") Console.Printf("CA229 DONE failures=%d", Failures);
    }
}
