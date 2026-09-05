// Primera capa definitiva del Diario. La navegación es local y no duplica el
// inventario real; las acciones autoritativas se conectarán por eventos cuando
// cada sección abandone su pantalla provisional.
class CaelumJournalOverlay : EventHandler
{
    const JOURNAL_PAGE_COUNT = 6;

    Font TitleFont;
    Font TextFont;
    Font SmallFont;
    Font InventoryFont;

    override void OnRegister()
    {
        TitleFont = Font.GetFont("CaelumDisplay");
        TextFont = Font.GetFont("CaelumText");
        SmallFont = Font.GetFont("CaelumSmall");
        // El inventario comparte exactamente la métrica monoespaciada del HUD.
        InventoryFont = Font.GetFont("CaelumMono");
        SetOrder(100);
    }

    // InputProcess y ConsoleProcess pertenecen al ámbito UI. Los CVars user
    // conservan este estado en el cliente correcto sin eventos de red ni
    // escrituras sobre el EventHandler de ámbito play.
    ui bool IsJournalOpen()
    {
        if (consoleplayer < 0) { return false; }
        CVar openState = CVar.GetCVar(
            "ca_journal_open",
            players[consoleplayer]
        );
        return openState != null && openState.GetBool();
    }

    ui void SetJournalOpen(bool value)
    {
        if (consoleplayer < 0) { return; }
        CVar openState = CVar.GetCVar(
            "ca_journal_open",
            players[consoleplayer]
        );
        if (openState != null) { openState.SetBool(value); }
    }

    ui int GetJournalPage()
    {
        if (consoleplayer < 0) { return 0; }
        CVar pageState = CVar.GetCVar(
            "ca_journal_page",
            players[consoleplayer]
        );
        if (pageState == null) { return 0; }
        return Clamp(pageState.GetInt(), 0, JOURNAL_PAGE_COUNT - 1);
    }

    ui void SetJournalPage(int page)
    {
        if (consoleplayer < 0) { return; }
        CVar pageState = CVar.GetCVar(
            "ca_journal_page",
            players[consoleplayer]
        );
        if (pageState != null)
        {
            pageState.SetInt(Clamp(page, 0, JOURNAL_PAGE_COUNT - 1));
        }
    }

    ui String GetPageKey(int page)
    {
        switch (page)
        {
            case 1: return "CA_JOURNAL_CHARACTER";
            case 2: return "CA_JOURNAL_WORLD";
            case 3: return "CA_JOURNAL_CRAFTS";
            case 4: return "CA_JOURNAL_QUESTS";
            case 5: return "CA_JOURNAL_REPUTATION";
            default: return "CA_JOURNAL_INVENTORY";
        }
    }

    ui String GetPageIcon(int page)
    {
        switch (page)
        {
            case 1: return "graphics/caelum/ui/journal/icons/ca_ui_nav_character.png";
            case 2: return "graphics/caelum/ui/journal/icons/ca_ui_nav_world.png";
            case 3: return "graphics/caelum/ui/journal/icons/ca_ui_nav_crafts.png";
            case 4: return "graphics/caelum/ui/journal/icons/ca_ui_nav_quests.png";
            case 5: return "graphics/caelum/ui/journal/icons/ca_ui_nav_reputation.png";
            default: return "graphics/caelum/ui/journal/icons/ca_ui_nav_inventory.png";
        }
    }

    ui String GetInventoryCategoryIcon(int category)
    {
        switch (category)
        {
            case 1: return "ca_ui_category_weapons.png";
            case 2: return "ca_ui_category_armor.png";
            case 3: return "ca_ui_category_shields.png";
            case 4: return "ca_ui_category_accessories.png";
            case 5: return "ca_ui_category_consumables.png";
            case 6: return "ca_ui_category_materials.png";
            case 7: return "ca_ui_category_ammo.png";
            case 8: return "ca_ui_category_key_items.png";
            default: return "ca_ui_category_all.png";
        }
    }

    ui String GetInventoryFilterKey(int category)
    {
        switch (category)
        {
            case 1: return "CA_JOURNAL_FILTER_WEAPONS";
            case 2: return "CA_JOURNAL_FILTER_ARMOR";
            case 3: return "CA_JOURNAL_FILTER_SHIELDS";
            case 4: return "CA_JOURNAL_FILTER_ACCESSORIES";
            case 5: return "CA_JOURNAL_FILTER_CONSUMABLES";
            case 6: return "CA_JOURNAL_FILTER_MATERIALS";
            case 7: return "CA_JOURNAL_FILTER_AMMUNITION";
            case 8: return "CA_JOURNAL_FILTER_KEY_ITEMS";
            default: return "CA_JOURNAL_FILTER_ALL";
        }
    }

    ui String GetCraftingFilterKey(int recipeFilter)
    {
        switch (recipeFilter)
        {
            case CaelumConstants.CRAFTING_RECIPE_FILTER_PHYSICAL_WEAPON:
                return "CA_CRAFTING_FILTER_PHYSICAL_WEAPONS";
            case CaelumConstants.CRAFTING_RECIPE_FILTER_ARMOR:
                return "CA_CRAFTING_FILTER_ARMOR";
            case CaelumConstants.CRAFTING_RECIPE_FILTER_SHIELD:
                return "CA_CRAFTING_FILTER_SHIELDS";
            case CaelumConstants.CRAFTING_RECIPE_FILTER_ESSENCE_WEAPON:
                return "CA_CRAFTING_FILTER_ESSENCE_WEAPONS";
            case CaelumConstants.CRAFTING_RECIPE_FILTER_AMULET:
                return "CA_CRAFTING_FILTER_AMULETS";
            case CaelumConstants.CRAFTING_RECIPE_FILTER_SEAL:
                return "CA_CRAFTING_FILTER_SEALS";
            case CaelumConstants.CRAFTING_RECIPE_FILTER_PROCESSING:
                return "CA_CRAFTING_FILTER_PROCESSING";
            case CaelumConstants.CRAFTING_RECIPE_FILTER_COMPONENT:
                return "CA_CRAFTING_FILTER_COMPONENTS";
            default: return "CA_CRAFTING_FILTER_ALL";
        }
    }

    ui String GetCraftingActionKey(int craftingAction)
    {
        switch (craftingAction)
        {
            case CaelumConstants.CRAFTING_ACTION_CREATED:
                return "CA_CRAFTING_ACTION_CREATED";
            case CaelumConstants.CRAFTING_ACTION_FAILED_MATERIALS:
                return "CA_CRAFTING_ACTION_FAILED_MATERIALS";
            case CaelumConstants.CRAFTING_ACTION_FAILED_BOX_FULL:
                return "CA_CRAFTING_ACTION_FAILED_BOX_FULL";
            case CaelumConstants.CRAFTING_ACTION_FAILED_DUPLICATE:
                return "CA_CRAFTING_ACTION_FAILED_DUPLICATE";
            case CaelumConstants.CRAFTING_ACTION_MATERIALS_SPAWNED:
                return "CA_CRAFTING_ACTION_MATERIALS_SPAWNED";
            case CaelumConstants.CRAFTING_ACTION_FAILED_STATION:
                return "CA_CRAFTING_ACTION_FAILED_STATION";
            case CaelumConstants.CRAFTING_ACTION_FAILED_INFRASTRUCTURE:
                return "CA_CRAFTING_ACTION_FAILED_INFRASTRUCTURE";
            case CaelumConstants.CRAFTING_ACTION_FAILED_RECIPE_LOCKED:
                return "CA_CRAFTING_ACTION_FAILED_RECIPE_LOCKED";
            case CaelumConstants.CRAFTING_ACTION_PROCESSED:
                return "CA_CRAFTING_ACTION_PROCESSED";
            case CaelumConstants.CRAFTING_ACTION_TASK_STARTED:
                return "CA_CRAFTING_ACTION_TASK_STARTED";
            case CaelumConstants.CRAFTING_ACTION_TASK_CANCELLED:
                return "CA_CRAFTING_ACTION_TASK_CANCELLED";
            case CaelumConstants.CRAFTING_ACTION_FAILED_TASK_ACTIVE:
                return "CA_CRAFTING_ACTION_FAILED_TASK_ACTIVE";
            case CaelumConstants.CRAFTING_ACTION_FAILED_COMBAT:
                return "CA_CRAFTING_ACTION_FAILED_COMBAT";
            case CaelumConstants.CRAFTING_ACTION_FAILED_TARGET:
                return "CA_CRAFTING_ACTION_FAILED_TARGET";
            case CaelumConstants.CRAFTING_ACTION_REPAIRED:
                return "CA_CRAFTING_ACTION_REPAIRED";
            case CaelumConstants.CRAFTING_ACTION_DISMANTLED:
                return "CA_CRAFTING_ACTION_DISMANTLED";
            case CaelumConstants.CRAFTING_ACTION_DEBUG_TIME_ADVANCED:
                return "CA_CRAFTING_ACTION_DEBUG_TIME_ADVANCED";
            case CaelumConstants.CRAFTING_ACTION_DEBUG_TIME_BLOCKED:
                return "CA_CRAFTING_ACTION_DEBUG_TIME_BLOCKED";
            default: return "CA_CRAFTING_ACTION_NONE";
        }
    }

