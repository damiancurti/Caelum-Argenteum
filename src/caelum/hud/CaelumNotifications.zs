// Buzón del destinatario: no usa el último mensaje de consola ni datos del
// jugador cero. Se añade cuando llega el primer aviso, también en saves viejos.
class CaelumNotificationInbox : Inventory
{
    const LIMIT = 20;
    int Count;
    String Text[LIMIT];
    int RemainingTics[LIMIT];

    Default
    {
        Inventory.MaxAmount 1;
        Inventory.InterHubAmount 1;
        +INVENTORY.UNDROPPABLE
        +INVENTORY.UNCLEARABLE
        -INVENTORY.INVBAR
    }
    States { Spawn: TNT1 A -1; Stop; }
    override bool TryPickup(in out Actor toucher) { return false; }
    override Inventory CreateTossable(int amount) { return null; }

    void RemoveAt(int index)
    {
        for (int i = index; i < Count - 1; i++)
        {
            Text[i] = Text[i + 1];
            RemainingTics[i] = RemainingTics[i + 1];
        }
        Count--;
        Text[Count] = "";
        RemainingTics[Count] = 0;
    }

    void Add(String message, int duration)
    {
        if (Count == LIMIT) RemoveAt(0);
        Text[Count] = message;
        RemainingTics[Count] = duration;
        Count++;
    }

    override void Tick()
    {
        Super.Tick();
        for (int i = Count - 1; i >= 0; i--)
        {
            RemainingTics[i]--;
            if (RemainingTics[i] <= 0) RemoveAt(i);
        }
    }
}

class CaelumNotifications : Object
{
    static play void Notify(Actor recipient, String message)
    {
        if (recipient == null || recipient.player == null || message == "") return;
        let inbox = CaelumNotificationInbox(recipient.FindInventory("CaelumNotificationInbox"));
        if (inbox == null)
        {
            inbox = CaelumNotificationInbox(Actor.Spawn("CaelumNotificationInbox", recipient.Pos, NO_REPLACE));
            if (inbox == null) return;
            inbox.AttachToOwner(recipient);
        }
        let setting = CVar.GetCVar("ca_notification_seconds", recipient.player);
        double seconds = setting == null ? 8.0 : setting.GetFloat();
        inbox.Add(message, Max(1, int(Max(0.0, seconds) * TICRATE)));
    }

    static clearscope String EssenceKey(int essence)
    {
        if (essence == CaelumConstants.ESSENCE_WATER) return "CA_ESSENCE_WATER";
        if (essence == CaelumConstants.ESSENCE_EARTH) return "CA_ESSENCE_EARTH";
        if (essence == CaelumConstants.ESSENCE_WIND) return "CA_ESSENCE_WIND";
        if (essence == CaelumConstants.ESSENCE_QUINTESSENCE) return "CA_ESSENCE_QUINTESSENCE";
        return "CA_ESSENCE_FIRE";
    }

