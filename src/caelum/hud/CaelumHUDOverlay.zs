// CaelumHUDOverlay is the first permanent gameplay HUD component.
// It remains separate from the optional development panel so future health,
// Anima, adrenaline, and lucidity displays can be added without debug code.
class CaelumHUDOverlay : EventHandler
{
    Font HUDFont;

    // SmallFont is supplied by GZDoom and is temporary until original Caelum
    // Argenteum interface graphics and fonts are created.
    override void OnRegister()
    {
        HUDFont = Font.GetFont("SmallFont");
    }

    ui String GetActiveWeaponNameKey(int weaponType)
    {
        switch (weaponType)
        {
            case CaelumConstants.WEAPON_TYPE_SWORD: return "CA_WEAPON_TYPE_SWORD";
            case CaelumConstants.WEAPON_TYPE_STAFF: return "CA_WEAPON_TYPE_STAFF";
            case CaelumConstants.WEAPON_TYPE_CARBINE: return "CA_WEAPON_TYPE_CARBINE";
            case CaelumConstants.WEAPON_TYPE_DAGGER: return "CA_WEAPON_TYPE_DAGGER";
            case CaelumConstants.WEAPON_TYPE_HATCHET: return "CA_WEAPON_TYPE_HATCHET";
            case CaelumConstants.WEAPON_TYPE_MACHETE: return "CA_WEAPON_TYPE_MACHETE";
            case CaelumConstants.WEAPON_TYPE_JAVELIN: return "CA_WEAPON_TYPE_JAVELIN";
            case CaelumConstants.WEAPON_TYPE_AXE: return "CA_WEAPON_TYPE_AXE";
            case CaelumConstants.WEAPON_TYPE_FLAIL: return "CA_WEAPON_TYPE_FLAIL";
            case CaelumConstants.WEAPON_TYPE_SPEAR: return "CA_WEAPON_TYPE_SPEAR";
            case CaelumConstants.WEAPON_TYPE_GREATSWORD: return "CA_WEAPON_TYPE_GREATSWORD";
            case CaelumConstants.WEAPON_TYPE_WAR_AXE: return "CA_WEAPON_TYPE_WAR_AXE";
            case CaelumConstants.WEAPON_TYPE_HALBERD: return "CA_WEAPON_TYPE_HALBERD";
            case CaelumConstants.WEAPON_TYPE_GIANT_GAUNTLETS: return "CA_WEAPON_TYPE_GIANT_GAUNTLETS";
            case CaelumConstants.WEAPON_TYPE_STANDARD_BOW: return "CA_WEAPON_TYPE_STANDARD_BOW";
            case CaelumConstants.WEAPON_TYPE_LONGBOW: return "CA_WEAPON_TYPE_LONGBOW";
            case CaelumConstants.WEAPON_TYPE_CROSSBOW: return "CA_WEAPON_TYPE_CROSSBOW";
            case CaelumConstants.WEAPON_TYPE_BELL: return "CA_WEAPON_TYPE_BELL";
            case CaelumConstants.WEAPON_TYPE_BOOK: return "CA_WEAPON_TYPE_BOOK";
            case CaelumConstants.WEAPON_TYPE_STATUETTE: return "CA_WEAPON_TYPE_STATUETTE";
            default: return "CA_HUD_UNARMED";
        }
    }

    ui String GetEquipmentSizeKey(int equipmentSize)
    {
        switch (equipmentSize)
        {
            case CaelumConstants.EQUIPMENT_SIZE_XS: return "CA_EQUIPMENT_SIZE_XS";
            case CaelumConstants.EQUIPMENT_SIZE_S: return "CA_EQUIPMENT_SIZE_S";
            case CaelumConstants.EQUIPMENT_SIZE_L: return "CA_EQUIPMENT_SIZE_L";
            case CaelumConstants.EQUIPMENT_SIZE_XL: return "CA_EQUIPMENT_SIZE_XL";
            default: return "CA_EQUIPMENT_SIZE_M";
        }
    }

    ui String GetEssenceTypeKey(int essenceType)
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