    ui String GetEssenceKey(int essenceType)
    {
        switch (essenceType)
        {
            case CaelumConstants.ESSENCE_WATER: return "CA_ESSENCE_WATER";
            case CaelumConstants.ESSENCE_EARTH: return "CA_ESSENCE_EARTH";
            case CaelumConstants.ESSENCE_WIND: return "CA_ESSENCE_WIND";
            case CaelumConstants.ESSENCE_QUINTESSENCE:
                return "CA_ESSENCE_QUINTESSENCE";
            default: return "CA_ESSENCE_FIRE";
        }
    }

    ui String GetEquipmentActionKey(int actionCode)
    {
        switch (actionCode)
        {
            case CaelumConstants.EQUIPMENT_ACTION_CREATED:
                return "CA_EQUIPMENT_ACTION_CREATED";
            case CaelumConstants.EQUIPMENT_ACTION_EQUIPPED:
                return "CA_EQUIPMENT_ACTION_EQUIPPED";
            case CaelumConstants.EQUIPMENT_ACTION_UNEQUIPPED:
                return "CA_EQUIPMENT_ACTION_UNEQUIPPED";
            case CaelumConstants.EQUIPMENT_ACTION_BROKEN:
                return "CA_EQUIPMENT_ACTION_BROKEN";
            case CaelumConstants.EQUIPMENT_ACTION_DROPPED:
                return "CA_EQUIPMENT_ACTION_DROPPED";
            case CaelumConstants.EQUIPMENT_ACTION_FAILED_NOT_OWNED:
                return "CA_EQUIPMENT_ACTION_FAILED_NOT_OWNED";
            case CaelumConstants.EQUIPMENT_ACTION_FAILED_SIZE:
                return "CA_EQUIPMENT_ACTION_FAILED_SIZE";
            case CaelumConstants.EQUIPMENT_ACTION_FAILED_BOX_FULL:
                return "CA_EQUIPMENT_ACTION_FAILED_BOX_FULL";
            case CaelumConstants.EQUIPMENT_ACTION_CREATED_IN_MAGIC_BOX:
                return "CA_EQUIPMENT_ACTION_CREATED_IN_MAGIC_BOX";
            case CaelumConstants.EQUIPMENT_ACTION_FAILED_CARRY_CAPACITY:
                return "CA_EQUIPMENT_ACTION_FAILED_CARRY_CAPACITY";
            case CaelumConstants.EQUIPMENT_ACTION_STORED_IN_MAGIC_BOX:
                return "CA_EQUIPMENT_ACTION_STORED_IN_MAGIC_BOX";
            case CaelumConstants.EQUIPMENT_ACTION_RETRIEVED_FROM_MAGIC_BOX:
                return "CA_EQUIPMENT_ACTION_RETRIEVED_FROM_MAGIC_BOX";
            case CaelumConstants.EQUIPMENT_ACTION_USED:
                return "CA_EQUIPMENT_ACTION_USED";
            case CaelumConstants.EQUIPMENT_ACTION_FAILED_KEY_STORAGE:
                return "CA_EQUIPMENT_ACTION_FAILED_KEY_STORAGE";
            case CaelumConstants.EQUIPMENT_ACTION_FAILED_STORAGE:
                return "CA_EQUIPMENT_ACTION_FAILED_STORAGE";
            case CaelumConstants.EQUIPMENT_ACTION_DISMANTLED:
                return "CA_EQUIPMENT_ACTION_DISMANTLED";
            case CaelumConstants.EQUIPMENT_ACTION_FAILED_EQUIPPED:
                return "CA_EQUIPMENT_ACTION_FAILED_EQUIPPED";
            case CaelumConstants.EQUIPMENT_ACTION_FAILED_DISMANTLE_UNSUPPORTED:
                return "CA_EQUIPMENT_ACTION_FAILED_DISMANTLE_UNSUPPORTED";
            case CaelumConstants.EQUIPMENT_ACTION_REPAIR_STARTED:
                return "CA_EQUIPMENT_ACTION_REPAIR_STARTED";
            case CaelumConstants.EQUIPMENT_ACTION_REPAIRED:
                return "CA_EQUIPMENT_ACTION_REPAIRED";
            case CaelumConstants.EQUIPMENT_ACTION_DISMANTLE_STARTED:
                return "CA_EQUIPMENT_ACTION_DISMANTLE_STARTED";
            case CaelumConstants.EQUIPMENT_ACTION_FAILED_CRAFTING_TASK:
                return "CA_EQUIPMENT_ACTION_FAILED_CRAFTING_TASK";
            case CaelumConstants.EQUIPMENT_ACTION_FAILED_COMBAT:
                return "CA_EQUIPMENT_ACTION_FAILED_COMBAT";
            case CaelumConstants.EQUIPMENT_ACTION_FAILED_DURABILITY:
                return "CA_EQUIPMENT_ACTION_FAILED_DURABILITY";
            case CaelumConstants.EQUIPMENT_ACTION_FAILED_INFRASTRUCTURE:
                return "CA_EQUIPMENT_ACTION_FAILED_INFRASTRUCTURE";
            case CaelumConstants.EQUIPMENT_ACTION_FAILED_RESERVED:
                return "CA_EQUIPMENT_ACTION_FAILED_RESERVED";
            default: return "CA_EQUIPMENT_ACTION_NONE";
        }
    }

