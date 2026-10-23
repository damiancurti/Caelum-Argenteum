// #282: sólo lectura; iconos existentes y controles nativos remapeables.
class CaelumQuickUseHUD : Object ui
{
    const WIDTH=280.0;
    const HEIGHT=116.0;
    const ICON_SIZE=40.0;
    const NEIGHBOR_SIZE=30.0;
    const GAP=8.0;

    static bool Visible(CaelumPlayer user)
    {
        return user!=null && user.player!=null && user.player.playerstate==PST_LIVE
            && user.CharacterCreationComplete && !user.CreationWizardOpen
            && menuactive==Menu.Off && !automapactive;
    }

    static double Top(Vector2 resources)
    {
        Vector2 hud=CaelumPresentation.HUDScale();
        return Screen.GetHeight()-HEIGHT*hud.Y;
    }

    static void Text(Font font,int color,double x,double y,String value,double width)
    {CaelumInputHints.Draw(font,color,x,y,value,width);}

    // Una tecla real basta en este espacio; Controles conserva la lista completa.
    static String Binding(String command)
    {
        Array<int> keys;Bindings.GetAllKeysForCommand(keys,command);
        return keys.Size()>0?CaelumInputHints.KeyName(keys[0]):StringTable.Localize("CA_INTRO_UNBOUND",false);
    }

    static Inventory Neighbor(CaelumPlayer user,Inventory selected,bool previous)
    {
        if(selected==null)return null;
        Inventory first=null,last=null,before=null,after=null;
        bool seen=false;
        for(Inventory candidate=user.Inv;candidate!=null;candidate=candidate.Inv)
        {
            if(!CaelumQuickUse.Eligible(user,candidate))continue;
            if(first==null)first=candidate;
            if(seen && after==null)after=candidate;
            if(candidate==selected){before=last;seen=true;}
            last=candidate;
        }
        Inventory result=previous?(before!=null?before:last):(after!=null?after:first);
        return result==selected?null:result;
    }

    static void Icon(CaelumPlayer user,Inventory item,double center,double size)
    {
        if(item==null || !item.Icon.IsValid())return;
        bool available=CaelumQuickUse.Available(user,item);
        Screen.DrawTexture(item.Icon,false,center-size/2,32+(ICON_SIZE-size)/2,
            DTA_DESTWIDTHF,size,DTA_DESTHEIGHTF,size,DTA_LEFTOFFSETF,0.0,DTA_TOPOFFSETF,0.0,
            DTA_ALPHA,available?1.0:0.45,DTA_DESATURATE,available?0:255,
            DTA_VIRTUALWIDTHF,640.0,DTA_VIRTUALHEIGHTF,360.0,DTA_KEEPRATIO,true);
    }

    static void Draw(CaelumPlayer user,Font font,Vector2 resources)
    {
        if(!Visible(user) || font==null)return;
        Vector2 origin,size;
        [origin,size]=Screen.VirtualToRealCoords((0,0),(640,360),(640,360),false,false);
        Vector2 hud=CaelumPresentation.HUDScale();
        Vector2 factor=(hud.X*640/size.X,hud.Y*360/size.Y);
        let transform=new("Shape2DTransform");transform.Scale(factor);
        transform.Translate(((Screen.GetWidth()-WIDTH*hud.X)/2-origin.X*factor.X,
            Top(resources)-origin.Y*factor.Y));
        Screen.SetTransform(transform);
        let item=CaelumQuickUse.Eligible(user,user.InvSel)?user.InvSel:null;
        bool available=CaelumQuickUse.Available(user,item);
        if(item!=null)
        {
            Icon(user,Neighbor(user,item,true),WIDTH/6,NEIGHBOR_SIZE);
            Icon(user,item,WIDTH/2,ICON_SIZE);
            Icon(user,Neighbor(user,item,false),WIDTH*5/6,NEIGHBOR_SIZE);
            Text(font,available?Font.CR_GOLD:Font.CR_GRAY,WIDTH/2,0,item.GetTag(),WIDTH);
            let water=CaelumWaterContainer(item);
            String quantity=String.Format(StringTable.Localize("CA_QUICK_QUANTITY",false),item.Amount);
            if(water!=null)quantity=String.Format(StringTable.Localize("CA_QUICK_WATER",false),
                item.Amount,water.WaterLiters,water.GetCapacityLiters()) .. " · " .. water.WaterLabel();
            Text(font,Font.CR_WHITE,WIDTH/2,14,quantity,WIDTH);
            if(!available)Text(font,Font.CR_GRAY,WIDTH/2,74,StringTable.Localize("CA_QUICK_UNAVAILABLE",false),WIDTH);
        }
        else Text(font,Font.CR_GRAY,WIDTH/2,58,StringTable.Localize("CA_QUICK_EMPTY",false),WIDTH);
        String commands[3]={"invprev","invuse","invnext"};
        String labels[3]={"CA_QUICK_PREVIOUS","CA_QUICK_USE","CA_QUICK_NEXT"};
        for(int i=0;i<3;i++)
        {
            double center=WIDTH*(i+0.5)/3;
            Text(font,Font.CR_GRAY,center,88,StringTable.Localize(labels[i],false),WIDTH/3-4);
            Text(font,Font.CR_WHITE,center,102,Binding(commands[i]),WIDTH/3-4);
        }
        CaelumPresentation.End();
    }
}