    // La misma descripción sirve a la vista previa y a la recepción. Mirar un
    // equipo adaptativo sólo proyecta sus datos; no los escribe en la instancia.
    static play String Describe(CaelumPlayer user, Inventory item,
        int quantity, bool preview = false)
    {
        if (item == null) return "";
        String label;
        let equipment = CaelumEquipmentItem(item);
        if (equipment != null)
        {
            int kind = preview ? equipment.PreviewEquipmentKind() : equipment.EquipmentKind;
            int type = preview ? equipment.PreviewItemType() : equipment.ItemType;
            int tier = preview ? equipment.PreviewTier() : equipment.Tier;
            int slot = preview ? equipment.PreviewArmorSlot() : equipment.ArmorSlot;
            int size = preview ? equipment.PreviewEquipmentSize(user) : equipment.EquipmentSize;
            int essence = preview ? equipment.PreviewEssenceType() : equipment.EssenceType;
            if (kind == CaelumConstants.EQUIPMENT_KIND_WEAPON)
                label = CaelumDisplayNames.FormatWeaponName(type, tier);
            else if (kind == CaelumConstants.EQUIPMENT_KIND_ARMOR)
                label = String.Format("%s · %s", CaelumDisplayNames.FormatArmorTypeName(type, tier),
                    StringTable.Localize(CaelumDisplayNames.GetArmorSlotKey(slot), false));
            else if (kind == CaelumConstants.EQUIPMENT_KIND_SHIELD)
                label = CaelumDisplayNames.FormatShieldName(type, tier);
            else if (kind == CaelumConstants.EQUIPMENT_KIND_AMULET)
                label = CaelumDisplayNames.FormatAmuletName(type, tier);
            else label = CaelumDisplayNames.FormatSealName(type, tier);
            label.AppendFormat(" · T%d", tier);
            if (kind == CaelumConstants.EQUIPMENT_KIND_WEAPON
                || kind == CaelumConstants.EQUIPMENT_KIND_ARMOR
                || kind == CaelumConstants.EQUIPMENT_KIND_SHIELD)
                label.AppendFormat(" · %s", StringTable.Localize(CaelumDisplayNames.GetEquipmentSizeKey(size), false));
            if (kind == CaelumConstants.EQUIPMENT_KIND_WEAPON
                && (type == CaelumConstants.WEAPON_TYPE_STAFF
                    || type == CaelumConstants.WEAPON_TYPE_BELL
                    || type == CaelumConstants.WEAPON_TYPE_BOOK
                    || type == CaelumConstants.WEAPON_TYPE_STATUETTE))
                label.AppendFormat(" · %s", StringTable.Localize(EssenceKey(essence), false));
        }
        else
        {
            let consumable = CaelumConsumableItem(item);
            let special = CaelumSpecialInventoryItem(item);
            let key = CaelumWeightedKey(item);
            let ammunition = CaelumCarbineAmmo(item);
            if (item is "CaelumMagicBox")
                label = StringTable.Localize("CA_EQUIPMENT_MAGIC_BOX", false);
            else if (consumable != null)
                label = StringTable.Localize(CaelumDisplayNames.GetConsumableKey(consumable.GetConsumableType()), false);
            else if (special != null)
            {
                label = StringTable.Localize(CaelumDisplayNames.GetSpecialItemKey(special.GetSpecialCategory(), special.GetSpecialType()), false);
                if (special.GetSpecialTier() > 0) label.AppendFormat(" · T%d", special.GetSpecialTier());
            }
            else if (key != null)
                label = StringTable.Localize(CaelumDisplayNames.GetSpecialItemKey(CaelumConstants.EQUIPMENT_KIND_KEY, key.GetKeyType()), false);
            else if (ammunition != null)
                label = StringTable.Localize(CaelumDisplayNames.GetAmmunitionKey(ammunition.GetAmmoType()), false);
            else if (item is "CaelumArrowAmmo")
                label = StringTable.Localize("CA_WEAPON_AMMO_ARROWS", false);
            else if (item is "CaelumBoltAmmo")
                label = StringTable.Localize("CA_WEAPON_AMMO_BOLTS", false);
            else label = item.GetTag();
        }
        return quantity > 0 ? String.Format("%d × %s", quantity, label) : label;
    }

    static play void Acquired(CaelumPlayer user, Inventory item, int quantity)
    {
        if (quantity <= 0 || item == null) return;
        AcquiredDescription(user, Describe(user, item, 0), quantity);
    }

    static play void AcquiredDescription(CaelumPlayer user, String description, int quantity)
    {
        if (quantity > 0) Notify(user, String.Format("Recibido: %d × %s", quantity, description));
    }

    // Conteo real antes/después: incluye las pilas de la Caja y distingue
    // materiales de igual clase con tipos o tiers diferentes.
    static play int OwnedQuantity(CaelumPlayer user, Inventory prototype)
    {
        int total = 0;
        if (user == null || prototype == null) return 0;
        let source = CaelumSpecialInventoryItem(prototype);
        for (Inventory entry = user.Inv; entry != null; entry = entry.Inv)
        {
            if (entry.GetClass() != prototype.GetClass()) continue;
            let special = CaelumSpecialInventoryItem(entry);
            if (source != null && (source.GetSpecialType() != special.GetSpecialType()
                || source.GetSpecialTier() != special.GetSpecialTier())) continue;
            total += entry.Amount;
        }
        return total;
    }

    static ui void Draw(CaelumPlayer user, Font font)
    {
        let inbox = CaelumNotificationInbox(user.FindInventory("CaelumNotificationInbox"));
        if (inbox == null || inbox.Count == 0 || font == null) return;
        // Dos columnas de diez entradas: se lee hacia abajo y luego a la
        // derecha. Cada entrada reserva dos renglones; el panel termina antes
        // de Lucidez/Vida/Aire y deja libre el centro y el sello lateral.
        double textScale = Min(2.0, 20.0 / Max(1, font.GetHeight()));
        double lineHeight = Ceil(font.GetHeight() * textScale) + 1.0;
        double entryHeight = lineHeight * 2.0 + 2.0;
        for (int index = 0; index < inbox.Count; index++)
        {
            int column = index / 10;
            int row = index % 10;
            double x = column == 0 ? 40.0 : 706.0;
            int width = column == 0 ? 540 : 430;
            let lines = font.BreakLines(inbox.Text[index], int(width / textScale));
            for (int line = 0; line < Min(2, lines.Count()); line++)
            {
                String text = lines.StringAt(line);
                if (line == 1 && lines.Count() > 2) text = text.Left(Max(0, text.Length() - 3)) .. "...";
                Screen.DrawText(font, Font.CR_WHITE, x, 12.0 + row * entryHeight + line * lineHeight, text,
                    DTA_VIRTUALWIDTHF, 1280.0, DTA_VIRTUALHEIGHTF, 720.0,
                    DTA_SCALEX, textScale, DTA_SCALEY, textScale,
                    DTA_KEEPRATIO, true, DTA_SHADOW, true);
            }
            lines.Destroy();
        }
    }
}