    ui String FormatInventoryEntryName(
        int kind, int itemType, int armorSlot, int tier, int equipmentSize,
        int essenceType
    )
    {
        String sizeName = StringTable.Localize(
            CaelumDisplayNames.GetEquipmentSizeKey(equipmentSize), false
        );
        if (kind == CaelumConstants.EQUIPMENT_KIND_WEAPON)
        {
            String weaponName =
                CaelumDisplayNames.FormatWeaponName(itemType, tier);
            if (itemType == CaelumConstants.WEAPON_TYPE_STAFF
                || itemType == CaelumConstants.WEAPON_TYPE_BELL
                || itemType == CaelumConstants.WEAPON_TYPE_BOOK
                || itemType == CaelumConstants.WEAPON_TYPE_STATUETTE)
            {
                return String.Format(
                    "%s · %s · %s", weaponName, sizeName,
                    StringTable.Localize(GetEssenceKey(essenceType), false)
                );
            }
            return String.Format("%s · %s", weaponName, sizeName);
        }
        if (kind == CaelumConstants.EQUIPMENT_KIND_ARMOR)
        {
            return String.Format(
                "%s · %s · %s",
                CaelumDisplayNames.FormatArmorTypeName(itemType, tier),
                StringTable.Localize(
                    CaelumDisplayNames.GetArmorSlotKey(armorSlot), false
                ),
                sizeName
            );
        }
        if (kind == CaelumConstants.EQUIPMENT_KIND_SHIELD)
        {
            return String.Format(
                "%s · %s",
                CaelumDisplayNames.FormatShieldName(itemType, tier), sizeName
            );
        }
        if (kind == CaelumConstants.EQUIPMENT_KIND_AMULET)
        {
            return CaelumDisplayNames.FormatAmuletName(itemType, tier);
        }
        if (kind == CaelumConstants.EQUIPMENT_KIND_SEAL)
        {
            return CaelumDisplayNames.FormatSealName(itemType, tier);
        }
        if (kind == CaelumConstants.EQUIPMENT_KIND_CONSUMABLE)
        {
            return StringTable.Localize(
                CaelumDisplayNames.GetConsumableKey(itemType), false
            );
        }
        if (kind == CaelumConstants.EQUIPMENT_KIND_AMMUNITION)
        {
            return StringTable.Localize(
                CaelumDisplayNames.GetAmmunitionKey(itemType), false
            );
        }
        String specialName = StringTable.Localize(
            CaelumDisplayNames.GetSpecialItemKey(kind, itemType), false
        );
        if (kind == CaelumConstants.EQUIPMENT_KIND_MATERIAL && tier > 0)
        {
            return String.Format("%s · T%d", specialName, tier);
        }
        return specialName;
    }

    ui String GetWeaponNameKey(int weaponType)
    {
        return CaelumDisplayNames.GetWeaponKey(weaponType);
    }

    ui void DrawTexture(String path, double x, double y, double width,
        double height, double alpha = 1.0)
    {
        TextureID texture = TexMan.CheckForTexture(path, TexMan.Type_MiscPatch);
        if (!texture.IsValid()) { return; }
        Screen.DrawTexture(
            texture, true, x, y,
            DTA_VIRTUALWIDTHF, 640.0,
            DTA_VIRTUALHEIGHTF, 360.0,
            DTA_DESTWIDTHF, width,
            DTA_DESTHEIGHTF, height,
            DTA_ALPHA, alpha,
            DTA_KEEPRATIO, true
        );
    }

    ui void DrawTextLine(Font font, int textColor, double x, double y,
        String text)
    {
        if (font == null) { return; }
        Screen.DrawText(
            font, textColor, x, y, text,
            DTA_VIRTUALWIDTHF, 640.0,
            DTA_VIRTUALHEIGHTF, 360.0,
            DTA_KEEPRATIO, true,
            DTA_SHADOW, true
        );
    }

    ui void DrawCenteredText(Font font, int textColor, double centerX,
        double y, String text)
    {
        if (font == null) { return; }
        DrawTextLine(
            font,
            textColor,
            centerX - font.StringWidth(text) * 0.5,
            y,
            text
        );
    }

    ui void DrawPanel(double x, double y, double width, double height)
    {
        double corner = 32.0;
        String root = "graphics/caelum/ui/hud/components/";

        DrawTexture(root .. "ca_ui_panel_center.png", x + corner, y + corner,
            width - corner * 2.0, height - corner * 2.0);
        DrawTexture(root .. "ca_ui_panel_top.png", x + corner, y,
            width - corner * 2.0, corner);
        DrawTexture(root .. "ca_ui_panel_bottom.png", x + corner,
            y + height - corner, width - corner * 2.0, corner);
        DrawTexture(root .. "ca_ui_panel_left.png", x, y + corner,
            corner, height - corner * 2.0);
        DrawTexture(root .. "ca_ui_panel_right.png", x + width - corner,
            y + corner, corner, height - corner * 2.0);
        DrawTexture(root .. "ca_ui_panel_top_left.png", x, y, corner, corner);
        DrawTexture(root .. "ca_ui_panel_top_right.png", x + width - corner,
            y, corner, corner);
        DrawTexture(root .. "ca_ui_panel_bottom_left.png", x,
            y + height - corner, corner, corner);
        DrawTexture(root .. "ca_ui_panel_bottom_right.png",
            x + width - corner, y + height - corner, corner, corner);
    }

    ui void DrawNavigation()
    {
        int currentPage = GetJournalPage();
        for (int page = 0; page < JOURNAL_PAGE_COUNT; page++)
        {
            double centerX = 80.0 + page * 96.0;
            String laurel = page == currentPage
                ? "graphics/caelum/ui/journal/components/ca_ui_nav_laurel_selected.png"
                : "graphics/caelum/ui/journal/components/ca_ui_nav_laurel_normal.png";
            String frame = page == currentPage
                ? "graphics/caelum/ui/hud/components/ca_ui_icon_frame_selected.png"
                : "graphics/caelum/ui/hud/components/ca_ui_icon_frame_normal.png";
            // El laurel comparte la caja del marco y siempre se compone detrás.
            DrawTexture(laurel, centerX - 24.0, 38.0, 48.0, 48.0);
            DrawTexture(frame, centerX - 24.0, 38.0, 48.0, 48.0);
            DrawTexture(GetPageIcon(page), centerX - 14.0, 48.0, 28.0, 28.0);
            DrawCenteredText(
                SmallFont,
                page == currentPage ? Font.CR_GOLD : Font.CR_WHITE,
                centerX,
                86.0,
                StringTable.Localize(GetPageKey(page), false)
            );
        }
    }

