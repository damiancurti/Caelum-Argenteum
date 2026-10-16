// #247: ventana de clase y recorrido guardados por jugador, sin alterar atributos.
class CaelumFormationBreakerEffect : Inventory
{
    int Revision, RemainingTics, DashTics;
    double Power, DashSpeed, DashDefense, NormalCap, TrailClock;
    int ForwardInput, SideInput;
    vector2 Direction;
    String DashMap;

    override void Tick()
    {
        Super.Tick();
        if(Owner==null || Owner.health<=0)
        {if(Owner!=null)CaelumFormationBreaker.EndDash(CaelumPlayer(Owner));Destroy();return;}
        if(RemainingTics>0)RemainingTics--;
        if(RemainingTics<=0 && DashTics<=0)Destroy();
    }
    Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE }
    States { Spawn: TNT1 A -1; Stop; }
}

// Fotografía del sprite compuesto actual: no tiene física ni sigue al dueño.
class CaelumFormationAfterimage : Actor
{
    int Age;
    override void Tick()
    {
        Super.Tick();
        Age++;
        double remaining=1.0-Age/(CaelumFormationBreaker.TRAIL_LIFETIME*TICRATE);
        if(remaining<=0){Destroy();return;}
        Alpha=CaelumFormationBreaker.TRAIL_ALPHA*remaining;
    }
    Default { +NOBLOCKMAP +NOINTERACTION +NOGRAVITY RenderStyle "Translucent"; }
    States { Spawn: TNT1 A -1; Stop; }
}

class CaelumFormationBreaker : Object play
{
    const REVISION=1;
    const SPEED_MULTIPLIER=4.0;
    const DEFENSE_MULTIPLIER=10.0;
    const DASH_SECONDS=1.0;
    const TRAIL_ALPHA=0.5;
    const TRAIL_INTERVAL=0.1;
    const TRAIL_LIFETIME=0.3;

    static clearscope CaelumFormationBreakerEffect Status(CaelumPlayer user)
    {return user==null?null:CaelumFormationBreakerEffect(user.FindInventory("CaelumFormationBreakerEffect"));}

    static clearscope bool Dashing(CaelumPlayer user)
    {
        let effect=Status(user);
        return user!=null && user.health>0 && effect!=null && effect.Revision==REVISION
            && effect.DashTics>0 && effect.DashMap==level.MapName;
    }

    static clearscope double Defense(CaelumPlayer user)
    {return Dashing(user)?Status(user).DashDefense:1.0;}

    static bool Grounded(CaelumPlayer user)
    {return user.WaterLevel==0 && !user.bNOGRAVITY && !user.bFLY
        && (user.Pos.Z<=user.FloorZ || user.bOnMobj);}

    static void EndDash(CaelumPlayer user)
    {
        let effect=Status(user);
        if(effect==null || effect.DashTics<=0)return;
        effect.DashTics=0;
        // No volver a impulsar un cuerpo detenido por el contacto.
        double speed=user.Vel.XY.Length();
        if(speed>effect.NormalCap && speed>0)
        {user.Vel.X*=effect.NormalCap/speed;user.Vel.Y*=effect.NormalCap/speed;}
    }

    static bool Stand(CaelumPlayer user)
    {
        if(user.player.crouchfactor>=1)return true;
        double savedHeight=user.Height;
        user.Height=user.FullHeight;
        bool fits=user.TryMove(user.Pos.XY,false,null);
        user.Height=savedHeight;
        if(!fits)return false;
        user.player.crouchfactor=1;
        user.player.crouching=0;user.player.crouchdir=0;
        user.player.viewheight=user.ViewHeight;user.player.crouchviewdelta=0;
        user.IsCrouching=false;
        return true;
    }

    // true consume el gesto, incluso si el techo impide ponerse erguido.
    static bool TryBegin(CaelumPlayer user,int gesture)
    {
        if(Dashing(user))return true;
        let effect=Status(user);
        if(effect==null || effect.Revision!=REVISION || effect.RemainingTics<=0
            || (gesture & 1)==0 || user.player.cmd.forwardmove<=0 || !Grounded(user))return false;
        if(user.IsPhysicallyImmobilized() || (user.player.cmd.buttons & BT_JUMP))return true;
        double friction,moveFactor;[friction,moveFactor]=user.GetFriction();
        if(friction<=0 || friction>=1 || user.bNOFRICTION || !Stand(user))return true;
        effect.DashTics=Max(1,int(DASH_SECONDS*effect.Power*TICRATE+0.5));
        effect.DashSpeed=SPEED_MULTIPLIER*effect.Power;
        effect.DashDefense=DEFENSE_MULTIPLIER*effect.Power;
        effect.Direction=(0,0);effect.NormalCap=0;effect.TrailClock=0;
        effect.DashMap=level.MapName;
        effect.ForwardInput=int(gameinfo.normforwardmove[1]*256);
        effect.SideInput=user.player.cmd.sidemove==0?0
            :int(gameinfo.normsidemove[1]*256)*(user.player.cmd.sidemove>0?1:-1);
        return true;
    }

