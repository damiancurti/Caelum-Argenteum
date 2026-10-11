// #162: una herramienta, dos modos excluyentes, un pago por tic real.
class CaelumUtilityStaffRules : Object
{
    const REVISION=1;
    const FIRE=1;
    const ICE=2;
    // Registro geométrico de la punta en la vista de primera persona.
    const TIP_FORWARD=16.0;
    const TIP_RIGHT=6.5;
    const TIP_UP=4.0;
    const CONTACT_WEAR_TICS=TICRATE;
}

class CaelumUtilityStaff : Object play
{
    static clearscope double CostPerSecond(CaelumPlayer user)
    {
        return user!=null && user.DerivedStats!=null
            ? CaelumDemonBreathRules.ANIMA_PER_SECOND*user.DerivedStats.StaffAnimaCost
                /CaelumConstants.DEBUG_STAFF_ANIMA_COST : 0;
    }

    static bool CanEmit(CaelumPlayer user)
    {
        if(user==null || user.health<=0 || user.player==null || user.player.playerstate!=PST_LIVE
            || !user.CharacterCreationComplete || user.DerivedStats==null || user.WeaponModel==null
            || !user.WeaponModel.Equipped || user.WeaponModel.Durability<=0
            || user.WeaponModel.WeaponType!=CaelumConstants.WEAPON_TYPE_UTILITY_STAFF
            || !(user.player.ReadyWeapon is "CaelumUtilityStaffSelectorWeapon")
            || user.IsPhysicallyImmobilized() || user.CombatBlockModeActive
            || user.EquipmentMenuOpen || user.CraftingMenuOpen || user.CreationWizardOpen
            || user.StaffCastPending || user.WeaponChargeActive || CaelumRestState.IsActive(user))return false;
        return user.player.PendingWeapon==null || user.player.PendingWeapon==WP_NOCHANGE
            || user.player.PendingWeapon==user.player.ReadyWeapon;
    }

    static void Request(CaelumPlayer user,int mode)
    {
        if(CanEmit(user))user.UtilityStaffRequestedMode=mode;
    }

    static void EndEmission(CaelumPlayer user)
    {
        if(user==null)return;
        user.UtilityStaffRequestedMode=0;
        let stream=user.UtilityStaffStream; user.UtilityStaffStream=null;
        if(stream!=null)stream.Destroy();
    }

    static void Update(CaelumPlayer user)
    {
        if(!CanEmit(user)){EndEmission(user);return;}
        int buttons=user.player.cmd.buttons;
        int mode=(buttons&BT_ATTACK)!=0 ? CaelumUtilityStaffRules.FIRE
            : (buttons&BT_ALTATTACK)!=0 ? CaelumUtilityStaffRules.ICE : 0;
        if(mode==0 || user.UtilityStaffRequestedMode==0){EndEmission(user);return;}
        let item=user.FindNativeEquipmentItemById(user.ActiveWeaponItemId);
        if(item==null || item.Owner!=user || !item.Equipped || item.InMagicBox)
        {EndEmission(user);return;}
        if(user.UtilityStaffStream!=null && (CaelumUtilityStaffStream(user.UtilityStaffStream).Mode!=mode
            || CaelumUtilityStaffStream(user.UtilityStaffStream).SourceItem!=item || CaelumUtilityStaffStream(user.UtilityStaffStream).SourceMap!=level.MapName))
        {
            EndEmission(user); user.UtilityStaffRequestedMode=mode;
        }
        double cost=CostPerSecond(user)/TICRATE;
        if(user.CurrentAnima<cost)
        {user.LastStaffInsufficientAnima=true;EndEmission(user);return;}
        if(user.UtilityStaffStream==null)
        {
            let stream=CaelumUtilityStaffStream(Actor.Spawn("CaelumUtilityStaffStream",user.Pos,NO_REPLACE));
            if(stream==null)return;
            stream.Emitter=user; stream.SourceItem=item; stream.Mode=mode;
            stream.SourceMap=level.MapName;
            user.UtilityStaffStream=stream;
        }
        user.CurrentAnima-=cost;
        user.LastStaffInsufficientAnima=false;
        CaelumUtilityStaffStream(user.UtilityStaffStream).PaidTick();
        CaelumMainM00MagicTrial.RecordAnimaSpent(user,cost);
    }
}