    ui String GetActiveWeaponIconPath(int weaponType)
    {
        switch (weaponType)
        {
            case CaelumConstants.WEAPON_TYPE_SWORD: return "graphics/caelum/icons/ca_sword.png";
            case CaelumConstants.WEAPON_TYPE_STAFF: return "graphics/caelum/icons/ca_staff.png";
            case CaelumConstants.WEAPON_TYPE_CARBINE: return "graphics/caelum/icons/ca_carbine.png";
            case CaelumConstants.WEAPON_TYPE_DAGGER: return "graphics/caelum/icons/ca_dagger.png";
            case CaelumConstants.WEAPON_TYPE_HATCHET: return "graphics/caelum/icons/ca_hatchet.png";
            case CaelumConstants.WEAPON_TYPE_MACHETE: return "graphics/caelum/icons/ca_machete.png";
            case CaelumConstants.WEAPON_TYPE_JAVELIN: return "graphics/caelum/icons/ca_javelin.png";
            case CaelumConstants.WEAPON_TYPE_AXE: return "graphics/caelum/icons/ca_axe.png";
            case CaelumConstants.WEAPON_TYPE_FLAIL: return "graphics/caelum/icons/ca_flail.png";
            case CaelumConstants.WEAPON_TYPE_SPEAR: return "graphics/caelum/icons/ca_spear.png";
            case CaelumConstants.WEAPON_TYPE_GREATSWORD: return "graphics/caelum/icons/ca_greatsword.png";
            case CaelumConstants.WEAPON_TYPE_WAR_AXE: return "graphics/caelum/icons/ca_war_axe.png";
            case CaelumConstants.WEAPON_TYPE_HALBERD: return "graphics/caelum/icons/ca_halberd.png";
            case CaelumConstants.WEAPON_TYPE_GIANT_GAUNTLETS: return "graphics/caelum/icons/ca_giant_gauntlets.png";
            case CaelumConstants.WEAPON_TYPE_STANDARD_BOW: return "graphics/caelum/icons/ca_standard_bow.png";
            case CaelumConstants.WEAPON_TYPE_LONGBOW: return "graphics/caelum/icons/ca_longbow.png";
            case CaelumConstants.WEAPON_TYPE_CROSSBOW: return "graphics/caelum/icons/ca_crossbow.png";
            case CaelumConstants.WEAPON_TYPE_BELL: return "graphics/caelum/icons/ca_bell.png";
            case CaelumConstants.WEAPON_TYPE_BOOK: return "graphics/caelum/icons/ca_book.png";
            default: return "graphics/caelum/icons/ca_statuette.png";
        }
    }

    ui String GetActiveEssenceBadgePath(int essenceType)
    {
        switch (essenceType)
        {
            case CaelumConstants.ESSENCE_WATER: return "graphics/caelum/icons/elements/ca_element_water.png";
            case CaelumConstants.ESSENCE_EARTH: return "graphics/caelum/icons/elements/ca_element_earth.png";
            case CaelumConstants.ESSENCE_WIND: return "graphics/caelum/icons/elements/ca_element_wind.png";
            case CaelumConstants.ESSENCE_QUINTESSENCE: return "graphics/caelum/icons/elements/ca_element_quintessence.png";
            default: return "graphics/caelum/icons/elements/ca_element_fire.png";
        }
    }

    ui String GetBlockShieldSpritePath(int shieldType)
    {
        switch (shieldType)
        {
            case CaelumConstants.SHIELD_TYPE_KITE:
                return "sprites/caelum/shields/CSHKA0.png";
            case CaelumConstants.SHIELD_TYPE_TOWER:
                return "sprites/caelum/shields/CSHTA0.png";
            case CaelumConstants.SHIELD_TYPE_MAGIC:
                return "sprites/caelum/shields/CSHMA0.png";
            default:
                return "sprites/caelum/shields/CBUCA0.png";
        }
    }

    ui bool IsActiveWeaponMagical(int weaponType)
    {
        return weaponType == CaelumConstants.WEAPON_TYPE_STAFF
            || weaponType == CaelumConstants.WEAPON_TYPE_BELL
            || weaponType == CaelumConstants.WEAPON_TYPE_BOOK
            || weaponType == CaelumConstants.WEAPON_TYPE_STATUETTE;
    }

    // Presentación provisional en primera persona usando el mismo arte propio
    // del objeto. Sustituye el texto permanente de "arma activa" y mantiene
    // una sola fuente gráfica para inventario, suelo y vista del jugador.
    ui void DrawFirstPersonWeapon(CaelumPlayer localPlayer)
    {
        if (!localPlayer.HUDHasActiveWeapon) { return; }
        TextureID weaponIcon = TexMan.CheckForTexture(
            GetActiveWeaponIconPath(localPlayer.HUDActiveWeaponType),
            TexMan.Type_MiscPatch
        );
        if (!weaponIcon.IsValid()) { return; }

        Screen.DrawTexture(
            weaponIcon, true, 272.0, 232.0,
            DTA_VIRTUALWIDTHF, 640.0,
            DTA_VIRTUALHEIGHTF, 360.0,
            DTA_DESTWIDTHF, 96.0,
            DTA_DESTHEIGHTF, 96.0,
            DTA_KEEPRATIO, true
        );

        if (IsActiveWeaponMagical(localPlayer.HUDActiveWeaponType))
        {
            TextureID badge = TexMan.CheckForTexture(
                GetActiveEssenceBadgePath(localPlayer.HUDActiveWeaponEssenceType),
                TexMan.Type_MiscPatch
            );
            if (badge.IsValid())
            {
                Screen.DrawTexture(
                    badge, true, 342.0, 228.0,
                    DTA_VIRTUALWIDTHF, 640.0,
                    DTA_VIRTUALHEIGHTF, 360.0,
                    DTA_DESTWIDTHF, 24.0,
                    DTA_DESTHEIGHTF, 24.0,
                    DTA_KEEPRATIO, true
                );
            }
        }
    }