    ui void DrawInventoryPage(CaelumPlayer localPlayer)
    {
        for (int index = 0; index < 9; index++)
        {
            DrawTexture(
                "graphics/caelum/ui/journal/icons/"
                    .. GetInventoryCategoryIcon(index),
                54.0 + index * 57.0,
                124.0,
                28.0,
                28.0,
                index == localPlayer.FormalInventoryFilter ? 1.0 : 0.35
            );
        }
        DrawTextLine(
            InventoryFont, Font.CR_GOLD, 52.0, 151.0,
            String.Format(
                "%s · %d",
                StringTable.Localize(
                    GetInventoryFilterKey(localPlayer.FormalInventoryFilter),
                    false
                ),
                localPlayer.FormalInventoryEntryCount
            )
        );

        int selectedRow = localPlayer.FormalInventorySelectionIndex
            - localPlayer.FormalInventoryVisibleStart;
        for (int row = 0;
            row < CaelumPlayer.FORMAL_INVENTORY_VISIBLE_ROWS; row++)
        {
            int kind = localPlayer.FormalInventoryRowKind[row];
            if (kind < 0) { continue; }
            String entryLabel = FormatInventoryEntryName(
                kind,
                localPlayer.FormalInventoryRowType[row],
                localPlayer.FormalInventoryRowArmorSlot[row],
                localPlayer.FormalInventoryRowTier[row],
                localPlayer.FormalInventoryRowSize[row],
                localPlayer.FormalInventoryRowEssenceType[row]
            );
            if (localPlayer.FormalInventoryRowItemId[row] > 0)
            {
                entryLabel = String.Format(
                    "%s  #%d", entryLabel,
                    localPlayer.FormalInventoryRowItemId[row]
                );
            }
            else
            {
                entryLabel = String.Format(
                    "%s  x%d", entryLabel,
                    localPlayer.FormalInventoryRowAmount[row]
                );
            }
            if (localPlayer.FormalInventoryRowEquipped[row])
            {
                entryLabel = entryLabel .. "  [E]";
            }
            if (localPlayer.FormalInventoryRowInMagicBox[row])
            {
                entryLabel = entryLabel .. "  [M]";
            }
            if (localPlayer.FormalInventoryRowReservedUnits[row] > 0)
            {
                entryLabel = String.Format(
                    "%s  [R:%d]",
                    entryLabel,
                    localPlayer.FormalInventoryRowReservedUnits[row]
                );
            }
            DrawTextLine(
                InventoryFont,
                row == selectedRow ? Font.CR_GOLD : Font.CR_WHITE,
                52.0,
                170.0 + row * 21.0,
                (row == selectedRow ? "> " : "  ") .. entryLabel
            );
        }

        if (localPlayer.FormalInventoryEntryCount <= 0)
        {
            DrawTextLine(
                InventoryFont, Font.CR_GRAY, 52.0, 190.0,
                StringTable.Localize("CA_JOURNAL_INVENTORY_EMPTY", false)
            );
        }

        DrawTextLine(InventoryFont, Font.CR_WHITE, 414.0, 170.0,
            String.Format("%s: %.3f / %.3f",
                StringTable.Localize("CA_HUD_LOAD", false),
                localPlayer.HUDCarriedWeight,
                localPlayer.HUDCarryCapacity));
        DrawTextLine(InventoryFont, Font.CR_WHITE, 414.0, 190.0,
            String.Format("%s: %d / %d",
                StringTable.Localize("CA_EQUIPMENT_MAGIC_BOX", false),
                localPlayer.MagicBoxUsedSlots,
                localPlayer.MagicBoxMaximumSlots));
        if (selectedRow >= 0
            && selectedRow < CaelumPlayer.FORMAL_INVENTORY_VISIBLE_ROWS
            && localPlayer.FormalInventoryRowKind[selectedRow] >= 0)
        {
            DrawTextLine(InventoryFont, Font.CR_WHITE, 414.0, 220.0,
                String.Format("%s: %.3f",
                    StringTable.Localize(
                        "CA_JOURNAL_INVENTORY_WEIGHT", false
                    ),
                    localPlayer.FormalInventoryRowWeight[selectedRow]));
            if (localPlayer.FormalInventoryRowMaximumDurability[selectedRow]
                > 0)
            {
                DrawTextLine(InventoryFont, Font.CR_WHITE, 414.0, 240.0,
                    String.Format("%s: %d / %d",
                        StringTable.Localize(
                            "CA_JOURNAL_INVENTORY_DURABILITY", false
                        ),
                        localPlayer.FormalInventoryRowDurability[selectedRow],
                        localPlayer.FormalInventoryRowMaximumDurability[
                            selectedRow
                        ]));
            }
        }
        DrawTextLine(
            InventoryFont,
            localPlayer.LastEquipmentAction
                    == CaelumConstants.EQUIPMENT_ACTION_NONE
                ? Font.CR_GRAY : Font.CR_GOLD,
            52.0, 298.0,
            StringTable.Localize(
                GetEquipmentActionKey(localPlayer.LastEquipmentAction), false
            )
        );
        if (localPlayer.CraftingTaskActive)
        {
            DrawTextLine(
                InventoryFont, Font.CR_CYAN, 414.0, 278.0,
                String.Format(
                    "%s: %.1f / %.1f s",
                    StringTable.Localize("CA_CRAFTING_TASK_ACTIVE", false),
                    localPlayer.CraftingTaskRemainingSeconds,
                    localPlayer.CraftingTaskTotalSeconds
                )
            );
        }
    }

    ui void DrawCharacterPage(CaelumPlayer localPlayer)
    {
        if (localPlayer.Attributes == null) { return; }
        CaelumAttributes values = localPlayer.Attributes;
        DrawTextLine(TextFont, Font.CR_WHITE, 56.0, 132.0,
            String.Format("%s: %d | %s: %d | %s: %d",
                StringTable.Localize("CA_ATTRIBUTE_STRENGTH", false), values.Strength,
                StringTable.Localize("CA_ATTRIBUTE_TOUGHNESS", false), values.Toughness,
                StringTable.Localize("CA_ATTRIBUTE_CONSTITUTION", false), values.Constitution));
        DrawTextLine(TextFont, Font.CR_WHITE, 56.0, 164.0,
            String.Format("%s: %d | %s: %d | %s: %d",
                StringTable.Localize("CA_ATTRIBUTE_AGILITY", false), values.Agility,
                StringTable.Localize("CA_ATTRIBUTE_DEXTERITY", false), values.Dexterity,
                StringTable.Localize("CA_ATTRIBUTE_RESILIENCE", false), values.Resilience));
        DrawTextLine(TextFont, Font.CR_WHITE, 56.0, 196.0,
            String.Format("%s: %d | %s: %d | %s: %d",
                StringTable.Localize("CA_ATTRIBUTE_CHARISMA", false), values.Charisma,
                StringTable.Localize("CA_ATTRIBUTE_EMPATHY", false), values.Empathy,
                StringTable.Localize("CA_ATTRIBUTE_ELOQUENCE", false), values.Eloquence));
        DrawTextLine(TextFont, Font.CR_WHITE, 56.0, 228.0,
            String.Format("%s: %d | %s: %d | %s: %d",
                StringTable.Localize("CA_ATTRIBUTE_INTELLIGENCE", false), values.Intelligence,
                StringTable.Localize("CA_ATTRIBUTE_PATIENCE", false), values.Patience,
                StringTable.Localize("CA_ATTRIBUTE_INSIGHT", false), values.Insight));
    }

    ui void DrawCraftingSummary(CaelumPlayer localPlayer)
    {
        DrawCenteredText(
            TextFont,
            Font.CR_GOLD,
            320.0,
            136.0,
            String.Format(
                "%s: %d / %d",
                StringTable.Localize("CA_CRAFTING_RECIPE_BOOK", false),
                localPlayer.CraftingKnownRecipeCount,
                CaelumConstants.CRAFTING_NETWORK_PLAYABLE_RECIPE_COUNT
            )
        );
        DrawTextLine(TextFont, Font.CR_WHITE, 84.0, 176.0,
            String.Format("%s: %d / %d",
                StringTable.Localize(
                    "CA_CRAFTING_FILTER_PHYSICAL_WEAPONS", false
                ),
                localPlayer.CraftingKnownPhysicalRecipeCount,
                CaelumConstants.CRAFTING_NETWORK_PHYSICAL_RECIPE_COUNT));
        DrawTextLine(TextFont, Font.CR_WHITE, 344.0, 176.0,
            String.Format("%s: %d / %d",
                StringTable.Localize("CA_CRAFTING_FILTER_ARMOR", false),
                localPlayer.CraftingKnownArmorRecipeCount,
                CaelumConstants.CRAFTING_NETWORK_ARMOR_RECIPE_COUNT));
        DrawTextLine(TextFont, Font.CR_WHITE, 84.0, 204.0,
            String.Format("%s: %d / %d",
                StringTable.Localize(
                    "CA_CRAFTING_FILTER_ESSENCE_WEAPONS", false
                ),
                localPlayer.CraftingKnownEssenceRecipeCount,
                CaelumConstants.CRAFTING_NETWORK_ESSENCE_RECIPE_COUNT));
        DrawTextLine(TextFont, Font.CR_WHITE, 344.0, 204.0,
            String.Format("%s: %d / %d",
                StringTable.Localize("CA_CRAFTING_FILTER_AMULETS", false),
                localPlayer.CraftingKnownAmuletRecipeCount,
                CaelumConstants.CRAFTING_NETWORK_AMULET_RECIPE_COUNT));
        DrawTextLine(TextFont, Font.CR_WHITE, 84.0, 232.0,
            String.Format("%s: %d / %d",
                StringTable.Localize("CA_CRAFTING_FILTER_SEALS", false),
                localPlayer.CraftingKnownSealRecipeCount,
                CaelumConstants.CRAFTING_NETWORK_SEAL_RECIPE_COUNT));
        DrawTextLine(TextFont, Font.CR_WHITE, 344.0, 232.0,
            String.Format("%s: %d / %d",
                StringTable.Localize("CA_CRAFTING_FILTER_SHIELDS", false),
                localPlayer.CraftingKnownShieldRecipeCount,
                CaelumConstants.CRAFTING_NETWORK_SHIELD_RECIPE_COUNT));
        DrawTextLine(TextFont, Font.CR_WHITE, 84.0, 260.0,
            String.Format("%s: %d / %d",
                StringTable.Localize(
                    "CA_CRAFTING_FILTER_PROCESSING", false
                ),
                localPlayer.CraftingKnownProcessingRecipeCount,
                CaelumConstants.CRAFTING_NETWORK_PROCESSING_RECIPE_COUNT));
        DrawTextLine(TextFont, Font.CR_WHITE, 344.0, 260.0,
            String.Format("%s: %d / %d",
                StringTable.Localize(
                    "CA_CRAFTING_FILTER_COMPONENTS", false
                ),
                localPlayer.CraftingKnownComponentRecipeCount,
                CaelumConstants.CRAFTING_NETWORK_COMPONENT_RECIPE_COUNT));
        if (localPlayer.CraftingTaskActive)
        {
            DrawCenteredText(
                SmallFont, Font.CR_CYAN, 320.0, 282.0,
                String.Format(
                    "%s: %.1f / %.1f s",
                    StringTable.Localize("CA_CRAFTING_TASK_ACTIVE", false),
                    localPlayer.CraftingTaskRemainingSeconds,
                    localPlayer.CraftingTaskTotalSeconds
                )
            );
        }
        DrawCenteredText(SmallFont, Font.CR_GRAY, 320.0,
            localPlayer.CraftingTaskActive ? 304.0 : 288.0,
            StringTable.Localize("CA_JOURNAL_CRAFTS_STATION_HELP", false));
    }

