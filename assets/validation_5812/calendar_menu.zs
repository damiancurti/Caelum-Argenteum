// Diagnostic-only routing: the production live menu intentionally consumes F keys.
class CA502CalendarMenu : CaelumLiveMenu
{
    bool HideStats;
    override bool OnUIEvent(UIEvent e)
    {
        if(e.Type==UIEvent.Type_KeyDown)
        {
            String commandName="";
            if(e.KeyChar==UIEvent.Key_F1)commandName="ca502c_manual";
            else if(e.KeyChar==UIEvent.Key_F2){HideStats=false;commandName="ca502c_status";}
            else if(e.KeyChar==UIEvent.Key_F3)commandName="ca502c_wake";
            else if(e.KeyChar==UIEvent.Key_F4)commandName="ca502c_existing";
            else if(e.KeyChar==UIEvent.Key_F5)commandName="ca502c_missing";
            else if(e.KeyChar==UIEvent.Key_F6){HideStats=!HideStats;return true;}
            else if(e.KeyChar==UIEvent.Key_F7)commandName="ca502c_reading";
            else if(e.KeyChar==UIEvent.Key_F8)commandName="ca502c_cancel";
            if(commandName.Length()>0){EventHandler.SendNetworkEvent(commandName);return true;}
        }
        return Super.OnUIEvent(e);
    }
    override void Drawer()
    {
        Super.Drawer();if(HideStats)return;
        let checks=CA502HChecks(EventHandler.Find("CA502HChecks"));if(checks==null || !checks.CalendarHold)return;
        let font=Font.GetFont("CaelumMono");
        Screen.Dim(0x000000,0.9,0,0,Screen.GetWidth(),int(Screen.GetHeight()*0.21));
        Screen.DrawText(font,Font.CR_GOLD,8,6,checks.CalendarLine1,DTA_VIRTUALWIDTH,640,DTA_VIRTUALHEIGHT,360);
        Screen.DrawText(font,Font.CR_WHITE,8,20,checks.CalendarLine2,DTA_VIRTUALWIDTH,640,DTA_VIRTUALHEIGHT,360);
        Screen.DrawText(font,Font.CR_WHITE,8,34,checks.CalendarLine3,DTA_VIRTUALWIDTH,640,DTA_VIRTUALHEIGHT,360);
        Screen.DrawText(font,Font.CR_WHITE,8,48,checks.CalendarLine4,DTA_VIRTUALWIDTH,640,DTA_VIRTUALHEIGHT,360);
        Screen.DrawText(font,Font.CR_WHITE,8,62,"F1 fabricar | F3 despertar | F4 limpieza iniciada | F5 sin jabon | F7 leer",DTA_VIRTUALWIDTH,640,DTA_VIRTUALHEIGHT,360);
    }
}