    // Capa modular provisional para comunicar visualmente Block. Cada escudo
    // conserva una silueta/ocupacion distinta sin duplicar armas o personajes.
    ui void DrawFirstPersonBlockShield(CaelumPlayer localPlayer)
    {
        if (!localPlayer.HUDCombatBlockActive) { return; }

        String blockSpritePath = localPlayer.HUDCombatBlockUsesGauntlets
            ? "graphics/caelum/icons/ca_giant_gauntlets.png"
            : GetBlockShieldSpritePath(localPlayer.HUDActiveShieldType);
        TextureID shieldSprite = TexMan.CheckForTexture(
            blockSpritePath,
            TexMan.Type_MiscPatch
        );
        if (!shieldSprite.IsValid()) { return; }

        // Los cuatro tipos comparten el encuadre medio del escudo cometa:
        // desplazado a la izquierda, sin tamaño extremo ni centro de pantalla.
        double drawX = 90.0;
        double drawY = 125.0;
        double drawWidth = 210.0;
        double drawHeight = 230.0;

        if (localPlayer.HUDActiveShieldType
            == CaelumConstants.SHIELD_TYPE_MAGIC)
        {
            // Halo tenue adicional para distinguir el bloqueo mágico sin
            // requerir todavía un asset de efecto separado.
            Screen.DrawTexture(
                shieldSprite, true, 80.0, 115.0,
                DTA_VIRTUALWIDTHF, 640.0,
                DTA_VIRTUALHEIGHTF, 360.0,
                DTA_DESTWIDTHF, 230.0,
                DTA_DESTHEIGHTF, 250.0,
                DTA_ALPHA, 0.20,
                DTA_KEEPRATIO, true
            );
        }

        Screen.DrawTexture(
            shieldSprite, true, drawX, drawY,
            DTA_VIRTUALWIDTHF, 640.0,
            DTA_VIRTUALHEIGHTF, 360.0,
            DTA_DESTWIDTHF, drawWidth,
            DTA_DESTHEIGHTF, drawHeight,
            DTA_KEEPRATIO, true
        );
    }

    // Convert the stored play-scope state into a localized UI label.
    ui String GetAirStateKey(int airState)
    {
        if (airState == CaelumConstants.AIR_STATE_BREATHLESS)
        {
            return "CA_AIR_STATE_BREATHLESS";
        }

        if (airState == CaelumConstants.AIR_STATE_TIRED)
        {
            return "CA_AIR_STATE_TIRED";
        }

        return "CA_AIR_STATE_NORMAL";
    }

    // Match the visible color to the confirmed air thresholds.
    ui int GetAirColor(int airState)
    {
        if (airState == CaelumConstants.AIR_STATE_BREATHLESS)
        {
            return Font.CR_RED;
        }

        if (airState == CaelumConstants.AIR_STATE_TIRED)
        {
            return Font.CR_GOLD;
        }

        return Font.CR_LIGHTBLUE;
    }

    // Return an RGB color for the filled part of the bar. Screen.Dim draws a
    // solid rectangle, so no external image or copyrighted HUD art is needed.
    ui int GetAirBarColor(int airState)
    {
        if (airState == CaelumConstants.AIR_STATE_BREATHLESS)
        {
            return 0xB52A2A;
        }

        if (airState == CaelumConstants.AIR_STATE_TIRED)
        {
            return 0xD39A22;
        }

        return 0x3FAFD2;
    }

    ui String GetLucidityStateKey(int lucidityState)
    {
        if (lucidityState == CaelumConstants.LUCIDITY_STATE_STUNNED)
        {
            return "CA_LUCIDITY_STATE_STUNNED";
        }

        if (lucidityState == CaelumConstants.LUCIDITY_STATE_DIZZY)
        {
            return "CA_LUCIDITY_STATE_DIZZY";
        }

        return "CA_LUCIDITY_STATE_NORMAL";
    }

    ui int GetLucidityColor(int lucidityState)
    {
        if (lucidityState == CaelumConstants.LUCIDITY_STATE_STUNNED)
        {
            return Font.CR_RED;
        }

        if (lucidityState == CaelumConstants.LUCIDITY_STATE_DIZZY)
        {
            return Font.CR_GOLD;
        }

        return Font.CR_CYAN;
    }

    ui String GetSurvivalStateKey(int resourceType, int state)
    {
        if (state == CaelumConstants.SURVIVAL_STATE_NORMAL)
        {
            return "CA_SURVIVAL_STATE_NORMAL";
        }
        if (resourceType == 0)
        {
            return state == CaelumConstants.SURVIVAL_STATE_CRITICAL
                ? "CA_HUNGER_STATE_CRITICAL" : "CA_HUNGER_STATE_LOW";
        }
        if (resourceType == 1)
        {
            return state == CaelumConstants.SURVIVAL_STATE_CRITICAL
                ? "CA_THIRST_STATE_CRITICAL" : "CA_THIRST_STATE_LOW";
        }
        return state == CaelumConstants.SURVIVAL_STATE_CRITICAL
            ? "CA_SLEEP_STATE_CRITICAL" : "CA_SLEEP_STATE_LOW";
    }

    ui int GetSurvivalColor(int state)
    {
        if (state == CaelumConstants.SURVIVAL_STATE_CRITICAL) return Font.CR_RED;
        if (state == CaelumConstants.SURVIVAL_STATE_LOW) return Font.CR_GOLD;
        return Font.CR_GREEN;
    }

    ui String GetHealthStateKey(int state)
    {
        if (state == CaelumConstants.HEALTH_STATE_BADLY_WOUNDED)
        {
            return "CA_HEALTH_STATE_BADLY_WOUNDED";
        }
        if (state == CaelumConstants.HEALTH_STATE_WOUNDED)
        {
            return "CA_HEALTH_STATE_WOUNDED";
        }
        return "CA_HEALTH_STATE_NORMAL";
    }

