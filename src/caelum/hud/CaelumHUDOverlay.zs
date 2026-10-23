// CaelumHUDOverlay is the first permanent gameplay HUD component.
// It remains separate from the optional development panel so future health,
// Anima, adrenaline, and lucidity displays can be added without debug code.
class CaelumHUDOverlay : EventHandler
{
    Font HUDFont;

    // CaelumMono conserva alineación estable en contadores y recursos.
    override void OnRegister()
    {
        HUDFont = Font.GetFont("CaelumMono");
    }

    override void UiTick()
    {
        // El selector permanente ya muestra la elección. No exigir otra
        // pulsación sólo para cerrar la barra temporal nativa de Inventory.
        if(consoleplayer<0 || gamestate!=GS_LEVEL)return;
        let user=CaelumPlayer(players[consoleplayer].mo);
        if(CaelumQuickUseHUD.Visible(user))user.player.inventorytics=0;
    }

    ui String GetActiveWeaponNameKey(int weaponType)
    {
        switch (weaponType)
        {
            case CaelumConstants.WEAPON_TYPE_BOLAS: return "CA_WEAPON_TYPE_BOLAS";
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
            case CaelumConstants.WEAPON_TYPE_SHOTGUN: return "CA_WEAPON_TYPE_SHOTGUN";
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

    ui String GetSealTypeKey(int sealType)
    {
        switch (sealType)
        {
            case CaelumConstants.SEAL_WATER: return "CA_SEAL_WATER";
            case CaelumConstants.SEAL_EARTH: return "CA_SEAL_EARTH";
            case CaelumConstants.SEAL_AIR: return "CA_SEAL_AIR";
            case CaelumConstants.SEAL_QUINTESSENCE:
                return "CA_SEAL_QUINTESSENCE";
            default: return "CA_SEAL_FIRE";
        }
    }

    ui String GetActiveWeaponIconPath(int weaponType)
    {
        switch (weaponType)
        {
            case CaelumConstants.WEAPON_TYPE_BOLAS: return "CA_BOLAS_ICON";
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
            case CaelumConstants.WEAPON_TYPE_SHOTGUN: return "CA_SHOTGUN_T1";
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

    ui bool IsDomingoSwordViewActive(CaelumPlayer localPlayer)
    { return false; }

    // Presentación provisional en primera persona usando el mismo arte propio
    // del objeto. Sustituye el texto permanente de "arma activa" y mantiene
    // una sola fuente gráfica para inventario, suelo y vista del jugador.
    ui void DrawFirstPersonWeapon(CaelumPlayer localPlayer)
    {
        // La espada real usa PSprites nativos modulares. No superponerle el
        // icono provisional que normalmente representa al arma activa.
        if (CaelumFirstPersonView.OwnsView(localPlayer.player.ReadyWeapon)) { return; }
        if (!localPlayer.HUDHasActiveWeapon) { return; }
        TextureID weaponIcon = TexMan.CheckForTexture(
            CaelumIconResolver.ResolveTierPath(
                GetActiveWeaponIconPath(localPlayer.HUDActiveWeaponType),
                localPlayer.HUDActiveWeaponTier
            ),
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
        // El controlador nativo ya dibuja escudo y agarre; no duplicar el icono.
        if (CaelumFirstPersonView.OwnsView(localPlayer.player.ReadyWeapon)
            || localPlayer.player.ReadyWeapon is 'CaelumUnarmedWeapon') { return; }
        if (IsDomingoSwordViewActive(localPlayer)) { return; }
        if (!localPlayer.HUDCombatBlockActive) { return; }
        if (CaelumFirstPersonView.OwnsView(localPlayer.player.ReadyWeapon)
            && localPlayer.HUDCombatBlockUsesGauntlets) { return; }

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
        if (airState == CaelumConstants.AIR_STATE_NO_OXYGEN)
        {
            return "CA_AIR_STATE_NO_OXYGEN";
        }

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
        if (airState == CaelumConstants.AIR_STATE_NO_OXYGEN)
        {
            return Font.CR_LIGHTBLUE;
        }

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

    // Devuelve el color RGB del relleno. Los valores siguen dibujándose por
    // código y el paquete HUD-01 aporta solamente el marco modular exterior.
    ui int GetAirBarColor(int airState)
    {
        if (airState == CaelumConstants.AIR_STATE_NO_OXYGEN)
        {
            return 0x2877A8;
        }

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

    // Dibuja un recurso propio dentro del mismo lienzo virtual 640x360 que el
    // texto. Los fallos de arte son degradables: un PNG ausente no afecta la
    // simulación ni impide que continúen visibles los valores numéricos.
    ui void DrawHUDTexture(String path, double x, double y, double width,
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

    // Los extremos nunca se deforman; solamente se estira la pieza central.
    // El relleno se compone después dentro del hueco y no cubre los extremos.
    ui void DrawHUDBarFrame(double barX, double barY, double barWidth)
    {
        String root = "graphics/caelum/ui/hud/components/";
        double endWidth = 16.0;
        double frameHeight = 16.0;
        double frameX = barX - endWidth * 0.5;
        double frameY = barY - 4.5;
        double centerWidth = Max(1.0, barWidth - endWidth);
        DrawHUDTexture(root .. "ca_hud_bar_left.png", frameX, frameY,
            endWidth, frameHeight);
        DrawHUDTexture(root .. "ca_hud_bar_center.png", frameX + endWidth,
            frameY, centerWidth, frameHeight);
        DrawHUDTexture(root .. "ca_hud_bar_right.png",
            frameX + endWidth + centerWidth, frameY, endWidth, frameHeight);
    }

    // HUD-03: los laureles son remates independientes. Se dibujan al final
    // para no quedar ocultos por el marco ni por el relleno tintado.
    ui void DrawHUDBarLaurels(double barX, double barY, double barWidth)
    {
        String root = "graphics/caelum/ui/hud/components/";
        double laurelSize = 18.0;
        double laurelY = barY - 5.5;
        DrawHUDTexture(
            root .. "ca_hud_bar_laurel_left.png",
            barX - laurelSize * 0.5,
            laurelY,
            laurelSize,
            laurelSize
        );
        DrawHUDTexture(
            root .. "ca_hud_bar_laurel_right.png",
            barX + barWidth - laurelSize * 0.5,
            laurelY,
            laurelSize,
            laurelSize
        );
    }

    ui void DrawResourceLaurels(bool right)
    {
        double x=right?440.0:20.0;
        for(int row=2;row<5;row++)DrawHUDBarLaurels(x,230.0+24.0*row,180.0);
    }

    // Cada grupo conserva sus marcos, iconos y remates en una misma proyeccion.
    ui void DrawResourceSkin(bool right)
    {
        String root = "graphics/caelum/ui/hud/icons/";
        double x=right?440.0:20.0;
        for(int row=2;row<5;row++)DrawHUDBarFrame(x,230.0+24.0*row,180.0);
        if(right)
        {
            DrawHUDTexture(root .. "ca_hud_icon_adrenaline.png",422.0,273.0,18.0,18.0);
            DrawHUDTexture(root .. "ca_hud_icon_anima.png",422.0,297.0,18.0,18.0);
            DrawHUDTexture(root .. "ca_hud_icon_air.png",422.0,321.0,18.0,18.0);
        }
        else
        {
            DrawHUDTexture(root .. "ca_hud_icon_load.png",2.0,273.0,18.0,18.0);
            DrawHUDTexture(root .. "ca_hud_icon_lucidity.png",2.0,297.0,18.0,18.0);
            DrawHUDTexture(root .. "ca_hud_icon_health.png",2.0,321.0,18.0,18.0);
        }
    }

    // La descripcion ocupa el hueco encima del marco; las de la derecha
    // terminan sobre el extremo de la barra y crecen hacia dentro de la pantalla.
    ui void DrawResourceLabel(bool right,double barY,int color,String label,int tint=0xFFFFFFFF)
    {
        double x=right?620.0-HUDFont.StringWidth(label):20.0;
        Screen.DrawText(HUDFont,color,x,barY-CaelumPresentation.RESOURCE_LABEL_OFFSET,label,
            DTA_VIRTUALWIDTHF,640.0,DTA_VIRTUALHEIGHTF,360.0,
            DTA_KEEPRATIO,true,DTA_SHADOW,true,DTA_COLOR,tint);
    }

    // Si una recarga larga invade los recursos, queda por encima de ambos
    // grupos. El texto central conserva su escala nativa y su posición usual
    // cuando hay espacio suficiente entre las barras.
    ui double WeaponStatusY(String text,Vector2 resources,double leftWidth,double rightWidth)
    {
        Vector2 hud=CaelumPresentation.HUDScale();
        let user=consoleplayer>=0?CaelumPlayer(players[consoleplayer].mo):null;
        if(CaelumQuickUseHUD.Visible(user))
            return Min(360-CaelumQuickUseHUD.HEIGHT-HUDFont.GetHeight()-4,
                360-(CaelumPresentation.RESOURCE_BOTTOM_EDGE-218)*resources.Y/hud.Y-HUDFont.GetHeight()-2);
        double left=(Screen.GetWidth()-HUDFont.StringWidth(text)*hud.X)/2;
        if(left>leftWidth*resources.X && left>rightWidth*resources.X)return 326;
        return Min(326,360-(CaelumPresentation.RESOURCE_BOTTOM_EDGE-218)*resources.Y/hud.Y-HUDFont.GetHeight()-2);
    }

    // Coincide con DrawTexture/DrawText y DTA_KEEPRATIO: no mezclar otra
    // proyección de aspecto en los rellenos dibujados con coordenadas reales.
    ui Vector2, Vector2 ResourceRect(double x,double y,double width=164,double height=7)
    {
        Vector2 pos, size;
        [pos, size] = Screen.VirtualToRealCoords((x,y),(width,height),(640,360),false,false);
        return pos, size;
    }

    ui void DrawAirBar(CaelumPlayer localPlayer)
    {
        Vector2 pos, size;
        [pos, size] = ResourceRect(448, 326);
        int barX=int(pos.X), barY=int(pos.Y);
        int barWidth=Max(1,int(size.X)), barHeight=Max(1,int(size.Y));
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

    // Salud conserva la vida nativa y el máximo derivado de Constitución.
    ui void DrawHealthBar(CaelumPlayer localPlayer)
    {
        Vector2 pos, size;
        [pos, size] = ResourceRect(28, 326);
        int barX=int(pos.X), barY=int(pos.Y);
        int barWidth=Max(1,int(size.X)), barHeight=Max(1,int(size.Y));
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

    // Ánima conserva el relleno violeta entre Adrenalina y Aire.
    ui void DrawAnimaBar(CaelumPlayer localPlayer)
    {
        Vector2 pos, size;
        [pos, size] = ResourceRect(448, 302);
        int barX=int(pos.X), barY=int(pos.Y);
        int barWidth=Max(1,int(size.X)), barHeight=Max(1,int(size.Y));
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
        Vector2 pos, size;
        [pos, size] = ResourceRect(448, 278);
        int barX=int(pos.X), barY=int(pos.Y);
        int barWidth=Max(1,int(size.X)), barHeight=Max(1,int(size.Y));
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

    // Lucidez conserva sus colores, entre Carga y Salud.
    ui void DrawLucidityBar(CaelumPlayer localPlayer)
    {
        Vector2 pos, size;
        [pos, size] = ResourceRect(28, 302);
        int barX=int(pos.X), barY=int(pos.Y);
        int barWidth=Max(1,int(size.X)), barHeight=Max(1,int(size.Y));
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

    // Carga encabeza la columna izquierda. El color avanza desde
    // verde hasta rojo al acercarse y superar la capacidad máxima.
    ui void DrawLoadBar(CaelumPlayer localPlayer)
    {
        Vector2 pos, size;
        [pos, size] = ResourceRect(28, 278);
        int x=int(pos.X), y=int(pos.Y);
        int width=Max(1,int(size.X)), height=Max(1,int(size.Y));
        double ratio = localPlayer.HUDLoadRatio;
        int fill = int(width * Clamp(ratio, 0.0, 1.0));
        int barColor = 0x55B86A;
        if (ratio >= 1.0) barColor = 0xC34B4B;
        else if (ratio >= CaelumConstants.OVERLOAD_THRESHOLD) barColor = 0xD28B35;
        else if (ratio >= 0.50) barColor = 0xB7B547;
        Screen.Dim(0x161616, 0.85, x, y, width, height);
        if (fill > 0) Screen.Dim(barColor, 0.95, x, y, fill, height);
    }

    // Gradientes y bandas animadas hacen visible la pérdida de Lucidez.
    // El HUD se dibuja después para conservar la legibilidad de sus textos.
    ui void DrawLucidityDistortion(CaelumPlayer localPlayer,double fraction)
    {
        CaelumScreenFeedback.Lucidity(localPlayer,fraction);
    }

    // Indicador lateral: utiliza el icono real del Sello y su disponibilidad
    // autoritativa. La escala de grises conserva la transparencia y el detalle.
    ui double DrawSurvivalDebuffs(CaelumPlayer user)
    {
        let record=CaelumPersistentCharacterState(user.FindInventory("CaelumPersistentCharacterState"));
        let thermal=record!=null ? record.ThermalState : null;
        int row=0;
        double width=36;
        for(int resource=0;resource<4;resource++)
        {
            String label; int textColor, tint=0xFFFFFFFF;
            if(resource<3)
            {
                int state=CaelumSurvivalView.State(user,resource);
                if(state==CaelumConstants.SURVIVAL_STATE_NORMAL)continue;
                label=StringTable.Localize(CaelumSurvivalView.StateKey(resource,state),false);
                textColor=CaelumSurvivalView.TextColor(state);
            }
            else
            {
                if(thermal==null || thermal.Severity<=0)continue;
                label=StringTable.Localize(CaelumThermalRules.StateKey(thermal.Exposure,thermal.Toughness),false);
                textColor=Font.CR_WHITE;
                tint=0xFF000000|CaelumThermalHUD.ExposureColor(thermal.Exposure,thermal.Toughness);
            }
            double y=16+row*40;
            width=Max(width,36+HUDFont.StringWidth(label));
            DrawHUDTexture(CaelumSurvivalView.Icon(resource),-30,y,18,18);
            // El nombre crece hacia dentro; nunca entra en la columna de poderes.
            Screen.DrawText(HUDFont,textColor,-36-HUDFont.StringWidth(label),y+5,label,
                DTA_VIRTUALWIDTHF,640.0,DTA_VIRTUALHEIGHTF,360.0,
                DTA_KEEPRATIO,true,DTA_SHADOW,true,DTA_COLOR,tint);
            row++;
        }
        return width;
    }

    ui void DrawSealIndicator(CaelumPlayer localPlayer)
    {
        if (!localPlayer.HUDHasEquippedSeal) return;
        String path = CaelumIconResolver.ResolveEquipmentPath(
            CaelumConstants.EQUIPMENT_KIND_SEAL,
            localPlayer.HUDEquippedSealType, -1,
            localPlayer.HUDEquippedSealTier
        );
        let icon = TexMan.CheckForTexture(path, TexMan.Type_Any);
        if (!icon.IsValid()) return;
        bool available = localPlayer.HUDSealChannelAvailable;
        Screen.DrawTexture(icon, false, 0.0, 130.0,
            DTA_DESTWIDTHF, 88.0, DTA_DESTHEIGHTF, 88.0,
            DTA_LEFTOFFSETF, 0.0, DTA_TOPOFFSETF, 0.0,
            DTA_DESATURATE, available ? 0 : 255,
            DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0,
            DTA_KEEPRATIO, true
        );
        // Si falta Adrenalina no hay un tiempo de recuperación garantizado:
        // sólo la recarga real produce una cuenta regresiva.
        if (localPlayer.CombatChannelCooldownRemaining > 0.0)
        {
            int seconds = Max(1, int(Ceil(localPlayer.CombatChannelCooldownRemaining)));
            String countdown = String.Format("%ds", seconds);
            double x = 44.0 - HUDFont.StringWidth(countdown) * 0.5;
            Screen.DrawText(HUDFont, Font.CR_WHITE, x, 220.0, countdown,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0,
                DTA_KEEPRATIO, true, DTA_SHADOW, true
            );
        }
    }

    // El Tarot comparte la columna lateral del Sello. Ambos contadores leen
    // el registro guardado; dibujar nunca inicia ni modifica un poder.
    ui void DrawTarotIndicator(CaelumPlayer localPlayer)
    {
        let record = CaelumPersistentCharacterState(localPlayer.FindInventory("CaelumPersistentCharacterState"));
        if (record == null) return;
        bool selected = false;
        for (int card = 0; card < CaelumConstants.TAROT_CARD_COUNT; card++)
            selected = selected || CaelumTarotService.IsSelected(record, card);
        bool active = CaelumTarotService.EffectTics(record) > 0;
        if (!selected && !active && CaelumTarotService.CooldownTics(record) <= 0) return;
        bool available = active || (selected && CaelumTarotService.CooldownTics(record) <= 0
            && localPlayer.CurrentAnima >= CaelumConstants.TAROT_ACTIVATION_ANIMA);
        let icon = TexMan.CheckForTexture("graphics/caelum/icons/ca_tarot_back.png", TexMan.Type_Any);
        if (!icon.IsValid()) return;
        Screen.DrawTexture(icon, false, 12.0, 0.0,
            DTA_DESTWIDTHF, 64.0, DTA_DESTHEIGHTF, 96.0,
            DTA_LEFTOFFSETF, 0.0, DTA_TOPOFFSETF, 0.0,
            DTA_DESATURATE, available ? 0 : 255,
            DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0,
            DTA_KEEPRATIO, true);
        if (active)
        {
            String duration = String.Format(StringTable.Localize("CA_TAROT_HUD_DURATION", false),
                (CaelumTarotService.EffectTics(record) + TICRATE - 1) / TICRATE);
            Screen.DrawText(HUDFont, Font.CR_CYAN, 88.0 - HUDFont.StringWidth(duration), 98.0, duration,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0,
                DTA_KEEPRATIO, true, DTA_SHADOW, true);
        }
        if (CaelumTarotService.CooldownTics(record) > 0)
        {
            String cooldown = String.Format(StringTable.Localize("CA_TAROT_HUD_COOLDOWN", false),
                (CaelumTarotService.CooldownTics(record) + TICRATE - 1) / TICRATE);
            Screen.DrawText(HUDFont, Font.CR_WHITE, 88.0 - HUDFont.StringWidth(cooldown), 112.0, cooldown,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0,
                DTA_KEEPRATIO, true, DTA_SHADOW, true);
        }
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

        CaelumPlayer localPlayer = CaelumThermalHUD.ViewedPlayer(consoleplayer);

        if (localPlayer == null
            || localPlayer.player == null
            || localPlayer.player.playerstate != PST_LIVE
            || localPlayer.DerivedStats == null)
        {
            if(localPlayer!=null && localPlayer.player!=null
                && localPlayer.player.playerstate==PST_DEAD)
                CaelumScreenFeedback.Damage(localPlayer,event.FracTic);
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
        String activeWeaponName = localPlayer.HUDHasActiveWeapon
            ? CaelumDisplayNames.FormatWeaponName(
                localPlayer.HUDActiveWeaponType,
                localPlayer.HUDActiveWeaponTier
            )
            : StringTable.Localize("CA_HUD_UNARMED", false);
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
                    "%s: %s #%d | %s | %s",
                    StringTable.Localize("CA_HUD_ACTIVE_WEAPON", false),
                    activeWeaponName,
                    localPlayer.HUDActiveWeaponItemId,
                    StringTable.Localize(GetEssenceTypeKey(
                        localPlayer.HUDActiveWeaponEssenceType
                    ), false),
                    StringTable.Localize(
                        GetEquipmentSizeKey(localPlayer.HUDActiveWeaponSize),
                        false
                    )
                );
            }
            else
            {
                activeWeaponLine = String.Format(
                    "%s: %s #%d | %s",
                    StringTable.Localize("CA_HUD_ACTIVE_WEAPON", false),
                    activeWeaponName,
                    localPlayer.HUDActiveWeaponItemId,
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

        CaelumScreenFeedback.Damage(localPlayer,event.FracTic);
        DrawLucidityDistortion(localPlayer,event.FracTic);
        // El centro del marco HUD-01 es deliberadamente oscuro y casi opaco.
        // Dibujarlo primero permite que los rellenos tintados queden visibles
        // dentro de sus bordes metálicos en vez de quedar tapados por el arte.
        // Medir el texto localizado antes de limitar la ampliacion: los dos
        // grupos pueden crecer hasta tocarse, pero nunca invadirse ni cortarse.
        double leftWidth=Max(209,20+Max(HUDFont.StringWidth(loadLine),
            Max(HUDFont.StringWidth(lucidityLine),HUDFont.StringWidth(healthLine))));
        double rightWidth=Max(209,11+Max(HUDFont.StringWidth(adrenalineLine),
            Max(HUDFont.StringWidth(animaLine),HUDFont.StringWidth(airLine))));
        // Dos unidades incluyen la sombra y separan las etiquetas enfrentadas.
        leftWidth+=2;rightWidth+=2;
        // El selector central ocupa una columna propia en el borde inferior.
        // Reducir sólo el ajuste al viewport si los recursos invadirían ese hueco.
        Vector2 quickScale=CaelumPresentation.HUDScale();
        double quickWidth=CaelumQuickUseHUD.Visible(localPlayer)
            ?(CaelumQuickUseHUD.WIDTH+2*CaelumQuickUseHUD.GAP)*quickScale.X:0;
        Vector2 resourceScale=CaelumPresentation.ResourceScale(
            quickWidth>0?2*Max(leftWidth,rightWidth):leftWidth+rightWidth,quickWidth);
        CaelumPresentation.BeginResources(false,resourceScale);
        DrawResourceSkin(false);
        DrawLoadBar(localPlayer);
        DrawLucidityBar(localPlayer);
        DrawHealthBar(localPlayer);
        DrawResourceLaurels(false);
        CaelumPresentation.End();
        CaelumPresentation.BeginResources(true,resourceScale);
        DrawResourceSkin(true);
        DrawAdrenalineBar(localPlayer);
        DrawAnimaBar(localPlayer);
        DrawAirBar(localPlayer);
        DrawResourceLaurels(true);
        CaelumPresentation.End();
        DrawFirstPersonWeapon(localPlayer);
        DrawFirstPersonBlockShield(localPlayer);

        // Como antes, las etiquetas quedan por encima del arma de primera persona.
        CaelumPresentation.BeginResources(false,resourceScale);
        DrawResourceLabel(false,CaelumPresentation.RESOURCE_TOP_BAR,Font.CR_WHITE,loadLine);
        DrawResourceLabel(false,302,GetLucidityColor(localPlayer.LucidityState),lucidityLine);
        DrawResourceLabel(false,326,GetHealthTextColor(localPlayer.HealthState),healthLine);
        CaelumPresentation.End();
        CaelumPresentation.BeginResources(true,resourceScale);
        DrawResourceLabel(true,CaelumPresentation.RESOURCE_TOP_BAR,Font.CR_GOLD,adrenalineLine);
        DrawResourceLabel(true,302,Font.CR_PURPLE,animaLine);
        DrawResourceLabel(true,326,GetAirColor(localPlayer.AirState),airLine);
        CaelumPresentation.End();

        CaelumCompass.Draw(event, localPlayer, HUDFont);
        CaelumPresentation.BeginPowers(resourceScale);
        double debuffWidth=DrawSurvivalDebuffs(localPlayer);
        DrawSealIndicator(localPlayer);
        DrawTarotIndicator(localPlayer);
        CaelumPresentation.End();
        CaelumPresentation.BeginPowers(resourceScale,false);
        CaelumAbilityHUD.Draw(localPlayer,HUDFont);
        CaelumPresentation.End();
        CaelumQuickUseHUD.Draw(localPlayer,HUDFont,resourceScale);
        double noticeBottom=Max(12,CaelumCartography.Draw(localPlayer,resourceScale,debuffWidth));
        noticeBottom=Max(noticeBottom,CaelumTargetPanel.Draw(localPlayer,HUDFont));
        if(menuactive==Menu.Off)
        {
            if(localPlayer.HUDActiveWeaponNoticeRemaining>0)
                noticeBottom=CaelumPresentation.CenterMessage(HUDFont,Font.CR_GOLD,activeWeaponLine,noticeBottom);
            if(localPlayer.HUDAbilitySuccessRemaining>0)
                noticeBottom=CaelumPresentation.CenterMessage(HUDFont,Font.CR_GREEN,
                    StringTable.Localize("CA_ABILITY_USED_SUCCESSFULLY",false),noticeBottom);
        }
        CaelumPresentation.BeginHUD();

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
                HUDFont, Font.CR_WHITE, magazineX, WeaponStatusY(magazineLine,resourceScale,leftWidth,rightWidth), magazineLine,
                DTA_VIRTUALWIDTHF, 640.0,
                DTA_VIRTUALHEIGHTF, 360.0,
                DTA_KEEPRATIO, true,
                DTA_SHADOW, true
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
                HUDFont, chargeColor, chargeX, WeaponStatusY(chargeLine,resourceScale,leftWidth,rightWidth), chargeLine,
                DTA_VIRTUALWIDTHF, 640.0,
                DTA_VIRTUALHEIGHTF, 360.0,
                DTA_KEEPRATIO, true,
                DTA_SHADOW, true
            );
        }

        CaelumPresentation.End();
        CaelumNotifications.Draw(localPlayer,HUDFont,noticeBottom);
        CaelumNotifications.DrawExtraction(localPlayer);
    }
}
