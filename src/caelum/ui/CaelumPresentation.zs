// Preferencias globales del motor: sólo proyección, nunca estado del personaje.
class CaelumPresentation : Object ui
{
    static int UIScale()
    {
        // GZDoom 4.14.2 v_draw.cpp:GetUIScale no está expuesto a ZScript.
        // Conservar sus divisiones enteras y su límite, en un único adaptador.
        int width=Screen.GetWidth(), height=Screen.GetHeight();
        int value=CVar.GetCVar("uiscale").GetInt();
        if(value==0)value=Max(1,Min(height/400,width/640));
        return Max(1,Min(value,Max(height/200,width/320)));
    }
    static Vector2 MessageScale()
    {
        Vector2 size=Screen.GetTextScreenSize();
        return (Round(Screen.GetWidth()/size.X),Round(Screen.GetHeight()/size.Y));
    }
    static double Fit(double width,double height)
    {return Min(Screen.GetWidth()/width,Screen.GetHeight()/height);}
    static Vector2 HUDScale()
    {
        Vector2 scale=StatusBar==null?(Fit(640,360),Fit(640,360)):StatusBar.GetHUDScale();
        // Los grupos comparten el marco; nunca crecer fuera de su viewport.
        double fit=Min(1.0,Min(Screen.GetWidth()/(640*Max(0.001,scale.X)),Screen.GetHeight()/(360*Max(0.001,scale.Y))));
        return scale*fit;
    }
    static Vector2 MenuFactors()
    {
        Vector2 origin,size;
        [origin,size]=Screen.VirtualToRealCoords((0,0),(640,360),(640,360),false,false);
        // Fuentes y geometría comparten píxeles nativos; el marco debe caber.
        double scale=Min(double(UIScale()),Fit(640,360));
        return (scale*640/size.X,scale*360/size.Y);
    }
    static double CreatorFactor()
    {return Min(1.0,UIScale()/(Screen.GetHeight()/600.0));}
    static void AroundCenter(double factor)
    {
        let matrix=new("Shape2DTransform");
        matrix.Scale((factor,factor));
        matrix.Translate((Screen.GetWidth()*(1-factor)/2,Screen.GetHeight()*(1-factor)/2));
        Screen.SetTransform(matrix);
    }
    static void BeginMenu()
    {
        Vector2 factor=MenuFactors();
        let matrix=new("Shape2DTransform");matrix.Scale(factor);
        matrix.Translate((Screen.GetWidth()*(1-factor.X)/2,Screen.GetHeight()*(1-factor.Y)/2));
        Screen.SetTransform(matrix);
    }
    static Vector2 MenuPoint(double x,double y)
    {
        Vector2 factor=MenuFactors();
        return ((x-Screen.GetWidth()*(1-factor.X)/2)/factor.X,(y-Screen.GetHeight()*(1-factor.Y)/2)/factor.Y);
    }
    static void BeginCreator() {AroundCenter(CreatorFactor());}
    static Vector2, Vector2 MenuRect(Vector2 point,Vector2 extent)
    {
        Vector2 origin,size;
        [origin,size]=Screen.VirtualToRealCoords(point,extent,(640,360),false,false);
        Vector2 factor=MenuFactors();
        origin=(origin.X*factor.X+Screen.GetWidth()*(1-factor.X)/2,origin.Y*factor.Y+Screen.GetHeight()*(1-factor.Y)/2);
        return origin,(size.X*factor.X,size.Y*factor.Y);
    }
    static Vector2 UnscalePoint(double x,double y,double factor)
    {return ((x-Screen.GetWidth()*(1-factor)/2)/factor,(y-Screen.GetHeight()*(1-factor)/2)/factor);}
    static void BeginHUD()
    {
        Vector2 origin,size;
        [origin,size]=Screen.VirtualToRealCoords((0,0),(640,360),(640,360),false,false);
        Vector2 target=HUDScale();
        Vector2 factor=(target.X*640/size.X,target.Y*360/size.Y);
        let matrix=new("Shape2DTransform");matrix.Scale(factor);
        matrix.Translate(((Screen.GetWidth()-640*target.X)/2-origin.X*factor.X,
            Screen.GetHeight()-360*target.Y-origin.Y*factor.Y));
        Screen.SetTransform(matrix);
    }
    static void End() {Screen.ClearTransform();}
    // #213: cada grupo de recursos toma su propio borde, sin mover los
    // indicadores centrales ni modificar las preferencias nativas del HUD.
    const RESOURCE_ENLARGEMENT=1.95;
    const RESOURCE_RIGHT_EDGE=631.0;
    const RESOURCE_BOTTOM_EDGE=341.0;
    static Vector2 ResourceScale(double contentWidth)
    {
        Vector2 scale=HUDScale()*RESOURCE_ENLARGEMENT;
        double fit=Min(1.0,Min(Screen.GetWidth()/(contentWidth*scale.X),Screen.GetHeight()/((RESOURCE_BOTTOM_EDGE-218)*scale.Y)));
        return scale*fit;
    }
    static void BeginResources(bool right,Vector2 target)
    {
        Vector2 origin,size;
        [origin,size]=Screen.VirtualToRealCoords((0,0),(640,360),(640,360),false,false);
        Vector2 factor=(target.X*640/size.X,target.Y*360/size.Y);
        let matrix=new("Shape2DTransform");matrix.Scale(factor);
        matrix.Translate(((right?Screen.GetWidth()-RESOURCE_RIGHT_EDGE*target.X:0)-origin.X*factor.X,
            Screen.GetHeight()-RESOURCE_BOTTOM_EDGE*target.Y-origin.Y*factor.Y));
        Screen.SetTransform(matrix);
    }
    static double CenterMessage(Font font,int color,String text,double y)
    {
        Vector2 scale=MessageScale();
        let lines=font.BreakLines(text,Max(1,int(Screen.GetWidth()*0.8/scale.X)));
        for(int i=0;i<lines.Count();i++)
        {
            Screen.DrawText(font,color,(Screen.GetWidth()-font.StringWidth(lines.StringAt(i))*scale.X)/2,y,
                lines.StringAt(i),DTA_SCALEX,scale.X,DTA_SCALEY,scale.Y,DTA_SHADOW,true);
            y+=(font.GetHeight()+2)*scale.Y;
        }
        lines.Destroy();return y;
    }
    static void MenuBackground(Color color,double alpha)
    {
        End();Screen.Dim(color,alpha,0,0,Screen.GetWidth(),Screen.GetHeight());BeginMenu();
    }
    static void InteractionHint(Font font,String text)
    {
        text=CaelumInputHints.Resolve(text);
        Vector2 scale=MessageScale(),hud=HUDScale();
        let lines=font.BreakLines(text,Max(1,int(Screen.GetWidth()*0.8/scale.X)));
        double height=lines.Count()*(font.GetHeight()+2)*scale.Y;lines.Destroy();
        double y=Min(Screen.GetHeight()*214.0/360,Screen.GetHeight()-140*hud.Y-height);
        CenterMessage(font,Font.CR_GOLD,text,Max(0.0,y));
    }
    static bool CrosshairVisible()
    {
        if(!viewactive || gamestate!=GS_LEVEL || consoleplayer<0 || menuactive!=Menu.Off)return false;
        let user=CaelumPlayer(players[consoleplayer].mo);
        if(user==null || user.player==null || user.health<=0 || CaelumLiveMenu.Wanted(user)!=0)return false;
        if(user.player.ConversationNPC!=null && user.player.ConversationNPC.bInConversation)return false;
        let truco=CaelumTrucoMatch(user.FindInventory("CaelumTrucoMatch"));
        let trucazo=CaelumTrucazoMatch(user.FindInventory("CaelumTrucazoMatch"));
        return !(truco!=null && truco.Visible) && !(trucazo!=null && trucazo.Visible);
    }
}