    ui int GetHealthTextColor(int state)
    {
        if (state == CaelumConstants.HEALTH_STATE_BADLY_WOUNDED) return Font.CR_RED;
        if (state == CaelumConstants.HEALTH_STATE_WOUNDED) return Font.CR_GOLD;
        return Font.CR_GREEN;
    }

    ui int BlendRGB(int firstColor, int secondColor, double amount)
    {
        amount = Clamp(amount, 0.0, 1.0);
        int firstRed = (firstColor >> 16) & 255;
        int firstGreen = (firstColor >> 8) & 255;
        int firstBlue = firstColor & 255;
        int secondRed = (secondColor >> 16) & 255;
        int secondGreen = (secondColor >> 8) & 255;
        int secondBlue = secondColor & 255;
        int red = int(firstRed + (secondRed - firstRed) * amount);
        int green = int(firstGreen + (secondGreen - firstGreen) * amount);
        int blue = int(firstBlue + (secondBlue - firstBlue) * amount);
        return (red << 16) | (green << 8) | blue;
    }

    ui int GetHealthBarColor(double ratio)
    {
        if (ratio <= 0.10) return 0xC43B3B;
        if (ratio <= 0.50)
        {
            return BlendRGB(0xC43B3B, 0xD49A28, (ratio - 0.10) / 0.40);
        }
        return BlendRGB(0xD49A28, 0x3FAE55, (ratio - 0.50) / 0.50);
    }

    // Screen.Dim uses real screen pixels. This conversion reproduces the same
    // centered 640x360 canvas used by the localized text on any aspect ratio.
    ui void DrawAirBar(CaelumPlayer localPlayer)
    {
        double scale = Min(
            Screen.GetWidth() / 640.0,
            Screen.GetHeight() / 360.0
        );
        double canvasWidth = 640.0 * scale;
        double canvasHeight = 360.0 * scale;
        double offsetX = (Screen.GetWidth() - canvasWidth) * 0.5;
        double offsetY = (Screen.GetHeight() - canvasHeight) * 0.5;

        int barX = int(offsetX + 20.0 * scale);
        int barY = int(offsetY + 326.0 * scale);
        int barWidth = Max(1, int(180.0 * scale));
        int barHeight = Max(1, int(7.0 * scale));
        // Read stored fields directly. Calling a play-scope function such as
        // GetAirRatio from this UI context is forbidden by ZScript.
        double ratio = 0.0;

        if (localPlayer.DerivedStats.MaximumAir > 0.0)
        {
            ratio = Clamp(
                localPlayer.CurrentAir / localPlayer.DerivedStats.MaximumAir,
                0.0,
                1.0
            );
        }
        int fillWidth = int(barWidth * ratio);

        // The dark outer rectangle acts as a background and thin border.
        Screen.Dim(0x101820, 0.85, barX, barY, barWidth, barHeight);

        if (fillWidth > 0)
        {
            Screen.Dim(
                GetAirBarColor(localPlayer.AirState),
                0.95,
                barX,
                barY,
                fillWidth,
                barHeight
            );
        }
    }

    // Health uses GZDoom's inherited current value and Caelum's Constitution-
    // based maximum. It sits above air so both resources remain readable.
    ui void DrawHealthBar(CaelumPlayer localPlayer)
    {
        double scale = Min(
            Screen.GetWidth() / 640.0,
            Screen.GetHeight() / 360.0
        );
        double canvasWidth = 640.0 * scale;
        double canvasHeight = 360.0 * scale;
        double offsetX = (Screen.GetWidth() - canvasWidth) * 0.5;
        double offsetY = (Screen.GetHeight() - canvasHeight) * 0.5;

        int barX = int(offsetX + 20.0 * scale);
        int barY = int(offsetY + 302.0 * scale);
        int barWidth = Max(1, int(180.0 * scale));
        int barHeight = Max(1, int(7.0 * scale));
        double ratio = 0.0;

        if (localPlayer.CaelumMaximumHealth > 0)
        {
            ratio = Clamp(
                double(localPlayer.health) / localPlayer.CaelumMaximumHealth,
                0.0,
                1.0
            );
        }

        int fillWidth = int(barWidth * ratio);
        Screen.Dim(0x201010, 0.85, barX, barY, barWidth, barHeight);

        if (fillWidth > 0)
        {
            Screen.Dim(GetHealthBarColor(ratio), 0.95, barX, barY, fillWidth, barHeight);
        }
    }

