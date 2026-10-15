// #260: gesto nativo, pago único y llegada al límite del modo actual.
class CaelumMovementImpulse : Object play
{
    static void Clear(CaelumPlayer user)
    {
        user.MovementTapReady=false;
        user.MovementTapPending=0;
        for(int i=0;i<4;i++)user.MovementTapTimes[i]=0;
    }

    static bool MediumAllowed(CaelumPlayer user)
    {
        if(user.WaterLevel>0 || (user.bNOGRAVITY && user.bFLY))return true;
        // MovePlayer precede a CheckJump: no autorizar el tic que inicia el salto.
        return (user.Pos.Z<=user.FloorZ || user.bOnMobj)
            && (user.player.cmd.buttons & BT_JUMP)==0;
    }

    static void Observe(CaelumPlayer user,bool readingMenu)
    {
        if(!CaelumPlayerAuthority.CanMutate(user))return;
        int now=level.time+1;
        if(user.MovementTapLastTic==now && user.MovementTapMap==level.MapName)return;
        user.MovementTapLastTic=now;
        user.MovementTapPending=0;
        int mask=0;
        int buttons=user.player.cmd.buttons;
        // Botones nativos: W mantenida no vuelve a pulsarse al soltar S.
        // El signo sirve sólo para ejes analógicos sin botón direccional.
        if(buttons & BT_FORWARD)mask|=1;
        if(buttons & BT_BACK)mask|=2;
        if(buttons & BT_MOVERIGHT)mask|=4;
        if(buttons & BT_MOVELEFT)mask|=8;
        if((buttons & (BT_FORWARD|BT_BACK))==0)
        {
            if(user.player.cmd.forwardmove>0)mask|=1;
            if(user.player.cmd.forwardmove<0)mask|=2;
        }
        if((buttons & (BT_MOVERIGHT|BT_MOVELEFT))==0)
        {
            if(user.player.cmd.sidemove>0)mask|=4;
            if(user.player.cmd.sidemove<0)mask|=8;
        }
        bool blocked=readingMenu || user.CreationWizardOpen || !user.CharacterCreationComplete
            || user.EquipmentMenuOpen || user.CraftingMenuOpen || user.PalomoMerchantMenuOpen
            || user.HasActiveConversation() || CaelumTimeSkipState.IsOpen(user)
            || CaelumRestState.IsActive(user) || user.IsPhysicallyImmobilized()
            || user.health<=0 || user.player.playerstate!=PST_LIVE || user.reactiontime>0
            || (user.player.cheats & (CF_FROZEN|CF_TOTALLYFROZEN))!=0 || !MediumAllowed(user);
        if(blocked || !user.MovementTapReady || user.MovementTapMap!=level.MapName)
        {
            Clear(user);user.MovementTapReady=!blocked;
            user.MovementTapMap=level.MapName;user.MovementTapMask=mask;
            return;
        }
        for(int i=0;i<4;i++)
        {
            int bit=1<<i;
            if((mask & bit)==0 || (user.MovementTapMask & bit)!=0)continue;
            int first=user.MovementTapTimes[i];
            if(first>0 && now-first<=int(CaelumConstants.MOVEMENT_DOUBLE_TAP_SECONDS*TICRATE))
                user.MovementTapPending|=bit;
            else user.MovementTapTimes[i]=now;
        }
        user.MovementTapMask=mask;
        // Consumir el par incluso si no puede pagarse; dos diagonales son un gesto.
        if(user.MovementTapPending!=0)
            for(int i=0;i<4;i++)user.MovementTapTimes[i]=0;
    }

    static bool Begin(CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || user.MovementTapPending==0)return false;
        user.MovementTapPending=0;
        if(user.IsPhysicallyImmobilized() || !MediumAllowed(user) || user.DerivedStats==null
            || user.DerivedStats.TotalMass<=0
            || (user.player.cmd.forwardmove==0 && user.player.cmd.sidemove==0))return false;
        double friction,moveFactor;[friction,moveFactor]=user.GetFriction();
        if(friction<=0 || friction>=1 || user.bNOFRICTION)return false;
        double duration=CaelumConstants.MOVEMENT_ACCELERATION_SECONDS
            * user.DerivedStats.TotalMass/CaelumConstants.MOVEMENT_ACCELERATION_REFERENCE_KG;
        double cost=user.RunningAirCostPerSecond()*duration;
        if(!CaelumAirPayment.CanAfford(user,cost))return false;
        double previousAir=user.CurrentAir;
        CaelumAirPayment.Spend(user,cost);
        CaelumMainM00RonnieTrial.RecordAirLesson(user,previousAir-user.CurrentAir,true);
        user.UpdateAirStateEffects();
        user.MovementAccelerationFactor=1;
        user.MovementAccelerationStep=0;
        user.MovementAccelerationSeconds=duration;
        user.ApplyPhysicalMovement();
        return true;
    }

    static void Finish(CaelumPlayer user,vector3 thrust)
    {
        double friction,moveFactor;[friction,moveFactor]=user.GetFriction();
        // El propio motor ya resolvió modo, diagonal, orientación, postura,
        // inventario, agua y vuelo. Su impulso define el límite estacionario.
        vector3 target=thrust/(1-friction);
        double cap=target.Length();
        if(cap<=0)return;
        vector3 direction=target/cap;
        vector3 current=user.Vel;
        if(target.Z==0)current.Z=0;
        double along=current dot direction;
        double perpendicular=Max(0.0,current.LengthSquared()-along*along);
        // Conservar la componente lateral sin que una diagonal sume velocidad
        // por encima del límite. Un empuje ajeno ya más rápido no se recorta.
        if(current.Length()<cap)
            user.Vel+=direction*(Sqrt(Max(0.0,cap*cap-perpendicular))-along);
    }
}
