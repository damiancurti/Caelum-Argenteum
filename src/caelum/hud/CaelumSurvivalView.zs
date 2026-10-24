// #256: presentación compartida, sin escritura sobre los recursos del personaje.
class CaelumSurvivalView : Object
{
    static clearscope int State(CaelumPlayer user, int resource)
    { return resource == 0 ? user.HungerState : resource == 1 ? user.ThirstState : user.SleepState; }
    static clearscope double Value(CaelumPlayer user, int resource)
    { return resource == 0 ? user.CurrentHunger : resource == 1 ? user.CurrentThirst : user.CurrentSleep; }
    static clearscope String NameKey(int resource)
    { return resource == 0 ? "CA_HUD_HUNGER" : resource == 1 ? "CA_HUD_THIRST" : "CA_HUD_SLEEP"; }
    static clearscope String Icon(int resource)
    {
        return "graphics/caelum/ui/hud/icons/ca_hud_icon_" ..
            (resource == 0 ? "hunger" : resource == 1 ? "thirst" : resource == 2 ? "sleep" : resource == 3 ? "thermal" : "contamination") .. ".png";
    }
    static clearscope String ContaminationStateKey(CaelumPlayer user)
    {
        double value=CaelumFoodIllness.Value(user);
        if(value<=0)return "CA_FOOD_CLEAN";
        if(value<=CaelumFoodData.ILLNESS_THRESHOLD)return "CA_FOOD_CONTAMINATED";
        bool immune=user.Attributes!=null && CaelumToughnessRules.StatusResponse(user.Attributes.Toughness)<=0;
        if(value>=CaelumContaminationData.SEVERE_THRESHOLD)
            return immune ? "CA_CONTAMINATION_SICK_IMMUNE" : "CA_CONTAMINATION_SICK";
        if(immune)
            return "CA_FOOD_IMMUNE";
        return "CA_FOOD_CONTAMINATED";
    }
    static clearscope int ContaminationColor(CaelumPlayer user)
    {return CaelumFoodIllness.Value(user)>CaelumFoodData.ILLNESS_THRESHOLD ? Font.CR_RED : Font.CR_GREEN;}
    static clearscope int BaseColor(int resource)
    { return resource == 0 ? 0x75A84A : resource == 1 ? 0x3F9FD2 : 0x8074C8; }
    static clearscope String StateKey(int resourceType, int state)
    {
        if (state == CaelumConstants.SURVIVAL_STATE_NORMAL)
        {
            return "CA_SURVIVAL_STATE_NORMAL";
        }
        if (resourceType == 0)
        {
            return state == CaelumConstants.SURVIVAL_STATE_CRITICAL
                ? "CA_HUNGER_STATE_CRITICAL" : "CA_HUNGER_STATE_LOW";
        }
        if (resourceType == 1)
        {
            return state == CaelumConstants.SURVIVAL_STATE_CRITICAL
                ? "CA_THIRST_STATE_CRITICAL" : "CA_THIRST_STATE_LOW";
        }
        return state == CaelumConstants.SURVIVAL_STATE_CRITICAL
            ? "CA_SLEEP_STATE_CRITICAL" : "CA_SLEEP_STATE_LOW";
    }

    static clearscope int TextColor(int state)
    {
        if (state == CaelumConstants.SURVIVAL_STATE_CRITICAL) return Font.CR_RED;
        if (state == CaelumConstants.SURVIVAL_STATE_LOW) return Font.CR_GOLD;
        return Font.CR_GREEN;
    }

    static ui void Bar(double value, int state, double barX, double barY, double barWidth, int baseColor)
    {
        Vector2 pos, size;
        [pos, size] = Screen.VirtualToRealCoords((barX,barY),(barWidth,7),(640,360),false,false);
        int x=int(pos.X), y=int(pos.Y);
        int width=Max(1,int(size.X)), height=Max(1,int(size.Y));
        int fill = int(width * Clamp(value / 100.0, 0.0, 1.0));
        // Conservar la paleta de cada recurso en todos sus estados.
        int barColor = baseColor;

        if (baseColor == 0x75A84A)
        {
            if (state == CaelumConstants.SURVIVAL_STATE_LOW) barColor = 0xA5A139;
            if (state == CaelumConstants.SURVIVAL_STATE_CRITICAL) barColor = 0x9D5643;
        }
        else if (baseColor == 0x3F9FD2)
        {
            if (state == CaelumConstants.SURVIVAL_STATE_LOW) barColor = 0x8A9D7D;
            if (state == CaelumConstants.SURVIVAL_STATE_CRITICAL) barColor = 0x826D87;
        }
        else
        {
            if (state == CaelumConstants.SURVIVAL_STATE_LOW) barColor = 0xAA876F;
            if (state == CaelumConstants.SURVIVAL_STATE_CRITICAL) barColor = 0xA55882;
        }
        Screen.Dim(0x161616, 0.85, x, y, width, height);
        if (fill > 0) Screen.Dim(barColor, 0.95, x, y, fill, height);
    }