    // Anima uses a violet bar above health. Like the other resource graphics,
    // it is drawn through code and requires no copyrighted interface artwork.
    ui void DrawAnimaBar(CaelumPlayer localPlayer)
    {
        double scale = Min(
            Screen.GetWidth() / 640.0,
            Screen.GetHeight() / 360.0
        );
        double canvasWidth = 640.0 * scale;
        double canvasHeight = 360.0 * scale;
        double offsetX = (Screen.GetWidth() - canvasWidth) * 0.5;
        double offsetY = (Screen.GetHeight() - canvasHeight) * 0.5;

        int barX = int(offsetX + 20.0 * scale);
        int barY = int(offsetY + 278.0 * scale);
        int barWidth = Max(1, int(180.0 * scale));
        int barHeight = Max(1, int(7.0 * scale));
        double ratio = 0.0;

        if (localPlayer.DerivedStats.MaximumAnima > 0.0)
        {
            ratio = Clamp(
                localPlayer.CurrentAnima / localPlayer.DerivedStats.MaximumAnima,
                0.0,
                1.0
            );
        }

        int fillWidth = int(barWidth * ratio);
        Screen.Dim(0x181020, 0.85, barX, barY, barWidth, barHeight);

        if (fillWidth > 0)
        {
            Screen.Dim(0x8C4FC4, 0.95, barX, barY, fillWidth, barHeight);
        }
    }

    // Adrenaline is shown in gold above the other resources. The stored combat
    // timer is displayed in text so its confirmed thirty-second delay is easy
    // to verify without opening the development panel.
    ui void DrawAdrenalineBar(CaelumPlayer localPlayer)
    {
        double scale = Min(
            Screen.GetWidth() / 640.0,
            Screen.GetHeight() / 360.0
        );
        double canvasWidth = 640.0 * scale;
        double canvasHeight = 360.0 * scale;
        double offsetX = (Screen.GetWidth() - canvasWidth) * 0.5;
        double offsetY = (Screen.GetHeight() - canvasHeight) * 0.5;

        int barX = int(offsetX + 20.0 * scale);
        int barY = int(offsetY + 254.0 * scale);
        int barWidth = Max(1, int(180.0 * scale));
        int barHeight = Max(1, int(7.0 * scale));
        double ratio = 0.0;

        if (localPlayer.DerivedStats.MaximumAdrenaline > 0.0)
        {
            ratio = Clamp(
                localPlayer.CurrentAdrenaline
                    / localPlayer.DerivedStats.MaximumAdrenaline,
                0.0,
                1.0
            );
        }

        int fillWidth = int(barWidth * ratio);
        Screen.Dim(0x201A0C, 0.85, barX, barY, barWidth, barHeight);

        if (fillWidth > 0)
        {
            Screen.Dim(0xD49A28, 0.95, barX, barY, fillWidth, barHeight);
        }
    }

    // Lucidity is cyan while clear, gold while dizzy, and red while stunned.
    // It is placed above adrenaline to keep every live resource in one stack.
    ui void DrawLucidityBar(CaelumPlayer localPlayer)
    {
        double scale = Min(Screen.GetWidth() / 640.0, Screen.GetHeight() / 360.0);
        double canvasWidth = 640.0 * scale;
        double canvasHeight = 360.0 * scale;
        double offsetX = (Screen.GetWidth() - canvasWidth) * 0.5;
        double offsetY = (Screen.GetHeight() - canvasHeight) * 0.5;
        int barX = int(offsetX + 20.0 * scale);
        int barY = int(offsetY + 230.0 * scale);
        int barWidth = Max(1, int(180.0 * scale));
        int barHeight = Max(1, int(7.0 * scale));
        double ratio = Clamp(
            localPlayer.CurrentLucidity / CaelumConstants.MAXIMUM_LUCIDITY,
            0.0,
            1.0
        );
        int fillWidth = int(barWidth * ratio);
        int fillColor = 0x41B9C7;

        if (localPlayer.LucidityState == CaelumConstants.LUCIDITY_STATE_STUNNED)
        {
            fillColor = 0xC43B3B;
        }
        else if (localPlayer.LucidityState == CaelumConstants.LUCIDITY_STATE_DIZZY)
        {
            fillColor = 0xD49A28;
        }

        Screen.Dim(0x102022, 0.85, barX, barY, barWidth, barHeight);

        if (fillWidth > 0)
        {
            Screen.Dim(fillColor, 0.95, barX, barY, fillWidth, barHeight);
        }
    }

    // Survival resources use a separate lower-right stack so the growing HUD
    // remains readable instead of extending too far up the left side.
    ui void DrawSurvivalBar(double value, int state, int virtualY, int baseColor)
    {
        double scale = Min(Screen.GetWidth() / 640.0, Screen.GetHeight() / 360.0);
        double offsetX = (Screen.GetWidth() - 640.0 * scale) * 0.5;
        double offsetY = (Screen.GetHeight() - 360.0 * scale) * 0.5;
        int x = int(offsetX + 440.0 * scale);
        int y = int(offsetY + virtualY * scale);
        int width = Max(1, int(180.0 * scale));
        int height = Max(1, int(7.0 * scale));
        int fill = int(width * Clamp(value / 100.0, 0.0, 1.0));
        // "color" is a built-in ZScript type, so the variable needs a more
        // specific name to remain compatible with GZDoom 4.14.2's parser.
        int barColor = baseColor;

        // Keep each resource identifiable in critical states by using a
        // hand-tuned mixture of its base hue with gold or red.
        if (baseColor == 0x75A84A)
        {
            if (state == CaelumConstants.SURVIVAL_STATE_LOW) barColor = 0xA5A139;
            if (state == CaelumConstants.SURVIVAL_STATE_CRITICAL) barColor = 0x9D5643;
        }
        else if (baseColor == 0x3F9FD2)
        {
            if (state == CaelumConstants.SURVIVAL_STATE_LOW) barColor = 0x8A9D7D;
            if (state == CaelumConstants.SURVIVAL_STATE_CRITICAL) barColor = 0x826D87;
        }
        else
        {
            if (state == CaelumConstants.SURVIVAL_STATE_LOW) barColor = 0xAA876F;
            if (state == CaelumConstants.SURVIVAL_STATE_CRITICAL) barColor = 0xA55882;
        }
        Screen.Dim(0x161616, 0.85, x, y, width, height);
        if (fill > 0) Screen.Dim(barColor, 0.95, x, y, fill, height);
    }

