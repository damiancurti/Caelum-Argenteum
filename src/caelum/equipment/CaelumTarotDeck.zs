// El objeto representa las 78 cartas físicas. Ninguna esencia viaja en él:
// mover el mazo entre inventario y Caja no modifica TarotOwned del personaje.
class CaelumTarotDeck : CaelumSpecialInventoryItem
{
    Default
    {
        Tag "$CA_TAROT_DECK_NAME";
        Inventory.Icon "graphics/caelum/icons/ca_tarot_back.png";
        +INVENTORY.UNDROPPABLE
        +INVENTORY.UNCLEARABLE
        +INVULNERABLE
    }
    override int GetSpecialCategory() { return CaelumConstants.EQUIPMENT_KIND_KEY_ITEM; }
    override int GetSpecialType() { return CaelumConstants.KEY_ITEM_TAROT_DECK; }
    override double GetUnitWeight() { return CaelumConstants.TAROT_DECK_WEIGHT; }
    override Inventory CreateTossable(int tossAmount) { return null; }
    States { Spawn: CTAR A -1; Stop; }
}

class CaelumTarotDeckRules : Object play
{
    const REVISION = 1;
    static CaelumTarotDeck Owned(CaelumPlayer user)
    {
        return CaelumInventoryService.FindOwnedTarotDeck(user);
    }
    static bool InOwnedBox(CaelumPlayer user, bool explain = false)
    {
        let deck = Owned(user);
        bool valid = deck != null && deck.InMagicBox && CaelumMainM00FoolCapture.HasOwnedBox(user);
        if (!valid && explain) CaelumTarotPowers.Feedback(user, "CA_TAROT_DECK_CAPTURE_REQUIRED");
        return valid;
    }
    static bool Grant(CaelumPlayer user, bool explain = true)
    {
        return CaelumInventoryService.GrantTarotDeck(user, explain);
    }
    static void EnsureLegacy(CaelumPlayer user)
    {
        if (user == null || user.player == null || (user.player.cheats & CF_PREDICTING)) return;
        let record = user.GetPersistentCharacterState(false);
        if (record == null || record.TarotDeckRevision >= REVISION) return;
        // Sólo evidencia de una entrega/captura anterior habilita recuperación.
        // Si no cabe, se reintenta al liberar espacio sin tocar progreso previo.
        if (record.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_MAGIC_BOX_GRANTED)
            || record.CountTarotCards() > 0)
        {
            if (!Grant(user, false)) return;
        }
        record.TarotDeckRevision = REVISION;
    }
}
