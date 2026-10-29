// Buzón del destinatario: no usa el último mensaje de consola ni datos del
// jugador cero. Se añade cuando llega el primer aviso, también en saves viejos.
class CaelumNotificationInbox : Inventory
{
    const LIMIT = 20;
    int Count;
    String Text[LIMIT];
    int RemainingTics[LIMIT];
    int SurvivalCategory[LIMIT];
    String ExtractionText;
    int ExtractionRemainingTics;
    int HistoryRevision, HistoryCount;
    String HistoryText[LIMIT];
    // Revisión aditiva: importar el estado presente una vez, sin repetir avisos antiguos.
    int SurvivalRevision;
    int SurvivalStates[4];

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
            SurvivalCategory[i] = SurvivalCategory[i + 1];
        }
        Count--;
        Text[Count] = "";
        RemainingTics[Count] = 0;
        SurvivalCategory[Count] = 0;
    }

    void Add(String message, int duration)
    {
        EnsureHistory();
        Remember(message);
        if (Count == LIMIT) RemoveAt(0);
        Text[Count] = message;
        RemainingTics[Count] = duration;
        SurvivalCategory[Count] = 0;
        Count++;
    }

    void AddSurvival(int resource, String message, int duration)
    {
        // Un solo aviso vivo por recurso. Cambiar de estado actualiza el texto
        // sin renovar su reloj ni volcar oscilaciones rápidas en el historial.
        for (int i = 0; i < Count; i++)
            if (SurvivalCategory[i] == resource + 1)
            { Text[i] = message; return; }
        Add(message, duration);
        SurvivalCategory[Count - 1] = resource + 1;
    }

    override void Tick()
    {
        Super.Tick();
        EnsureHistory();
        if (ExtractionRemainingTics > 0) ExtractionRemainingTics--;
        for (int i = Count - 1; i >= 0; i--)
        {
            RemainingTics[i]--;
            if (RemainingTics[i] <= 0) RemoveAt(i);
        }
    }

    void Remember(String message)
    {
        if(HistoryCount==LIMIT)
        {for(int i=0;i<LIMIT-1;i++)HistoryText[i]=HistoryText[i+1];HistoryCount--;}
        HistoryText[HistoryCount++]=message;
    }
    void EnsureHistory()
    {
        // Revisión aditiva e idempotente: los saves previos conservan sus avisos.
        if(HistoryRevision>=1)return;
        HistoryCount=0;
        for(int i=0;i<Count;i++)Remember(Text[i]);
        HistoryRevision=1;
    }
}

class CaelumNotifications : Object
{
    static play CaelumNotificationInbox Inbox(Actor recipient)
    {
        if (recipient == null || recipient.player == null) return null;
        let inbox = CaelumNotificationInbox(recipient.FindInventory("CaelumNotificationInbox"));
        if (inbox == null)
        {
            inbox = CaelumNotificationInbox(Actor.Spawn("CaelumNotificationInbox", recipient.Pos, NO_REPLACE));
            if (inbox == null) return null;
            inbox.AttachToOwner(recipient);
        }
        return inbox;
    }

    static play int Duration(Actor recipient)
    {
        let setting = CVar.GetCVar("ca_notification_seconds", recipient.player);
        double seconds = setting == null ? 8.0 : setting.GetFloat();
        return Max(1, int(Max(0.0, seconds) * TICRATE));
    }

    static play void Notify(Actor recipient, String message)
    {
        if (message == "") return;
        let inbox = Inbox(recipient);
        if (inbox != null) inbox.Add(message, Duration(recipient));
    }