    // La carga comparte la columna de supervivencia. El color avanza desde
    // verde hasta rojo al acercarse y superar la capacidad máxima.
    ui void DrawLoadBar(CaelumPlayer localPlayer, int virtualY)
    {
        double scale = Min(Screen.GetWidth() / 640.0, Screen.GetHeight() / 360.0);
        double offsetX = (Screen.GetWidth() - 640.0 * scale) * 0.5;
        double offsetY = (Screen.GetHeight() - 360.0 * scale) * 0.5;
        int x = int(offsetX + 440.0 * scale);
        int y = int(offsetY + virtualY * scale);
        int width = Max(1, int(180.0 * scale));
        int height = Max(1, int(7.0 * scale));
        double ratio = localPlayer.HUDLoadRatio;
        int fill = int(width * Clamp(ratio, 0.0, 1.0));
        int barColor = 0x55B86A;
        if (ratio >= 1.0) barColor = 0xC34B4B;
        else if (ratio >= CaelumConstants.OVERLOAD_THRESHOLD) barColor = 0xD28B35;
        else if (ratio >= 0.50) barColor = 0xB7B547;
        Screen.Dim(0x161616, 0.85, x, y, width, height);
        if (fill > 0) Screen.Dim(barColor, 0.95, x, y, fill, height);
    }

    // A restrained full-screen tint plus opposed color bands represents the
    // documented dizzy visual distortion without depending on temporary art.
    // HUD text is drawn afterward and therefore stays crisp and readable.
    ui void DrawLucidityDistortion(CaelumPlayer localPlayer)
    {
        if (localPlayer.LucidityState == CaelumConstants.LUCIDITY_STATE_NORMAL)
        {
            return;
        }

        double strength = localPlayer.LucidityState
            == CaelumConstants.LUCIDITY_STATE_STUNNED ? 0.13 : 0.08;
        int width = Screen.GetWidth();
        int height = Screen.GetHeight();
        int bandWidth = Max(1, int(width * 0.055));
        Screen.Dim(0x6E547D, strength, 0, 0, width, height);
        Screen.Dim(0x3E88A8, strength * 0.75, 0, 0, bandWidth, height);
        Screen.Dim(0xA45A62, strength * 0.75, width - bandWidth, 0, bandWidth, height);
    }

