// Datos de presentación: tres segundos y fases visuales, sin reglas de coste.
class CaelumClassCastLayout : Object
{
    const SECONDS=3;
    const LOWER_END=0.25;
    const RAISE_END=0.50;
    const TURN_BEGIN=0.65;
    const TURN_END=0.90;
    const LOWER_DISTANCE=180.0;
    const HAND_SIZE=0.90;
    const HAND_Y=164.0;
    const PALM_Y=196.0;
    const PALM_VERTICAL_SCALE=1.10;
    const RIGHT_PALM_OFFSET=8.0;
    const LEFT_X=108.0;
    const RIGHT_X=212.0;
    const TURN_DEGREES=28.0;
    const EDGE_WIDTH=0.12;
}

// Componente compartido #238. El ciclo de habilidad decide cuándo iniciarlo;
// no cobra Ánima, activa efectos ni toma decisiones pendientes de diseño.
class CaelumClassCastView : Object play
{
    const REVISION=1;

    static void Begin(CaelumPlayer user)
    {
        if(user==null)return;
        user.ClassPreparationRevision=REVISION;
        user.ClassPreparationTics=CaelumClassCastLayout.SECONDS*TICRATE;
        user.CancelCombatBlockMode();
        user.CancelPendingStaffCast(false);
        user.CancelRangedReload();
        user.CancelWeaponCharge();
        user.PhysicalAttackPending=false;
        user.AttackAnimationDurationTics=0;
    }

    static void Advance(CaelumPlayer user)
    {
        // Los campos nuevos valen cero en saves anteriores; no se inicia nada.
        if(user.ClassPreparationRevision<REVISION)
            user.ClassPreparationRevision=REVISION;
        if(user.ClassPreparationTics>0)user.ClassPreparationTics--;
    }

    static clearscope bool Active(CaelumPlayer user)
    {return user!=null && user.ClassPreparationTics>0;}

    static double Smooth(double value)
    {value=Clamp(value,0.0,1.0);return value*value*(3.0-2.0*value);}

    static void Hand(CaelumPlayer user,int layer,bool left,bool palms,Vector2 position,double rotation)
    {
        int hand=palms?(left?6:7):(left?9:10);
        State pose=CaelumAppearanceHands.Hand(user,hand);
        int variant=CaelumAppearanceHands.Variant(user);
        if(palms && variant>=0 && variant<18)
            pose=GetDefaultByType("CaelumClassCastHandFrames").FindStateByString(
                String.Format("V%d_%d",variant,left?0:1));
        CaelumFirstPersonLayers.Place(user,layer,pose,position,
            CaelumFirstPersonLayers.Pivot(200+hand),CaelumClassCastLayout.HAND_SIZE,rotation);
    }

    static void Apply(CaelumPlayer user)
    {
        if(!Active(user) || user.player==null || user.health<=0
            || user.player.playerstate!=PST_LIVE || !user.CharacterCreationComplete
            || user.CreationWizardOpen || user.EquipmentMenuOpen || user.CraftingMenuOpen
            || CaelumRestState.IsActive(user) || user.ForcedSleepTics>0)return;
        double progress=1.0-user.ClassPreparationTics/double(CaelumClassCastLayout.SECONDS*TICRATE);
        if(progress<CaelumClassCastLayout.LOWER_END)
        {
            // Las capas reales se vuelven a dibujar antes de este desplazamiento.
            // No tocar el arma nativa ni acumular el descenso entre cuadros.
            double lower=CaelumClassCastLayout.LOWER_DISTANCE
                *Smooth(progress/CaelumClassCastLayout.LOWER_END);
            for(int layer=44;layer<=53;layer++)
            {
                let sprite=user.player.FindPSprite(layer);
                if(sprite!=null)
                {
                    sprite.x-=lower*0.85;sprite.y+=lower;
                    sprite.oldx=sprite.x;sprite.oldy=sprite.y;
                    sprite.bInterpolate=false;
                }
            }
            return;
        }
        user.A_ClearOverlays(10,50);
        user.A_ClearOverlays(53,53);
        double rise=Smooth((progress-CaelumClassCastLayout.LOWER_END)
            /(CaelumClassCastLayout.RAISE_END-CaelumClassCastLayout.LOWER_END));
        double turn=Smooth((progress-CaelumClassCastLayout.TURN_BEGIN)
            /(CaelumClassCastLayout.TURN_END-CaelumClassCastLayout.TURN_BEGIN));
        bool palms=turn>=0.5;
        double width=CaelumClassCastLayout.EDGE_WIDTH
            +(1.0-CaelumClassCastLayout.EDGE_WIDTH)*Abs(turn*2.0-1.0);
        double rotation=CaelumClassCastLayout.TURN_DEGREES*Sin(turn*180.0);
        double y=CaelumClassCastLayout.HAND_Y
            +(CaelumClassCastLayout.PALM_Y-CaelumClassCastLayout.HAND_Y)*turn
            +(1.0-rise)*CaelumClassCastLayout.LOWER_DISTANCE;
        Hand(user,51,true,palms,(CaelumClassCastLayout.LEFT_X,y),rotation);
        Hand(user,52,false,palms,(CaelumClassCastLayout.RIGHT_X,
            y+CaelumClassCastLayout.RIGHT_PALM_OFFSET*turn),-rotation);
        for(int hand=51;hand<=52;hand++)
        {
            let sprite=user.player.FindPSprite(hand);
            if(sprite!=null)
            {
                sprite.scale.X*=width;sprite.bAddBob=false;
                if(palms)sprite.scale.Y*=CaelumClassCastLayout.PALM_VERTICAL_SCALE;
                // Las armas compuestas limpian estas capas antes de recrearlas.
                // Su origen anterior no pertenece a las manos del lanzamiento.
                sprite.oldx=sprite.x;sprite.oldy=sprite.y;
                sprite.bInterpolate=false;
            }
        }
    }
}
