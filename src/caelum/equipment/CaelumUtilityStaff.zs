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

    static double ActorCostPerSecond(Actor emitter)
    {
        let user=CaelumPlayer(emitter);let npc=CaelumCombatActor(emitter);
        return user!=null && user.DerivedStats!=null
            ? CaelumDemonBreathRules.ANIMA_PER_SECOND*user.DerivedStats.StaffAnimaCost
                /CaelumConstants.DEBUG_STAFF_ANIMA_COST
            : npc!=null ? CaelumDemonBreathRules.ANIMA_PER_SECOND*npc.GetMagicAnimaCost(CaelumConstants.DEBUG_STAFF_ANIMA_COST)
                /CaelumConstants.DEBUG_STAFF_ANIMA_COST : 0;
    }

    static CaelumUtilityStaffStream Stream(Actor emitter)
    {
        let user=CaelumPlayer(emitter);let npc=CaelumCombatActor(emitter);
        return user!=null ? CaelumUtilityStaffStream(user.UtilityStaffStream)
            : npc!=null ? npc.CombatUtilityStaffStream : null;
    }

    static bool CanEmit(CaelumPlayer user)
    {
        if(user==null || user.health<=0 || user.player==null || user.player.playerstate!=PST_LIVE
            || !user.CharacterCreationComplete || user.DerivedStats==null || user.WeaponModel==null
            || !user.WeaponModel.Equipped || user.WeaponModel.Durability<=0
            || user.WeaponModel.WeaponType!=CaelumConstants.WEAPON_TYPE_UTILITY_STAFF
            || !(user.player.ReadyWeapon is "CaelumUtilityStaffSelectorWeapon")
            || user.IsPhysicallyImmobilized() || CaelumClassCastView.Active(user)
            || user.CombatBlockModeActive
            || user.EquipmentMenuOpen || user.CraftingMenuOpen || user.CreationWizardOpen
            || user.StaffCastPending || user.WeaponChargeActive || CaelumRestState.IsActive(user))return false;
        return user.player.PendingWeapon==null || user.player.PendingWeapon==WP_NOCHANGE
            || user.player.PendingWeapon==user.player.ReadyWeapon;
    }

    static void Request(CaelumPlayer user,int mode)
    {
        if(CanEmit(user))user.UtilityStaffRequestedMode=mode;
    }

    static void EndEmission(Actor emitter)
    {
        if(emitter==null)return;
        let user=CaelumPlayer(emitter);let npc=CaelumCombatActor(emitter);
        let stream=Stream(emitter);
        if(user!=null){user.UtilityStaffRequestedMode=0;user.UtilityStaffStream=null;}
        if(npc!=null)npc.CombatUtilityStaffStream=null;
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
        Emit(user,item,mode);
    }

    static bool Emit(Actor emitter,CaelumEquipmentItem item,int mode)
    {
        let user=CaelumPlayer(emitter);let npc=CaelumCombatActor(emitter);
        let resident=CaelumAnchoredResident(emitter);
        if(emitter==null || emitter.health<=0 || item==null || item.Owner!=emitter
            || !item.Equipped || item.InMagicBox || item.Durability<=0
            || item.ItemType!=CaelumConstants.WEAPON_TYPE_UTILITY_STAFF
            || (mode!=CaelumUtilityStaffRules.FIRE && mode!=CaelumUtilityStaffRules.ICE)
            || (resident!=null && resident.IsRuloPartyFighting() && mode==CaelumUtilityStaffRules.FIRE)
            || (npc!=null && (CaelumBolas.Restrained(npc) || CaelumBolas.Interrupted(npc))))
        {EndEmission(emitter);return false;}
        let stream=Stream(emitter);
        if(stream!=null && (stream.Mode!=mode || stream.SourceItem!=item || stream.SourceMap!=level.MapName))
        {EndEmission(emitter);stream=null;}
        double cost=ActorCostPerSecond(emitter)/TICRATE;
        double resource=user!=null ? user.CurrentAnima : npc!=null ? npc.CurrentCombatAnima : 0;
        if(resource<cost)
        {if(user!=null)user.LastStaffInsufficientAnima=true;EndEmission(emitter);return false;}
        if(stream==null)
        {
            stream=CaelumUtilityStaffStream(Actor.Spawn("CaelumUtilityStaffStream",emitter.Pos,NO_REPLACE));
            if(stream==null)return false;
            stream.Emitter=emitter; stream.SourceItem=item; stream.Mode=mode;
            stream.SourceMap=level.MapName;
            if(user!=null)user.UtilityStaffStream=stream;
            if(npc!=null)npc.CombatUtilityStaffStream=stream;
        }
        if(user!=null){user.CurrentAnima-=cost;user.LastStaffInsufficientAnima=false;}
        if(npc!=null){npc.CurrentCombatAnima-=cost;npc.MarkActorCombatActivity();}
        stream.PaidTick();
        if(user!=null)CaelumMainM00MagicTrial.RecordAnimaSpent(user,cost);
        return true;
    }
}

class CaelumUtilityStaffStream : Actor
{
    Actor Emitter;
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
        vector3 eye=Emitter.Pos+(0,0,Emitter.player!=null ? Emitter.player.viewheight : Emitter.Height/2);
        if(Emitter.player==null && Emitter.target!=null)
        {
            vector3 aim=Emitter.target.Pos+(0,0,Emitter.target.Height/2)-eye;
            if(aim.Length()>0)Direction=aim.Unit();
        }
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
            if(Emitter is "CaelumPlayer" && nearby.thing is "CaelumM00TrainingDummy"
                && CaelumElementalStream.Contact(self,Emitter,Direction,nearby.thing))
                CaelumMainM00MagicTrial.RecordStaffContact(CaelumPlayer(Emitter),nearby.thing,ice);
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
                let user=CaelumPlayer(Emitter);
                if(user!=null)user.ApplyWeaponDurabilityFromSuccessfulDamage(CaelumElementalStream.Damage(Emitter),
                    CaelumConstants.WEAPON_TYPE_UTILITY_STAFF,1,SourceItem.EquipmentSize,SourceItem,true);
                else CaelumWeaponUseRules.Wear(SourceItem,CaelumElementalStream.Damage(Emitter));
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
        if(Emitter==null || Emitter.health<=0 || CaelumUtilityStaff.Stream(Emitter)!=self
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
    override void WorldLoaded(WorldEvent e)
    {
        // La carga no llama PostBeginPlay: migrar antes de cualquier actor/proyectil.
        let actors=ThinkerIterator.Create("CaelumCombatActor");CaelumCombatActor npc;
        while((npc=CaelumCombatActor(actors.Next()))!=null)
        {
            npc.EnsureCombatPersonality();
            let bull=CaelumBull(npc);if(bull!=null)bull.EnsureBullChargeRevision();
            let resident=CaelumAnchoredResident(npc);if(resident!=null)resident.EnsureResidentTools();
        }
    }
    override void WorldUnloaded(WorldEvent e)
    {
        let streams=ThinkerIterator.Create("CaelumUtilityStaffStream");CaelumUtilityStaffStream stream;
        while((stream=CaelumUtilityStaffStream(streams.Next()))!=null)
            CaelumUtilityStaff.EndEmission(stream.Emitter);
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