    ui String FormatCraftingRecipeName(CaelumPlayer localPlayer)
    {
        if (!localPlayer.CraftingSelectedRecipeKnown)
        {
            return StringTable.Localize("CA_CRAFTING_RECIPE_UNKNOWN", false);
        }
        if (localPlayer.CraftingSelectedRecipeKind
            == CaelumConstants.CRAFTING_RECIPE_KIND_ARMOR)
        {
            return String.Format(
                "%s · %s",
                CaelumDisplayNames.FormatArmorTypeName(
                    localPlayer.CraftingSelectedArmorType,
                    localPlayer.CraftingSelectionTier
                ),
                StringTable.Localize(
                    CaelumDisplayNames.GetArmorSlotKey(
                        localPlayer.CraftingSelectedArmorSlot
                    ),
                    false
                )
            );
        }
        if (localPlayer.CraftingSelectedRecipeKind
            == CaelumConstants.CRAFTING_RECIPE_KIND_SHIELD)
        {
            return CaelumDisplayNames.FormatShieldName(
                localPlayer.CraftingSelectedShieldType,
                localPlayer.CraftingSelectionTier
            );
        }
        if (localPlayer.CraftingSelectedRecipeKind
            == CaelumConstants.CRAFTING_RECIPE_KIND_ESSENCE_WEAPON)
        {
            return String.Format(
                "%s · %s",
                CaelumDisplayNames.FormatWeaponName(
                    localPlayer.CraftingSelectedEssenceWeaponType,
                    localPlayer.CraftingSelectionTier
                ),
                StringTable.Localize(
                    GetEssenceKey(localPlayer.CraftingSelectedEssenceType),
                    false
                )
            );
        }
        if (localPlayer.CraftingSelectedRecipeKind
            == CaelumConstants.CRAFTING_RECIPE_KIND_AMULET)
        {
            return CaelumDisplayNames.FormatAmuletName(
                localPlayer.CraftingSelectedAmuletType,
                localPlayer.CraftingSelectionTier
            );
        }
        if (localPlayer.CraftingSelectedRecipeKind
            == CaelumConstants.CRAFTING_RECIPE_KIND_SEAL)
        {
            return CaelumDisplayNames.FormatSealName(
                localPlayer.CraftingSelectedSealType,
                localPlayer.CraftingSelectionTier
            );
        }
        if (localPlayer.CraftingSelectedRecipeKind
                == CaelumConstants.CRAFTING_RECIPE_KIND_PROCESSING
            || localPlayer.CraftingSelectedRecipeKind
                == CaelumConstants.CRAFTING_RECIPE_KIND_COMPONENT)
        {
            return FormatInventoryEntryName(
                CaelumConstants.EQUIPMENT_KIND_MATERIAL,
                localPlayer.CraftingOutputMaterialType,
                -1,
                localPlayer.CraftingOutputMaterialTier,
                CaelumConstants.EQUIPMENT_SIZE_M,
                CaelumConstants.ESSENCE_FIRE
            );
        }
        return CaelumDisplayNames.FormatCatalogueWeaponName(
            localPlayer.CraftingSelectedWeapon,
            localPlayer.CraftingSelectionTier
        );
    }

    ui int GetCraftingEfficiencyPercentForIndex(int efficiencyIndex)
    {
        if (efficiencyIndex == 1)
        {
            return CaelumConstants.CRAFTING_EFFICIENCY_CAREFUL_PERCENT;
        }
        if (efficiencyIndex == 2)
        {
            return CaelumConstants.CRAFTING_EFFICIENCY_PERFECT_PERCENT;
        }
        return CaelumConstants.CRAFTING_EFFICIENCY_FAST_PERCENT;
    }

    ui String FormatCraftingBlueprintNodeName(
        CaelumPlayer localPlayer, int node
    )
    {
        if (localPlayer.CraftingBlueprintNodeKind[node]
            == CaelumConstants.CRAFTING_BLUEPRINT_NODE_FINAL)
        {
            return StringTable.Localize(
                "CA_JOURNAL_CRAFTING_FINAL_STEP", false
            );
        }
        return FormatInventoryEntryName(
            CaelumConstants.EQUIPMENT_KIND_MATERIAL,
            localPlayer.CraftingBlueprintNodeMaterialType[node],
            -1,
            localPlayer.CraftingBlueprintNodeMaterialTier[node],
            CaelumConstants.EQUIPMENT_SIZE_M,
            CaelumConstants.ESSENCE_FIRE
        );
    }

    ui void DrawCraftingBlueprint(CaelumPlayer localPlayer)
    {
        int visibleRows = 4;
        int nodeCount = localPlayer.CraftingBlueprintNodeCount;
        if (nodeCount <= 0) { return; }
        int selected = Clamp(
            localPlayer.CraftingBlueprintSelectedNode,
            0, nodeCount - 1
        );
        int visibleStart = Clamp(
            selected - 1,
            0, Max(0, nodeCount - visibleRows)
        );

        DrawTextLine(
            SmallFont, Font.CR_GRAY, 52.0, 212.0,
            String.Format(
                "%s  ·  %s %d/%d",
                StringTable.Localize(
                    "CA_JOURNAL_CRAFTING_BREAKDOWN", false
                ),
                StringTable.Localize(
                    "CA_JOURNAL_CRAFTING_SELECTED_STEP", false
                ),
                selected + 1,
                nodeCount
            )
        );

        for (int row = 0; row < visibleRows; row++)
        {
            int node = visibleStart + row;
            if (node >= nodeCount) { break; }
            int nodeKind = localPlayer.CraftingBlueprintNodeKind[node];
            String indentation = "";
            for (int depth = 0;
                depth < Min(4, localPlayer.CraftingBlueprintNodeDepth[node]);
                depth++)
            {
                indentation = indentation .. "  ";
            }
            String nodeName = FormatCraftingBlueprintNodeName(
                localPlayer, node
            );
            String nodeLine;
            if (nodeKind == CaelumConstants.CRAFTING_BLUEPRINT_NODE_RAW)
            {
                nodeLine = String.Format(
                    "%s%s %d/%d",
                    indentation,
                    nodeName,
                    localPlayer.CraftingBlueprintNodeOwnedUnits[node],
                    localPlayer.CraftingBlueprintNodeUnits[node]
                );
            }
            else
            {
                if (nodeKind
                    == CaelumConstants.CRAFTING_BLUEPRINT_NODE_FINAL)
                {
                    nodeLine = String.Format(
                        "%s%s x%d · %d%% · %d t/u · %.1f s",
                        indentation,
                        nodeName,
                        localPlayer.CraftingBlueprintNodeInputUnits[node],
                        GetCraftingEfficiencyPercentForIndex(
                            localPlayer.CraftingBlueprintNodeEfficiency[node]
                        ),
                        localPlayer.CraftingBlueprintNodeComplexityTics[node],
                        localPlayer.CraftingBlueprintNodeSeconds[node]
                    );
                }
                else
                {
                    nodeLine = String.Format(
                        "%s%s %d/%d · %d%% · %d t/u · %.1f s",
                        indentation,
                        nodeName,
                        localPlayer.CraftingBlueprintNodeOwnedUnits[node],
                        localPlayer.CraftingBlueprintNodeUnits[node],
                        GetCraftingEfficiencyPercentForIndex(
                            localPlayer.CraftingBlueprintNodeEfficiency[node]
                        ),
                        localPlayer.CraftingBlueprintNodeComplexityTics[node],
                        localPlayer.CraftingBlueprintNodeSeconds[node]
                    );
                }
            }
            bool nodeAvailable = nodeKind
                    == CaelumConstants.CRAFTING_BLUEPRINT_NODE_FINAL
                || localPlayer.CraftingBlueprintNodeExecuted[node]
                || localPlayer.CraftingBlueprintNodeOwnedUnits[node]
                    >= localPlayer.CraftingBlueprintNodeUnits[node];
            int color = node == selected
                ? Font.CR_GOLD
                : nodeAvailable ? Font.CR_GREEN : Font.CR_RED;
            DrawTextLine(
                SmallFont, color,
                52.0, 228.0 + row * 14.0,
                nodeLine
            );
        }
    }

