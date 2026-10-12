// Borrador exclusivamente UI, limitado a la sesión del motor. Nunca apunta al
// perfil guardado, ni usa CVars globales como autoridad de una partida cargada.
class CaelumCreationDraft : Object ui
{
    int Page, Race, FirstClass, SecondClass, Sex, HeightChoice;
    int SkinTone, BeastForm;
    int Face, HairStyle, HairColor;
    int SelectedLayer, SelectedAttribute;
    int Personality[4];
    int LayerBonus[4];
    int AttributeBonus[12];
}

class CaelumCharacterSettings : StaticEventHandler
{
    ui CaelumCreationDraft Draft;
    ui bool MenusReady;

    override void UiTick()
    {
        if (MenusReady) return;
        // También limpia el catálogo antes de abrir la búsqueda nativa de
        // opciones: no deja accesos indirectos a los selectores retirados.
        CaelumPlayerPreferencesMenu.Filter(OptionMenuDescriptor(MenuDescriptor.GetDescriptor("NewPlayerMenu")));
        HideLegacyControlSection();
        CaelumControlMenus.Setup();
        let legacy = MenuDescriptor.GetDescriptor("PlayerMenu");
        if (legacy != null) legacy.mClass = "CaelumPlayerPreferencesRedirect";
        MenusReady = true;
    }

    ui void HideLegacyControlSection()
    {
        let desc = OptionMenuDescriptor(MenuDescriptor.GetDescriptor("CustomizeControls"));
        if (desc == null) return;
        for (int i = desc.mItems.Size() - 1; i >= 0; i--)
        {
            let item = OptionMenuItemStaticText(desc.mItems[i]);
            if (item == null || item.mLabel != "$CA_CONTROL_LEGACY_SECTION") continue;
            desc.mItems.Delete(i);
            if (i > 0)
            {
                let spacer = OptionMenuItemStaticText(desc.mItems[i - 1]);
                if (spacer != null && spacer.mLabel == " ") desc.mItems.Delete(i - 1);
            }
            return;
        }
    }

    override void InterfaceProcess(ConsoleEvent e)
    {
        if (e.Name == "ca_identity_committed") Draft = null;
        if (e.Name == "ca_appearance_discard")
        {
            let editor=CaelumAppearanceMenu(Menu.GetCurrentMenu());
            if(editor!=null){editor.EditSubject=null;editor.EditProfile=null;editor.Close();}
        }
    }

    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="ca_appearance_commit")return;
        let user=CaelumPlayerAuthority.FromNetworkPlayer(e.Player);
        if(!CaelumPlayerAuthority.CanMutate(user) || !user.CharacterCreationComplete)return;
        let profile=CaelumCharacterIdentity.Profile(user);
        if(profile==null || profile.AppearanceEditSerial!=e.Args[2]
            || !CaelumAppearance.ValidPacked(e.Args[0],e.Args[1]))return;
        // Una sola escritura confirmada; cancelar sólo descarta el borrador UI.
        profile.SkinTone=e.Args[0];
        int packed=e.Args[1];
        if(profile.Race==CaelumConstants.RACE_BEAST_MAN)profile.BeastForm=packed%CaelumAppearance.FORM_COUNT;
        else
        {
            packed/=CaelumAppearance.FORM_COUNT;
            profile.Face=packed%CaelumAppearance.FACE_COUNT;
            packed/=CaelumAppearance.FACE_COUNT;
            profile.HairStyle=packed%CaelumAppearance.HAIR_COUNT;
            profile.HairColor=packed/CaelumAppearance.HAIR_COUNT;
        }
        profile.AppearanceEditSerial++;
        user.UpdateWorldCarbineVisual();
    }

    override void WorldLoaded(WorldEvent e)
    {
        if(consoleplayer>=0)EventHandler.SendInterfaceEvent(consoleplayer,"ca_appearance_discard");
        if (!e.IsSaveGame) return;
        // Cada jugador limpia su propio puente; la carga no puede confirmar
        // por accidente un borrador pendiente de una partida nueva.
        for (int i = 0; i < MAXPLAYERS; i++)
        {
            if (!playeringame[i]) continue;
            let user = CaelumPlayerAuthority.FromNetworkPlayer(i);
            if (user != null)
            {
                user.ClearNewCharacterDraftReady();
                CaelumCharacterIdentity.Ensure(user);
                user.UpdateWorldCarbineVisual();
            }
        }
    }
}

// Se conserva nombre de red, equipo y preferencias de manejo nativas. Raza,
// profesión y sexo pertenecen al creador; colores/skins sin recursos propios
// no se presentan como opciones funcionales de aspecto.
class CaelumPlayerPreferencesMenu : OptionMenu
{
    static void Filter(OptionMenuDescriptor desc)
    {
        if (desc == null) return;
        for (int i = desc.mItems.Size() - 1; i >= 0; i--)
        {
            let item = desc.mItems[i];
            if (item is 'OptionMenuItemPlayerClassItem'
                || item is 'OptionMenuItemPlayerSkinItem'
                || item is 'OptionMenuItemPlayerGenderItem'
                || item is 'OptionMenuItemPlayerColorItem'
                || item is 'OptionMenuItemPlayerColorSlider') desc.mItems.Delete(i);
        }
    }

    override void Init(Menu parent, OptionMenuDescriptor desc)
    {
        Filter(desc);
        Super.Init(parent, desc);
    }
}

class CaelumPlayerPreferencesRedirect : ListMenu
{
    override void Drawer() {}
    override void Ticker()
    {
        Close();
        Menu.SetMenu("NewPlayerMenu");
    }
}
