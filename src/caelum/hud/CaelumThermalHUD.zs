// Proyección de lectura: usa los umbrales autoritativos, sin acumular estado
// ni consultar clima, inventario mutable o geometría durante el dibujo.
class CaelumThermalHUD : Object
{
    const BAR_X=440.0;
    const BAR_Y=230.0;
    const BAR_WIDTH=180.0;
    const FILL_INSET=8.0;
    const FILL_WIDTH=164.0;
    const FILL_HEIGHT=7.0;
    const LABEL_Y=242.0;

    static clearscope double Range(double toughness)
    {return CaelumThermalRules.Threshold(3,toughness);}

    static clearscope double BandPosition(int edge)
    {
        if(edge==3)return 0.5;
        double boundary=CaelumThermalRules.Threshold(Abs(edge-3),0);
        return Position(edge<3 ? -boundary : boundary,0);
    }

    static clearscope double Position(double exposure,double toughness)
    {return 0.5+0.5*Clamp(exposure/Range(toughness),-1.0,1.0);}

    static clearscope int BandColor(int band)
    {
        int colors[6]={0x377DAA,0x539FBC,0x789C9F,0xAD9873,0xD18D45,0xBC5743};
        return colors[Clamp(band,0,5)];
    }

    static clearscope int ExposureColor(double exposure,double toughness)
    {
        double position=Position(exposure,toughness);
        for(int band=0;band<5;band++)
            if(position<BandPosition(band+1))return BandColor(band);
        return BandColor(5);
    }

    static clearscope String StateKey(double exposure,double toughness)
    {return CaelumThermalRules.Severity(exposure,toughness)==0 ? "CA_HUD_THERMAL_SAFE"
        : CaelumThermalRules.StateKey(exposure,toughness);}

    static clearscope CaelumPlayer ViewedPlayer(int viewer)
    {
        if(viewer<0 || viewer>=MAXPLAYERS || !playeringame[viewer])return null;
        let camera=CaelumPlayer(players[viewer].camera);
        if(camera!=null && camera.player!=null && camera.player.playerstate==PST_LIVE)return camera;
        return CaelumPlayer(players[viewer].mo);
    }
}