    static void Guard(CaelumPlayer user,bool modal)
    {
        if(!CaelumPlayerAuthority.CanMutate(user))return;
        let effect=Status(user);
        if(effect==null || effect.DashTics<=0)return;
        if(!Dashing(user) || modal || !Grounded(user) || user.IsPhysicallyImmobilized()
            || user.player==null || user.player.playerstate!=PST_LIVE || user.reactiontime>0
            || (user.player.cheats & (CF_FROZEN|CF_TOTALLYFROZEN))!=0
            || (user.player.cmd.buttons & BT_JUMP))
        {EndDash(user);return;}
        // Se filtra antes de CheckCrouch, sin bloquear la mirada ni el salto.
        user.player.cmd.buttons &= ~BT_CROUCH;
        user.player.crouching=0;user.player.crouchdir=0;
    }

    static void PrepareMove(CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || !Dashing(user))return;
        let effect=Status(user);
        user.player.cmd.forwardmove=effect.ForwardInput;
        user.player.cmd.sidemove=effect.SideInput;
        user.player.cmd.buttons=(user.player.cmd.buttons & ~BT_CROUCH)|BT_RUN;
        user.MovementAccelerationFactor=1;user.MovementAccelerationStep=0;
        user.ApplyPhysicalMovement();
    }

    static void Drive(CaelumPlayer user,vector3 thrust)
    {
        if(!CaelumPlayerAuthority.CanMutate(user))return;
        let effect=Status(user);
        double friction,moveFactor;[friction,moveFactor]=user.GetFriction();
        if(friction<=0 || friction>=1 || user.bNOFRICTION){EndDash(user);return;}
        vector2 steady=thrust.XY/(1-friction);
        effect.NormalCap=steady.Length();
        if(effect.NormalCap<=0){EndDash(user);return;}
        if(effect.Direction.LengthSquared()==0)effect.Direction=steady/effect.NormalCap;
        vector2 velocity=effect.Direction*effect.NormalCap*effect.DashSpeed;
        user.Vel.X=velocity.X;user.Vel.Y=velocity.Y;
    }

    static void Photograph(Actor source)
    {
        if(source==null || source.bInvisible)return;
        let ghost=CaelumFormationAfterimage(Actor.Spawn("CaelumFormationAfterimage",source.Pos));
        if(ghost==null)return;
        ghost.sprite=source.sprite;ghost.frame=source.frame;
        ghost.Scale=source.Scale;ghost.Angle=source.Angle;
        ghost.WorldOffset=source.WorldOffset;ghost.SpriteOffset=source.SpriteOffset;
        ghost.FloorClip=source.FloorClip;ghost.Translation=source.Translation;
        ghost.Alpha=TRAIL_ALPHA;
    }

    // Después de resolver ambos receptores: el contacto final conserva defensa.
    static void AfterPhysics(CaelumPlayer user,vector3 before)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || !Dashing(user))return;
        let effect=Status(user);
        vector3 travelled=user.Pos-before;
        // Un cuerpo puede transmitir impulso y limpiar BlockingMobj durante
        // TryMove. El avance real detecta también ese impedimento transitorio.
        bool obstructed=(travelled.XY dot effect.Direction)+0.00001
            <effect.NormalCap*effect.DashSpeed;
        if(travelled.XY.LengthSquared()>0)
        {
            effect.TrailClock+=1.0/TICRATE;
            if(effect.TrailClock+1e-8>=TRAIL_INTERVAL)
            {
                effect.TrailClock-=TRAIL_INTERVAL;
                // La cabeza modular puede recibir Tick después del jugador.
                // Sin sincronizarla, la fotografía queda un paso detrás del cuerpo.
                if(user.AppearanceHead!=null)user.AppearanceHead.UpdateVisual();
                Photograph(user);Photograph(user.AppearanceHead);
            }
        }
        effect.DashTics--;
        if(effect.DashTics<=0)
        {effect.DashTics=1;EndDash(user);}
        else if(obstructed || !Grounded(user) || user.IsPhysicallyImmobilized())EndDash(user);
    }

    static bool Release(CaelumPlayer user)
    {
        if(user==null || user.health<=0 || user.DerivedStats==null)return false;
        let effect=Status(user);
        if(effect==null)effect=CaelumFormationBreakerEffect(user.GiveInventoryType("CaelumFormationBreakerEffect"));
        if(effect==null)return false;
        effect.Revision=REVISION;effect.Power=CaelumClassAbilityRules.BeneficialPower(user);
        effect.RemainingTics=Max(effect.RemainingTics,
            int(CaelumClassAbilityRules.EFFECT_SECONDS*effect.Power*TICRATE+0.5));
        CaelumNotifications.Notify(user,StringTable.Localize("CA_FORMATION_BREAKER_CAST",false));
        return true;
    }
}