    // RenderOverlay draws only client-side information and never changes the
    // gameplay resource. A 640x360 virtual canvas keeps the placement stable
    // on Damian's 1920x1080 display and other aspect ratios.
    override void RenderOverlay(RenderEvent event)
    {
        if (HUDFont == null || consoleplayer < 0)
        {
            return;
        }

        CaelumPlayer localPlayer = CaelumPlayer(players[consoleplayer].mo);

        if (localPlayer == null
            || localPlayer.player == null
            || localPlayer.player.playerstate != PST_LIVE
            || localPlayer.DerivedStats == null)
        {
            return;
        }

        String stateLabel = StringTable.Localize(
            GetAirStateKey(localPlayer.AirState),
            false
        );
        String airLine = String.Format(
            "%s: %.0f / %.0f  (%s)",
            StringTable.Localize("CA_HUD_AIR", false),
            localPlayer.CurrentAir,
            localPlayer.DerivedStats.MaximumAir,
            stateLabel
        );
        String healthLine = String.Format(
            "%s: %d / %d  (%s)",
            StringTable.Localize("CA_HUD_HEALTH", false),
            Max(0, localPlayer.health),
            localPlayer.CaelumMaximumHealth,
            StringTable.Localize(GetHealthStateKey(localPlayer.HealthState), false)
        );
        String animaLine = String.Format(
            "%s: %.0f / %.0f",
            StringTable.Localize("CA_HUD_ANIMA", false),
            localPlayer.CurrentAnima,
            localPlayer.DerivedStats.MaximumAnima
        );
        String adrenalineLine = String.Format(
            "%s: %.0f / %.0f  (%s: %.1fs)",
            StringTable.Localize("CA_HUD_ADRENALINE", false),
            localPlayer.CurrentAdrenaline,
            localPlayer.DerivedStats.MaximumAdrenaline,
            StringTable.Localize("CA_RESOURCE_COMBAT_TIME", false),
            localPlayer.CombatTimeRemaining
        );
        String lucidityLine = String.Format(
            "%s: %.0f / %.0f  (%s)",
            StringTable.Localize("CA_HUD_LUCIDITY", false),
            localPlayer.CurrentLucidity,
            CaelumConstants.MAXIMUM_LUCIDITY,
            StringTable.Localize(
                GetLucidityStateKey(localPlayer.LucidityState),
                false
            )
        );
        if (localPlayer.LucidityPhysicalStunRemaining > 0.0)
        {
            lucidityLine.AppendFormat(
                "  %s: %.1fs",
                StringTable.Localize("CA_RESOURCE_LUCIDITY_STUN_TIME", false),
                localPlayer.LucidityPhysicalStunRemaining
            );
        }
        String hungerLine = String.Format("%s: %.0f%% (%s)",
            StringTable.Localize("CA_HUD_HUNGER", false), localPlayer.CurrentHunger,
            StringTable.Localize(GetSurvivalStateKey(0, localPlayer.HungerState), false));
        String thirstLine = String.Format("%s: %.0f%% (%s)",
            StringTable.Localize("CA_HUD_THIRST", false), localPlayer.CurrentThirst,
            StringTable.Localize(GetSurvivalStateKey(1, localPlayer.ThirstState), false));
        String sleepLine = String.Format("%s: %.0f%% (%s)",
            StringTable.Localize("CA_HUD_SLEEP", false), localPlayer.CurrentSleep,
            StringTable.Localize(GetSurvivalStateKey(2, localPlayer.SleepState), false));
        double loadPercent = localPlayer.HUDLoadRatio * 100.0;
        String loadStateKey = "CA_LOAD_NORMAL";
        if (localPlayer.HUDLoadRatio >= 1.0)
        {
            loadStateKey = "CA_LOAD_CAPACITY_EXCEEDED";
        }
        else if (localPlayer.HUDLoadRatio >= CaelumConstants.OVERLOAD_THRESHOLD)
        {
            loadStateKey = "CA_LOAD_OVERLOAD";
        }
        String loadLine = String.Format("%s: %.3f / %.3f (%.1f%%, %s)",
            StringTable.Localize("CA_HUD_LOAD", false),
            localPlayer.HUDCarriedWeight,
            localPlayer.HUDCarryCapacity,
            loadPercent,
            StringTable.Localize(loadStateKey, false));
        String activeWeaponName = StringTable.Localize(
            localPlayer.HUDHasActiveWeapon
                ? GetActiveWeaponNameKey(localPlayer.HUDActiveWeaponType)
                : "CA_HUD_UNARMED",
            false
        );
        String activeWeaponLine;
        if (localPlayer.HUDHasActiveWeapon)
        {
            bool magicalWeapon =
                localPlayer.HUDActiveWeaponType
                    == CaelumConstants.WEAPON_TYPE_STAFF
                || localPlayer.HUDActiveWeaponType
                    == CaelumConstants.WEAPON_TYPE_BELL
                || localPlayer.HUDActiveWeaponType
                    == CaelumConstants.WEAPON_TYPE_BOOK
                || localPlayer.HUDActiveWeaponType
                    == CaelumConstants.WEAPON_TYPE_STATUETTE;
            if (magicalWeapon)
            {
                activeWeaponLine = String.Format(
                    "%s: %s | %s | T%d | %s",
                    StringTable.Localize("CA_HUD_ACTIVE_WEAPON", false),
                    activeWeaponName,
                    StringTable.Localize(GetEssenceTypeKey(
                        localPlayer.HUDActiveWeaponEssenceType
                    ), false),
                    localPlayer.HUDActiveWeaponTier,
                    StringTable.Localize(
                        GetEquipmentSizeKey(localPlayer.HUDActiveWeaponSize),
                        false
                    )
                );
            }
            else
            {
                activeWeaponLine = String.Format(
                    "%s: %s | T%d | %s",
                    StringTable.Localize("CA_HUD_ACTIVE_WEAPON", false),
                    activeWeaponName,
                    localPlayer.HUDActiveWeaponTier,
                    StringTable.Localize(
                        GetEquipmentSizeKey(localPlayer.HUDActiveWeaponSize),
                        false
                    )
                );
            }
        }
        else
        {
            activeWeaponLine = String.Format(
                "%s: %s",
                StringTable.Localize("CA_HUD_ACTIVE_WEAPON", false),
                activeWeaponName
            );
        }

        DrawLucidityDistortion(localPlayer);
        DrawLucidityBar(localPlayer);
        DrawAdrenalineBar(localPlayer);
        DrawAnimaBar(localPlayer);
        DrawHealthBar(localPlayer);
        DrawAirBar(localPlayer);
        DrawLoadBar(localPlayer, 254);
        DrawSurvivalBar(localPlayer.CurrentHunger, localPlayer.HungerState, 278, 0x75A84A);
        DrawSurvivalBar(localPlayer.CurrentThirst, localPlayer.ThirstState, 302, 0x3F9FD2);
        DrawSurvivalBar(localPlayer.CurrentSleep, localPlayer.SleepState, 326, 0x8074C8);

        DrawFirstPersonWeapon(localPlayer);
        DrawFirstPersonBlockShield(localPlayer);

        if (localPlayer.HUDAbilitySuccessRemaining > 0.0)
        {
            String abilityMessage = StringTable.Localize(
                "CA_ABILITY_USED_SUCCESSFULLY", false
            );
            double abilityX = 320.0
                - HUDFont.StringWidth(abilityMessage) * 0.5;
            Screen.DrawText(
                HUDFont, Font.CR_GREEN, abilityX, 72.0, abilityMessage,
                DTA_VIRTUALWIDTHF, 640.0,
                DTA_VIRTUALHEIGHTF, 360.0,
                DTA_KEEPRATIO, true
            );
        }

        if (localPlayer.HUDHasActiveWeapon
            && localPlayer.HUDActiveWeaponIsRanged)
        {
            String magazineLine = String.Format(
                "%s: %d / %d  |  %s: %d%s",
                StringTable.Localize("CA_HUD_MAGAZINE", false),
                localPlayer.HUDRangedMagazineCount,
                localPlayer.HUDRangedMagazineCapacity,
                StringTable.Localize("CA_HUD_RESERVE", false),
                localPlayer.HUDRangedReserveCount,
                localPlayer.RangedReloadActive
                    ? String.Format("  |  %s %.1fs",
                        StringTable.Localize("CA_HUD_RELOADING", false),
                        localPlayer.RangedReloadRemainingSeconds)
                    : ""
            );
            double magazineX = 320.0
                - HUDFont.StringWidth(magazineLine) * 0.5;
            Screen.DrawText(
                HUDFont, Font.CR_WHITE, magazineX, 326.0, magazineLine,
                DTA_VIRTUALWIDTHF, 640.0,
                DTA_VIRTUALHEIGHTF, 360.0,
                DTA_KEEPRATIO, true
            );
        }
        else if (localPlayer.WeaponChargeActive
            || localPlayer.WeaponChargedStateActive)
        {
            String chargeLine;
            int chargeColor = Font.CR_GOLD;
            if (localPlayer.WeaponChargeActive)
            {
                chargeLine = String.Format(
                    "%s: %.1fs",
                    StringTable.Localize("CA_HUD_CHARGING", false),
                    localPlayer.WeaponChargeRemainingSeconds
                );
            }
            else
            {
                chargeLine = String.Format(
                    "%s: %.1fs",
                    StringTable.Localize("CA_HUD_CHARGED", false),
                    localPlayer.WeaponChargedRemainingSeconds
                );
                chargeColor = Font.CR_GREEN;
            }
            double chargeX = 320.0
                - HUDFont.StringWidth(chargeLine) * 0.5;
            Screen.DrawText(
                HUDFont, chargeColor, chargeX, 326.0, chargeLine,
                DTA_VIRTUALWIDTHF, 640.0,
                DTA_VIRTUALHEIGHTF, 360.0,
                DTA_KEEPRATIO, true
            );
        }

        // Al cambiar de familia, el texto aparece solo de forma breve.
        // La identificación permanente ahora recae en el arma visible.
        if (localPlayer.HUDActiveWeaponNoticeRemaining > 0.0)
        {
            double noticeX = 320.0
                - HUDFont.StringWidth(activeWeaponLine) * 0.5;
            Screen.DrawText(
                HUDFont, Font.CR_GOLD, noticeX, 48.0, activeWeaponLine,
                DTA_VIRTUALWIDTHF, 640.0,
                DTA_VIRTUALHEIGHTF, 360.0,
                DTA_KEEPRATIO, true
            );
        }

        Screen.DrawText(HUDFont, Font.CR_WHITE, 440.0, 266.0,
            loadLine, DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0,
            DTA_KEEPRATIO, true);

        Screen.DrawText(HUDFont, GetSurvivalColor(localPlayer.HungerState), 440.0, 290.0,
            hungerLine, DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
        Screen.DrawText(HUDFont, GetSurvivalColor(localPlayer.ThirstState), 440.0, 314.0,
            thirstLine, DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
        Screen.DrawText(HUDFont, GetSurvivalColor(localPlayer.SleepState), 440.0, 338.0,
            sleepLine, DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);

        Screen.DrawText(
            HUDFont,
            GetLucidityColor(localPlayer.LucidityState),
            20.0,
            242.0,
            lucidityLine,
            DTA_VIRTUALWIDTHF, 640.0,
            DTA_VIRTUALHEIGHTF, 360.0,
            DTA_KEEPRATIO, true
        );

        Screen.DrawText(
            HUDFont,
            Font.CR_GOLD,
            20.0,
            266.0,
            adrenalineLine,
            DTA_VIRTUALWIDTHF, 640.0,
            DTA_VIRTUALHEIGHTF, 360.0,
            DTA_KEEPRATIO, true
        );

        Screen.DrawText(
            HUDFont,
            Font.CR_PURPLE,
            20.0,
            290.0,
            animaLine,
            DTA_VIRTUALWIDTHF, 640.0,
            DTA_VIRTUALHEIGHTF, 360.0,
            DTA_KEEPRATIO, true
        );

        Screen.DrawText(
            HUDFont,
            GetHealthTextColor(localPlayer.HealthState),
            20.0,
            314.0,
            healthLine,
            DTA_VIRTUALWIDTHF, 640.0,
            DTA_VIRTUALHEIGHTF, 360.0,
            DTA_KEEPRATIO, true
        );

        Screen.DrawText(
            HUDFont,
            GetAirColor(localPlayer.AirState),
            20.0,
            338.0,
            airLine,
            DTA_VIRTUALWIDTHF, 640.0,
            DTA_VIRTUALHEIGHTF, 360.0,
            DTA_KEEPRATIO, true
        );
    }
}
