// Sólo presentación local: consulta las tablas nativas, nunca escribe teclas.
class CaelumInputHints : Object ui
{
    static String Label(String text,String hint)
    {return String.Format(StringTable.Localize("CA_HINT_LABEL",false),text,hint);}

    static String KeyName(int scan)
    {
        String key;
        switch(scan)
        {
            case InputEvent.Key_UpArrow:key="CA_HINT_UP";break;
            case InputEvent.Key_DownArrow:key="CA_HINT_DOWN";break;
            case InputEvent.Key_LeftArrow:key="CA_HINT_LEFT";break;
            case InputEvent.Key_RightArrow:key="CA_HINT_RIGHT";break;
            case InputEvent.Key_PgUp:key="CA_HINT_PGUP";break;
            case InputEvent.Key_PgDn:key="CA_HINT_PGDN";break;
            case InputEvent.Key_Backspace:key="CA_HINT_BACKSPACE";break;
            case InputEvent.Key_Space:key="CA_HINT_SPACE";break;
            case InputEvent.Key_Escape:key="CA_HINT_ESC";break;
            case InputEvent.Key_Enter:key="CA_HINT_ENTER";break;
            case InputEvent.Key_Tab:key="CA_HINT_TAB";break;
        }
        if(key!="")return StringTable.Localize(key,false);
        String name=KeyBindings.NameKeys(scan,0);
        if(name.Length()==1)return String.Format("%c",String.CharUpper(name.GetNextCodePoint(0)));
        return name;
    }
    static String Fixed(String text,int scan)
    {return Label(text,KeyName(scan));}
    static String Navigation(String text,bool horizontal=false,bool confirm=false)
    {
        String hint=KeyName(horizontal?InputEvent.Key_LeftArrow:InputEvent.Key_UpArrow).."/"
            ..KeyName(horizontal?InputEvent.Key_RightArrow:InputEvent.Key_DownArrow);
        if(confirm)hint=hint..", "..KeyName(InputEvent.Key_Enter);
        return Label(text,hint);
    }
    static bool NativeNavigation(int scan)
    {
        return scan==InputEvent.Key_UpArrow || scan==InputEvent.Key_DownArrow || scan==InputEvent.Key_LeftArrow
            || scan==InputEvent.Key_RightArrow || scan==InputEvent.Key_Enter || scan==InputEvent.Key_PgUp
            || scan==InputEvent.Key_PgDn || scan==InputEvent.Key_Backspace || scan==InputEvent.Key_Escape;
    }
    static String MenuKeys(String command)
    {
        Array<int> keys,available;Bindings.GetAllKeysForCommand(keys,command);
        let menu=CaelumLiveMenu(Menu.GetCurrentMenu());
        if(menu==null)return Keys(command);
        for(int i=0;i<keys.Size();i++)if(!NativeNavigation(keys[i]) && keys[i]!=InputEvent.Key_Mouse1
            && keys[i]!=InputEvent.Key_Mouse2 && keys[i]!=InputEvent.Key_Mouse4
            && keys[i]!=InputEvent.Key_MWheelUp && keys[i]!=InputEvent.Key_MWheelDown
            && keys[i]!=InputEvent.Key_Pad_Start)available.Push(keys[i]);
        return available.Size()>0?KeyBindings.NameAllKeys(available):StringTable.Localize(keys.Size()>0?"CA_HINT_MOUSE":"CA_INTRO_UNBOUND",false);
    }
    static String Bound(String text,String command) {return Label(text,MenuKeys(command));}
    // Sólo los paneles vivos ceden sus letras a Diario/salto temporal.
    // Los clics siguen invocando la acción aunque esa letra esté ocupada.
    static String ContextKey(int scan,int character=0,String allowedCommand="")
    {
        if(scan==0)scan=CaelumMenuPointer.KeyScan(character);
        // Las flechas/Enter ya fueron traducidas por Menu antes de consultar binds.
        if(scan==InputEvent.Key_UpArrow || scan==InputEvent.Key_DownArrow || scan==InputEvent.Key_LeftArrow
            || scan==InputEvent.Key_RightArrow || scan==InputEvent.Key_Enter || scan==InputEvent.Key_PgUp
            || scan==InputEvent.Key_PgDn || scan==InputEvent.Key_Backspace)return KeyName(scan);
        let menu=CaelumLiveMenu(Menu.GetCurrentMenu());
        if(menu!=null && menu.Context!=menu.CTX_SKIP && menu.Context!=menu.CTX_JOURNEY
            && menu.Context!=menu.CTX_CHEST && menu.Context!=menu.CTX_EQUIPMENT && menu.Context!=menu.CTX_CREATION)
        {
            String command=Bindings.GetBinding(scan);
            bool journal=menu.Journal().IsJournalOpen() || menu.Context==menu.CTX_REST;
            if(!(command~==allowedCommand) && (command~=="ca_time_skip" || (journal && command~=="ca_journal_toggle")))
                return StringTable.Localize("CA_HINT_MOUSE",false);
        }
        return KeyName(scan);
    }
    static String BoundOrFallback(String text,String command,int scan)
    {
        Array<int> keys;Bindings.GetAllKeysForCommand(keys,command);
        if(keys.Size()>0 && MenuKeys(command)!=StringTable.Localize("CA_HINT_MOUSE",false))return Bound(text,command);
        return Context(text,scan);
    }
    static String Context(String text,int scan,int character=0,String allowedCommand="")
    {return Label(text,ContextKey(scan,character,allowedCommand));}

    // No recortar la tecla al acortar una etiqueta: encajar todo el rótulo.
    static void Draw(Font font,int color,double x,double y,String label,double width)
    {
        double scale=Min(1.0,width/Max(1,font.StringWidth(label)));
        Screen.DrawText(font,color,x-font.StringWidth(label)*scale/2,y,label,
            DTA_VIRTUALWIDTHF,640.0,DTA_VIRTUALHEIGHTF,360.0,DTA_KEEPRATIO,true,
            DTA_SHADOW,true,DTA_SCALEX,scale,DTA_SCALEY,scale);
    }
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
