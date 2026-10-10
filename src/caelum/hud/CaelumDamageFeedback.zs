// Colores y respuesta visual aprobados #137. No alteran daño ni recursos.
class CaelumDamageFeedback : Object play
{
    const REVISION=2;
    const FLASH_TICS=18;
    const MAX_FLASH_ALPHA=0.40;
    const FLASH_PER_HEALTH_FRACTION=0.80;
    const WOUNDED_EDGE_ALPHA=0.12;
    const CRITICAL_EDGE_ALPHA=0.30;
    const EDGE_SCREEN_FRACTION=0.09;

    static void ClearFlash(CaelumPlayer user)
    {
        user.DamageVFXStrength=0;
        user.DamageVFXTic=level.time;
        user.DamageVFXKind=-1;
        if(user.player!=null)user.player.damagecount=0;
    }

    static void EnsureRevision(CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || user.DamageFeedbackRevision>=REVISION)return;
        // Los saves anteriores pueden traer un tic del mapa de origen. Sólo
        // se descarta ese destello transitorio; salud y demás estados persisten.
        ClearFlash(user);
        user.DamageFeedbackRevision=REVISION;
    }

    static clearscope double FlashAlpha(CaelumPlayer user,double fraction=0)
    {
        double age=level.time+fraction-user.DamageVFXTic;
        // Un reloj de otro mapa nunca rejuvenece ni amplifica un golpe viejo.
        if(age<0 || age>=FLASH_TICS)return 0;
        return Clamp(user.DamageVFXStrength,0.0,MAX_FLASH_ALPHA)*(1.0-age/FLASH_TICS);
    }

    static clearscope Color Tint(int kind)
    {
        switch(kind)
        {
            case 0:return 0xff6820;
            case 3:return 0x9eeaff;
            case 5:return 0x8aef36;
            case 7:return 0xbb7aff;
        }
        return 0xd52d35;
    }

    static int Kind(CaelumPlayer user,Actor inflictor,Name damageType)
    {
        if(user.PendingDamageVFXKind>0)return user.PendingDamageVFXKind-1;
        let shot=CaelumActorProjectile(inflictor);
        if(shot!=null && shot.CaelumElementalPayloadPrepared)return CaelumElementalVFX.Kind(shot);
        let thermal=CaelumThermalBody.Get(user);
        if(damageType=='CaelumThermal' && thermal!=null)return thermal.Exposure<0 ? 3 : 0;
        if(damageType=='Fire')return 0;
        if(damageType=='Ice')return 3;
        if(damageType=='Poison')return 5;
        if(damageType=='Electric')return 7;
        return -1;
    }

    static void Record(CaelumPlayer user,Actor inflictor,Name damageType,int healthLost)
    {
        EnsureRevision(user);
        // El contador de Doom usa puntos absolutos sobre su barra de cien.
        if(user.player!=null)user.player.damagecount=0;
        if(healthLost<=0)return;
        double previous=FlashAlpha(user);
        user.DamageVFXStrength=Min(MAX_FLASH_ALPHA,previous
            +FLASH_PER_HEALTH_FRACTION*healthLost/Max(1,user.CaelumMaximumHealth));
        user.DamageVFXTic=level.time;
        user.DamageVFXKind=Kind(user,inflictor,damageType);
    }
}

class CaelumScreenFeedback : Object ui
{
    static void Edges(Color color,double strength,double widthFraction)
    {
        int width=Screen.GetWidth(),height=Screen.GetHeight();
        // Bandas contiguas, no superpuestas: el centro conserva todo su contraste.
        for(int i=0;i<12;i++)
        {
            int x0=int(width*widthFraction*i/12),x1=int(width*widthFraction*(i+1)/12);
            int y0=int(height*widthFraction*i/12),y1=int(height*widthFraction*(i+1)/12);
            double alpha=strength*(1.0-double(i)/12)*(1.0-double(i)/12);
            Screen.Dim(color,alpha,x0,y0,Max(1,x1-x0),height-2*y0);
            Screen.Dim(color,alpha,width-x1,y0,Max(1,x1-x0),height-2*y0);
            Screen.Dim(color,alpha,x1,y0,width-2*x1,Max(1,y1-y0));
            Screen.Dim(color,alpha,x1,height-y1,width-2*x1,Max(1,y1-y0));
        }
    }

    static void Damage(CaelumPlayer user,double fraction)
    {
        double alpha=CaelumDamageFeedback.FlashAlpha(user,fraction);
        if(alpha>0)Screen.Dim(CaelumDamageFeedback.Tint(user.DamageVFXKind),alpha,
            0,0,Screen.GetWidth(),Screen.GetHeight());
        double ratio=double(Max(0,user.health))/Max(1,user.CaelumMaximumHealth);
        if(user.health>0 && ratio<=CaelumConstants.HEALTH_WOUNDED_THRESHOLD)
        {
            double strength=ratio<=CaelumConstants.HEALTH_BADLY_WOUNDED_THRESHOLD
                ? CaelumDamageFeedback.CRITICAL_EDGE_ALPHA : CaelumDamageFeedback.WOUNDED_EDGE_ALPHA;
            Edges(CaelumDamageFeedback.Tint(-1),strength,CaelumDamageFeedback.EDGE_SCREEN_FRACTION);
        }
    }

    static void Lucidity(CaelumPlayer user,double fraction)
    {
        if(user.LucidityState==CaelumConstants.LUCIDITY_STATE_NORMAL)return;
        bool stunned=user.LucidityState==CaelumConstants.LUCIDITY_STATE_STUNNED;
        double time=level.time+fraction;
        double wave=0.5+0.5*Sin(time*(stunned ? 3.0 : 2.0));
        double strength=(stunned ? 0.34 : 0.20)*(0.8+0.2*wave);
        Edges(0x8066bb,strength,(stunned ? 0.20 : 0.13)+0.025*wave);
        // Aberración cromática periférica animada; no mueve la cámara ni la puntería.
        int width=Screen.GetWidth(),height=Screen.GetHeight();
        for(int band=0;band<48;band++)
        {
            int y0=height*band/48,y1=height*(band+1)/48;
            double bend=0.5+0.5*Sin(time*2.5+band*9);
            int edge=Max(1,int(width*(0.015+0.025*bend)*(stunned ? 1.8 : 1.0)));
            for(int layer=0;layer<4;layer++)
            {
                int x0=edge*layer/4,x1=edge*(layer+1)/4;
                double alpha=strength*(1.0-double(layer)/4)*(1.0-double(layer)/4);
                Screen.Dim(0x37b9dc,alpha,x0,y0,Max(1,x1-x0),y1-y0);
                Screen.Dim(0xda64ba,alpha,width-x1,y0,Max(1,x1-x0),y1-y0);
            }
        }
    }
}