    ui void DrawCraftsPage(CaelumPlayer localPlayer)
    {
        if (!localPlayer.CraftingMenuOpen)
        {
            DrawCraftingSummary(localPlayer);
            return;
        }

        DrawTextLine(
            SmallFont, Font.CR_GOLD, 52.0, 126.0,
            String.Format(
                "%s: %s  ·  %s: %d/%d",
                StringTable.Localize("CA_CRAFTING_FILTER", false),
                StringTable.Localize(
                    GetCraftingFilterKey(localPlayer.CraftingRecipeFilter),
                    false
                ),
                StringTable.Localize("CA_CRAFTING_RECIPE_BOOK", false),
                localPlayer.CraftingKnownRecipeCount,
                CaelumConstants.CRAFTING_NETWORK_PLAYABLE_RECIPE_COUNT
            )
        );

        DrawTexture(
            "graphics/caelum/ui/hud/components/ca_ui_icon_frame_selected.png",
            52.0, 150.0, 64.0, 64.0
        );
        if (localPlayer.CraftingPreviewIconPath.Length() > 0)
        {
            DrawTexture(
                localPlayer.CraftingPreviewIconPath,
                60.0, 158.0, 48.0, 48.0
            );
        }

        String recipeName = FormatCraftingRecipeName(localPlayer);
        DrawTextLine(
            TextFont,
            localPlayer.CraftingSelectedRecipeKnown
                ? Font.CR_WHITE : Font.CR_DARKGRAY,
            132.0, 150.0, recipeName
        );
        DrawTextLine(
            SmallFont, Font.CR_WHITE, 132.0, 174.0,
            String.Format(
                "T%d · %s · x%d · %d%%",
                localPlayer.CraftingSelectionTier,
                StringTable.Localize(
                    CaelumDisplayNames.GetEquipmentSizeKey(
                        localPlayer.CraftingSelectionSize
                    ), false
                ),
                localPlayer.CraftingProcessingBatchMultiplier,
                localPlayer.CraftingEfficiencyPercent
            )
        );
        DrawTextLine(
            SmallFont, Font.CR_CYAN, 132.0, 194.0,
            String.Format(
                "%s: %.1f s  ·  %s: %.1f s",
                StringTable.Localize("CA_JOURNAL_CRAFTING_TIME", false),
                localPlayer.CraftingPreviewSeconds,
                StringTable.Localize(
                    "CA_JOURNAL_CRAFTING_FROM_RAW", false
                ),
                localPlayer.CraftingBlueprintFullSeconds
            )
        );

        DrawCraftingBlueprint(localPlayer);
        DrawTextLine(
            SmallFont,
            localPlayer.CraftingSelectedInfrastructureAvailable
                ? Font.CR_GREEN : Font.CR_RED,
            52.0, 288.0,
            String.Format(
                "%s  ·  %s: %d  ·  %s: %d/%d",
                StringTable.Localize(
                    localPlayer.CraftingSelectedInfrastructureAvailable
                        ? "CA_CRAFTING_INFRASTRUCTURE_READY"
                        : "CA_CRAFTING_INFRASTRUCTURE_MISSING",
                    false
                ),
                StringTable.Localize(
                    "CA_JOURNAL_CRAFTING_DIRECT_STEPS", false
                ),
                localPlayer.CraftingDirectPlanStepCount,
                StringTable.Localize("CA_EQUIPMENT_MAGIC_BOX", false),
                localPlayer.MagicBoxUsedSlots,
                localPlayer.MagicBoxMaximumSlots
            )
        );

        if (localPlayer.CraftingTaskActive)
        {
            DrawTextLine(
                SmallFont,
                localPlayer.CraftingTaskProgressing
                    ? Font.CR_CYAN : Font.CR_GOLD,
                52.0, 304.0,
                String.Format(
                    "%s: %.1f/%.1f s · %s",
                    StringTable.Localize("CA_CRAFTING_TASK_ACTIVE", false),
                    localPlayer.CraftingTaskRemainingSeconds,
                    localPlayer.CraftingTaskTotalSeconds,
                    StringTable.Localize(
                        localPlayer.CraftingTaskProgressing
                            ? "CA_JOURNAL_CRAFTING_RUNNING"
                            : "CA_JOURNAL_CRAFTING_PAUSED",
                        false
                    )
                )
            );
        }
        else
        {
            bool showEquipmentAction = localPlayer.LastCraftingAction
                    == CaelumConstants.CRAFTING_ACTION_NONE
                && localPlayer.LastEquipmentAction
                    != CaelumConstants.EQUIPMENT_ACTION_NONE;
            DrawTextLine(
                SmallFont,
                !showEquipmentAction
                    && localPlayer.LastCraftingAction
                        == CaelumConstants.CRAFTING_ACTION_NONE
                    ? Font.CR_GRAY : Font.CR_GOLD,
                52.0, 304.0,
                StringTable.Localize(
                    showEquipmentAction
                        ? GetEquipmentActionKey(
                            localPlayer.LastEquipmentAction
                        )
                        : GetCraftingActionKey(
                            localPlayer.LastCraftingAction
                        ),
                    false
                )
            );
        }
    }

    ui void DrawPlannedPage(String key)
    {
        DrawCenteredText(TextFont, Font.CR_WHITE, 320.0, 174.0,
            StringTable.Localize(key, false));
        DrawCenteredText(SmallFont, Font.CR_GRAY, 320.0, 210.0,
            StringTable.Localize("CA_JOURNAL_NO_FAKE_DATA", false));
    }