    static play void Survival(CaelumPlayer user)
    {
        if (user == null || !user.CharacterCreationComplete || user.health <= 0) return;
        let inbox = Inbox(user);
        if (inbox == null) return;
        let record = CaelumPersistentCharacterState(user.FindInventory("CaelumPersistentCharacterState"));
        let thermal = record != null ? record.ThermalState : null;
        for (int resource = 0; resource < 4; resource++)
        {
            int state = resource < 3 ? CaelumSurvivalView.State(user, resource)
                : thermal != null ? thermal.Severity * (thermal.Exposure < 0 ? -1 : 1) : 0;
            int previous = inbox.SurvivalStates[resource];
            inbox.SurvivalStates[resource] = state;
            if (inbox.SurvivalRevision < 1 || state == previous) continue;
            String key;
            if (resource == 0) key = state == 0 ? "CA_SURVIVAL_HUNGER_RECOVERED" : "CA_SURVIVAL_HUNGER_WARNING";
            else if (resource == 1) key = state == 0 ? "CA_SURVIVAL_THIRST_RECOVERED" : "CA_SURVIVAL_THIRST_WARNING";
            else if (resource == 2) key = state == 0 ? "CA_SURVIVAL_SLEEP_RECOVERED" : "CA_SURVIVAL_SLEEP_WARNING";
            else key = state == 0 ? "CA_SURVIVAL_THERMAL_RECOVERED"
                : state < 0 ? "CA_SURVIVAL_COLD_WARNING" : "CA_SURVIVAL_HEAT_WARNING";
            String message = StringTable.Localize(key, false);
            if (state != 0)
                message = StringTable.Localize(resource < 3 ? CaelumSurvivalView.StateKey(resource, state)
                    : CaelumThermalRules.StateKey(thermal.Exposure, thermal.Toughness), false) .. ": " .. message;
            inbox.AddSurvival(resource, message, Duration(user));
        }
        inbox.SurvivalRevision = 1;
    }

    static play void Extracted(Actor recipient, int material)
    {
        let inbox = Inbox(recipient);
        if (inbox == null) return;
        inbox.ExtractionText = String.Format(StringTable.Localize("CA_GATHERING_EXTRACTED", false),
            StringTable.Localize(CaelumDisplayNames.GetSpecialItemKey(
                CaelumConstants.EQUIPMENT_KIND_MATERIAL, material), false));
        inbox.ExtractionRemainingTics = Duration(recipient);
    }

