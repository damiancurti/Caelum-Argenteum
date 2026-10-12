// Sólo presentación local: consulta las tablas nativas, nunca escribe teclas.
class CaelumInputHints : Object ui
{
    static String Keys(String command)
    {
        Array<int> keys;
        Bindings.GetAllKeysForCommand(keys,command);
        String result=KeyBindings.NameAllKeys(keys);
        return result==""?StringTable.Localize("CA_INTRO_UNBOUND",false):result;
    }

    static bool Matches(int scan,String command)
    {return Bindings.GetBinding(scan)~==command;}

    static String Resolve(String text)
    {
        int start=text.IndexOf("{bind:");
        while(start>=0)
        {
            String tail=text.Mid(start+6);
            int end=tail.IndexOf("}");
            if(end<0)break;
            String command=tail.Left(end);
            text=text.Left(start)..Keys(command)..tail.Mid(end+1);
            start=text.IndexOf("{bind:");
        }
        return text;
    }
}

// Se agrupan las filas nativas, sin reemplazar tablas ni resetear preferencias.
class CaelumControlMenus : Object ui
{
    static void RemoveMatches(String source,String destination)
    {
        let from=OptionMenuDescriptor(MenuDescriptor.GetDescriptor(source));
        let to=OptionMenuDescriptor(MenuDescriptor.GetDescriptor(destination));
        if(from==null || to==null)return;
        for(int i=from.mItems.Size()-1;i>=0;i--)
        {
            let item=OptionMenuItemControl(from.mItems[i]);
            if(item==null)continue;
            for(int j=0;j<to.mItems.Size();j++)
            {
                let target=OptionMenuItemControl(to.mItems[j]);
                if(target!=null && item.GetAction()==target.GetAction()){from.mItems.Delete(i);break;}
            }
        }
    }
    static void Setup()
    {
        let root=OptionMenuDescriptor(MenuDescriptor.GetDescriptor("CustomizeControls"));
        if(root!=null)for(int i=0;i<root.mItems.Size();i++)
        {
            let reset=OptionMenuItemSafeCommand(root.mItems[i]);
            if(reset!=null && reset.GetAction()=='resetb2defaults')
                root.mItems[i]=new("OptionMenuItemSafeCommand").Init("$OPTMNU_DEFAULTS","ca_controls_reset");
        }
        RemoveMatches("ActionControlsMenu","CaelumCombatControls");
        RemoveMatches("WeaponsControlMenu","CaelumAbilityControls");
        RemoveMatches("OtherControlsMenu","MapControlsMenu");
        RemoveMatches("OtherControlsMenu","InventoryControlsMenu");
    }
}
