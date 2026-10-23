// #408: la calidad pertenece al agua del recipiente, no al jugador.
class CaelumWaterQuality : Object
{
    const REVISION = 1;
    const POTABLE = 0;
    const BIOLOGICAL = 1;
    const SALT = 2;
    const CHEMICAL = 4;
    const ALL = BIOLOGICAL | SALT | CHEMICAL;
    const UNIDENTIFIED = -1;

    static clearscope bool Valid(int quality) { return quality >= 0 && quality <= ALL; }
    static clearscope bool IsSafe(int quality) { return quality == POTABLE; }
    static clearscope int Source(CaelumPlayer user)
    {
        if (user == null || user.WaterLevel < 3 || user.CurSector == null) return UNIDENTIFIED;
        int quality = user.CurSector.GetUDMFInt('user_ca_water_quality');
        if (!Valid(quality)) return UNIDENTIFIED;
        // Una contaminación explícita prevalece sobre la marca potable antigua.
        if (quality != POTABLE) return quality;
        return user.CurSector.GetUDMFInt('user_ca_potable_water') != 0 ? POTABLE : UNIDENTIFIED;
    }
    static clearscope String Label(int quality)
    {
        if (!Valid(quality)) return StringTable.Localize("CA_WATER_UNKNOWN", false);
        if (IsSafe(quality)) return StringTable.Localize("CA_WATER_POTABLE", false);
        String result = "";
        if (quality & BIOLOGICAL) result = StringTable.Localize("CA_WATER_BIOLOGICAL", false);
        if (quality & SALT) result = result .. (result.Length() > 0 ? " + " : "") .. StringTable.Localize("CA_WATER_SALT", false);
        if (quality & CHEMICAL) result = result .. (result.Length() > 0 ? " + " : "") .. StringTable.Localize("CA_WATER_CHEMICAL", false);
        return result;
    }
    static play void InventoryAction(CaelumPlayer user, bool empty)
    {
        if (!CaelumPlayerAuthority.CanMutate(user) || user.health <= 0 || user.isFrozen()) return;
        let item = CaelumWaterContainer(user.GetFormalInventoryEntryAt(user.FormalInventorySelectionIndex));
        if (item == null || item.Owner != user || item.InMagicBox) return;
        bool changed = empty ? item.EmptyWater(user) : item.FillFromSource(user);
        CaelumNotifications.Notify(user, StringTable.Localize(changed
            ? (empty ? "CA_WATER_EMPTIED" : "CA_WATER_COLLECTED") : "CA_WATER_TRANSFER_REJECTED", false));
        user.RefreshFormalInventorySnapshot();
    }
}