    static ui void DrawExtraction(CaelumPlayer user)
    {
        if (menuactive != 0 || user.CraftingMenuOpen || user.EquipmentMenuOpen
            || user.player.ConversationNPC != null) return;
        let journal = CVar.GetCVar("ca_journal_open", user.player);
        if (journal != null && journal.GetBool()) return;
        let inbox = CaelumNotificationInbox(user.FindInventory("CaelumNotificationInbox"));
        if (inbox == null || inbox.ExtractionRemainingTics <= 0) return;
        let font = Font.GetFont("CaelumText");
        if (font == null) return;
        // Un solo aviso renovable y centrado; nunca acumula una columna sobre la mira.
        Vector2 scale=CaelumPresentation.MessageScale();
        CaelumPresentation.CenterMessage(font,Font.CR_GOLD,inbox.ExtractionText,
            Screen.GetHeight()/2-font.GetHeight()*scale.Y/2);
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
            if(kind==CaelumConstants.EQUIPMENT_KIND_CLOTHING)
                label=StringTable.Localize(CaelumClothingData.NameKey(type),false);
            else if (kind == CaelumConstants.EQUIPMENT_KIND_WEAPON)
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
            if (kind == CaelumConstants.EQUIPMENT_KIND_CLOTHING
                || kind == CaelumConstants.EQUIPMENT_KIND_WEAPON
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
            // Recetario y saco conservan su ID historico compartido; la clase
            // fisica distingue el nombre sin renumerar objetos de partidas.
            else if (item is "CaelumRecipeBook")
                label = StringTable.Localize("CA_KEY_ITEM_RECIPE_BOOK", false);
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

    static ui void DrawRestFeedback(CaelumPlayer user,Font font)
    {
        let inbox=CaelumNotificationInbox(user.FindInventory("CaelumNotificationInbox"));
        if(inbox==null || inbox.Count==0 || font==null)return;
        // El HUD oculta sus avisos durante los menús. El descanso conserva
        // visible el último resultado, debajo de sus controles y con la
        // escala de mensajes elegida; el historial sigue siendo el mismo.
        Vector2 origin,extent;
        [origin,extent]=CaelumPresentation.MenuRect((32,170),(576,1));
        Vector2 scale=CaelumPresentation.MessageScale();
        let lines=font.BreakLines(CaelumInputHints.Resolve(inbox.Text[inbox.Count-1]),
            Max(1,int((extent.X-16)/scale.X)));
        double lineHeight=(font.GetHeight()+2)*scale.Y;
        double height=lines.Count()*lineHeight+12;
        Vector2 hud=CaelumPresentation.HUDScale();
        if(origin.Y+height>Screen.GetHeight()-140*hud.Y*CaelumPresentation.RESOURCE_ENLARGEMENT)
        {
            // Con texto grande, usar temporalmente el panel de información
            // superior: no tapar los botones ni las barras de recursos.
            Vector2 above,area;
            [above,area]=CaelumPresentation.MenuRect((32,12),(576,127));
            origin.Y=Max(0,above.Y+area.Y-height);
        }
        Screen.Dim(0x080E16,1,int(origin.X),int(origin.Y),int(extent.X),int(height));
        for(int i=0;i<lines.Count();i++)
            Screen.DrawText(font,Font.CR_GOLD,origin.X+8,origin.Y+6+i*lineHeight,lines.StringAt(i),
                DTA_SCALEX,scale.X,DTA_SCALEY,scale.Y,DTA_SHADOW,true);
        lines.Destroy();
    }

    static ui void Draw(CaelumPlayer user, Font font,double minimumY=0)
    {
        if(menuactive!=Menu.Off)return;
        let inbox = CaelumNotificationInbox(user.FindInventory("CaelumNotificationInbox"));
        if (inbox == null || inbox.Count == 0 || font == null) return;
        // Escala de mensajes del motor; nunca encoger texto para llenar cupos.
        // El historial conserva las entradas que no caben en el aviso temporal.
        Vector2 scale=CaelumPresentation.MessageScale(), hud=CaelumPresentation.HUDScale();
        double x=CaelumCompass.Visible(user)?CaelumCompassLayout.NOTIFY_LEFT*CaelumCompass.Scale():16.0;
        x+=CaelumAbilityHUD.ReservedWidth(user);
        double width=Screen.GetWidth()*0.45-x;
        double top=Max(12.0,minimumY);
        if(CVar.GetCVar("con_notifytime").GetFloat()>0)
            top+=Clamp(CVar.GetCVar("con_notifylines").GetInt(),0,4)*18*scale.Y;
        double bottom=Screen.GetHeight()-140*hud.Y;
        double lineHeight=(font.GetHeight()+2)*scale.Y;
        double y=top;
        bool overflow=false;
        for(int index=inbox.Count-1;index>=0;index--)
        {
            let lines=font.BreakLines(CaelumInputHints.Resolve(inbox.Text[index]),Max(1,int(width/scale.X)));
            double needed=(lines.Count()+1)*lineHeight;
            if(y+needed>bottom)
            {overflow=true;lines.Destroy();break;}
            for(int line=0;line<lines.Count();line++)
                Screen.DrawText(font,Font.CR_WHITE,x,y+line*lineHeight,lines.StringAt(line),
                    DTA_SCALEX,scale.X,DTA_SCALEY,scale.Y,DTA_SHADOW,true);
            y+=needed;lines.Destroy();
        }
        if(overflow)
        {
            String hint=String.Format(CaelumInputHints.Resolve(StringTable.Localize("CA_MESSAGES_MORE",false)),CaelumNotificationMenu.Link());
            let lines=font.BreakLines(hint,Max(1,int(width/scale.X)));
            // Reservar el indicador completo antes de los recursos; no alterar la mira.
            if(y+lines.Count()*lineHeight<=bottom)
                for(int line=0;line<lines.Count();line++)
                    Screen.DrawText(font,Font.CR_GOLD,x,y+line*lineHeight,lines.StringAt(line),
                        DTA_SCALEX,scale.X,DTA_SCALEY,scale.Y,DTA_SHADOW,true);
            lines.Destroy();
        }
    }
}