class CaelumUtilityStaffStream : Actor
{
    CaelumPlayer Emitter;
    CaelumEquipmentItem SourceItem;
    int Mode,NextHeatTic,Revision;
    String SourceMap;
    double PaidSeconds,TotalPaidSeconds;
    Vector3 Direction;
    Actor Visuals[4];
    Default { +NOBLOCKMAP +NOGRAVITY +NOCLIP +INVISIBLE Radius 1; Height 1; }
    States { Spawn: TNT1 A -1; Stop; }

    void UpdateOrigin()
    {
        double angle=Emitter.Angle,pitch=Emitter.Pitch;
        Direction=(Cos(angle)*Cos(pitch),Sin(angle)*Cos(pitch),-Sin(pitch));
        vector3 eye=Emitter.Pos+(0,0,Emitter.player.viewheight);
        vector3 tip=eye+Direction*CaelumUtilityStaffRules.TIP_FORWARD
            +(Sin(angle),-Cos(angle),0)*CaelumUtilityStaffRules.TIP_RIGHT
            +(0,0,CaelumUtilityStaffRules.TIP_UP);
        vector3 ray=tip-eye; FLineTraceData hit;
        bool blocked=Emitter.LineTrace(VectorAngle(ray.X,ray.Y),ray.Length(),
            -VectorAngle(ray.XY.Length(),ray.Z),TRF_THRUACTORS|TRF_ABSPOSITION,
            eye.Z,eye.X,eye.Y,hit);
        SetOrigin(blocked ? eye : tip,false);
    }

    void PaidTick()
    {
        Revision=CaelumUtilityStaffRules.REVISION;
        UpdateOrigin();
        if(NextHeatTic<=0)NextHeatTic=level.time+TICRATE;
        PaidSeconds+=1.0/TICRATE; TotalPaidSeconds+=1.0/TICRATE;
        bool ice=Mode==CaelumUtilityStaffRules.ICE;
        CaelumElementalVFX.Light(self,ice ? 3 : 0);
        for(int i=0;i<CaelumDemonBreathRules.SEGMENTS;i++)
        {
            double along=CaelumDemonBreathRules.Range()*(i+0.5)/CaelumDemonBreathRules.SEGMENTS;
            vector3 point=Pos+Direction*along;
            if(!CaelumElementalStream.Visible(self,point))
            {if(Visuals[i]!=null){Visuals[i].Destroy();Visuals[i]=null;}continue;}
            if(Visuals[i]==null)Visuals[i]=Spawn("CaelumUtilityStreamVisual",point,NO_REPLACE);
            let visual=CaelumUtilityStreamVisual(Visuals[i]);
            if(visual==null)continue;
            visual.master=self; visual.SetOrigin(point,false);
            visual.Angle=VectorAngle(Direction.X,Direction.Y);
            visual.Pitch=-VectorAngle(Direction.XY.Length(),Direction.Z);
            visual.Kind=ice ? 3 : 0; visual.Segment=i;
            // Diámetro visual de la sección del mismo cono; los atlas de
            // #137 se registran con un lienzo nativo de 64 unidades.
            double width=2*along*Tan(CaelumDemonBreathRules.CONE_DEGREES/2)/64;
            visual.Scale=(width,width);
        }
        bool contacted=false;
        let nearby=BlockThingsIterator.Create(Emitter,CaelumDemonBreathRules.Range()+Emitter.Radius
            +CaelumUtilityStaffRules.TIP_FORWARD+CaelumUtilityStaffRules.TIP_RIGHT);
        while(nearby.Next())
        {
            // El muñeco verifica el mismo cono y oclusión sin recibir estados ni desgaste.
            if(nearby.thing is "CaelumM00TrainingDummy"
                && CaelumElementalStream.Contact(self,Emitter,Direction,nearby.thing))
                CaelumMainM00MagicTrial.RecordStaffContact(Emitter,nearby.thing,ice);
            if(CaelumElementalStream.Status(nearby.thing)!=null
                && CaelumElementalStream.Contact(self,Emitter,Direction,nearby.thing))
            {CaelumElementalStream.ApplyContact(Emitter,nearby.thing,ice);contacted=true;}
        }
        if(contacted && SourceItem!=null)
        {
            SourceItem.UtilityStaffContactTics++;
            if(SourceItem.UtilityStaffContactTics>=CaelumUtilityStaffRules.CONTACT_WEAR_TICS)
            {
                SourceItem.UtilityStaffContactTics-=CaelumUtilityStaffRules.CONTACT_WEAR_TICS;
                Emitter.ApplyWeaponDurabilityFromSuccessfulDamage(CaelumElementalStream.Damage(Emitter),
                    CaelumConstants.WEAPON_TYPE_UTILITY_STAFF,1,SourceItem.EquipmentSize,SourceItem,true);
            }
        }
        if(level.time>=NextHeatTic){FlushHeat();NextHeatTic=level.time+TICRATE;}
        if(SourceItem==null || SourceItem.Durability<=0)CaelumUtilityStaff.EndEmission(Emitter);
    }