    override bool InputProcess(InputEvent e)
    {
        // El slot nativo sólo conoce clases de Weapon. Caelum mantiene varias
        // instancias exactas (acabado, tier y durabilidad propios), por lo que
        // el 2 cicla sus objetos equipados antes de que Doom seleccione Pistol.
        bool slotTwo = e.KeyChar == 50 || e.KeyString ~== "2";
        if (!IsJournalOpen())
        {
            if (menuactive == 0 && slotTwo
                && (e.Type == InputEvent.Type_KeyDown
                    || e.Type == InputEvent.Type_KeyUp))
            {
                if (e.Type == InputEvent.Type_KeyDown)
                {
                    SendNetworkEvent("ca_cycle_weapon_slot_2");
                }
                return true;
            }
            return false;
        }
        if (e.Type != InputEvent.Type_KeyDown
            && e.Type != InputEvent.Type_KeyUp)
        {
            return false;
        }
        if (e.KeyScan == InputEvent.Key_Grave
            || e.KeyScan == InputEvent.Key_Pad_Start)
        {
            return false;
        }
        if (e.Type == InputEvent.Type_KeyUp) { return true; }

        int currentPage = GetJournalPage();
        CaelumPlayer localPlayer = CaelumPlayer(players[consoleplayer].mo);
        bool craftingSession = currentPage == 3
            && localPlayer != null && localPlayer.CraftingMenuOpen;

        if (e.KeyScan == InputEvent.Key_Escape
            || e.KeyScan == InputEvent.Key_Pad_B)
        {
            if (craftingSession)
            {
                SendNetworkEvent("ca_crafting_session_close");
                SendNetworkEvent("ca_journal_menu_select_sound");
            }
            SetJournalOpen(false);
        }
        else if (currentPage == 3 && craftingSession
            && (e.KeyChar == 113 || e.KeyChar == 81
                || e.KeyString ~== "q"))
        {
            SendNetworkEvent("ca_crafting_session_close");
            SendNetworkEvent("ca_journal_menu_select_sound");
            SetJournalOpen(false);
        }
        else if (currentPage == 3 && craftingSession
            && (e.KeyScan == InputEvent.Key_Tab
                || e.KeyScan == InputEvent.Key_Pad_Y))
        {
            SendNetworkEvent("ca_crafting_filter");
            SendNetworkEvent("ca_journal_menu_move_sound");
        }
        else if (currentPage != 3 && e.KeyScan == InputEvent.Key_Tab)
        {
            SetJournalOpen(false);
        }
        else if (currentPage == 0
            && (e.KeyScan == InputEvent.Key_DownArrow
                || e.KeyScan == InputEvent.Key_Pad_DPad_Down))
        {
            SendNetworkEvent("ca_inventory_next");
            SendNetworkEvent("ca_journal_menu_move_sound");
        }
        else if (currentPage == 0
            && (e.KeyScan == InputEvent.Key_UpArrow
                || e.KeyScan == InputEvent.Key_Pad_DPad_Up))
        {
            SendNetworkEvent("ca_inventory_previous");
            SendNetworkEvent("ca_journal_menu_move_sound");
        }
        else if (currentPage == 0
            && (e.KeyChar == 102 || e.KeyChar == 70
                || e.KeyScan == InputEvent.Key_Pad_Y))
        {
            SendNetworkEvent("ca_inventory_filter");
            SendNetworkEvent("ca_journal_menu_move_sound");
        }
        else if (currentPage == 0
            && (e.KeyScan == InputEvent.Key_Enter
                || e.KeyScan == InputEvent.Key_Pad_A))
        {
            SendNetworkEvent("ca_inventory_activate");
            SendNetworkEvent("ca_journal_menu_select_sound");
        }
        else if (currentPage == 0
            && (e.KeyChar == 99 || e.KeyChar == 67
                || e.KeyScan == InputEvent.Key_Pad_X))
        {
            SendNetworkEvent("ca_inventory_storage");
            SendNetworkEvent("ca_journal_menu_select_sound");
        }
        else if (currentPage == 0
            && (e.KeyChar == 100 || e.KeyChar == 68))
        {
            SendNetworkEvent("ca_inventory_drop");
            SendNetworkEvent("ca_journal_menu_select_sound");
        }
        else if (currentPage == 0
            && (e.KeyScan == InputEvent.Key_RightArrow
                || e.KeyScan == InputEvent.Key_Pad_DPad_Right))
        {
            if (localPlayer != null
                && localPlayer.FormalInventoryFilter
                    >= CaelumPlayer.FORMAL_INVENTORY_FILTER_COUNT - 1)
            {
                SetJournalPage(1);
                SendNetworkEvent("ca_journal_menu_move_sound");
            }
            else
            {
                SendNetworkEvent("ca_inventory_filter");
                SendNetworkEvent("ca_journal_menu_move_sound");
            }
        }
        else if (currentPage == 0
            && (e.KeyScan == InputEvent.Key_LeftArrow
                || e.KeyScan == InputEvent.Key_Pad_DPad_Left))
        {
            if (localPlayer != null && localPlayer.FormalInventoryFilter > 0)
            {
                SendNetworkEvent("ca_inventory_filter_previous");
                SendNetworkEvent("ca_journal_menu_move_sound");
            }
        }
        else if (currentPage == 3 && craftingSession
            && (e.KeyScan == InputEvent.Key_DownArrow
                || e.KeyScan == InputEvent.Key_Pad_DPad_Down))
        {
            SendNetworkEvent("ca_crafting_step_next");
            SendNetworkEvent("ca_journal_menu_move_sound");
        }
        else if (currentPage == 3 && craftingSession
            && (e.KeyScan == InputEvent.Key_UpArrow
                || e.KeyScan == InputEvent.Key_Pad_DPad_Up))
        {
            SendNetworkEvent("ca_crafting_step_previous");
            SendNetworkEvent("ca_journal_menu_move_sound");
        }
        else if (currentPage == 3 && craftingSession
            && (e.KeyScan == InputEvent.Key_RightArrow
                || e.KeyScan == InputEvent.Key_Pad_DPad_Right))
        {
            SendNetworkEvent("ca_crafting_recipe_next");
            SendNetworkEvent("ca_journal_menu_move_sound");
        }
        else if (currentPage == 3 && craftingSession
            && (e.KeyScan == InputEvent.Key_LeftArrow
                || e.KeyScan == InputEvent.Key_Pad_DPad_Left))
        {
            SendNetworkEvent("ca_crafting_recipe_previous");
            SendNetworkEvent("ca_journal_menu_move_sound");
        }
        else if (currentPage == 3 && craftingSession
            && (e.KeyScan == InputEvent.Key_Space
                || e.KeyScan == InputEvent.Key_Pad_X))
        {
            SendNetworkEvent("ca_crafting_tier");
            SendNetworkEvent("ca_journal_menu_move_sound");
        }
        else if (currentPage == 3 && craftingSession
            && (e.KeyChar == 114 || e.KeyChar == 82))
        {
            SendNetworkEvent("ca_crafting_size");
            SendNetworkEvent("ca_journal_menu_move_sound");
        }
        else if (currentPage == 3 && craftingSession
            && (e.KeyChar == 98 || e.KeyChar == 66))
        {
            SendNetworkEvent("ca_crafting_batch");
            SendNetworkEvent("ca_journal_menu_move_sound");
        }
        else if (currentPage == 3 && craftingSession
            && (e.KeyChar == 120 || e.KeyChar == 88))
        {
            SendNetworkEvent("ca_crafting_efficiency");
            SendNetworkEvent("ca_journal_menu_move_sound");
        }
        else if (currentPage == 3 && craftingSession
            && (e.KeyChar == 99 || e.KeyChar == 67))
        {
            SendNetworkEvent("ca_crafting_cancel_task");
            SendNetworkEvent("ca_journal_menu_select_sound");
        }
        else if (currentPage == 3 && craftingSession
            && (e.KeyChar == 116 || e.KeyChar == 84))
        {
            SendNetworkEvent("ca_debug_advance_crafting_time");
            SendNetworkEvent("ca_journal_menu_select_sound");
        }
        else if (currentPage == 3 && craftingSession
            && (e.KeyChar == 102 || e.KeyChar == 70))
        {
            SendNetworkEvent("ca_crafting_repair_selected");
            SendNetworkEvent("ca_journal_menu_select_sound");
        }
        else if (currentPage == 3 && craftingSession
            && (e.KeyChar == 100 || e.KeyChar == 68))
        {
            SendNetworkEvent("ca_crafting_dismantle_selected");
            SendNetworkEvent("ca_journal_menu_select_sound");
        }
        else if (currentPage == 3 && craftingSession
            && (e.KeyScan == InputEvent.Key_Enter
                || e.KeyScan == InputEvent.Key_Pad_A
                || e.KeyChar == 101 || e.KeyChar == 69))
        {
            SendNetworkEvent("ca_crafting_create");
            SendNetworkEvent("ca_journal_menu_select_sound");
        }
        else if (e.KeyScan == InputEvent.Key_RightArrow
            || e.KeyScan == InputEvent.Key_Pad_DPad_Right)
        {
            int nextPage = (GetJournalPage() + 1) % JOURNAL_PAGE_COUNT;
            SetJournalPage(nextPage);
            if (nextPage == 3)
            {
                SendNetworkEvent("ca_crafting_page_turn_sound");
            }
            if (nextPage == 0)
            {
                SendNetworkEvent("ca_inventory_refresh");
            }
        }
        else if (e.KeyScan == InputEvent.Key_LeftArrow
            || e.KeyScan == InputEvent.Key_Pad_DPad_Left)
        {
            int nextPage =
                (GetJournalPage() + JOURNAL_PAGE_COUNT - 1)
                    % JOURNAL_PAGE_COUNT;
            SetJournalPage(nextPage);
            if (nextPage == 3)
            {
                SendNetworkEvent("ca_crafting_page_turn_sound");
            }
            if (nextPage == 0)
            {
                SendNetworkEvent("ca_inventory_refresh");
            }
        }
        return true;
    }

