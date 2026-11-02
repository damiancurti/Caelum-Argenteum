// #481: la UI sólo lee el objetivo; consulta binds actuales en cada dibujo.
class CaelumTargetPanel : Object ui
{
    static String Resource(String key,double value,double maximum)
    {return String.Format("%s: %.0f / %.0f",StringTable.Localize(key,false),Max(0,value),Max(0,maximum));}

    static double Draw(CaelumPlayer user,Font font,double minimumTop=0)
    {
        if(user==null || user.TargetInfo==null || user.TargetInfo.Title=="" || !CaelumPresentation.CrosshairVisible())return 0;
        let info=user.TargetInfo;let enemy=CaelumCombatActor(info.Subject);let other=CaelumPlayer(info.Subject);
        Vector2 scale=CaelumPresentation.MessageScale();
        double width=Min(CaelumTargetPanelData.WIDTH,Screen.GetWidth()/scale.X-2*CaelumTargetPanelData.PADDING);
        double x=(Screen.GetWidth()-width*scale.X)/2;
        double y=Max(CaelumTargetPanelData.TOP*scale.Y,minimumTop);
        double row=(font.GetHeight()+CaelumTargetPanelData.ROW_GAP)*scale.Y;
        bool stats=enemy!=null || (other!=null && other.DerivedStats!=null);
        String actions=CaelumInputHints.Resolve(info.Actions);
        let lines=font.BreakLines(actions,Max(1,int(width-2*CaelumTargetPanelData.PADDING)));
        int actionRows=actions==""?0:lines.Count();
        double height=(1+(stats?6:0)+actionRows)*row+2*CaelumTargetPanelData.PADDING*scale.Y;
        Screen.Dim(CaelumTargetPanelData.BACKGROUND,CaelumTargetPanelData.OPACITY,int(x),int(y),int(width*scale.X),int(height));
        double textY=y+CaelumTargetPanelData.PADDING*scale.Y;
        String title=info.Title;int titleColor=Font.CR_GOLD;
        let match=CaelumStandaloneMatch.View();
        let captureBase=CaelumCaptureBase(info.Subject);let objective=CaelumCaptureObjective(info.Subject);
        if(captureBase!=null || objective!=null)
            titleColor=(captureBase!=null?captureBase.Side:objective.Side)==0?Font.CR_RED:Font.CR_LIGHTBLUE;
        if(other!=null && match!=null && match.TeamsEnabled() && match.Member(other.PlayerNumber()))
        {
            int team=match.Team[other.PlayerNumber()];
            title=CaelumStandaloneMatch.TeamName(team).." - "..title;titleColor=team==0?Font.CR_RED:Font.CR_LIGHTBLUE;
        }
        Text(font,titleColor,title,Screen.GetWidth()/2,textY,width-16,scale);textY+=row;
        if(stats)
        {
            String resources[4];
            resources[0]=Resource("CA_HUD_HEALTH",info.Subject.health,enemy!=null?enemy.CombatMaximumHealth:other.CaelumMaximumHealth);
            resources[1]=Resource("CA_HUD_ANIMA",enemy!=null?enemy.CurrentCombatAnima:other.CurrentAnima,enemy!=null?enemy.MaximumCombatAnima:other.DerivedStats.MaximumAnima);
            resources[2]=Resource("CA_HUD_AIR",enemy!=null?enemy.CurrentCombatAir:other.CurrentAir,enemy!=null?enemy.MaximumCombatAir:other.DerivedStats.MaximumAir);
            resources[3]=Resource("CA_HUD_ADRENALINE",enemy!=null?enemy.CurrentCombatAdrenaline:other.CurrentAdrenaline,enemy!=null?enemy.MaximumCombatAdrenaline:other.DerivedStats.MaximumAdrenaline);
            for(int i=0;i<4;i++)Text(font,Font.CR_WHITE,resources[i],x+(width/4+(i%2)*width/2)*scale.X,textY+(i/2)*row,width/2-16,scale);
            textY+=row*2;
            double insight=user.Attributes!=null?user.Attributes.Insight:0;
            for(int i=0;i<12;i++)
            {
                String value=CaelumTargetInfo.VisibleAttribute(CaelumTargetInfo.Attribute(info.Subject,i),insight);
                String label=StringTable.Localize(CaelumTargetPanelData.AttributeKey(i),false)..": "..value;
                Text(font,value=="¿?"?Font.CR_GRAY:Font.CR_WHITE,label,x+(width/6+(i%3)*width/3)*scale.X,textY+(i/3)*row,width/3-12,scale);
            }
            textY+=row*4;
        }
        for(int i=0;i<actionRows;i++)
        {Text(font,Font.CR_GOLD,lines.StringAt(i),Screen.GetWidth()/2,textY,width-16,scale);textY+=row;}
        lines.Destroy();return y+height+CaelumTargetPanelData.PADDING*scale.Y;
    }

    static void Text(Font font,int color,String text,double x,double y,double width,Vector2 scale)
    {
        double fit=Min(1.0,width/Max(1,font.StringWidth(text)));
        Screen.DrawText(font,color,x-font.StringWidth(text)*scale.X*fit/2,y,text,
            DTA_SCALEX,scale.X*fit,DTA_SCALEY,scale.Y*fit,DTA_SHADOW,true);
    }
}