    void FlushHeat()
    {
        double seconds=PaidSeconds; PaidSeconds=0;
        if(SourceMap==level.MapName)
            CaelumElementalStream.Transfer(self,Direction,seconds,Mode==CaelumUtilityStaffRules.ICE);
    }

    override void Tick()
    {
        Super.Tick();
        if(Emitter==null || Emitter.health<=0 || Emitter.UtilityStaffStream!=self
            || SourceMap!=level.MapName)Destroy();
    }

    override void OnDestroy()
    {
        FlushHeat(); A_RemoveLight('CaelumElement');
        for(int i=0;i<4;i++)if(Visuals[i]!=null)Visuals[i].Destroy();
        Super.OnDestroy();
    }
}

class CaelumUtilityStreamVisual : Actor
{
    int Age,Segment,Kind;
    override void Tick()
    {
        Super.Tick();
        if(master==null || master.bDestroyed){Destroy();return;}
        sprite=GetSpriteIndex(CaelumElementalVFXData.SpriteName(Kind));
        frame=(Age/CaelumElementalVFXData.FRAME_TICS+Segment)%4;
        Age++;
    }
    Default { +NOINTERACTION +NOGRAVITY +BRIGHT RenderStyle "Add"; Alpha 0.55; Scale 0.35; }
    States { Spawn: TNT1 A -1; Stop; }
}

class CaelumUtilityStaffSelectorWeapon : CaelumPhysicalSelectorWeapon
{
    Default { Weapon.SelectionOrder 101; Weapon.SlotNumber 1; }
    override int GetCaelumWeaponType(){return CaelumConstants.WEAPON_TYPE_UTILITY_STAFF;}
}

class CaelumUtilityStaffEvents : StaticEventHandler
{
    override void WorldUnloaded(WorldEvent e)
    {
        // Se liquida el intervalo pagado en el mapa de origen, antes de
        // congelar el hub; nunca se traslada radiación pendiente al destino.
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
            {
                let user=CaelumPlayer(players[i].mo);
                CaelumUtilityStaff.EndEmission(user);
                if(user!=null)
                {
                    if(user.BolasBinding!=null)user.BolasBinding.Resolve(false);
                    user.BolasPreparedTics=0;user.BolasPreparedItem=0;user.BolasReleaseUntil=0;
                }
            }
    }
}

class CaelumUtilityStaffFrames : Actor
{
    States (Actor,Weapon,Overlay)
    {
    Ready: DUST A -1; Stop;
    Fire: DUST B -1; Stop;
    Ice: DUST C -1; Stop;
    Equip: DUST D -1; Stop;
    Pickup: CUST A -1; Stop;
    }
}
