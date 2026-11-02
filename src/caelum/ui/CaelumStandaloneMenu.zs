// El motor conecta la red al arrancar. El menú entrega sólo datos al puente;
// nunca carga, exporta ni transforma un personaje de campaña.
class CaelumStandaloneMenu : CaelumHintOptionMenu
{
    static bool Available()
    {return gamestate!=GS_LEVEL && CVar.GetCVar('ca_standalone_bridge').GetBool();}
    override void Init(Menu parent,OptionMenuDescriptor desc)
    {
        Super.Init(parent,desc);
        CVar.GetCVar('ca_standalone_menu_ready').SetInt(Available()?1:0);
        for(int i=0;i<desc.mItems.Size();i++)
            if(desc.mItems[i] is 'OptionMenuItemCommand')
            {desc.mItems[i].mGrayCheck=CVar.GetCVar('ca_standalone_menu_ready');desc.mItems[i].mGrayCheckVal=0;}
    }
}

class CaelumStandaloneMenuEvents : StaticEventHandler
{
    override void ConsoleProcess(ConsoleEvent e)
    {
        if(e.Name!='ca_standalone_launch' || !CaelumStandaloneMenu.Available())return;
        String host=CVar.GetCVar('ca_match_host').GetString();
        String session=CVar.GetCVar('ca_match_session').GetString();
        // El separador no forma parte de un nombre de archivo de Windows.
        if(host.IndexOf('|')>=0 || session.IndexOf('|')>=0
            || host.IndexOf('\n')>=0 || session.IndexOf('\n')>=0
            || host.IndexOf('\r')>=0 || session.IndexOf('\r')>=0)return;
        Console.Printf("CA_STANDALONE_REQUEST %d|%d|%d|%d|%d|%d|%s|%s|%d",
            CVar.GetCVar('ca_match_role').GetInt(),CVar.GetCVar('ca_match_mode').GetInt(),
            CVar.GetCVar('ca_match_preset').GetInt(),CVar.GetCVar('ca_match_players').GetInt(),
            CVar.GetCVar('ca_match_port').GetInt(),CVar.GetCVar('ca_match_venue').GetInt(),host,session,CVar.GetCVar('ca_match_palomo').GetInt());
    }
}