    override void ConsoleProcess(ConsoleEvent e)
    {
        if (e.Name ~== "ca_journal_toggle")
        {
            bool opening = !IsJournalOpen();
            if (!opening && GetJournalPage() == 3)
            {
                SendNetworkEvent("ca_crafting_session_close");
            }
            SetJournalOpen(opening);
            if (opening) { SendNetworkEvent("ca_inventory_refresh"); }
        }
    }

    override void NetworkProcess(ConsoleEvent e)
    {
        CaelumPlayer requestingPlayer = CaelumPlayer(players[e.Player].mo);
        if (requestingPlayer == null) { return; }
        if (e.Name == "ca_inventory_refresh")
        {
            requestingPlayer.RefreshFormalInventorySnapshot();
        }
        else if (e.Name == "ca_inventory_next")
        {
            requestingPlayer.CycleFormalInventorySelection(1);
        }
        else if (e.Name == "ca_inventory_previous")
        {
            requestingPlayer.CycleFormalInventorySelection(-1);
        }
        else if (e.Name == "ca_inventory_filter")
        {
            requestingPlayer.CycleFormalInventoryFilter();
        }
        else if (e.Name == "ca_inventory_filter_previous")
        {
            requestingPlayer.CycleFormalInventoryFilter(-1);
        }
        else if (e.Name == "ca_inventory_activate")
        {
            requestingPlayer.ActivateFormalInventorySelection();
        }
        else if (e.Name == "ca_inventory_storage")
        {
            requestingPlayer.ToggleFormalInventoryStorage();
        }
        else if (e.Name == "ca_inventory_drop")
        {
            requestingPlayer.DropFormalInventorySelection();
        }
        else if (e.Name == "ca_journal_menu_move_sound")
        {
            requestingPlayer.A_StartSound(
                "caelum/ui/menu_move",
                CHAN_6,
                CHANF_LOCAL | CHANF_UI
            );
        }
        else if (e.Name == "ca_journal_menu_select_sound")
        {
            requestingPlayer.A_StartSound(
                "caelum/ui/menu_select",
                CHAN_6,
                CHANF_LOCAL | CHANF_UI
            );
        }
        else if (e.Name == "ca_crafting_page_turn_sound")
        {
            requestingPlayer.A_StartSound(
                "caelum/ui/crafting_page_turn",
                CHAN_6,
                CHANF_LOCAL | CHANF_UI
            );
        }
        else if (e.Name == "ca_crafting_session_close")
        {
            requestingPlayer.CloseCraftingStationSession();
        }
        else if (e.Name == "ca_crafting_toggle")
        {
            requestingPlayer.ToggleCraftingMenu();
        }
        else if (e.Name == "ca_crafting_recipe_next")
        {
            requestingPlayer.CycleCraftingRecipe(1);
        }
        else if (e.Name == "ca_crafting_recipe_previous")
        {
            requestingPlayer.CycleCraftingRecipe(-1);
        }
        else if (e.Name == "ca_crafting_filter")
        {
            requestingPlayer.CycleCraftingRecipeFilter();
        }
        else if (e.Name == "ca_crafting_tier")
        {
            requestingPlayer.CycleCraftingTier();
        }
        else if (e.Name == "ca_crafting_size")
        {
            requestingPlayer.CycleCraftingSize();
        }
        else if (e.Name == "ca_crafting_batch")
        {
            requestingPlayer.CycleCraftingBatch();
        }
        else if (e.Name == "ca_crafting_efficiency")
        {
            requestingPlayer.CycleCraftingEfficiency();
        }
        else if (e.Name == "ca_crafting_step_next")
        {
            requestingPlayer.CycleCraftingBlueprintSelection(1);
        }
        else if (e.Name == "ca_crafting_step_previous")
        {
            requestingPlayer.CycleCraftingBlueprintSelection(-1);
        }
        else if (e.Name == "ca_crafting_cancel_task")
        {
            requestingPlayer.CancelCraftingTask();
        }
        else if (e.Name == "ca_crafting_repair_selected")
        {
            requestingPlayer.BeginRepairSelectedEquipment();
        }
        else if (e.Name == "ca_crafting_dismantle_selected")
        {
            requestingPlayer.BeginDismantleSelectedEquipment();
        }
        else if (e.Name == "ca_crafting_create")
        {
            requestingPlayer.CraftSelectedPhysicalWeapon();
        }
        else if (e.Name == "ca_cycle_weapon_slot_2")
        {
            requestingPlayer.CycleEquippedWeaponSlot(2);
        }
    }

    override void RenderOverlay(RenderEvent event)
    {
        if (!IsJournalOpen() || consoleplayer < 0
            || TitleFont == null || TextFont == null || SmallFont == null
            || InventoryFont == null)
        {
            return;
        }
        CaelumPlayer localPlayer = CaelumPlayer(players[consoleplayer].mo);
        if (localPlayer == null) { return; }
        int currentPage = GetJournalPage();

        Screen.Dim(0x05070A, 0.92, 0, 0, Screen.GetWidth(), Screen.GetHeight());
        DrawPanel(16.0, 12.0, 608.0, 336.0);
        DrawCenteredText(TitleFont, Font.CR_GOLD, 320.0, 16.0,
            StringTable.Localize("CA_JOURNAL_TITLE", false));
        DrawNavigation();
        DrawCenteredText(TextFont, Font.CR_GOLD, 320.0, 106.0,
            StringTable.Localize(GetPageKey(currentPage), false));

        if (currentPage == 0) { DrawInventoryPage(localPlayer); }
        else if (currentPage == 1) { DrawCharacterPage(localPlayer); }
        else if (currentPage == 2) { DrawPlannedPage("CA_JOURNAL_WORLD_PENDING"); }
        else if (currentPage == 3) { DrawCraftsPage(localPlayer); }
        else if (currentPage == 4) { DrawPlannedPage("CA_JOURNAL_QUESTS_PENDING"); }
        else { DrawPlannedPage("CA_JOURNAL_REPUTATION_PENDING"); }

        DrawCenteredText(SmallFont, Font.CR_GRAY, 320.0, 322.0,
            StringTable.Localize(
                currentPage == 0
                    ? "CA_JOURNAL_INVENTORY_HELP"
                    : currentPage == 3 && localPlayer.CraftingMenuOpen
                        ? "CA_JOURNAL_CRAFTING_HELP"
                        : "CA_JOURNAL_NAVIGATION_HELP",
                false
            ));
    }
}