    static ui void ThermalBar(CaelumPlayer localPlayer, double barX, double barY, double barWidth)
    {
        let record=CaelumPersistentCharacterState(localPlayer.FindInventory("CaelumPersistentCharacterState"));
        let thermal=record!=null ? record.ThermalState : null;
        Vector2 pos, size;
        [pos, size] = Screen.VirtualToRealCoords((barX,barY),(barWidth,7),(640,360),false,false);
        int x=int(pos.X), y=int(pos.Y);
        int width=Max(1,int(size.X)), height=Max(1,int(size.Y));
        int stroke=Max(1,int(Screen.GetWidth()/640.0));
        int strokeY=Max(1,int(Screen.GetHeight()/360.0));
        for(int band=0;band<6;band++)
        {
            int left=x+int(width*CaelumThermalHUD.BandPosition(band));
            int right=x+int(width*CaelumThermalHUD.BandPosition(band+1));
            Screen.Dim(CaelumThermalHUD.BandColor(band),0.80,left,y,Max(1,right-left),height);
        }
        // ±10, ±20 y el cero se distinguen también por geometría, sin color.
        for(int tick=1;tick<6;tick++)
            Screen.Dim(tick==3 ? 0xFFFFFF : 0x20252B,0.9,
                x+int(width*CaelumThermalHUD.BandPosition(tick)),y,stroke,height);
        if(thermal!=null)
        {
            double toughness=localPlayer.Attributes!=null ? localPlayer.Attributes.Toughness : thermal.Toughness;
            double exposure=thermal.Exposure;
            int marker=x+int((width-1)*CaelumThermalHUD.Position(exposure,toughness));
            Screen.Dim(0x080C10,1,marker-2*stroke,y-strokeY,5*stroke,height+2*strokeY);
            Screen.Dim(0xFFFFFF,1,marker,y-strokeY,stroke,height+2*strokeY);
        }
    }

    static ui String, int, int ThermalLabel(CaelumPlayer localPlayer)
    {
        let record=CaelumPersistentCharacterState(localPlayer.FindInventory("CaelumPersistentCharacterState"));
        let thermal=record!=null ? record.ThermalState : null;
        String label=StringTable.Localize("CA_HUD_THERMAL_UNAVAILABLE",false);
        int textColor=Font.CR_GRAY;
        int textTint=0xFFFFFFFF;
        if(thermal!=null)
        {
            double toughness=localPlayer.Attributes!=null ? localPlayer.Attributes.Toughness : thermal.Toughness;
            double exposure=thermal.Exposure;
            textColor=Font.CR_WHITE;
            textTint=0xFF000000 | CaelumThermalHUD.ExposureColor(exposure,toughness);
            String stateName=StringTable.Localize(CaelumThermalHUD.StateKey(exposure,toughness),false);
            bool beyond=Abs(exposure)>CaelumThermalHUD.Range(toughness);
            String key=beyond ? (exposure<0 ? "CA_HUD_THERMAL_BELOW" : "CA_HUD_THERMAL_ABOVE") : "CA_HUD_THERMAL_VALUE";
            double displayed=beyond ? (exposure<0 ? -1 : 1)*CaelumThermalHUD.Range(toughness) : exposure;
            String value=String.Format(Abs(displayed)<1000 ? "%+.1f" : "%+.2e",displayed);
            label=String.Format(StringTable.Localize(key,false),value,stateName);
        }
        return label,textColor,textTint;
    }

}

// Catálogo de etiquetas de presentación; no crea una tabla de resistencias nueva.
class CaelumCharacterView : Object
{
    static clearscope String ResistanceKey(int essence)
    {
        switch (essence)
        {
            case CaelumConstants.ESSENCE_FIRE: return "CA_CHARACTER_RESIST_FIRE";
            case CaelumConstants.ESSENCE_WATER: return "CA_CHARACTER_RESIST_WATER";
            case CaelumConstants.ESSENCE_EARTH: return "CA_CHARACTER_RESIST_EARTH";
            case CaelumConstants.ESSENCE_WIND: return "CA_CHARACTER_RESIST_WIND";
            default: return "CA_CHARACTER_RESIST_QUINTESSENCE";
        }
    }
}
