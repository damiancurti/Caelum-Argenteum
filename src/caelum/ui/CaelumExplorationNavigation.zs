// Accesos locales: los datos siguen perteneciendo al Diario, Inventory y automapa.
class CaelumExplorationNavigation : Object ui
{
    static CaelumPlayer Subject()
    {return consoleplayer>=0?CaelumPlayer(players[consoleplayer].mo):null;}
    static bool Available()
    {
        let user=Subject();
        if(user==null)return false;
        let truco=CaelumTrucoMatch.View(user);
        let trucazo=CaelumTrucazoMatch.View(user);
        return gamestate==GS_LEVEL && user!=null && user.health>0
            && user.CharacterCreationComplete && !user.CreationWizardOpen
            && user.player!=null && (user.player.ConversationNPC==null || !user.player.ConversationNPC.bInConversation)
            && (truco==null || !truco.Visible) && (trucazo==null || !trucazo.Visible)
            && CaelumLiveMenu.Wanted(user)<100;
    }
    static bool IsShortcut(String command)
    {
        return command~=="ca_exploration" || command~=="ca_inventory_open" || command~=="ca_world_open"
            || command~=="ca_keys_open" || command~=="ca_missions_open"
            || command~=="showpop 1" || command~=="showpop 2" || command~=="showpop 3";
    }
    static bool Shortcut(int type,int scan)
    {
        String command=Bindings.GetBinding(scan);
        if(!IsShortcut(command) || !Available())return false;
        if(type!=InputEvent.Type_KeyDown)return true;
        if(command~=="showpop 1")OpenPage(4);
        else if(command~=="showpop 2")Command("ca_keys_open");
        else if(command~=="showpop 3")OpenPage(1);
        else Command(command);
        return true;
    }
    static void CloseMenus()
    {
        let current=Menu.GetCurrentMenu();
        while(current!=null)
        {
            let live=CaelumLiveMenu(current);if(live!=null)live.ResetInput();
            current.Close();
            let next=Menu.GetCurrentMenu();if(next==current)break;
            current=next;
        }
    }
    static void OpenPage(int page)
    {
        if(!Available())return;
        let view=CaelumLiveMenu.Journal();if(view==null)return;
        if(view.GetJournalPage()==3 && page!=3)EventHandler.SendNetworkEvent("ca_crafting_session_close");
        // Volver al Diario no reinicia el detalle, los filtros ni la selección.
        if(page>=0 && page!=view.GetJournalPage())view.SetJournalPage(page);
        if(!view.IsJournalOpen())view.SetJournalOpen(true);
        if(view.GetJournalPage()==0)EventHandler.SendNetworkEvent("ca_inventory_refresh");
        if(view.GetJournalPage()==4)EventHandler.SendNetworkEvent("ca_social_refresh");
        CloseMenus();
        Menu.SetMenu("CaelumLiveMenu");
    }
    static bool Command(String command)
    {
        if(command~=="ca_exploration")
        {if(Available() && CaelumNavigationMenu(Menu.GetCurrentMenu())==null)Menu.SetMenu("CaelumNavigationMenu");return true;}
        if(command~=="ca_nav_journal"){OpenPage(-1);return true;}
        if(command~=="ca_inventory_open"){OpenPage(0);return true;}
        if(command~=="ca_world_open"){OpenPage(2);return true;}
        if(command~=="ca_missions_open"){OpenPage(4);return true;}
        if(command~=="ca_keys_open")
        {if(Available() && CaelumOwnedDocumentsMenu(Menu.GetCurrentMenu())==null)Menu.SetMenu("CaelumOwnedDocumentsMenu");return true;}
        if(command~=="ca_nav_notes")
        {if(Available())Menu.SetMenu("CaelumMapNoteMenu");return true;}
        if(command~=="ca_nav_local")
        {
            if(Available())
            {
                let view=CaelumLiveMenu.Journal();
                if(view!=null)
                {
                    if(view.GetJournalPage()==3)EventHandler.SendNetworkEvent("ca_crafting_session_close");
                    view.SetJournalOpen(false);
                }
                CloseMenus();
            }
            return true;
        }
        return false;
    }
}

// La orden togglemap sólo se despacha desde un elemento nativo visible.
// Si el mapa ya estaba abierto, regresar conserva su centro, zoom y rotación.
class CaelumNavigationMenu : CaelumHintOptionMenu
{
    CaelumPlayer Subject;
    String OriginMap;
    override void Init(Menu parent,OptionMenuDescriptor desc)
    {
        Super.Init(parent,desc);Subject=CaelumExplorationNavigation.Subject();OriginMap=level.MapName;
        mDesc.mFont=Font.GetFont("CaelumText");
        for(int i=0;i<mDesc.mItems.Size();i++)
            if(mDesc.mItems[i].GetAction()=='ca_nav_local'
                || mDesc.mItems[i].GetAction()=='event ca_nav_local; togglemap')
                mDesc.mItems[i]=new("OptionMenuItemCommand").Init("$CA_NAV_LOCAL",
                    automapactive?'ca_nav_local':'event ca_nav_local; togglemap');
        if(CaelumExplorationNavigation.Available())menuactive=Menu.OnNoPause;
    }
    override void Ticker()
    {
        Super.Ticker();if(GetCurrentMenu()!=self)return;
        if(Subject!=CaelumExplorationNavigation.Subject() || OriginMap!=level.MapName
            || !CaelumExplorationNavigation.Available()){Close();return;}
        menuactive=Menu.OnNoPause;
    }
    override void OnReturn()
    {if(CaelumExplorationNavigation.Available())menuactive=Menu.OnNoPause;}
    override bool MenuEvent(int key,bool fromcontroller)
    {
        if(!CaelumExplorationNavigation.Available() && key!=MKEY_Back)return true;
        return Super.MenuEvent(key,fromcontroller);
    }
}

// Proyección de los objetos nativos poseídos. No añade copias, conocimiento ni Use.
class CaelumOwnedDocumentsMenu : CaelumNotificationMenu
{
    static bool Includes(Inventory item)
    {return item is "CaelumWeightedKey" || item is "CaelumSealedLetter" || item is "CaelumProcessingManual";}
    override String TitleKey(){return "CA_NAV_KEYS";}
    override String HelpKey(){return "CA_NAV_OWNED_HELP";}
    override void CollectText(Array<String> text)
    {
        if(Subject!=null)for(Inventory item=Subject.Inv;item!=null;item=item.Inv)
        {
            if(item.Owner!=Subject || item.Amount<=0 || !Includes(item))continue;
            text.Push(String.Format("%s  x%d",item.GetTag(),item.Amount));
            let special=CaelumSpecialInventoryItem(item);
            text.Push(StringTable.Localize(special!=null && special.InMagicBox?"CA_NAV_IN_BOX":"CA_NAV_CARRIED",false));
            text.Push(StringTable.Localize(item is "CaelumWeightedKey"?"CA_NAV_KEY_HELP":"CA_NAV_NO_TEXT",false));
        }
        if(text.Size()==0)text.Push(StringTable.Localize("CA_NAV_NO_DOCUMENTS",false));
    }
}
