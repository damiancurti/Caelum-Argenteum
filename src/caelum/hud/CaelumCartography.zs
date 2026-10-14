// Cartela local sobre el automapa nativo: no escribe geometría, marcas ni CVars.
class CaelumCartography : Object ui
{
    static bool Visible(CaelumPlayer user)
    {
        let rest=user==null?null:CaelumRestState(user.FindInventory("CaelumRestState"));
        return automapactive && gamestate==GS_LEVEL && menuactive==Menu.Off
            && user!=null && user.player!=null && user.health>0
            && !user.CreationWizardOpen && !user.CraftingMenuOpen && !user.EquipmentMenuOpen
            && !user.PalomoMerchantMenuOpen && (rest==null || rest.Status!=CaelumRestRules.STATUS_ACTIVE);
    }
    static String ClockText(CaelumPlayer user)
    {
        let clock=CaelumWorldClock(user.FindInventory("CaelumWorldClock"));
        if(clock==null)return "";
        if(CaelumWorldCatalogue.IsLimboMap(level.MapName))
            return CaelumWorldClock.FormatStamp(clock.LocalDays(),clock.LocalTics());
        let calendar=CaelumCalendarState(user.FindInventory("CaelumCalendarState"));
        return calendar==null?"":calendar.FormatDate(clock);
    }
    // #235 aporta sólo el objetivo conocido y seguido. La selección de una
    // fila del Diario no constituye seguimiento ni autoriza revelar su destino.
    static String KnownObjective(CaelumPlayer user) {return "";}
    static String Keys(String command)
    {
        Array<int> keys,normal,available;
        AutomapBindings.GetAllKeysForCommand(keys,command);
        Bindings.GetAllKeysForCommand(normal,command);
        for(int i=0;i<keys.Size();i++)available.Push(keys[i]);
        for(int i=0;i<normal.Size();i++)
        {
            String mapBinding=AutomapBindings.GetBinding(normal[i]);
            if(mapBinding.Length()!=0 && !(mapBinding~==command))continue;
            bool duplicate=false;
            for(int j=0;j<available.Size();j++)if(available[j]==normal[i])duplicate=true;
            if(!duplicate)available.Push(normal[i]);
        }
        return available.Size()>0?KeyBindings.NameAllKeys(available):StringTable.Localize("CA_INTRO_UNBOUND",false);
    }
    static String Controls()
    {
        return String.Format(StringTable.Localize("CA_MAP_CONTROLS",false),
            Keys("+am_zoomin"),Keys("+am_zoomout"),Keys("am_togglefollow"),Keys("am_setmark"),Keys("togglemap"));
    }
    static double Text(Font font,int color,double x,double y,double width,double scale,String value)
    {
        if(value.Length()==0)return y;
        let lines=font.BreakLines(value,Max(1,int(width/scale)));
        for(int i=0;i<lines.Count();i++)
        {
            Screen.DrawText(font,color,x,y,lines.StringAt(i),DTA_SCALEX,scale,DTA_SCALEY,scale,DTA_SHADOW,true);
            y+=(font.GetHeight()+CaelumCartographyLayout.TEXT_GAP)*scale;
        }
        lines.Destroy();return y;
    }
    static double Draw(CaelumPlayer user,Vector2 resources,double debuffWidth)
    {
        if(!Visible(user))return 0;
        let journal=CVar.GetCVar("ca_journal_open",user.player);
        if(journal!=null && journal.GetBool())return 0;
        let font=Font.GetFont("CaelumText");let title=Font.GetFont("CaelumDisplay");
        if(font==null || title==null)return 0;
        double left=Max(CaelumCartographyLayout.MARGIN,CaelumCompassLayout.NOTIFY_LEFT*CaelumCompass.Scale());
        Vector2 powers=CaelumPresentation.PowerScale(resources);
        double width=Screen.GetWidth()-left-(CaelumPresentation.POWER_WIDTH+debuffWidth+CaelumCartographyLayout.MARGIN)*powers.X-CaelumCartographyLayout.MARGIN;
        double scale=Min(double(CaelumPresentation.UIScale()),Min(width/CaelumCartographyLayout.REFERENCE_WIDTH,Screen.GetHeight()/CaelumCartographyLayout.REFERENCE_HEIGHT));
        scale=Max(0.001,scale);
        double top=CaelumCartographyLayout.TOP;
        Vector2 messages=CaelumPresentation.MessageScale();
        if(CVar.GetCVar("con_notifytime").GetFloat()>0)
            top+=Clamp(CVar.GetCVar("con_notifylines").GetInt(),0,4)*CaelumCartographyLayout.NATIVE_NOTICE_HEIGHT*messages.Y;
        String location=StringTable.Localize(CaelumWorldCatalogue.LocationNameKey(CaelumWorldCatalogue.LocationForMap(level.MapName)),false);
        String objective=KnownObjective(user);
        bool rotated=CVar.GetCVar("am_rotate").GetInt()==1 || (CVar.GetCVar("am_rotate").GetInt()==2 && viewactive);
        String stamp=ClockText(user).."  |  "..StringTable.Localize(rotated?"CA_MAP_HEADING_UP":"CA_MAP_NORTH_UP",false);
        Array<String> rows;
        rows.Push(stamp);
        if(!viewactive)
        {
            rows.Push(StringTable.Localize("CA_MAP_LEGEND",false));
            rows.Push(Controls());
            rows.Push(StringTable.Localize(CVar.GetCVar("am_followplayer").GetBool()?"CA_MAP_FOLLOW_PAN":"CA_MAP_FREE_PAN",false));
            if(level.MapName=="MAP01")rows.Push(StringTable.Localize("CA_MAP_STACKED",false));
        }
        if(objective.Length()>0)rows.Push(objective);
        double inner=Max(1,width-2*CaelumCartographyLayout.PADDING*scale);
        let titleLines=title.BreakLines(location,Max(1,int(inner/scale)));
        double height=(titleLines.Count()*(title.GetHeight()+CaelumCartographyLayout.TEXT_GAP)+CaelumCartographyLayout.PADDING)*scale;
        titleLines.Destroy();
        for(int i=0;i<rows.Size();i++)
        {let lines=font.BreakLines(rows[i],Max(1,int(inner/scale)));height+=lines.Count()*(font.GetHeight()+CaelumCartographyLayout.TEXT_GAP)*scale;lines.Destroy();}
        // La reserva preferida de avisos nativos no puede empujar la cartela
        // sobre las barras. Las preferencias grandes conservan su valor;
        // sólo se limita la posición de esta presentación local.
        double bottom=Screen.GetHeight()-(CaelumPresentation.RESOURCE_BOTTOM_EDGE-CaelumPresentation.RESOURCE_TOP_BAR+CaelumPresentation.RESOURCE_LABEL_OFFSET)*resources.Y-CaelumCartographyLayout.MARGIN;
        top=Min(top,Max(CaelumCartographyLayout.TOP,bottom-height));
        Screen.Dim(CaelumCartographyLayout.PANEL_COLOR,CaelumCartographyLayout.PANEL_ALPHA,int(left),int(top),int(width),int(height));
        Screen.DrawThickLine(left,top,left+width,top,Max(1,scale),CaelumCartographyLayout.RULE_COLOR);
        double y=Text(title,Font.CR_GOLD,left+CaelumCartographyLayout.PADDING*scale,top+CaelumCartographyLayout.PADDING*scale/2,inner,scale,location);
        for(int i=0;i<rows.Size();i++)y=Text(font,Font.CR_WHITE,left+CaelumCartographyLayout.PADDING*scale,y,inner,scale,rows[i]);
        Screen.DrawThickLine(left,top+height,left+width,top+height,Max(1,scale),CaelumCartographyLayout.RULE_COLOR);
        return top+height+CaelumCartographyLayout.AFTER_GAP*scale;
    }
}
